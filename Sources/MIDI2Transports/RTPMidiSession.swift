import Foundation
#if canImport(Network)
@preconcurrency import Network
import Darwin

/// Cross-platform RTP-MIDI2 transport for explicitly selected software peers.
/// `open()` only creates or adopts a listener; `connect(host:port)` or `connect(peer:)`
/// selects the remote peer. There is no self-connect or in-process fallback.
public final class RTPMidiSession: MIDITransport, @unchecked Sendable {
    public var onReceiveUMP: (([UInt32]) -> Void)?
    public var onReceiveUmps: (([[UInt32]]) -> Void)?
    public var onPeerConnectionState: ((String) -> Void)?

    private let localName: String
    private let listenPort: UInt16?
    private let listenDescriptor: Int32?
    private let queue = DispatchQueue(label: "FountainCoach.MIDI2Transports.RTPMidiSession")
    private var listener: NWListener?
    private var connection: NWConnection?
    private var incoming: [NWConnection] = []
    private let readiness = DispatchSemaphore(value: 0)
    private let stateLock = NSLock()
    private var readinessError: Error?
    private var nativeReadSource: DispatchSourceRead?

    public init(localName: String, mtu: Int = 1500, enableDiscovery: Bool = false,
                enableCINegotiation: Bool = true, listenPort: UInt16? = nil,
                listenDescriptor: Int32? = nil) {
        self.localName = localName
        self.listenPort = listenPort
        self.listenDescriptor = listenDescriptor
    }

    public var port: UInt16? { listener?.port?.rawValue ?? listenPort }

    /// A Bonjour-resolved RTP-MIDI endpoint. The endpoint is retained as a Network.framework value so callers
    /// cannot turn discovery into a guessed host/port pair.
    public struct DiscoveredPeer: @unchecked Sendable {
        public let name: String
        fileprivate let endpoint: NWEndpoint

        public init(name: String, endpoint: NWEndpoint) {
            self.name = name
            self.endpoint = endpoint
        }
    }

