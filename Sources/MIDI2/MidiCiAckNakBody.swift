/// SysEx body for MIDI-CI ACK/NAK response messages.
public struct MidiCiAckNakBody: Equatable {
    /// Indicates whether the message is an ACK (`true`) or NAK (`false`).
    public var ack: Bool
    /// Optional numeric status code.
    public var statusCode: UInt8
    /// Human readable message describing the result.
    public var message: String

    public init(ack: Bool, statusCode: UInt8, message: String) {
        self.ack = ack
        self.statusCode = statusCode
        self.message = message
    }

    /// Serialize to SysEx7 payload bytes.
    public func sysEx7Bytes() -> [UInt8] {
        let msgBytes = message.utf8.map { $0 & 0x7F }
        return [ack ? 1 : 0, statusCode & 0x7F, UInt8(msgBytes.count)] + msgBytes
    }

    /// Serialize to SysEx8 payload bytes.
    public func sysEx8Bytes() -> [UInt8] {
        let msgBytes = Array(message.utf8)
        return [ack ? 1 : 0, statusCode, UInt8(msgBytes.count)] + msgBytes
    }

    /// Deserialize from SysEx7 payload bytes.
    public init(sysEx7Bytes bytes: [UInt8]) {
        self.ack = bytes.first ?? 0 > 0
        self.statusCode = bytes.dropFirst().first ?? 0
        let len = Int(bytes.dropFirst(2).first ?? 0)
        let msg = bytes.dropFirst(3).prefix(len)
        self.message = String(bytes: msg, encoding: .utf8) ?? ""
    }

    /// Deserialize from SysEx8 payload bytes.
    public init(sysEx8Bytes bytes: [UInt8]) {
        self.ack = bytes.first ?? 0 > 0
        self.statusCode = bytes.dropFirst().first ?? 0
        let len = Int(bytes.dropFirst(2).first ?? 0)
        let msg = bytes.dropFirst(3).prefix(len)
        self.message = String(bytes: msg, encoding: .utf8) ?? ""
    }
}
