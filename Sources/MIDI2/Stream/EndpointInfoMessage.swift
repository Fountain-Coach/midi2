import Foundation

/// Typed wrapper for Stream opcode `.endpointInfoNotification` (mt=0xF, opcode=0x01).
public struct EndpointInfoNotification: Equatable {
    public var staticFunctionBlocks: Bool
    public var numberOfFunctionBlocks: UInt8
    public var midi1Supported: Bool
    public var midi2Supported: Bool
    public var jrTimestampsRx: Bool
    public var jrTimestampsTx: Bool

    public init(
        staticFunctionBlocks: Bool = false,
        numberOfFunctionBlocks: UInt8 = 0,
        midi1Supported: Bool = false,
        midi2Supported: Bool = false,
        jrTimestampsRx: Bool = false,
        jrTimestampsTx: Bool = false
    ) throws {
        try EndpointInfoNotification.validate(numberOfFunctionBlocks: numberOfFunctionBlocks)
        self.staticFunctionBlocks = staticFunctionBlocks
        self.numberOfFunctionBlocks = numberOfFunctionBlocks
        self.midi1Supported = midi1Supported
        self.midi2Supported = midi2Supported
        self.jrTimestampsRx = jrTimestampsRx
        self.jrTimestampsTx = jrTimestampsTx
    }

    private static func validate(numberOfFunctionBlocks: UInt8) throws {
        guard numberOfFunctionBlocks <= 0x20 else {
            throw MIDIError.valueOutOfRange(name: "numberOfFunctionBlocks", value: UInt64(numberOfFunctionBlocks), range: 0...0x20)
        }
    }

    private static func decode(data1: UInt8, data2: UInt8) throws -> EndpointInfoNotification {
        let hasReservedBit = (data1 & 0x40) != 0
        guard !hasReservedBit else {
            throw MIDIError.malformedPacket("reserved bit set in endpoint info byte1")
        }
        let nfb = data1 & 0x3F
        try validate(numberOfFunctionBlocks: nfb)
        let reservedCapabilities = data2 & 0xF0
        guard reservedCapabilities == 0 else {
            throw MIDIError.malformedPacket("reserved bits set in endpoint info capability flags")
        }
        return try EndpointInfoNotification(
            staticFunctionBlocks: (data1 & 0x80) != 0,
            numberOfFunctionBlocks: nfb,
            midi1Supported: (data2 & 0x01) != 0,
            midi2Supported: (data2 & 0x02) != 0,
            jrTimestampsRx: (data2 & 0x04) != 0,
            jrTimestampsTx: (data2 & 0x08) != 0
        )
    }

    private var encodedData1: UInt8 {
        var byte: UInt8 = 0
        if staticFunctionBlocks { byte |= 0x80 }
        byte |= numberOfFunctionBlocks & 0x3F
        return byte
    }

    private var encodedData2: UInt8 {
        var byte: UInt8 = 0
        if midi1Supported { byte |= 0x01 }
        if midi2Supported { byte |= 0x02 }
        if jrTimestampsRx { byte |= 0x04 }
        if jrTimestampsTx { byte |= 0x08 }
        return byte
    }

    /// Encode to a 32-bit UMP in the given group.
    public func ump(group: Uint4) -> UmpPacket32 {
        UmpPacket32(mt: 0xF, group: group, status: StreamOpcode.endpointInfoNotification.rawValue, data1: encodedData1, data2: encodedData2)
    }

    /// Failable decode from a 32-bit UMP. Returns nil on opcode mismatch or validation failure.
    public init?(ump: UmpPacket32) {
        guard let body = StreamBody(ump: ump), body.opcode == .endpointInfoNotification else { return nil }
        do {
            self = try EndpointInfoNotification.decode(data1: body.data1, data2: body.data2)
        } catch {
            return nil
        }
    }

    /// Throwing decode from a 32-bit UMP that validates opcode and reserved bits.
    public init(parsingUMP ump: UmpPacket32) throws {
        let body = try StreamBody(parsingUMP: ump)
        guard body.opcode == .endpointInfoNotification else {
            throw MIDIError.malformedPacket("expected endpointInfoNotification opcode, got \(body.opcode)")
        }
        self = try EndpointInfoNotification.decode(data1: body.data1, data2: body.data2)
    }
}