    /// Browse the native RTP-MIDI Bonjour service and return the first matching endpoint. Resolution remains in
    /// Network.framework; callers must pass the returned typed endpoint to `connect(peer:)`.
    public static func discoverPeer(named name: String? = nil, timeout: TimeInterval = 10) async throws -> DiscoveredPeer {
        let browser = NWBrowser(for: .bonjour(type: "_rtp-midi._udp", domain: "local."), using: .udp)
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let state = DiscoveryState()
                @Sendable func finish(_ result: Result<DiscoveredPeer, Error>) {
                    guard state.claim() else { return }
                    browser.cancel()
                    continuation.resume(with: result)
                }
                browser.browseResultsChangedHandler = { results, _ in
                    for result in results {
                        if case .service(let serviceName, _, _, _) = result.endpoint {
                            let requestedName = name ?? "<any>"
                            FileHandle.standardError.write(Data("[RTP-MIDI-DISCOVERY] service=\(serviceName) requested=\(requestedName)\n".utf8))
                        }
                    }
                    guard let result = results.first(where: { result in
                        guard case .service(let serviceName, _, _, _) = result.endpoint else { return false }
                        return name == nil || serviceName == name
                    }) else { return }
                    let serviceName: String
                    if case .service(let value, _, _, _) = result.endpoint { serviceName = value } else { return }
                    finish(.success(DiscoveredPeer(name: serviceName, endpoint: result.endpoint)))
                }
                browser.stateUpdateHandler = { state in
                    if case .failed(let error) = state { finish(.failure(error)) }
                }
                browser.start(queue: DispatchQueue(label: "FountainCoach.MIDI2Transports.RTPMidiDiscovery"))
                DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                    finish(.failure(RTPMidiError.discoveryTimedOut))
                }
            }
        } onCancel: {
            browser.cancel()
        }
    }

    public func open() throws {
        if let listenDescriptor {
            configureNativeReceive(descriptor: listenDescriptor)
            readiness.signal()
            return
        }
        let listener: NWListener
        if let listenPort, let port = NWEndpoint.Port(rawValue: listenPort) {
            listener = try NWListener(using: .udp, on: port)
        } else {
            listener = try NWListener(using: .udp, on: .any)
        }
        listener.service = NWListener.Service(name: localName, type: "_rtp-midi._udp")
        listener.newConnectionHandler = { [weak self] connection in
            guard let self else { return }
            // Listener-side replies must travel over the accepted connection that
            // delivered the request; this keeps response routing bound to the peer.
            self.connection = connection
            self.incoming.append(connection)
            self.configureReceive(on: connection)
            connection.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    self?.onPeerConnectionState?("ready")
                case .failed(let error):
                    self?.onPeerConnectionState?("failed: \(error.localizedDescription)")
                case .cancelled:
                    self?.onPeerConnectionState?("cancelled")
                default:
                    break
                }
            }
            connection.start(queue: self.queue)
        }
        listener.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                self.readiness.signal()
            case .failed(let error):
                self.stateLock.lock()
                self.readinessError = error
                self.stateLock.unlock()
                self.readiness.signal()
            case .cancelled:
                self.stateLock.lock()
                self.readinessError = RTPMidiError.listenerCancelled
                self.stateLock.unlock()
                self.readiness.signal()
            default:
                break
            }
        }
        listener.start(queue: queue)
        self.listener = listener
    }

    /// Wait for Network.framework to bind the listener and expose its actual port.
    /// This is a transport readiness observation, not a caller-selected port.
    public func waitUntilReady(timeout: TimeInterval = 10) throws {
        guard readiness.wait(timeout: .now() + timeout) == .success else {
            throw RTPMidiError.listenerReadinessTimedOut
        }
        stateLock.lock()
        let error = readinessError
        stateLock.unlock()
        if let error { throw error }
        guard let port, port != 0 else { throw RTPMidiError.listenerHasNoPort }
    }

    public func connect(host: String, port: UInt16) throws {
        guard let endpointPort = NWEndpoint.Port(rawValue: port) else { throw RTPMidiError.invalidPort(port) }
        let connection = NWConnection(host: NWEndpoint.Host(host), port: endpointPort, using: .udp)
        let connectionReadiness = DispatchSemaphore(value: 0)
        let connectionState = ConnectionState()
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.onPeerConnectionState?("ready")
                connectionReadiness.signal()
            case .failed(let error):
                connectionState.set(error)
                self?.onPeerConnectionState?("failed: \(error.localizedDescription)")
                connectionReadiness.signal()
            case .cancelled:
                connectionState.set(RTPMidiError.connectionCancelled)
                self?.onPeerConnectionState?("cancelled")
                connectionReadiness.signal()
            default:
                break
            }
        }
        configureReceive(on: connection)
        connection.start(queue: queue)
        self.connection = connection
        guard connectionReadiness.wait(timeout: .now() + 10) == .success else {
            connection.cancel()
            throw RTPMidiError.connectionReadinessTimedOut
        }
        if let error = connectionState.error { throw error }
    }

    /// Connect to an endpoint obtained from `discoverPeer`; no numeric port is accepted here.
    public func connect(peer: DiscoveredPeer) throws {
        let connection = NWConnection(to: peer.endpoint, using: .udp)
        let connectionReadiness = DispatchSemaphore(value: 0)
        let connectionState = ConnectionState()
        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                connectionReadiness.signal()
            case .failed(let error):
                connectionState.set(error)
                connectionReadiness.signal()
            case .cancelled:
                connectionState.set(RTPMidiError.connectionCancelled)
                connectionReadiness.signal()
            default:
                break
            }
        }
        configureReceive(on: connection)
        connection.start(queue: queue)
        self.connection = connection
        guard connectionReadiness.wait(timeout: .now() + 10) == .success else {
            connection.cancel()
            throw RTPMidiError.connectionReadinessTimedOut
        }
        if let error = connectionState.error { throw error }
    }

    public func close() throws {
        connection?.cancel()
        listener?.cancel()
        incoming.forEach { $0.cancel() }
        connection = nil
        listener = nil
        incoming.removeAll()
        nativeReadSource?.cancel()
        nativeReadSource = nil
    }

    public func send(umpWords: [UInt32]) throws {
        guard umpWords.count == 1 || umpWords.count == 2 || (!umpWords.isEmpty && umpWords.count.isMultiple(of: 4)) else {
            throw RTPMidiError.invalidPayload
        }
        guard let connection else { throw RTPMidiError.notConnected }
        var payload = Data([0x80, 0x61, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        for word in umpWords {
            var bigEndian = word.bigEndian
            payload.append(Data(bytes: &bigEndian, count: 4))
        }
        connection.send(content: payload, completion: .contentProcessed { error in
            if let error {
                FileHandle.standardError.write(Data("[RTP-MIDI] send failed: \(error)\n".utf8))
            }
        })
    }

    private func configureReceive(on connection: NWConnection) {
        connection.receiveMessage { [weak self, weak connection] data, _, _, error in
            guard let self else { return }
            if let data, let words = Self.decode(data) {
                self.onReceiveUmps?(words.map { $0 })
                words.forEach { self.onReceiveUMP?($0) }
            }
            if let error {
                FileHandle.standardError.write(Data("[RTP-MIDI] receive failed: \(error)\n".utf8))
            } else if let connection {
                self.configureReceive(on: connection)
            }
        }
    }

    private func configureNativeReceive(descriptor: Int32) {
        let source = DispatchSource.makeReadSource(fileDescriptor: descriptor, queue: queue)
        source.setEventHandler { [weak self] in
            guard let self else { return }
            var bytes = [UInt8](repeating: 0, count: 65_535)
            let count = Darwin.recv(descriptor, &bytes, bytes.count, 0)
            guard count > 0 else { return }
            let data = Data(bytes.prefix(Int(count)))
            if let words = Self.decode(data) {
                self.onReceiveUmps?(words)
                words.forEach { self.onReceiveUMP?($0) }
            }
        }
        source.setCancelHandler { _ = Darwin.close(descriptor) }
        source.resume()
        nativeReadSource = source
    }

    private static func decode(_ data: Data) -> [[UInt32]]? {
        guard data.count >= 12 else { return nil }
        let payload = data.dropFirst(12)
        guard payload.count == 4 || payload.count == 8 || (payload.count >= 16 && payload.count % 16 == 0) else { return nil }
        var words: [UInt32] = []
        words.reserveCapacity(payload.count / 4)
        var offset = payload.startIndex
        while offset < payload.endIndex {
            let next = payload.index(offset, offsetBy: 4)
            let word = payload[offset..<next].withUnsafeBytes { UInt32(bigEndian: $0.load(as: UInt32.self)) }
            words.append(word)
            offset = next
        }
        // Preserve one datagram as one callback value. This keeps contiguous
        // SysEx8 packet sequences together while retaining 32/64-bit single-message support.
        return [words]
    }
}

private final class DiscoveryState: @unchecked Sendable {
    private let lock = NSLock()
    private var finished = false

    func claim() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard !finished else { return false }
        finished = true
        return true
    }
}

