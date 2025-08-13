/// Common 32-bit UMP header (messageType + group + status + two data bytes).
///
/// The first 32-bit word of many UMP packet types share this layout.  The
/// leading nibble is the message type, followed by a 4-bit group.  The next
/// byte is the status field and the final two bytes are typically payload
/// data or counts depending on the message type.
public struct UmpHeader32: Equatable {
    /// Raw 32-bit word representing the header.
    public let word: UInt32

    /// Creates a header from a raw 32-bit word.  Fails if the message type is
    /// not one of the valid 32-bit UMP types.
    public init?(word: UInt32) {
        let mt = UInt8((word >> 28) & 0xF)
        // Valid message types for 32-bit packets as defined by the MIDI 2.0
        // specification (Utility, System, MIDI 1.0, Data64, or Flex Data).
        let valid: Set<UInt8> = [0, 1, 2, 3, 15]
        guard valid.contains(mt) else { return nil }
        self.word = word
    }

    /// Creates a header from individual fields.
    public init?(
        messageType: UInt8,
        group: Uint4,
        status: UInt8,
        byte1: UInt8,
        byte2: UInt8
    ) {
        let valid: Set<UInt8> = [0, 1, 2, 3, 15]
        guard valid.contains(messageType) else { return nil }

        let word =
            (UInt32(messageType) << 28) |
            (UInt32(group.rawValue) << 24) |
            (UInt32(status) << 16) |
            (UInt32(byte1) << 8) |
            UInt32(byte2)

        self.word = word
    }

    /// The 4-bit message type field (bits 31-28).
    public var messageType: UInt8 { UInt8((word >> 28) & 0xF) }

    /// The 4-bit group field (bits 27-24).
    public var group: Uint4 { Uint4(UInt8((word >> 24) & 0xF))! }

    /// The 8-bit status field (bits 23-16).
    public var status: UInt8 { UInt8((word >> 16) & 0xFF) }

    /// Byte 3 of the packet (bits 15-8).
    public var byte1: UInt8 { UInt8((word >> 8) & 0xFF) }

    /// Byte 4 of the packet (bits 7-0).
    public var byte2: UInt8 { UInt8(word & 0xFF) }

    /// The lower 16 bits interpreted as a single value.
    public var data: UInt16 { UInt16(byte1) << 8 | UInt16(byte2) }

    /// Number of data bytes following the status byte.  For MIDI 1.0 channel
    /// voice messages this depends on the status nibble; for most other
    /// messages the value is fixed by the specification.
    public var dataByteCount: Int {
        let status = self.status
        let statusNibble = status >> 4

        switch statusNibble {
        case 0xC, 0xD:
            return 1
        case 0xF:
            switch status & 0xF {
            case 0x1, 0x3:
                return 1
            case 0x2:
                return 2
            default:
                return 0
            }
        default:
            return 2
        }
    }
}

