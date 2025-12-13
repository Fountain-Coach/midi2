import Foundation

/// Direction of a Function Block, per M2-104-UM Figure 22.
public enum FunctionBlockDirection: UInt8, Equatable {
    case reserved = 0
    case input = 1
    case output = 2
    case bidirectional = 3
}

/// MIDI 1.0 bandwidth indicator for a Function Block.
public enum Midi1Bandwidth: UInt8, Equatable {
    case notMidi1 = 0
    case unrestricted = 1
    case restrict31_25kbps = 2
}

/// Fully-typed Function Block Info Notification (mt=0xF, opcode=0x11).
public struct FunctionBlockInfoNotification: Equatable {
    public var index: UInt8
    public var firstGroup: UInt8 // 0..15
    public var groupCount: UInt8 // 0..15
    public var active: Bool
    public var direction: FunctionBlockDirection
    public var midi1Bandwidth: Midi1Bandwidth

    public init(
        index: UInt8,
        firstGroup: UInt8,
        groupCount: UInt8,
        active: Bool,
        direction: FunctionBlockDirection,
        midi1Bandwidth: Midi1Bandwidth
    ) throws {
        guard firstGroup <= 0x0F else {
            throw MIDIError.valueOutOfRange(name: "firstGroup", value: UInt64(firstGroup), range: 0...0x0F)
        }
        guard groupCount <= 0x0F else {
            throw MIDIError.valueOutOfRange(name: "groupCount", value: UInt64(groupCount), range: 0...0x0F)
        }
        self.index = index
        self.firstGroup = firstGroup
        self.groupCount = groupCount
        self.active = active
        self.direction = direction
        self.midi1Bandwidth = midi1Bandwidth
    }

    private var word0: UInt32 {
        (UInt32(0xF) << 28) |
        (UInt32(index) << 8) |
        (UInt32(firstGroup & 0x0F) << 4) |
        UInt32(groupCount & 0x0F) |
        (UInt32(StreamOpcode.functionBlockInfoNotification.rawValue) << 16)
    }

    private var word1: UInt32 {
        let activeBit: UInt32 = active ? 0x80000000 : 0
        let directionBits: UInt32 = UInt32(direction.rawValue & 0x03) << 16
        let bandwidthBits: UInt32 = UInt32(midi1Bandwidth.rawValue & 0x03) << 8
        return activeBit | directionBits | bandwidthBits
    }

    /// Encode to a 64-bit UMP in the given group.
    public func ump(group: Uint4) -> UmpPacket64 {
        let w0 = (UInt32(0xF) << 28) |
                 (UInt32(group.rawValue) << 24) |
                 (UInt32(StreamOpcode.functionBlockInfoNotification.rawValue) << 16) |
                 (UInt32(index) << 8) |
                 (UInt32(firstGroup & 0x0F) << 4) |
                 UInt32(groupCount & 0x0F)
        return UmpPacket64(word0: w0, word1: word1)
    }

    /// Failable decode from a 64-bit UMP. Returns nil on opcode mismatch or validation failure.
    public init?(ump64: UmpPacket64) {
        do {
            try self.init(parsingUMP64: ump64)
        } catch {
            return nil
        }
    }

    /// Throwing decode from a 64-bit UMP that validates opcode and reserved bits.
    public init(parsingUMP64 ump: UmpPacket64) throws {
        let w0 = ump.word0
        let mt = UInt8((w0 >> 28) & 0xF)
        guard mt == 0xF else {
            throw MIDIError.malformedPacket("expected mt 0xF but got \(mt)")
        }
        let opcode = UInt8((w0 >> 16) & 0xFF)
        guard opcode == StreamOpcode.functionBlockInfoNotification.rawValue else {
            throw MIDIError.malformedPacket("expected functionBlockInfoNotification opcode, got 0x\(String(opcode, radix: 16))")
        }
        let idx = UInt8((w0 >> 8) & 0xFF)
        let fg = UInt8((w0 >> 4) & 0x0F)
        let gc = UInt8(w0 & 0x0F)

        let w1 = ump.word1
        let reservedMask: UInt32 = ~(0x80030300)
        guard (w1 & reservedMask) == 0 else {
            throw MIDIError.malformedPacket("reserved bits set in function block info")
        }
        let dirRaw = UInt8((w1 >> 16) & 0x03)
        guard let dir = FunctionBlockDirection(rawValue: dirRaw) else {
            throw MIDIError.malformedPacket("invalid direction \(dirRaw)")
        }
        let bwRaw = UInt8((w1 >> 8) & 0x03)
        guard let bw = Midi1Bandwidth(rawValue: bwRaw) else {
            throw MIDIError.malformedPacket("reserved midi1Bandwidth value \(bwRaw)")
        }
        let act = (w1 & 0x80000000) != 0

        try self.init(index: idx, firstGroup: fg, groupCount: gc, active: act, direction: dir, midi1Bandwidth: bw)
    }
}
