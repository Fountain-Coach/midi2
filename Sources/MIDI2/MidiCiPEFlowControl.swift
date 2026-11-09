/// A source-verified MIDI-CI Property Exchange flow-control status field group.
///
/// M2-101-UM v1.2.1, §§5.10.2, 5.10.3, 5.11.2, 5.11.3,
/// Tables 14 and 16 (pp. 34 and 36-37).
///
/// This is the eight-byte status/detail block within a MIDI-CI ACK/NAK
/// message. The universal SysEx envelope, MUID routing, transaction lifecycle,
/// and any actual resending remain the responsibility of the MIDI-CI runtime.
/// It is NOT the legacy PE Notify 0x3F message.
public struct MidiCiPEFlowControl: Equatable, Sendable {
    public enum Action: UInt8, Sendable {
        case sendNextChunks = 0x11
        case resendMostRecentChunk = 0x12

        public var ack: Bool { self == .sendNextChunks }
        public var subID2: UInt8 { ack ? 0x7D : 0x7F }
    }

    public enum ValidationError: Error, Equatable, Sendable {
        case invalidSubID
        case invalidOriginalTransaction
        case invalidStreamID
        case invalidChunkNumber
        case invalidStatusData
        case malformedStatusFields
    }

    public let action: Action
    public let originalTransactionSubID2: UInt8
    public let peStreamID: UInt8
    public let peChunkNumber: UInt16

    public init(
        action: Action,
        originalTransactionSubID2: UInt8,
        peStreamID: UInt8,
        peChunkNumber: UInt16
    ) throws {
        guard (0x30...0x3F).contains(originalTransactionSubID2) else {
            throw ValidationError.invalidOriginalTransaction
        }
        guard peStreamID <= 0x7F else { throw ValidationError.invalidStreamID }
        guard peChunkNumber <= 0x3FFF else { throw ValidationError.invalidChunkNumber }
        self.action = action
        self.originalTransactionSubID2 = originalTransactionSubID2
        self.peStreamID = peStreamID
        self.peChunkNumber = peChunkNumber
    }

    public var subID2: UInt8 { action.subID2 }
    public var statusCode: UInt8 { action.rawValue }
    public var statusData: UInt8 { 0 }

    /// Original Sub-ID#2, Status Code, Status Data, five PE detail bytes.
    /// The two 7-bit chunk bytes are least-significant first. Final details
    /// are reserved and emitted as zero.
    public func statusFields() -> [UInt8] {
        [
            originalTransactionSubID2, statusCode, statusData,
            peStreamID,
            UInt8(peChunkNumber & 0x7F),
            UInt8((peChunkNumber >> 7) & 0x7F),
            0, 0
        ]
    }

    public static func decode(
        subID2: UInt8, statusFields fields: [UInt8]
    ) throws -> Self {
        guard subID2 == 0x7D || subID2 == 0x7F else {
            throw ValidationError.invalidSubID
        }
        guard fields.count == 8, fields.allSatisfy({ $0 <= 0x7F }) else {
            throw ValidationError.malformedStatusFields
        }
        let action: Action
        switch (subID2, fields[1]) {
        case (0x7D, 0x11): action = .sendNextChunks
        case (0x7F, 0x12): action = .resendMostRecentChunk
        default: throw ValidationError.invalidSubID
        }
        guard fields[2] == 0 else { throw ValidationError.invalidStatusData }
        return try Self(
            action: action,
            originalTransactionSubID2: fields[0],
            peStreamID: fields[3],
            peChunkNumber: UInt16(fields[4]) | (UInt16(fields[5]) << 7)
        )
    }
}
