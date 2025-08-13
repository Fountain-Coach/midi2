import Foundation

/// Helpers for streaming Mixed Data Set data in UMP packets.
public enum MixedDataSet {
    /// Representation of a Mixed Data Set message chunk.
    public struct Chunk: Equatable {
        public let mdsID: Uint4
        public let numberOfChunks: UInt16
        public let chunkNumber: UInt16
        public let manufacturerID: UInt16
        public let deviceID: UInt16
        public let subID1: UInt16
        public let subID2: UInt16
        public let data: [UInt8]

        public init(mdsID: Uint4,
                    numberOfChunks: UInt16,
                    chunkNumber: UInt16,
                    manufacturerID: UInt16,
                    deviceID: UInt16,
                    subID1: UInt16,
                    subID2: UInt16,
                    data: [UInt8]) {
            self.mdsID = mdsID
            self.numberOfChunks = numberOfChunks
            self.chunkNumber = chunkNumber
            self.manufacturerID = manufacturerID
            self.deviceID = deviceID
            self.subID1 = subID1
            self.subID2 = subID2
            self.data = data
        }
    }

    /// Errors thrown by the Mixed Data Set streaming helpers.
    public enum StreamError: Error {
        case payloadTooLong
        case invalidPacketSequence
        case wrongMessageType
    }

    private static let maxChunkPayload = 14
    private static let maxValidBytes = 0xFFFF

    /// Fragment a Mixed Data Set chunk into UMP packets.
    /// - Parameters:
    ///   - chunk: The chunk metadata and payload.
    ///   - group: UMP group (0-15).
    /// - Returns: Array of 16 byte UMP packets.
    public static func fragment(chunk: Chunk, group: UInt8 = 0) throws -> [[UInt8]] {
        let validBytes = 16 + chunk.data.count
        guard validBytes <= maxValidBytes else { throw StreamError.payloadTooLong }

        let mtg = 0x50 | (group & 0x0F)
        let statusId = (0x8 << 4) | chunk.mdsID.rawValue

        var header: [UInt8] = [mtg, statusId]
        header.append(UInt8((validBytes >> 8) & 0xFF))
        header.append(UInt8(validBytes & 0xFF))
        header.append(UInt8((chunk.numberOfChunks >> 8) & 0xFF))
        header.append(UInt8(chunk.numberOfChunks & 0xFF))
        header.append(UInt8((chunk.chunkNumber >> 8) & 0xFF))
        header.append(UInt8(chunk.chunkNumber & 0xFF))
        header.append(UInt8((chunk.manufacturerID >> 8) & 0xFF))
        header.append(UInt8(chunk.manufacturerID & 0xFF))
        header.append(UInt8((chunk.deviceID >> 8) & 0xFF))
        header.append(UInt8(chunk.deviceID & 0xFF))
        header.append(UInt8((chunk.subID1 >> 8) & 0xFF))
        header.append(UInt8(chunk.subID1 & 0xFF))
        header.append(UInt8((chunk.subID2 >> 8) & 0xFF))
        header.append(UInt8(chunk.subID2 & 0xFF))

        var packets: [[UInt8]] = [header]

        var index = 0
        while index < chunk.data.count {
            let remaining = chunk.data.count - index
            let size = min(maxChunkPayload, remaining)
            let chunkData = Array(chunk.data[index..<index+size])
            var packet: [UInt8] = [mtg, (0x9 << 4) | chunk.mdsID.rawValue]
            packet.append(contentsOf: chunkData)
            if size < maxChunkPayload {
                packet.append(contentsOf: Array(repeating: 0, count: maxChunkPayload - size))
            }
            packets.append(packet)
            index += size
        }

        return packets
    }

    /// Reassemble a Mixed Data Set chunk from UMP packets.
    /// - Parameter packets: Array of 16 byte UMP packets.
    /// - Returns: Chunk metadata and payload.
    public static func reassemble(_ packets: [[UInt8]]) throws -> Chunk {
        guard !packets.isEmpty else { throw StreamError.invalidPacketSequence }
        let header = packets[0]
        guard header.count == 16 else { throw StreamError.invalidPacketSequence }
        let mt = header[0] >> 4
        guard mt == 0x5 else { throw StreamError.wrongMessageType }
        let status = header[1] >> 4
        guard status == 0x8 else { throw StreamError.invalidPacketSequence }
        let mdsIdRaw = header[1] & 0x0F
        guard let mdsID = Uint4(mdsIdRaw) else { throw StreamError.invalidPacketSequence }
        let validBytes = Int(header[2]) << 8 | Int(header[3])
        guard validBytes >= 16 else { throw StreamError.invalidPacketSequence }
        let numberOfChunks = UInt16(header[4]) << 8 | UInt16(header[5])
        let chunkNumber = UInt16(header[6]) << 8 | UInt16(header[7])
        let manufacturerID = UInt16(header[8]) << 8 | UInt16(header[9])
        let deviceID = UInt16(header[10]) << 8 | UInt16(header[11])
        let subID1 = UInt16(header[12]) << 8 | UInt16(header[13])
        let subID2 = UInt16(header[14]) << 8 | UInt16(header[15])

        let expectedPayloadBytes = validBytes - 16
        let requiredPayloadPackets = (expectedPayloadBytes + maxChunkPayload - 1) / maxChunkPayload
        guard packets.count == 1 + requiredPayloadPackets else { throw StreamError.invalidPacketSequence }

        var data: [UInt8] = []
        for packet in packets.dropFirst() {
            guard packet.count == 16 else { throw StreamError.invalidPacketSequence }
            let mt2 = packet[0] >> 4
            guard mt2 == 0x5 else { throw StreamError.wrongMessageType }
            let status2 = packet[1] >> 4
            let mdsId2 = packet[1] & 0x0F
            guard status2 == 0x9, mdsId2 == mdsIdRaw else { throw StreamError.invalidPacketSequence }
            data.append(contentsOf: packet[2..<16])
        }
        guard data.count >= expectedPayloadBytes else { throw StreamError.invalidPacketSequence }
        data = Array(data.prefix(expectedPayloadBytes))

        return Chunk(mdsID: mdsID,
                     numberOfChunks: numberOfChunks,
                     chunkNumber: chunkNumber,
                     manufacturerID: manufacturerID,
                     deviceID: deviceID,
                     subID1: subID1,
                     subID2: subID2,
                     data: data)
    }
}

