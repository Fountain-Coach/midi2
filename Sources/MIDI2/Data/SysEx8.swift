import Foundation

/// Helpers for streaming SysEx8 data in UMP packets.
public enum SysEx8 {
    /// Errors thrown by the SysEx8 streaming helpers.
    public enum StreamError: Error {
        case invalidManufacturerID
        case payloadTooLong
        case invalidPacketSequence
        case wrongMessageType
    }

    private static let maxChunk = 14
    private static let maxPayloadLength = 0xFFFF

    /// Fragment a SysEx8 payload into UMP packets.
    /// - Parameters:
    ///   - manufacturerID: 1 or 3 byte manufacturer identifier.
    ///   - payload: SysEx payload bytes excluding manufacturer ID.
    ///   - group: UMP group (0-15).
    /// - Returns: Array of 16 byte UMP packets.
    public static func fragment(manufacturerID: [UInt8], payload: [UInt8], group: UInt8 = 0) throws -> [[UInt8]] {
        guard isValidManufacturerID(manufacturerID) else { throw StreamError.invalidManufacturerID }
        guard payload.count <= maxPayloadLength else { throw StreamError.payloadTooLong }

        let message = manufacturerID + payload
        var packets: [[UInt8]] = []
        var index = 0
        let totalChunks = Int(ceil(Double(message.count) / Double(maxChunk)))

        while index < message.count {
            let remaining = message.count - index
            let chunkSize = min(maxChunk, remaining)
            let chunk = Array(message[index..<index+chunkSize])
            let status: UInt8
            if totalChunks == 1 {
                status = 0x0
            } else if index == 0 {
                status = 0x1
            } else if remaining <= maxChunk {
                status = 0x3
            } else {
                status = 0x2
            }
            var packet: [UInt8] = [0x50 | (group & 0x0F), (status << 4) | UInt8(chunk.count)]
            packet.append(contentsOf: chunk)
            if chunk.count < maxChunk {
                packet.append(contentsOf: Array(repeating: 0, count: maxChunk - chunk.count))
            }
            packets.append(packet)
            index += chunkSize
        }
        return packets
    }

    /// Reassemble SysEx8 payload from UMP packets.
    /// - Parameter packets: Array of 16 byte UMP packets.
    /// - Returns: Manufacturer ID and payload.
    public static func reassemble(_ packets: [[UInt8]]) throws -> (manufacturerID: [UInt8], payload: [UInt8]) {
        guard !packets.isEmpty else { throw StreamError.invalidPacketSequence }
        var bytes: [UInt8] = []
        for (i, packet) in packets.enumerated() {
            guard packet.count == 16 else { throw StreamError.invalidPacketSequence }
            let mt = packet[0] >> 4
            guard mt == 0x5 else { throw StreamError.wrongMessageType }
            let status = packet[1] >> 4
            let count = Int(packet[1] & 0x0F)
            guard count <= maxChunk else { throw StreamError.invalidPacketSequence }
            let data = Array(packet[2..<(2 + maxChunk)]).prefix(count)
            bytes.append(contentsOf: data)

            switch status {
            case 0x0:
                if packets.count != 1 { throw StreamError.invalidPacketSequence }
            case 0x1:
                if i != 0 { throw StreamError.invalidPacketSequence }
            case 0x2:
                if i == 0 || i == packets.count - 1 { throw StreamError.invalidPacketSequence }
            case 0x3:
                if i != packets.count - 1 { throw StreamError.invalidPacketSequence }
            default:
                throw StreamError.invalidPacketSequence
            }
        }
        guard !bytes.isEmpty else { throw StreamError.invalidPacketSequence }
        let manufacturerID: [UInt8]
        let payload: [UInt8]
        if bytes[0] == 0x00 {
            guard bytes.count >= 3 else { throw StreamError.invalidManufacturerID }
            manufacturerID = Array(bytes[0..<3])
            payload = Array(bytes.dropFirst(3))
        } else {
            manufacturerID = [bytes[0]]
            payload = Array(bytes.dropFirst())
        }
        guard isValidManufacturerID(manufacturerID) else { throw StreamError.invalidManufacturerID }
        return (manufacturerID, payload)
    }

    private static func isValidManufacturerID(_ id: [UInt8]) -> Bool {
        if id.count == 1 {
            return id[0] != 0x00
        } else if id.count == 3 {
            return id[0] == 0x00
        } else {
            return false
        }
    }
}

