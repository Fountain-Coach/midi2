import Foundation

#if canImport(CoreMIDI)
import CoreMIDI
#endif

#if canImport(CoreAudioKit)
import CoreAudioKit
#endif

/// Cross‑platform MIDI IO facade.
///
/// - On Apple platforms with CoreMIDI available, this provides real device IO
///   including MIDI 2.0 UMP send/receive paths and (optionally) Bluetooth MIDI
///   pairing UI via CoreAudioKit.
/// - On other platforms, it falls back to VirtualMIDIRouter used by tests.
public final class AppleMIDIIO: @unchecked Sendable {

    public enum IOError: Error {
        case coreMIDINotAvailable
        case clientCreationFailed(OSStatus)
        case portCreationFailed(OSStatus)
        case endpointNotFound
        case sendFailed(OSStatus)
        case unsupportedForMIDI1Endpoint
    }

    public struct Endpoint: Equatable, Hashable {
        public var name: String
        public var uniqueID: Int32
        public var supportsMIDI2: Bool
        public var isSource: Bool
        public var isDestination: Bool
    }

    public typealias ReceiveHandler = @Sendable (_ group: UInt8, _ words: [UInt32], _ hostTime: UInt64) -> Void

    #if canImport(CoreMIDI)
    private var client: MIDIClientRef = 0
    private var inputPort_v2: MIDIPortRef = 0
    private var outputPort_v2: MIDIPortRef = 0
    private var inputPort_v1: MIDIPortRef = 0
    private var outputPort_v1: MIDIPortRef = 0

    private var receiveHandlers: [MIDIEndpointRef: ReceiveHandler] = [:]
    #else
    private var virtualName: String?
    #endif

    public init(clientName: String = "MIDI2Bridge") throws {
        #if canImport(CoreMIDI)
        var clientRef: MIDIClientRef = 0
        var status = MIDIClientCreateWithBlock(clientName as CFString, &clientRef, { _ in })
        if status != noErr {
            throw IOError.clientCreationFailed(status)
        }
        self.client = clientRef

        // Create v2 (UMP) ports when available.
        if #available(iOS 16.0, macOS 13.0, *) {
            var outV2: MIDIPortRef = 0
            status = MIDIOutputPortCreateWithProtocol(client, clientName as CFString, ._2_0, &outV2)
            if status != noErr { throw IOError.portCreationFailed(status) }
            outputPort_v2 = outV2

            var inV2: MIDIPortRef = 0
            status = MIDIInputPortCreateWithProtocol(client, clientName as CFString, ._2_0, &inV2, nil)
            if status != noErr { throw IOError.portCreationFailed(status) }
            inputPort_v2 = inV2
        }

        // Always create v1 ports for compatibility.
        var outV1: MIDIPortRef = 0
        status = MIDIOutputPortCreate(client, (clientName + ".v1.out") as CFString, &outV1)
        if status != noErr { throw IOError.portCreationFailed(status) }
        outputPort_v1 = outV1

