/// Aggregate type for Function Block discovery (mt=0xF, opcode `.functionBlockDiscovery`).
///
/// The schema models a 32‑bit `filterBitmap`. Stream messages carry only two
/// data bytes, so discovery is transported as two consecutive `.functionBlockDiscovery`
/// packets:
///  - First packet carries the high 16 bits (bits 31…16).
///  - Second packet carries the low 16 bits (bits 15…0).
///
/// Both packets use the same opcode with `data1` = high byte and `data2` = low
/// byte of their respective 16‑bit halves.
public struct FunctionBlockDiscovery: Equatable {
    public var filterBitmap: UInt32

    public init(filterBitmap: UInt32) {
        self.filterBitmap = filterBitmap
    }

    /// Encode into two UMP packets (high half, then low half).
    public func umps(group: Uint4) -> [UmpPacket32] {
        let high16 = UInt16((filterBitmap >> 16) & 0xFFFF)
        let low16 = UInt16(filterBitmap & 0xFFFF)
        let hi = StreamBody(opcode: .functionBlockDiscovery,
                             data1: UInt8((high16 >> 8) & 0xFF),
                             data2: UInt8(high16 & 0xFF)).ump(group: group)
        let lo = StreamBody(opcode: .functionBlockDiscovery,
                             data1: UInt8((low16 >> 8) & 0xFF),
                             data2: UInt8(low16 & 0xFF)).ump(group: group)
        return [hi, lo]
    }

    /// Parse from exactly two UMP packets produced by `umps(group:)`.
    public init(parsingUMPs packets: [UmpPacket32]) throws {
        guard packets.count == 2 else {
            throw MIDIError.malformedPacket("expected two packets for FB discovery")
        }
        let hiBody = try StreamBody(parsingUMP: packets[0])
        let loBody = try StreamBody(parsingUMP: packets[1])
        guard hiBody.opcode == .functionBlockDiscovery, loBody.opcode == .functionBlockDiscovery else {
            throw MIDIError.malformedPacket("invalid opcode in FB discovery sequence")
        }
        let high16 = (UInt32(hiBody.data1) << 8) | UInt32(hiBody.data2)
        let low16 = (UInt32(loBody.data1) << 8) | UInt32(loBody.data2)
        self.filterBitmap = (high16 << 16) | low16
    }
}
