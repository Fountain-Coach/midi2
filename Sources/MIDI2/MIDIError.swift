import Foundation

/// Common errors that can occur when working with MIDI 2.0 data structures.
public enum MIDIError: LocalizedError {
    case valueOutOfRange(name: String, value: UInt64, range: ClosedRange<UInt64>)
    case malformedPacket(String)

    public var errorDescription: String? {
        switch self {
        case let .valueOutOfRange(name, value, range):
            return "\(name) value \(value) out of range \(range.lowerBound)...\(range.upperBound)"
        case .malformedPacket(let reason):
            return "Malformed packet: \(reason)"
        }
    }
}