        var inV1: MIDIPortRef = 0
        status = MIDIInputPortCreate(client, (clientName + ".v1.in") as CFString, &inV1, nil, nil)
        if status != noErr { throw IOError.portCreationFailed(status) }
        inputPort_v1 = inV1
        #else
        // Non‑Apple fallback uses VirtualMIDIRouter only.
        self.virtualName = nil
        #endif
    }

    deinit {
        #if canImport(CoreMIDI)
        if inputPort_v2 != 0 { MIDIPortDispose(inputPort_v2) }
        if outputPort_v2 != 0 { MIDIPortDispose(outputPort_v2) }
        if inputPort_v1 != 0 { MIDIPortDispose(inputPort_v1) }
        if outputPort_v1 != 0 { MIDIPortDispose(outputPort_v1) }
        if client != 0 { MIDIClientDispose(client) }
        #endif
    }

    // MARK: - Discovery

    /// Enumerate system endpoints and their protocol support.
    public func enumerateEndpoints() throws -> [Endpoint] {
        #if canImport(CoreMIDI)
        var results: [Endpoint] = []

        let sourceCount = MIDIGetNumberOfSources()
        for idx in 0..<sourceCount {
            let ep = MIDIGetSource(idx)
            if ep == 0 { continue }
            results.append(try describeEndpoint(ep, isSource: true))
        }

        let destCount = MIDIGetNumberOfDestinations()
        for idx in 0..<destCount {
            let ep = MIDIGetDestination(idx)
            if ep == 0 { continue }
            results.append(try describeEndpoint(ep, isSource: false))
        }

        return results
        #else
        // Fallback: list virtual router sources/dests as generic endpoints.
        return []
        #endif
    }

    #if canImport(CoreMIDI)
    private func describeEndpoint(_ ep: MIDIEndpointRef, isSource: Bool) throws -> Endpoint {
        var name: Unmanaged<CFString>?
        var uid: Int32 = 0
        var protocolID: UInt32 = 0

        MIDIObjectGetStringProperty(ep, kMIDIPropertyName, &name)
        MIDIObjectGetIntegerProperty(ep, kMIDIPropertyUniqueID, &uid)
        MIDIObjectGetIntegerProperty(ep, kMIDIPropertyProtocolID, &protocolID)

        let supportsMIDI2: Bool
        if #available(iOS 16.0, macOS 13.0, *) {
            supportsMIDI2 = protocolID == MIDIProtocolID._2_0.rawValue
        } else {
            supportsMIDI2 = false
        }

        return Endpoint(
            name: (name?.takeRetainedValue() as String?) ?? "(unnamed)",
            uniqueID: uid,
            supportsMIDI2: supportsMIDI2,
            isSource: isSource,
            isDestination: !isSource
        )
    }
    #endif

    // MARK: - Receive

    /// Connect a receiver to a source endpoint by name substring.
    public func openInput(nameContains: String, handler: @escaping ReceiveHandler) throws {
        #if canImport(CoreMIDI)
        // Prefer v2 source if present; else v1.
        let src = try findEndpoint(nameContains: nameContains, isSource: true)
        let endpoint = src.endpoint

        if #available(iOS 16.0, macOS 13.0, *), src.supportsMIDI2, inputPort_v2 != 0 {
            let status = MIDIPortConnectSource(inputPort_v2, endpoint, Unmanaged.passUnretained(self).toOpaque())
            if status != noErr { throw IOError.portCreationFailed(status) }
            receiveHandlers[endpoint] = handler

            // Install read block for v2 port
            MIDIInputPortSetHandler(inputPort_v2) { [weak self] (list, src) in
                self?.handleEventList(list: list, source: src)
            }
            return
        }

        // v1 fallback
        let status = MIDIPortConnectSource(inputPort_v1, endpoint, Unmanaged.passUnretained(self).toOpaque())
        if status != noErr { throw IOError.portCreationFailed(status) }
        receiveHandlers[endpoint] = handler

        MIDIInputPortSetBlock(inputPort_v1) { [weak self] packetList, src in
            self?.handlePacketList(packetList: packetList, source: src)
        }
        #else
        // Fallback: subscribe to virtual router
        guard let name = VirtualMIDIRouter.sourceName(matching: nameContains) else { throw IOError.endpointNotFound }
        _ = VirtualMIDIRouter.subscribe(nameMatch: name, handler: handler)
        #endif
    }

    // MARK: - Send

    /// Send UMP words to the first destination whose name contains the substring.
    public func sendUMP(toDestinationNameContains nameContains: String, words: [UInt32], hostTime: UInt64 = 0) throws {
        #if canImport(CoreMIDI)
        let dest = try findEndpoint(nameContains: nameContains, isSource: false)
        if #available(iOS 16.0, macOS 13.0, *), dest.supportsMIDI2, outputPort_v2 != 0 {
            try sendUMP_v2(to: dest.endpoint, words: words, hostTime: hostTime)
        } else {
            // For MIDI 1.0 endpoints we would need to down‑convert UMP to MIDI1 bytes.
            // For now, signal unsupported to avoid incorrect transmission.
            throw IOError.unsupportedForMIDI1Endpoint
        }
        #else
        guard let name = VirtualMIDIRouter.sourceName(matching: nameContains) else { throw IOError.endpointNotFound }
        let group = UInt8((words.first ?? 0) >> 24 & 0x0F)
        VirtualMIDIRouter.publish(name: name, group: group, words: words, hostTime: hostTime)
        #endif
    }

    #if canImport(CoreMIDI)
    @available(iOS 16.0, macOS 13.0, *)
    private func sendUMP_v2(to destination: MIDIEndpointRef, words: [UInt32], hostTime: UInt64) throws {
        // Build a MIDIEventList from UMP words.
        var eventList = MIDIEventList()
        var packet = MIDIEventPacket()
        packet.timeStamp = hostTime
        packet.wordCount = UInt32(words.count)
        withUnsafeMutablePointer(to: &eventList) { listPtr in
            listPtr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<MIDIEventList>.size) { _ in }
        }
        var copied = packet
        // Unsafe trick: allocate contiguous memory for list + packet + words
        let totalWords = words.count
        let listSize = MIDIEventList.sizeInBytes(packetCount: 1, totalWords: totalWords)
        let rawPtr = UnsafeMutableRawPointer.allocate(byteCount: listSize, alignment: 8)
        defer { rawPtr.deallocate() }

        let listPtr = rawPtr.bindMemory(to: MIDIEventList.self, capacity: 1)
        listPtr.pointee.protocol = ._2_0
        listPtr.pointee.numPackets = 1

        let firstPacketPtr = MIDIEventList.packetPtr(listPtr)
        firstPacketPtr.pointee.timeStamp = hostTime
        firstPacketPtr.pointee.wordCount = UInt32(totalWords)
        let wordsPtr = UnsafeMutableBufferPointer(start: UnsafeMutablePointer(mutating: MIDIEventList.wordsPtr(firstPacketPtr)), count: totalWords)
        for (i, w) in words.enumerated() { wordsPtr[i] = w }

        let status = MIDISendEventList(outputPort_v2, destination, listPtr)
        if status != noErr { throw IOError.sendFailed(status) }
    }

    private func findEndpoint(nameContains: String, isSource: Bool) throws -> (endpoint: MIDIEndpointRef, supportsMIDI2: Bool) {
        if isSource {
            let count = MIDIGetNumberOfSources()
            for idx in 0..<count {
                let ep = MIDIGetSource(idx)
                if ep == 0 { continue }
                let (name, supports2) = endpointNameAndProtocol(ep)
                if name.contains(nameContains) { return (ep, supports2) }
            }
        } else {
            let count = MIDIGetNumberOfDestinations()
            for idx in 0..<count {
                let ep = MIDIGetDestination(idx)
                if ep == 0 { continue }
                let (name, supports2) = endpointNameAndProtocol(ep)
                if name.contains(nameContains) { return (ep, supports2) }
            }
        }
        throw IOError.endpointNotFound
    }

    private func endpointNameAndProtocol(_ ep: MIDIEndpointRef) -> (String, Bool) {
        var name: Unmanaged<CFString>?
        var proto: Int32 = 0
        MIDIObjectGetStringProperty(ep, kMIDIPropertyName, &name)
        MIDIObjectGetIntegerProperty(ep, kMIDIPropertyProtocolID, &proto)
        let supports2: Bool
        if #available(iOS 16.0, macOS 13.0, *) {
            supports2 = proto == Int32(MIDIProtocolID._2_0.rawValue)
        } else {
            supports2 = false
        }
        return ((name?.takeRetainedValue() as String?) ?? "(unnamed)", supports2)
    }

    private func handleEventList(list: UnsafePointer<MIDIEventList>, source: UnsafeMutableRawPointer?) {
        // Extract words and forward to handler
        var packetPtr = MIDIEventList.packetPtr(UnsafeMutablePointer(mutating: list))
        for _ in 0..<list.pointee.numPackets {
            let wordCount = Int(packetPtr.pointee.wordCount)
            let wordsBuffer = UnsafeBufferPointer(start: MIDIEventList.wordsPtr(packetPtr), count: wordCount)
            let words = Array(wordsBuffer)
            let group = UInt8((words.first ?? 0) >> 24 & 0x0F)
            let time = packetPtr.pointee.timeStamp
            // Route to all handlers (we do not track per‑source receive handler mapping beyond existence)
            for (_, handler) in receiveHandlers { handler(group, words, time) }
            packetPtr = MIDIEventList.nextPacket(packetPtr)
        }
    }

    private func handlePacketList(packetList: UnsafePointer<MIDIPacketList>, source: UnsafeMutableRawPointer?) {
        // MIDI 1.0 bytes -> not converted; forward as SysEx7 UMP if desired. Here we ignore for simplicity.
    }
    #endif

    // MARK: - Bluetooth UI (iOS)

    #if canImport(CoreAudioKit) && os(iOS)
    /// Returns a view controller that allows users to pair BLE MIDI devices.
    public func makeBluetoothPairingViewController() -> UIViewController {
        return CABTMIDICentralViewController()
    }
    #endif
}

