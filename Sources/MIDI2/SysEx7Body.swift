/// 7-bit clean stream framed in 32-bit UMP words (up to 6 bytes per word).
public struct SysEx7Body: Equatable {
    /// Ordered packets forming the SysEx7 transfer.
    public var packets: [SysEx7Packet]

    /// Creates a body from already constructed packets.
    public init(packets: [SysEx7Packet]) {
        self.packets = packets
    }

    /// Creates a body by encoding a manufacturer ID and payload into SysEx7 packets.
    /// - Parameters:
    ///   - manufacturerID: 1- or 3-byte manufacturer identifier.
    ///   - payload: SysEx payload bytes excluding manufacturer ID.
    ///   - group: UMP group for all resulting packets.
    /// - Throws: ``SysEx7.StreamError`` if the manufacturer ID or payload are invalid.
    public init(manufacturerID: [UInt8], payload: [UInt8], group: Uint4) throws {
        let raw = try SysEx7.fragment(manufacturerID: manufacturerID, payload: payload, group: group.rawValue)
        self.packets = try raw.map { try SysEx7Packet(parsing: $0) }
    }

    /// Raw 8-byte packets.
    public var rawPackets: [[UInt8]] { packets.map { $0.rawBytes } }

    /// Packets as ``UmpPacket64`` values.
    public var umps: [UmpPacket64] { packets.map { $0.ump } }

    /// Creates a body from raw 8-byte packets. Fails if any packet is invalid.
    public init?(rawPackets: [[UInt8]]) {
        var result: [SysEx7Packet] = []
        result.reserveCapacity(rawPackets.count)
        for bytes in rawPackets {
            guard let pkt = SysEx7Packet(rawBytes: bytes) else { return nil }
            result.append(pkt)
        }
        self.packets = result
    }

    /// Creates a body from UMP packets. Fails if any packet is invalid.
    public init?(umps: [UmpPacket64]) {
        self.init(rawPackets: umps.map { $0.rawBytes })
    }

    /// Reassembles the manufacturer ID and payload from the contained packets.
    /// - Returns: Manufacturer ID and payload bytes.
    /// - Throws: ``SysEx7.StreamError`` if the packet sequence is malformed.
    public func manufacturerAndPayload() throws -> (manufacturerID: [UInt8], payload: [UInt8]) {
        try SysEx7.reassemble(rawPackets)
    }
}

