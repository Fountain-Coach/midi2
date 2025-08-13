/// Raw 8-byte Universal MIDI Packet carrying a SysEx7 fragment.
public struct SysEx7Packet: Equatable {
    /// Status nibble indicating position of this fragment in the SysEx7 stream.
    public enum Status: UInt8, Equatable {
        /// Packet contains a complete message (single packet transfer).
        case complete = 0x0
        /// First packet of a multi-packet transfer.
        case start = 0x1
        /// Continuation packet of a multi-packet transfer.
        case `continue` = 0x2
        /// Final packet of a multi-packet transfer.
        case end = 0x3
    }

    /// UMP group (0–15).
    public var group: Uint4
    /// Status of the packet within the SysEx7 message.
    public var status: Status
    /// Payload data bytes (0–6 bytes).
    public var data: [UInt8]

    /// Number of payload bytes in ``data`` encoded as a 4-bit value.
    public var byteCount: Uint4 { Uint4(UInt8(data.count))! }

    /// Creates a packet from fields. ``data`` may contain at most six bytes.
    public init(group: Uint4, status: Status, data: [UInt8]) {
        precondition(data.count <= 6)
        self.group = group
        self.status = status
        self.data = data
    }

    /// Raw 8-byte representation of the packet.
    public var rawBytes: [UInt8] {
        var bytes: [UInt8] = [0x30 | group.rawValue,
                              (status.rawValue << 4) | byteCount.rawValue]
        bytes.append(contentsOf: data)
        if data.count < 6 {
            bytes.append(contentsOf: Array(repeating: 0, count: 6 - data.count))
        }
        return bytes
    }

    /// UMP packet view of this SysEx7 fragment.
    public var ump: UmpPacket64 { UmpPacket64(rawBytes: rawBytes)! }

    /// Creates a packet from raw bytes. Fails if bytes do not form a valid SysEx7 packet.
    public init?(rawBytes: [UInt8]) {
        guard rawBytes.count == 8 else { return nil }
        let mt = rawBytes[0] >> 4
        guard mt == 0x3 else { return nil }
        guard let group = Uint4(rawBytes[0] & 0x0F) else { return nil }
        let statusNibble = rawBytes[1] >> 4
        guard let status = Status(rawValue: statusNibble) else { return nil }
        let count = Int(rawBytes[1] & 0x0F)
        guard count <= 6 else { return nil }
        let payload = Array(rawBytes[2..<(2 + count)])
        self.init(group: group, status: status, data: payload)
    }

    /// Creates a packet from a ``UmpPacket64``.
    public init?(ump: UmpPacket64) {
        self.init(rawBytes: ump.rawBytes)
    }

    /// Failable initialiser that throws ``MIDIError`` for malformed packets.
    public init(parsing rawBytes: [UInt8]) throws {
        guard rawBytes.count == 8 else {
            throw MIDIError.malformedPacket("expected 8 bytes but got \(rawBytes.count)")
        }
        let mt = rawBytes[0] >> 4
        guard mt == 0x3 else {
            throw MIDIError.malformedPacket("expected mt 0x3 but got \(mt)")
        }
        guard let group = Uint4(rawBytes[0] & 0x0F) else {
            throw MIDIError.malformedPacket("invalid group \(rawBytes[0] & 0x0F)")
        }
        let statusNibble = rawBytes[1] >> 4
        guard let status = Status(rawValue: statusNibble) else {
            throw MIDIError.malformedPacket("invalid SysEx7 status 0x\(String(statusNibble, radix: 16))")
        }
        let count = Int(rawBytes[1] & 0x0F)
        guard count <= 6 else {
            throw MIDIError.malformedPacket("invalid byte count \(count)")
        }
        let payload = Array(rawBytes[2..<(2 + count)])
        self.init(group: group, status: status, data: payload)
    }

    /// Failable initialiser from ``UmpPacket64`` that throws ``MIDIError`` for malformed packets.
    public init(parsingUMP ump: UmpPacket64) throws {
        try self.init(parsing: ump.rawBytes)
    }
}

