import Foundation

enum MidiCiEncoding {
    // MARK: - 7-bit helpers
    static func encodeUInt16To7Bit(_ value: UInt16) -> [UInt8] {
        [UInt8((value >> 7) & 0x7F), UInt8(value & 0x7F)]
    }

    static func decodeUInt16From7Bit(_ bytes: ArraySlice<UInt8>) -> UInt16 {
        UInt16(bytes[bytes.startIndex]) << 7 | UInt16(bytes[bytes.startIndex + 1])
    }

    static func encodeUInt32To7Bit(_ value: UInt32) -> [UInt8] {
        [
            UInt8((value >> 21) & 0x7F),
            UInt8((value >> 14) & 0x7F),
            UInt8((value >> 7) & 0x7F),
            UInt8(value & 0x7F)
        ]
    }

    static func decodeUInt32From7Bit(_ bytes: ArraySlice<UInt8>) -> UInt32 {
        let i = bytes.startIndex
        return (UInt32(bytes[i]) << 21) |
               (UInt32(bytes[i + 1]) << 14) |
               (UInt32(bytes[i + 2]) << 7) |
               UInt32(bytes[i + 3])
    }

    // MARK: - 8-bit helpers
    static func encodeUInt16To8Bit(_ value: UInt16) -> [UInt8] {
        [UInt8((value >> 8) & 0xFF), UInt8(value & 0xFF)]
    }

    static func decodeUInt16From8Bit(_ bytes: ArraySlice<UInt8>) -> UInt16 {
        let i = bytes.startIndex
        return UInt16(bytes[i]) << 8 | UInt16(bytes[i + 1])
    }

    static func encodeUInt32To8Bit(_ value: UInt32) -> [UInt8] {
        [
            UInt8((value >> 24) & 0xFF),
            UInt8((value >> 16) & 0xFF),
            UInt8((value >> 8) & 0xFF),
            UInt8(value & 0xFF)
        ]
    }

    static func decodeUInt32From8Bit(_ bytes: ArraySlice<UInt8>) -> UInt32 {
        let i = bytes.startIndex
        return (UInt32(bytes[i]) << 24) |
               (UInt32(bytes[i + 1]) << 16) |
               (UInt32(bytes[i + 2]) << 8) |
               UInt32(bytes[i + 3])
    }
}
