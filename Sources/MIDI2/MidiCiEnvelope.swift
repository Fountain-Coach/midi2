/// SysEx(7/8) payload for MIDI-CI transactions.
public struct MidiCiEnvelope: Equatable {
    /// Real-time or non-realtime scope.
    public enum Scope: UInt8, Equatable { case nonRealtime = 0x7E, realtime = 0x7F }

    public var scope: Scope
    public var subId2: UInt8
    public var version: UInt8
    public var body: MidiCiBody

    public init(scope: Scope, subId2: UInt8, version: UInt8 = 1, body: MidiCiBody) {
        self.scope = scope
        self.subId2 = subId2
        self.version = version
        self.body = body
    }

    /// Serialize to SysEx7 payload bytes.
    public func sysEx7Payload() -> [UInt8] {
        [scope.rawValue, 0x0D, subId2 & 0x7F, version & 0x7F] + body.sysEx7Bytes
    }

    /// Serialize to SysEx8 payload bytes.
    public func sysEx8Payload() -> [UInt8] {
        [scope.rawValue, 0x0D, subId2, version] + body.sysEx8Bytes
    }

    /// Deserialize from SysEx7 payload bytes.
    public init(sysEx7Payload bytes: [UInt8]) throws {
        guard bytes.count >= 4 else { throw MIDIError.malformedPacket("payload too short") }
        guard let scope = Scope(rawValue: bytes[0]) else { throw MIDIError.malformedPacket("invalid scope") }
        guard bytes[1] == 0x0D else { throw MIDIError.malformedPacket("invalid subId1") }
        let subId2 = bytes[2]
        let version = bytes[3]
        let bodyBytes = Array(bytes.dropFirst(4))
        let body = try MidiCiBody(subId2: subId2, sysEx7Bytes: bodyBytes)
        self.init(scope: scope, subId2: subId2, version: version, body: body)
    }

    /// Deserialize from SysEx8 payload bytes.
    public init(sysEx8Payload bytes: [UInt8]) throws {
        guard bytes.count >= 4 else { throw MIDIError.malformedPacket("payload too short") }
        guard let scope = Scope(rawValue: bytes[0]) else { throw MIDIError.malformedPacket("invalid scope") }
        guard bytes[1] == 0x0D else { throw MIDIError.malformedPacket("invalid subId1") }
        let subId2 = bytes[2]
        let version = bytes[3]
        let bodyBytes = Array(bytes.dropFirst(4))
        let body = try MidiCiBody(subId2: subId2, sysEx8Bytes: bodyBytes)
        self.init(scope: scope, subId2: subId2, version: version, body: body)
    }
}

/// MIDI-CI message bodies.
public enum MidiCiBody: Equatable {
    case discovery(MidiCiDiscoveryBody)
    case profiles(MidiCiProfilesBody)
    case propertyExchange(MidiCiPropertyExchangeBody)
    case processInquiry(MidiCiProcessInquiryBody)
    case ackNak(MidiCiAckNakBody)

    var sysEx7Bytes: [UInt8] {
        switch self {
        case .discovery(let b): return b.sysEx7Bytes()
        case .profiles(let b): return b.sysEx7Bytes()
        case .propertyExchange(let b): return b.sysEx7Bytes()
        case .processInquiry(let b): return b.sysEx7Bytes()
        case .ackNak(let b): return b.sysEx7Bytes()
        }
    }

    var sysEx8Bytes: [UInt8] {
        switch self {
        case .discovery(let b): return b.sysEx8Bytes()
        case .profiles(let b): return b.sysEx8Bytes()
        case .propertyExchange(let b): return b.sysEx8Bytes()
        case .processInquiry(let b): return b.sysEx8Bytes()
        case .ackNak(let b): return b.sysEx8Bytes()
        }
    }

    init(subId2: UInt8, sysEx7Bytes bytes: [UInt8]) throws {
        switch subId2 {
        case 0x70:
            guard let b = MidiCiDiscoveryBody(sysEx7Bytes: bytes) else { throw MIDIError.malformedPacket("discovery body") }
            self = .discovery(b)
        case 0x72:
            self = .profiles(MidiCiProfilesBody(sysEx7Bytes: bytes))
        case 0x7C:
            self = .propertyExchange(MidiCiPropertyExchangeBody(sysEx7Bytes: bytes))
        case 0x7E:
            self = .processInquiry(MidiCiProcessInquiryBody(sysEx7Bytes: bytes))
        case 0x7F:
            self = .ackNak(MidiCiAckNakBody(sysEx7Bytes: bytes))
        default:
            throw MIDIError.malformedPacket("unsupported subId2 \(subId2)")
        }
    }

    init(subId2: UInt8, sysEx8Bytes bytes: [UInt8]) throws {
        switch subId2 {
        case 0x70:
            guard let b = MidiCiDiscoveryBody(sysEx8Bytes: bytes) else { throw MIDIError.malformedPacket("discovery body") }
            self = .discovery(b)
        case 0x72:
            self = .profiles(MidiCiProfilesBody(sysEx8Bytes: bytes))
        case 0x7C:
            self = .propertyExchange(MidiCiPropertyExchangeBody(sysEx8Bytes: bytes))
        case 0x7E:
            self = .processInquiry(MidiCiProcessInquiryBody(sysEx8Bytes: bytes))
        case 0x7F:
            self = .ackNak(MidiCiAckNakBody(sysEx8Bytes: bytes))
        default:
            throw MIDIError.malformedPacket("unsupported subId2 \(subId2)")
        }
    }
}
