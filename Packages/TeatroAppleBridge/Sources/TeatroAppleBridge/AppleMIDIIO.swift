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

    /// Mapping strategy for MIDI 2.0 per‑note controller messages when down‑converting to MIDI 1.0.
    public enum PerNoteMapping { case off, polyPressure, channelPressure }
    /// Controls how per‑note controller messages are mapped during down‑conversion. Defaults to `.polyPressure`.
    public var perNoteMapping: PerNoteMapping = .polyPressure

    #if canImport(CoreMIDI)
    private var client: MIDIClientRef = 0
    private var inputPort_v2: MIDIPortRef = 0
    private var outputPort_v2: MIDIPortRef = 0
    private var inputPort_v1: MIDIPortRef = 0
    private var outputPort_v1: MIDIPortRef = 0

    private var receiveHandlers: [MIDIEndpointRef: ReceiveHandler] = [:]
    private var rxSysex1Accum: [UInt8] = []
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
            // Down‑convert UMP to MIDI 1.0 bytes and send via legacy packet API.
            try sendUMP_downconvertToMIDI1(to: dest.endpoint, words: words, hostTime: hostTime)
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

    // MARK: - UMP -> MIDI 1.0 Down‑conversion

    private var sysex7Accum: [UInt8] = []

    private func sendUMP_downconvertToMIDI1(to destination: MIDIEndpointRef, words: [UInt32], hostTime: UInt64) throws {
        // We accumulate MIDI 1.0 bytes for all incoming UMP packets (words) and send as a single packet list.
        var byteChunks: [[UInt8]] = []

        var i = 0
        while i < words.count {
            let w0 = words[i]
            let mt = UInt8((w0 >> 28) & 0x0F)
            switch mt {
            case 0x2: // MIDI 1.0 Channel Voice (already 1.0 semantics)
                let status = UInt8((w0 >> 16) & 0xFF)
                let d1 = UInt8((w0 >> 8) & 0xFF)
                let d2 = UInt8(w0 & 0xFF)
                let statusNib = status >> 4
                if statusNib == 0xC || statusNib == 0xD {
                    byteChunks.append([status, d1])
                } else {
                    byteChunks.append([status, d1, d2])
                }
                i += 1

            case 0x4: // MIDI 2.0 Channel Voice -> downconvert
                guard i + 1 < words.count else { break }
                let w1 = words[i+1]
                let statusNib = UInt8((w0 >> 20) & 0x0F)
                let channel = UInt8((w0 >> 16) & 0x0F)
                let dataByte2 = UInt8((w0 >> 8) & 0xFF) // note or controller or program

                func v16to7(_ v: UInt16) -> UInt8 { return UInt8((UInt32(v) * 127 + 32767) / 65535) }
                func v32to7(_ v: UInt32) -> UInt8 { return UInt8((UInt64(v) * 127 + 2147483647) / 4294967295) }
                func v32to14(_ v: UInt32) -> UInt16 { return UInt16((UInt64(v) * 16383 + 2147483647) / 4294967295) }

                switch statusNib {
                case 0x8: // Note Off
                    let vel16 = UInt16((w1 >> 16) & 0xFFFF)
                    let vel7 = v16to7(vel16)
                    byteChunks.append([0x80 | channel, dataByte2 & 0x7F, vel7])
                case 0x9: // Note On
                    let vel16 = UInt16((w1 >> 16) & 0xFFFF)
                    let vel7 = v16to7(vel16)
                    byteChunks.append([0x90 | channel, dataByte2 & 0x7F, vel7])
                case 0xA: // Poly Pressure
                    let press = v32to7(w1)
                    byteChunks.append([0xA0 | channel, dataByte2 & 0x7F, press])
                case 0xB: // Control Change
                    let val = v32to7(w1)
                    byteChunks.append([0xB0 | channel, dataByte2 & 0x7F, val])
                case 0xC: // Program Change (+ optional bank valid in byte3, bank MSB/LSB in word1[31:16])
                    let bankValid = ((w0 & 0xFF) & 0x80) != 0
                    if bankValid {
                        let msb = UInt8((w1 >> 24) & 0xFF)
                        let lsb = UInt8((w1 >> 16) & 0xFF)
                        byteChunks.append([0xB0 | channel, 0x00, msb & 0x7F]) // Bank MSB
                        byteChunks.append([0xB0 | channel, 0x20, lsb & 0x7F]) // Bank LSB
                    }
                    byteChunks.append([0xC0 | channel, dataByte2 & 0x7F])
                case 0xD: // Channel Pressure
                    let press = v32to7(w1)
                    byteChunks.append([0xD0 | channel, press])
                case 0xE: // Pitch Bend
                    let bend14 = v32to14(w1)
                    let lsb = UInt8(bend14 & 0x7F)
                    let msb = UInt8((bend14 >> 7) & 0x7F)
                    byteChunks.append([0xE0 | channel, lsb, msb])
                case 0xF: // Per-note controllers/management
                    let press = v32to7(w1)
                    switch perNoteMapping {
                    case .off:
                        break
                    case .polyPressure:
                        // Map to Poly Pressure with note=byte2
                        byteChunks.append([0xA0 | channel, dataByte2 & 0x7F, press])
                    case .channelPressure:
                        byteChunks.append([0xD0 | channel, press])
                    }
                default:
                    // Others: no MIDI 1 mapping -> drop silently.
                    break
                }
                i += 2

            case 0x1: // System Common / Real-time
                let status = UInt8((w0 >> 16) & 0xFF)
                let d1 = UInt8((w0 >> 8) & 0xFF)
                let d2 = UInt8(w0 & 0xFF)
                // Determine message length
                let len: Int
                switch status {
                case 0xF1, 0xF3: len = 2 // MTC Quarter Frame, Song Select
                case 0xF2: len = 3 // Song Position
                case 0xF6, 0xF8, 0xFA, 0xFB, 0xFC, 0xFE, 0xFF: len = 1 // Tune Request, Realtime
                default: len = 1
                }
                if len == 1 {
                    byteChunks.append([status])
                } else if len == 2 {
                    byteChunks.append([status, d1])
                } else {
                    byteChunks.append([status, d1, d2])
                }
                i += 1

            case 0x3: // Data messages: handle SysEx7; ignore others
                // A SysEx7 UMP is 64-bit; we need both words.
                guard i + 1 < words.count else { break }
                let w1 = words[i+1]
                let b0 = UInt8((w0 >> 24) & 0xFF)
                let b1 = UInt8((w0 >> 16) & 0xFF)
                // let group = b0 & 0x0F
                let syxStatus = b1 >> 4 // 0=complete,1=start,2=continue,3=end
                let count = Int(b1 & 0x0F)
                // Extract up to 6 data bytes from word0[7:0] + word1[31:0]
                var bytes: [UInt8] = []
                bytes.append(UInt8((w0 >> 8) & 0xFF))
                bytes.append(UInt8(w0 & 0xFF))
                bytes.append(UInt8((w1 >> 24) & 0xFF))
                bytes.append(UInt8((w1 >> 16) & 0xFF))
                bytes.append(UInt8((w1 >> 8) & 0xFF))
                bytes.append(UInt8(w1 & 0xFF))
                if count <= 6 { bytes = Array(bytes.prefix(count)) }

                switch syxStatus {
                case 0x0: // complete single‑packet
                    var syx: [UInt8] = [0xF0]
                    syx.append(contentsOf: bytes)
                    syx.append(0xF7)
                    byteChunks.append(syx)
                case 0x1: // start
                    sysex7Accum = bytes
                case 0x2: // continue
                    sysex7Accum.append(contentsOf: bytes)
                case 0x3: // end
                    sysex7Accum.append(contentsOf: bytes)
                    var syx: [UInt8] = [0xF0]
                    syx.append(contentsOf: sysex7Accum)
                    syx.append(0xF7)
                    byteChunks.append(syx)
                    sysex7Accum.removeAll(keepingCapacity: false)
                default:
                    break
                }
                i += 2

            case 0x5: // SysEx8 (128-bit). Not generally convertible; attempt only if bytes are 7‑bit clean.
                // Requires 4 words.
                guard i + 3 < words.count else { break }
                let b0 = UInt8((w0 >> 24) & 0xFF)
                let b1 = UInt8((w0 >> 16) & 0xFF)
                let status = b1 >> 4
                let count = Int(b1 & 0x0F)
                // Extract 14 data bytes from w0[7:0], w1, w2, w3
                var data: [UInt8] = []
                data.append(UInt8((w0 >> 8) & 0xFF))
                data.append(UInt8(w0 & 0xFF))
                data.append(UInt8((words[i+1] >> 24) & 0xFF))
                data.append(UInt8((words[i+1] >> 16) & 0xFF))
                data.append(UInt8((words[i+1] >> 8) & 0xFF))
                data.append(UInt8(words[i+1] & 0xFF))
                data.append(UInt8((words[i+2] >> 24) & 0xFF))
                data.append(UInt8((words[i+2] >> 16) & 0xFF))
                data.append(UInt8((words[i+2] >> 8) & 0xFF))
                data.append(UInt8(words[i+2] & 0xFF))
                data.append(UInt8((words[i+3] >> 24) & 0xFF))
                data.append(UInt8((words[i+3] >> 16) & 0xFF))
                data.append(UInt8((words[i+3] >> 8) & 0xFF))
                data.append(UInt8(words[i+3] & 0xFF))
                if count <= 14 { data = Array(data.prefix(count)) }

                func is7bitClean(_ arr: [UInt8]) -> Bool { return arr.allSatisfy { $0 < 0x80 } }

                switch status {
                case 0x0: // complete in one
                    if is7bitClean(data) {
                        var syx: [UInt8] = [0xF0]
                        syx.append(contentsOf: data)
                        syx.append(0xF7)
                        byteChunks.append(syx)
                    }
                case 0x1: // start
                    if is7bitClean(data) { sysex7Accum = data } else { sysex7Accum.removeAll() }
                case 0x2: // continue
                    if is7bitClean(data) { sysex7Accum.append(contentsOf: data) } else { sysex7Accum.removeAll() }
                case 0x3: // end
                    if is7bitClean(data), !sysex7Accum.isEmpty {
                        sysex7Accum.append(contentsOf: data)
                        var syx: [UInt8] = [0xF0]
                        syx.append(contentsOf: sysex7Accum)
                        syx.append(0xF7)
                        byteChunks.append(syx)
                    }
                    sysex7Accum.removeAll()
                default:
                    break
                }
                i += 4

            default:
                // Unsupported message types ignored.
                i += 1
            }
        }

        // Build and send MIDIPacketList containing all byteChunks.
        // Conservative capacity.
        let capacity = 4096
        let raw = UnsafeMutableRawPointer.allocate(byteCount: capacity, alignment: 4)
        defer { raw.deallocate() }
        let listPtr = raw.bindMemory(to: MIDIPacketList.self, capacity: 1)
        var packet = MIDIPacketListInit(listPtr)
        for chunk in byteChunks {
            var local = chunk // mutable copy to get pointer
            packet = MIDIPacketListAdd(listPtr, capacity, packet, hostTime, local.count, &local)
            if packet == nil {
                // If buffer overflow, flush and re-init.
                MIDISend(outputPort_v1, destination, listPtr)
                packet = MIDIPacketListInit(listPtr)
                var local2 = chunk
                packet = MIDIPacketListAdd(listPtr, capacity, packet, hostTime, local2.count, &local2)
            }
        }
        MIDISend(outputPort_v1, destination, listPtr)
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
        // Convert legacy MIDIPacketList to UMP words and forward to all handlers.
        var packet = packetList.pointee.packet
        for _ in 0..<packetList.pointee.numPackets {
            // Access packet.data bytes
            let dataOffset = MemoryLayout.offset(of: \MIDIPacket.data) ?? MemoryLayout<MIDIPacket>.size
            let dataPtr = UnsafeRawPointer(&packet).advanced(by: dataOffset).assumingMemoryBound(to: UInt8.self)
            let count = Int(packet.length)
            let bytes = Array(UnsafeBufferPointer(start: dataPtr, count: count))
            processMIDI1Bytes(bytes, time: packet.timeStamp)
            packet = MIDIPacketNext(&packet).pointee
        }
    }

    /// Parse MIDI 1.0 bytes and forward as UMP words using the registered handlers.
    private func processMIDI1Bytes(_ bytes: [UInt8], time: MIDITimeStamp) {
        var i = 0
        var runningStatus: UInt8? = nil
        while i < bytes.count {
            let b = bytes[i]
            if b >= 0xF8 { // Single-byte real-time
                let word: UInt32 = (0x1 << 28) | (UInt32(b) << 16)
                for (_, h) in receiveHandlers { h(0, [word], time) }
                i += 1
                continue
            }
            if b >= 0x80 {
                if b == 0xF0 { // SysEx start
                    // Accumulate until F7 in this packet
                    var j = i + 1
                    while j < bytes.count && bytes[j] != 0xF7 { rxSysex1Accum.append(bytes[j]); j += 1 }
                    if j < bytes.count && bytes[j] == 0xF7 { // complete
                        emitSysEx7(fromAccum: &rxSysex1Accum, time: time)
                        rxSysex1Accum.removeAll(keepingCapacity: false)
                        i = j + 1
                    } else {
                        i = j
                    }
                    runningStatus = nil
                    continue
                } else if b == 0xF7 { // unexpected end
                    emitSysEx7(fromAccum: &rxSysex1Accum, time: time)
                    rxSysex1Accum.removeAll(keepingCapacity: false)
                    i += 1
                    runningStatus = nil
                    continue
                }

                // System Common (not real-time)
                if b >= 0xF1 && b <= 0xF6 {
                    let needed: Int = (b == 0xF2 ? 2 : (b == 0xF1 || b == 0xF3 ? 1 : 0))
                    guard i + 1 + needed <= bytes.count else { break }
                    let d1 = needed >= 1 ? bytes[i+1] : 0
                    let d2 = needed >= 2 ? bytes[i+2] : 0
                    let word: UInt32 = (0x1 << 28) | (UInt32(b) << 16) | (UInt32(d1) << 8) | UInt32(d2)
                    for (_, h) in receiveHandlers { h(0, [word], time) }
                    i += 1 + needed
                    runningStatus = nil
                    continue
                }

                // Channel Voice status
                if b >= 0x80 && b <= 0xEF {
                    let nib = b >> 4
                    let dataCount = (nib == 0xC || nib == 0xD) ? 1 : 2
                    guard i + 1 + dataCount <= bytes.count else { break }
                    let d1 = bytes[i+1]
                    let d2 = dataCount == 2 ? bytes[i+2] : 0
                    let word: UInt32 = (0x2 << 28) | (0 /*group*/ << 24) | (UInt32(b) << 16) | (UInt32(d1) << 8) | UInt32(d2)
                    for (_, h) in receiveHandlers { h(0, [word], time) }
                    runningStatus = b
                    i += 1 + dataCount
                    continue
                }
            } else if let status = runningStatus { // Running status data
                let nib = status >> 4
                let dataCount = (nib == 0xC || nib == 0xD) ? 1 : 2
                if dataCount == 1 {
                    let d1 = bytes[i]
                    let word: UInt32 = (0x2 << 28) | (0 << 24) | (UInt32(status) << 16) | (UInt32(d1) << 8)
                    for (_, h) in receiveHandlers { h(0, [word], time) }
                    i += 1
                    continue
                } else {
                    guard i + 1 < bytes.count else { break }
                    let d1 = bytes[i]
                    let d2 = bytes[i+1]
                    let word: UInt32 = (0x2 << 28) | (0 << 24) | (UInt32(status) << 16) | (UInt32(d1) << 8) | UInt32(d2)
                    for (_, h) in receiveHandlers { h(0, [word], time) }
                    i += 2
                    continue
                }
            }

            // Unknown or stray byte; skip
            i += 1
        }
    }

    private func emitSysEx7(fromAccum accum: inout [UInt8], time: MIDITimeStamp) {
        guard !accum.isEmpty else { return }
        // Split manufacturer ID and payload
        var manufacturer: [UInt8] = []
        var payload: [UInt8] = []
        if accum[0] == 0x00 {
            guard accum.count >= 3 else { return }
            manufacturer = Array(accum[0..<3])
            payload = Array(accum.dropFirst(3))
        } else {
            manufacturer = [accum[0]]
            payload = Array(accum.dropFirst(1))
        }
        guard let packets = try? SysEx7.fragment(manufacturerID: manufacturer, payload: payload, group: 0) else { return }
        for p in packets {
            // Convert 8 bytes to two words
            let w0 = (UInt32(p[0]) << 24) | (UInt32(p[1]) << 16) | (UInt32(p[2]) << 8) | UInt32(p[3])
            let w1 = (UInt32(p[4]) << 24) | (UInt32(p[5]) << 16) | (UInt32(p[6]) << 8) | UInt32(p[7])
            for (_, h) in receiveHandlers { h(0, [w0, w1], time) }
        }
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