private final class ConnectionState: @unchecked Sendable {
    private let lock = NSLock()
    private var storedError: Error?

    var error: Error? {
        lock.lock()
        defer { lock.unlock() }
        return storedError
    }

    func set(_ error: Error) {
        lock.lock()
        storedError = error
        lock.unlock()
    }
}

public enum RTPMidiError: Error, LocalizedError {
    case invalidPort(UInt16)
    case notConnected
    case invalidPayload
    case listenerReadinessTimedOut
    case listenerHasNoPort
    case listenerCancelled
    case discoveryTimedOut
    case connectionReadinessTimedOut
    case connectionCancelled

    public var errorDescription: String? {
        switch self {
        case .invalidPort(let port): return "invalid RTP-MIDI port \(port)"
        case .notConnected: return "RTP-MIDI session has no explicit peer connection"
        case .invalidPayload: return "RTP-MIDI payload is not a complete 32-, 64-, or contiguous 128-bit UMP sequence"
        case .listenerReadinessTimedOut: return "RTP-MIDI listener did not become ready"
        case .listenerHasNoPort: return "RTP-MIDI listener did not report an assigned port"
        case .listenerCancelled: return "RTP-MIDI listener was cancelled before becoming ready"
        case .discoveryTimedOut: return "RTP-MIDI Bonjour discovery did not find a matching peer"
        case .connectionReadinessTimedOut: return "RTP-MIDI peer connection did not become ready"
        case .connectionCancelled: return "RTP-MIDI peer connection was cancelled before becoming ready"
        }
    }
}
#else
import Glibc

