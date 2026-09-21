import Foundation

#if canImport(Network)
@preconcurrency import Network
import Darwin

/// Minimal RTP-MIDI2 UMP transport for a governed software peer.
/// The caller must open both sessions and connect the initiator to the responder's
/// observed listener port; no self-connect or implicit endpoint is created.
public final class RTPMidiSession: MIDITransport, @unchecked Sendable {
    public var onReceiveUMP: (([UInt32]) -> Void)?
    public var onPeerConnectionState: ((String) -> Void)?

    private let localName: String
    private let listenPort: UInt16?
    private let queue = DispatchQueue(label: "FountainCoach.MIDI2Transports.RTPMidiSession")
    private var listener: NWListener?
    private var connection: NWConnection?
    private let readiness = DispatchSemaphore(value: 0)
    private let lock = NSLock()
    private var readinessError: Error?

    public init(localName: String, listenPort: UInt16? = nil) {
        self.localName = localName
        self.listenPort = listenPort
    }

    public var port: UInt16? { listener?.port?.rawValue ?? listenPort }

    public func open() throws {
        let listener = try NWListener(using: .udp, on: listenPort.map { NWEndpoint.Port(rawValue: $0)! } ?? .any)
        listener.service = NWListener.Service(name: localName, type: "_rtp-midi._udp")
        listener.newConnectionHandler = { [weak self] connection in
            guard let self else { return }
            self.connection = connection
            self.receive(on: connection)
            connection.stateUpdateHandler = { [weak self] state in
                if case .ready = state { self?.onPeerConnectionState?("ready") }
            }
            connection.start(queue: self.queue)
        }
        listener.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready: self.readiness.signal()
            case .failed(let error): self.lock.lock(); self.readinessError = error; self.lock.unlock(); self.readiness.signal()
            case .cancelled: self.lock.lock(); self.readinessError = RTPMidiError.listenerCancelled; self.lock.unlock(); self.readiness.signal()
            default: break
            }
        }
        listener.start(queue: queue)
        self.listener = listener
    }

    public func waitUntilReady(timeout: TimeInterval = 10) throws {
        guard readiness.wait(timeout: .now() + timeout) == .success else { throw RTPMidiError.listenerReadinessTimedOut }
        lock.lock(); let error = readinessError; lock.unlock()
        if let error { throw error }
        guard port.map({ $0 != 0 }) == true else { throw RTPMidiError.listenerHasNoPort }
    }

    public func connect(host: String, port: UInt16) throws {
        guard let endpointPort = NWEndpoint.Port(rawValue: port) else { throw RTPMidiError.invalidPort(port) }
        let connection = NWConnection(host: NWEndpoint.Host(host), port: endpointPort, using: .udp)
        connection.stateUpdateHandler = { [weak self] state in
            if case .ready = state { self?.onPeerConnectionState?("ready") }
        }
        receive(on: connection)
        connection.start(queue: queue)
        self.connection = connection
    }

    public func close() throws {
        connection?.cancel()
        listener?.cancel()
        connection = nil
        listener = nil
    }

    public func send(umpWords: [UInt32]) throws {
        guard [1, 2, 4].contains(umpWords.count) else { throw RTPMidiError.invalidPayload }
        guard let connection else { throw RTPMidiError.notConnected }
        var payload = Data([0x80, 0x61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
        for word in umpWords { var value = word.bigEndian; payload.append(Data(bytes: &value, count: 4)) }
        connection.send(content: payload, completion: .contentProcessed { _ in })
    }

    private func receive(on connection: NWConnection) {
        connection.receiveMessage { [weak self, weak connection] data, _, _, error in
            if let data, let words = Self.decode(data) { words.forEach { self?.onReceiveUMP?($0) } }
            if error == nil, let connection { self?.receive(on: connection) }
        }
    }

    private static func decode(_ data: Data) -> [[UInt32]]? {
        guard data.count >= 16, [4, 8, 16].contains(data.count - 12) else { return nil }
        let payload = data.dropFirst(12)
        var words: [UInt32] = []
        var offset = payload.startIndex
        while offset < payload.endIndex {
            let next = payload.index(offset, offsetBy: 4)
            words.append(payload[offset..<next].withUnsafeBytes { UInt32(bigEndian: $0.load(as: UInt32.self)) })
            offset = next
        }
        return [words]
    }
}

#else
import Glibc

/// Linux RTP-MIDI2 UMP transport using an admitted UDP listener and peer.
public final class RTPMidiSession: MIDITransport, @unchecked Sendable {
    public var onReceiveUMP: (([UInt32]) -> Void)?
    public var onPeerConnectionState: ((String) -> Void)?
    private let listenPort: UInt16?
    private let queue = DispatchQueue(label: "FountainCoach.MIDI2Transports.RTPMidiSession")
    private let lock = NSLock()
    private var socketFD: Int32 = -1
    private var peerAddress: sockaddr_in?
    private var readSource: DispatchSourceRead?

    public init(localName: String, listenPort: UInt16? = nil) { self.listenPort = listenPort }

    public var port: UInt16? {
        lock.lock(); defer { lock.unlock() }
        guard socketFD >= 0 else { return nil }
        var address = sockaddr_in(); var length = socklen_t(MemoryLayout<sockaddr_in>.size)
        let result = withUnsafeMutablePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { getsockname(socketFD, $0, &length) } }
        return result == 0 ? UInt16(bigEndian: address.sin_port) : nil
    }

    public func open() throws {
        let fd = socket(AF_INET, Int32(SOCK_DGRAM.rawValue), 0)
        guard fd >= 0 else { throw RTPMidiError.socketUnavailable }
        var address = sockaddr_in(sin_family: sa_family_t(AF_INET), sin_port: (listenPort ?? 0).bigEndian, sin_addr: in_addr(s_addr: 0), sin_zero: (0,0,0,0,0,0,0,0))
        let bound = withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(fd, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        guard bound == 0 else { _ = Glibc.close(fd); throw RTPMidiError.socketUnavailable }
        lock.lock(); socketFD = fd; lock.unlock()
        let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)
        source.setEventHandler { [weak self] in self?.receiveDatagram() }
        source.setCancelHandler { _ = Glibc.close(fd) }; source.resume(); readSource = source
        onPeerConnectionState?("ready")
    }

    public func waitUntilReady(timeout: TimeInterval = 10) throws {
        guard port.map({ $0 != 0 }) == true else { throw RTPMidiError.listenerHasNoPort }
    }

    public func connect(host: String, port: UInt16) throws {
        var hints = addrinfo(ai_flags: 0, ai_family: AF_INET, ai_socktype: Int32(SOCK_DGRAM.rawValue), ai_protocol: 0, ai_addrlen: 0, ai_addr: nil, ai_canonname: nil, ai_next: nil)
        var result: UnsafeMutablePointer<addrinfo>?
        guard getaddrinfo(host, String(port), &hints, &result) == 0, let result, let raw = result.pointee.ai_addr else { throw RTPMidiError.invalidPort(port) }
        defer { freeaddrinfo(result) }
        peerAddress = raw.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
        onPeerConnectionState?("ready")
    }

    public func close() throws { readSource?.cancel(); readSource = nil; lock.lock(); socketFD = -1; peerAddress = nil; lock.unlock() }

    public func send(umpWords: [UInt32]) throws {
        guard [1, 2, 4].contains(umpWords.count) else { throw RTPMidiError.invalidPayload }
        lock.lock(); let fd = socketFD; let address = peerAddress; lock.unlock(); guard fd >= 0, var address else { throw RTPMidiError.notConnected }
        var data = Data(repeating: 0, count: 12)
        for word in umpWords { var value = word.bigEndian; withUnsafeBytes(of: &value) { data.append(contentsOf: $0) } }
        let sent = data.withUnsafeBytes { buffer in withUnsafePointer(to: &address) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sendto(fd, buffer.baseAddress, data.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } } }
        guard sent == data.count else { throw RTPMidiError.sendFailed }
    }

    private func receiveDatagram() {
        var bytes = [UInt8](repeating: 0, count: 65_535); var sender = sockaddr_in(); var length = socklen_t(MemoryLayout<sockaddr_in>.size)
        lock.lock(); let fd = socketFD; lock.unlock(); guard fd >= 0 else { return }
        let count = bytes.withUnsafeMutableBytes { buffer in
            withUnsafeMutablePointer(to: &sender) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                recvfrom(fd, buffer.baseAddress, buffer.count, 0, $0, &length)
            } }
        }
        let payloadByteCount = count - 12
        guard payloadByteCount > 0, payloadByteCount.isMultiple(of: 16) else { return }
        var words: [UInt32] = []; var offset = 12
        while offset < count { words.append(bytes[offset..<offset+4].withUnsafeBytes { UInt32(bigEndian: $0.load(as: UInt32.self)) }); offset += 4 }
        onReceiveUMP?(words)
    }
}

#endif

public enum RTPMidiError: Error, LocalizedError {
    case invalidPort(UInt16), notConnected, invalidPayload, socketUnavailable, sendFailed
    case listenerReadinessTimedOut, listenerHasNoPort, listenerCancelled
    public var errorDescription: String? { String(describing: self) }
}
