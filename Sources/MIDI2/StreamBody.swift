/// Endpoint discovery, protocol selection, and FB info.
public struct StreamBody: Equatable {
    /// Stream message opcode.
    public var opcode: StreamOpcode
    /// First data byte following the opcode.
    public var data1: UInt8
    /// Second data byte following the opcode.
    public var data2: UInt8

    /// Creates a new body.
    public init(opcode: StreamOpcode, data1: UInt8 = 0, data2: UInt8 = 0) {
        self.opcode = opcode
        self.data1 = data1
        self.data2 = data2
    }

    /// Encodes the body into a 32‑bit UMP packet using the supplied group.
    public func ump(group: Uint4) -> UmpPacket32 {
        let byte0 = UInt32(0xF << 4 | group.rawValue)
        let word = (byte0 << 24) |
                   (UInt32(opcode.rawValue) << 16) |
                   (UInt32(data1) << 8) |
                   UInt32(data2)
        return UmpPacket32(word: word)
    }

    /// Decodes a body from a 32‑bit UMP packet.
    public init?(ump: UmpPacket32) {
        let word = ump.word
        let mt = UInt8((word >> 28) & 0xF)
        guard mt == 0xF else { return nil }
        let status = UInt8((word >> 16) & 0xFF)
        guard let op = StreamOpcode(rawValue: status) else { return nil }
        let data1 = UInt8((word >> 8) & 0xFF)
        let data2 = UInt8(word & 0xFF)
        self.init(opcode: op, data1: data1, data2: data2)
    }

    /// Failable initialiser that throws ``MIDIError`` on malformed packets.
    public init(parsingUMP ump: UmpPacket32) throws {
        let word = ump.word
        let mt = UInt8((word >> 28) & 0xF)
        guard mt == 0xF else {
            throw MIDIError.malformedPacket("expected mt 0xF but got \(mt)")
        }
        let status = UInt8((word >> 16) & 0xFF)
        guard let op = StreamOpcode(rawValue: status) else {
            throw MIDIError.malformedPacket("invalid stream opcode 0x\(String(status, radix: 16))")
        }
        let data1 = UInt8((word >> 8) & 0xFF)
        let data2 = UInt8(word & 0xFF)
        self.init(opcode: op, data1: data1, data2: data2)
    }
}

