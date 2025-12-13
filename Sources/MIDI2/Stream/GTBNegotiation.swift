import Foundation

/// Validation helpers for Group Terminal Block negotiation.
///
/// This is a metadata-level validator: it does not change the on-wire format.
/// It ensures GTB layouts do not overlap and can be used prior to advertising blocks.
public enum GTBValidator {
    /// Validate a list of function blocks for overlapping group ranges.
    /// - Parameters:
    ///   - blocks: Function blocks to validate.
    ///   - allowOverlap: When true, overlapping ranges are permitted.
    /// - Throws: ``MIDIError.malformedPacket`` if overlap is detected and disallowed.
    public static func validate(blocks: [GroupTerminalBlock], allowOverlap: Bool = false) throws {
        guard !allowOverlap else { return }
        let ranges: [(UInt8, ClosedRange<Int>)] = blocks.map { blk in
            let start = Int(blk.firstGroup & 0x0F)
            let count = Int(blk.groupCount & 0x0F)
            let end = start + max(0, count - 1)
            return (blk.index, start...end)
        }
        for i in 0..<ranges.count {
            for j in (i + 1)..<ranges.count {
                if ranges[i].1.overlaps(ranges[j].1) {
                    throw MIDIError.malformedPacket("GTB/function block overlap between index \(ranges[i].0) and \(ranges[j].0)")
                }
            }
        }
    }

    /// Validate a GTB descriptor against known function blocks (ensures group coverage).
    /// - Parameters:
    ///   - descriptor: GTB descriptor with per-group permissions.
    ///   - blocks: Function blocks to validate against.
    ///   - allowOverlap: Allow overlapping block ranges when true.
    public static func validate(descriptor: GtbDescriptor, blocks: [GroupTerminalBlock], allowOverlap: Bool = false) throws {
        try validate(blocks: blocks, allowOverlap: allowOverlap)
        let ranges: [ClosedRange<Int>] = blocks.map { blk in
            let start = Int(blk.firstGroup & 0x0F)
            let count = Int(blk.groupCount & 0x0F)
            let end = start + max(0, count - 1)
            return start...end
        }
        for (group, _) in descriptor.groups {
            let g = Int(group & 0x0F)
            let covered = ranges.contains { $0.contains(g) }
            if !covered {
                throw MIDIError.malformedPacket("GTB descriptor group \(group) not covered by any Function Block")
            }
        }
    }

    /// Enforce message-type restrictions for a GTB context.
    /// - Parameters:
    ///   - mt: Message type nibble.
    ///   - allowed: Set of allowed MT values.
    /// - Throws: ``MIDIError.malformedPacket`` if disallowed.
    public static func enforceAllowedMessageType(mt: UInt8, allowed: Set<UInt8>) throws {
        if !allowed.contains(mt) {
            throw MIDIError.malformedPacket("GTB disallows message type 0x\(String(mt, radix: 16))")
        }
    }
}