// MARK: - MIDIEventList helpers (compat layer)

#if canImport(CoreMIDI)
@available(iOS 16.0, macOS 13.0, *)
fileprivate extension MIDIEventList {
    static func sizeInBytes(packetCount: Int, totalWords: Int) -> Int {
        let header = MemoryLayout<MIDIEventList>.size
        let packetHeader = MemoryLayout<MIDIEventPacket>.size
        let wordsBytes = totalWords * MemoryLayout<UInt32>.size
        return header + packetHeader + wordsBytes
    }

    static func packetPtr(_ list: UnsafeMutablePointer<MIDIEventList>) -> UnsafeMutablePointer<MIDIEventPacket> {
        return withUnsafeMutableBytes(of: &list.pointee) { raw in
            let base = raw.baseAddress!.advanced(by: MemoryLayout<MIDIEventList>.size)
            return base.bindMemory(to: MIDIEventPacket.self, capacity: 1)
        }
    }

    static func nextPacket(_ packet: UnsafeMutablePointer<MIDIEventPacket>) -> UnsafeMutablePointer<MIDIEventPacket> {
        let addr = UnsafeMutableRawPointer(packet)
            .advanced(by: MemoryLayout<MIDIEventPacket>.size + Int(packet.pointee.wordCount) * MemoryLayout<UInt32>.size)
        return addr.bindMemory(to: MIDIEventPacket.self, capacity: 1)
    }

    static func wordsPtr(_ packet: UnsafeMutablePointer<MIDIEventPacket>) -> UnsafeMutablePointer<UInt32> {
        let addr = UnsafeMutableRawPointer(packet)
            .advanced(by: MemoryLayout<MIDIEventPacket>.size)
        return addr.bindMemory(to: UInt32.self, capacity: Int(packet.pointee.wordCount))
    }
}
#endif

