/// Body of a single SysEx7 UMP packet.
///
/// The packet is represented as the status nibble, the byte count and up to six
/// bytes of payload data.  Encoding and decoding operate on ``UmpPacket64``
/// values as SysEx7 packets are 64 bits wide.
public struct SysEx7Body: Equatable {
    /// Status nibble (0 = complete, 1 = start, 2 = continue, 3 = end).
    public enum Status: UInt8, Equatable {
        case complete = 0x0
        case start    = 0x1
        case `continue` = 0x2
        case end      = 0x3
    }

    /// Status of the packet.
    public var status: Status
    /// Payload data (0–6 bytes).
    public var data: [UInt8]

    /// Creates a new body.
    public init(status: Status, data: [UInt8]) {
        precondition(data.count <= 6)
        self.status = status
        self.data = data
    }

    /// Encodes the body into a ``UmpPacket64`` using the supplied group.
    public func ump(group: Uint4) -> UmpPacket64 {
        var bytes: [UInt8] = [0x30 | group.rawValue,
                              (status.rawValue << 4) | UInt8(data.count)]
        bytes.append(contentsOf: data)
        if data.count < 6 {
            bytes.append(contentsOf: Array(repeating: 0, count: 6 - data.count))
        }
        return UmpPacket64(rawBytes: bytes)!
    }

    /// Decodes a body from a ``UmpPacket64``.
    public init?(ump: UmpPacket64) {
        let bytes = ump.rawBytes
        let mt = bytes[0] >> 4
        guard mt == 0x3 else { return nil }
        let statusNibble = bytes[1] >> 4
        guard let status = Status(rawValue: statusNibble) else { return nil }
        let count = Int(bytes[1] & 0x0F)
        guard count <= 6 else { return nil }
        let payload = Array(bytes[2..<(2 + count)])
        self.init(status: status, data: payload)
    }

    /// Failable initialiser that throws ``MIDIError`` for malformed packets.
    public init(parsingUMP ump: UmpPacket64) throws {
        let bytes = ump.rawBytes
        let mt = bytes[0] >> 4
        guard mt == 0x3 else {
            throw MIDIError.malformedPacket("expected mt 0x3 but got \(mt)")
        }
        let statusNibble = bytes[1] >> 4
        guard let status = Status(rawValue: statusNibble) else {
            throw MIDIError.malformedPacket("invalid SysEx7 status 0x\(String(statusNibble, radix: 16))")
        }
        let count = Int(bytes[1] & 0x0F)
        guard count <= 6 else {
            throw MIDIError.malformedPacket("invalid byte count \(count)")
        }
        let payload = Array(bytes[2..<(2 + count)])
        self.init(status: status, data: payload)
    }
}