/// Linux RTP-MIDI transport for the governed software-peer path. It uses the
/// same 12-byte RTP-MIDI header and UMP payload framing as the Network.framework
/// implementation above; host discovery remains explicit and numeric ports are
/// accepted only when the caller has already admitted them.
public final class RTPMidiSession: MIDITransport, @unchecked Sendable {
    public var onReceiveUMP: (([UInt32]) -> Void)?
    public var onReceiveUmps: (([[UInt32]]) -> Void)?
    public var onPeerConnectionState: ((String) -> Void)?

    private let localName: String
    private let listenPort: UInt16?
    private let queue = DispatchQueue(label: "FountainCoach.MIDI2Transports.RTPMidiSession.linux")
    private var socketFD: Int32 = -1
    private var peerAddress: sockaddr_storage?
    private var readSource: DispatchSourceRead?
    private let lock = NSLock()

    public init(localName: String, mtu: Int = 1500, enableDiscovery: Bool = false,
                enableCINegotiation: Bool = true, listenPort: UInt16? = nil,
                listenDescriptor: Int32? = nil) {
        self.localName = localName
        self.listenPort = listenPort
        if let listenDescriptor { self.socketFD = listenDescriptor }
    }

    public var port: UInt16? {
        lock.lock(); defer { lock.unlock() }
        guard socketFD >= 0 else { return nil }
        var address = sockaddr_storage()
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let result = withUnsafeMutablePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                getsockname(socketFD, $0, &length)
            }
        }
        guard result == 0 else { return nil }
        return withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) {
                UInt16(bigEndian: $0.pointee.sin6_port)
            }
        }
    }

    public func open() throws {
        lock.lock()
        guard socketFD < 0 else { lock.unlock(); return }
        let fd = socket(AF_INET6, Int32(SOCK_DGRAM.rawValue), 0)
        guard fd >= 0 else { lock.unlock(); throw RTPMidiError.socketUnavailable }
        var v6Only: Int32 = 0
        _ = setsockopt(fd, Int32(IPPROTO_IPV6), IPV6_V6ONLY, &v6Only, socklen_t(MemoryLayout<Int32>.size))
        var address = sockaddr_in6()
        address.sin6_family = sa_family_t(AF_INET6)
        address.sin6_addr = in6addr_any
        address.sin6_port = listenPort.map { $0.bigEndian } ?? 0
        let bindResult = withUnsafePointer(to: &address) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in6>.size))
            }
        }
        guard bindResult == 0 else {
            _ = Glibc.close(fd)
            lock.unlock()
            throw RTPMidiError.socketUnavailable
        }
        socketFD = fd
        lock.unlock()

        let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
        source.setEventHandler { [weak self] in self?.receiveDatagram() }
        source.setCancelHandler { _ = Glibc.close(fd) }
        source.resume()
        readSource = source
        onPeerConnectionState?("ready")
    }

    public func waitUntilReady(timeout: TimeInterval = 10) throws {
        lock.lock(); let ready = socketFD >= 0; lock.unlock()
        guard ready else { throw RTPMidiError.listenerHasNoPort }
        guard port != 0 else { throw RTPMidiError.listenerHasNoPort }
    }

    public func connect(host: String, port: UInt16) throws {
        guard let address = resolve(host: host, port: port) else { throw RTPMidiError.invalidPort(port) }
        lock.lock(); peerAddress = address; lock.unlock()
        onPeerConnectionState?("ready")
    }

    public func close() throws {
        readSource?.cancel()
        readSource = nil
        lock.lock(); socketFD = -1; peerAddress = nil; lock.unlock()
        onPeerConnectionState?("cancelled")
    }

    public func send(umpWords: [UInt32]) throws {
        guard umpWords.count == 1 || umpWords.count == 2 || (!umpWords.isEmpty && umpWords.count.isMultiple(of: 4)) else { throw RTPMidiError.invalidPayload }
        lock.lock(); let fd = socketFD; let address = peerAddress; lock.unlock()
        guard fd >= 0, var address else { throw RTPMidiError.notConnected }
        let addressLength = Self.addressLength(address)
        var bytes = Data(repeating: 0, count: 12)
        for word in umpWords {
            var value = word.bigEndian
            withUnsafeBytes(of: &value) { bytes.append(contentsOf: $0) }
        }
        let sent = bytes.withUnsafeBytes { rawBuffer in
            withUnsafePointer(to: &address) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    sendto(fd, rawBuffer.baseAddress, bytes.count, 0, $0, addressLength)
                }
            }
        }
        guard sent == bytes.count else { throw RTPMidiError.sendFailed }
    }

    private func receiveDatagram() {
        var bytes = [UInt8](repeating: 0, count: 65_535)
        var sender = sockaddr_storage()
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        lock.lock(); let fd = socketFD; lock.unlock()
        guard fd >= 0 else { return }
        let count = bytes.withUnsafeMutableBytes { buffer in
            withUnsafeMutablePointer(to: &sender) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { senderPointer in
                    recvfrom(fd, buffer.baseAddress, buffer.count, 0, senderPointer, &length)
                }
            }
        }
        guard count > 0 else { return }
        lock.lock(); peerAddress = sender; lock.unlock()
        guard let words = Self.decode(Data(bytes.prefix(Int(count)))) else { return }
        onReceiveUmps?(words)
        words.forEach { onReceiveUMP?($0) }
    }

    private func resolve(host: String, port: UInt16) -> sockaddr_storage? {
        var hints = addrinfo(ai_flags: 0, ai_family: AF_UNSPEC, ai_socktype: Int32(SOCK_DGRAM.rawValue), ai_protocol: 0,
                             ai_addrlen: 0, ai_addr: nil, ai_canonname: nil, ai_next: nil)
        var result: UnsafeMutablePointer<addrinfo>?
        let service = String(port)
        guard getaddrinfo(host, service, &hints, &result) == 0, let result else { return nil }
        defer { freeaddrinfo(result) }
        guard let raw = result.pointee.ai_addr else { return nil }
        var address = sockaddr_storage()
        memcpy(&address, raw, Int(result.pointee.ai_addrlen))
        return address
    }

    private static func addressLength(_ address: sockaddr_storage) -> socklen_t {
        address.ss_family == sa_family_t(AF_INET6)
            ? socklen_t(MemoryLayout<sockaddr_in6>.size)
            : socklen_t(MemoryLayout<sockaddr_in>.size)
    }

    private static func decode(_ data: Data) -> [[UInt32]]? {
        guard data.count >= 12 else { return nil }
        let payload = data.dropFirst(12)
        guard payload.count == 4 || payload.count == 8 || (payload.count >= 16 && payload.count % 16 == 0) else { return nil }
        var words: [UInt32] = []
        words.reserveCapacity(payload.count / 4)
        var offset = payload.startIndex
        while offset < payload.endIndex {
            let next = payload.index(offset, offsetBy: 4)
            let word = payload[offset..<next].withUnsafeBytes { UInt32(bigEndian: $0.load(as: UInt32.self)) }
            words.append(word)
            offset = next
        }
        return [words]
    }
}
public enum RTPMidiError: Error {
    case notConnected
    case invalidPort(UInt16)
    case invalidPayload
    case socketUnavailable
    case sendFailed
    case listenerHasNoPort
}
#endif
