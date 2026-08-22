/// Software packet-ordering and reserved-message validation. This is not hardware transport.
public enum UmpValidation: Equatable { case accepted(sequence: UInt64), outOfOrder(expected: UInt64, actual: UInt64), reserved, invalid }

public final class UmpOrderingValidator {
    private var nextSequence: UInt64 = 0
    public init() {}

    public func validate(packet: [UInt32], sequence: UInt64) -> UmpValidation {
        guard sequence == nextSequence else { return .outOfOrder(expected: nextSequence, actual: sequence) }
        guard !packet.isEmpty, packet.count <= 4 else { return .invalid }
        let messageType = UInt8((packet[0] >> 28) & 0x0F)
        guard messageType != 0x0D else { return .reserved }
        nextSequence += 1
        return .accepted(sequence: sequence)
    }
}
