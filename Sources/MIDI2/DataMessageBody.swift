import Foundation

/// Body payload for UMP Data Messages (message type ``0x5``).
///
/// This implementation currently supports SysEx8 and Mixed Data Set transfers.
public enum DataMessageBody: Equatable {
    /// SysEx8 payload consisting of manufacturer ID and data bytes.
    case sysex8(manufacturerID: [UInt8], data: [UInt8])
    /// Mixed Data Set chunk consisting of header fields and payload.
    case mds(MixedDataSet.Chunk)

    /// Kind of data message.
    public var kind: DataMessageKind {
        switch self {
        case .sysex8: return .sysex8
        case .mds: return .mds
        }
    }

    /// Encodes the body into an array of ``UmpPacket128`` packets using the
    /// supplied group.
    public func umpPackets(group: Uint4) throws -> [UmpPacket128] {
        switch self {
        case let .sysex8(mfr, data):
            let packets = try SysEx8.fragment(manufacturerID: mfr, payload: data, group: group.rawValue)
            return packets.compactMap { UmpPacket128(rawBytes: $0) }
        case let .mds(chunk):
            let packets = try MixedDataSet.fragment(chunk: chunk, group: group.rawValue)
            return packets.compactMap { UmpPacket128(rawBytes: $0) }
        }
    }

    /// Decodes a SysEx8 body from an array of ``UmpPacket128`` packets.
    /// Returns `nil` if the packets do not form a valid SysEx8 transfer.
    public init?(sysex8Packets packets: [UmpPacket128]) {
        let raw = packets.map { $0.rawBytes }
        guard let (mfr, payload) = try? SysEx8.reassemble(raw) else { return nil }
        self = .sysex8(manufacturerID: mfr, data: payload)
    }

    /// Decodes a Mixed Data Set body from an array of ``UmpPacket128`` packets.
    /// Returns `nil` if the packets do not form a valid Mixed Data Set chunk.
    public init?(mdsPackets packets: [UmpPacket128]) {
        let raw = packets.map { $0.rawBytes }
        guard let chunk = try? MixedDataSet.reassemble(raw) else { return nil }
        self = .mds(chunk)
    }
}

