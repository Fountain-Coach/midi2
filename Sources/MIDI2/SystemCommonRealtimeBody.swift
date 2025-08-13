/// UMP 0x1 System Common & Real-Time.
public struct SystemCommonRealtimeBody: Equatable {
    /// MIDI system status byte.
    public var status: SystemStatus
    /// First data byte (may be unused for some statuses).
    public var data1: UInt8
    /// Second data byte (may be unused for some statuses).
    public var data2: UInt8

    /// Creates a new body.
    public init(status: SystemStatus, data1: UInt8 = 0, data2: UInt8 = 0) {
        self.status = status
        self.data1 = data1
        self.data2 = data2
    }

    /// Encodes the body into a 32‑bit UMP packet using the supplied group.
    public func ump(group: Uint4) -> UmpPacket32 {
        let byte0 = UInt32(0x1 << 4 | group.rawValue)
        let word = (byte0 << 24) |
                   (UInt32(status.rawValue) << 16) |
                   (UInt32(data1) << 8) |
                   UInt32(data2)
        return UmpPacket32(word: word)
    }

    /// Decodes a body from a 32‑bit UMP packet.
    public init?(ump: UmpPacket32) {
        let word = ump.word
        let mt = UInt8((word >> 28) & 0xF)
        guard mt == 0x1 else { return nil }
        let statusByte = UInt8((word >> 16) & 0xFF)
        guard let status = SystemStatus(rawValue: statusByte) else { return nil }
        let data1 = UInt8((word >> 8) & 0xFF)
        let data2 = UInt8(word & 0xFF)
        self.init(status: status, data1: data1, data2: data2)
    }

    /// Failable initialiser that performs validation and throws `MIDIError` on
    /// malformed packets.
    public init(parsingUMP ump: UmpPacket32) throws {
        let word = ump.word
        let mt = UInt8((word >> 28) & 0xF)
        guard mt == 0x1 else {
            throw MIDIError.malformedPacket("expected mt 0x1 but got \(mt)")
        }
        let statusByte = UInt8((word >> 16) & 0xFF)
        guard let status = SystemStatus(rawValue: statusByte) else {
            throw MIDIError.malformedPacket("invalid system status 0x\(String(statusByte, radix: 16))")
        }
        let data1 = UInt8((word >> 8) & 0xFF)
        let data2 = UInt8(word & 0xFF)
        self.init(status: status, data1: data1, data2: data2)
    }
}

