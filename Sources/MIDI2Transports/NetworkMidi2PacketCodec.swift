import Foundation

/// Bounded framing for M2-124-UM v1.0.1, sections 5.1-5.5 (pp. 21-24),
/// section 6.4 (pp. 27-29), section 7.1 (p. 42) and Appendix A.1 (pp. 51-52).
///
/// This is not NetworkMidi2Session: no socket, discovery, authorization,
/// session admission, FEC, retransmit or hardware interoperability is claimed.
public enum NetworkMidi2PacketError: Error, Equatable, Sendable {
    case invalidSignature
    case truncatedCommand
    case invalidPacketLength
    case commandPayloadTooLarge
    case udpPacketTooLarge
    case invalidEndpointName
    case invalidProductInstanceID
    case invalidInvitationCapabilities
}

public struct NetworkMidi2Command: Equatable, Sendable {
    public let code: UInt8
    public let specificData: UInt16
    /// Payload in network-order 32-bit words. For 0xFF, UMP message boundaries
    /// must be verified by the owning UMP runtime before dispatch.
    public let payload: [UInt32]

    public init(code: UInt8, specificData: UInt16 = 0, payload: [UInt32] = []) throws {
        guard payload.count <= 255 else { throw NetworkMidi2PacketError.commandPayloadTooLarge }
        // §7.1 limits each UMP Data command to 64 32-bit words.
        guard code != 0xFF || payload.count <= 64 else {
            throw NetworkMidi2PacketError.commandPayloadTooLarge
        }
        self.code = code
        self.specificData = specificData
        self.payload = payload
    }

    public var umpSequenceNumber: UInt16? { code == 0xFF ? specificData : nil }
}

public enum NetworkMidi2PacketCodec {
    /// §5.2: big-endian "MIDI" signature exactly once per UDP payload.
    public static let signature: UInt32 = 0x4D49_4449
    /// §5.1.1 recommends a 1400-byte UDP limit. This is sender policy, not a SHALL receiver limit.
    public static let maximumEmissionBytes = 1400

    public static func encode(_ commands: [NetworkMidi2Command]) throws -> Data {
        var bytes: [UInt8] = []
        bytes.reserveCapacity(4 + commands.reduce(0) { $0 + 4 + $1.payload.count * 4 })
        append(signature, to: &bytes)
        for command in commands {
            bytes.append(command.code)
            bytes.append(UInt8(command.payload.count))
            bytes.append(UInt8((command.specificData >> 8) & 0xFF))
            bytes.append(UInt8(command.specificData & 0xFF))
            for word in command.payload { append(word, to: &bytes) }
        }
        guard bytes.count <= maximumEmissionBytes else {
            throw NetworkMidi2PacketError.udpPacketTooLarge
        }
        return Data(bytes)
    }

    /// Preserves unknown command codes and reserved words for the future
    /// session layer. The codec itself cannot issue the §5.5 NAK.
    public static func decode(_ datagram: Data) throws -> [NetworkMidi2Command] {
        let bytes = Array(datagram)
        guard bytes.count >= 4 else { throw NetworkMidi2PacketError.invalidPacketLength }
        guard readWord(bytes, at: 0) == signature else {
            throw NetworkMidi2PacketError.invalidSignature
        }
        var commands: [NetworkMidi2Command] = []
        var offset = 4
        while offset < bytes.count {
            guard bytes.count - offset >= 4 else {
                throw NetworkMidi2PacketError.truncatedCommand
            }
            let code = bytes[offset]
            let count = Int(bytes[offset + 1])
            guard code != 0xFF || count <= 64 else {
                throw NetworkMidi2PacketError.commandPayloadTooLarge
            }
            let specificData = UInt16(bytes[offset + 2]) << 8 | UInt16(bytes[offset + 3])
            offset += 4
            guard bytes.count - offset >= count * 4 else {
                throw NetworkMidi2PacketError.truncatedCommand
            }
            var words: [UInt32] = []
            words.reserveCapacity(count)
            for i in 0..<count { words.append(readWord(bytes, at: offset + i * 4)) }
            offset += count * 4
            commands.append(try NetworkMidi2Command(
                code: code, specificData: specificData, payload: words
            ))
        }
        return commands
    }

    /// §6.4 Table 10 and §6.5 Table 12. Identity encoding is reusable for
    /// invitation and accepted reply. Authentication and permission remain elsewhere.
    private static func endpointIdentity(
        code: UInt8, endpointName: String, productInstanceID: String,
        capabilities: UInt8 = 0
    ) throws -> NetworkMidi2Command {
        let name = Array(endpointName.utf8)
        guard !name.isEmpty, name.count <= 98, !name.contains(0) else {
            throw NetworkMidi2PacketError.invalidEndpointName
        }
        let product = Array(productInstanceID.utf8)
        guard !product.isEmpty, product.count <= 42,
              product.allSatisfy({ (32...126).contains(Int($0)) }) else {
            throw NetworkMidi2PacketError.invalidProductInstanceID
        }
        var nameBytes = name
        padToWord(&nameBytes)
        var productBytes = product
        padToWord(&productBytes)
        let specificData = UInt16(nameBytes.count / 4) << 8 |
            UInt16(code == 0x01 ? capabilities : 0)
        return try NetworkMidi2Command(
            code: code, specificData: specificData,
            payload: words(from: nameBytes + productBytes)
        )
    }

    public static func invitation(
        endpointName: String, productInstanceID: String, capabilities: UInt8 = 0
    ) throws -> NetworkMidi2Command {
        // §6.4 Table 11: only bit 0 and bit 1 are defined; D2-D7 are reserved.
        guard capabilities & 0xFC == 0 else {
            throw NetworkMidi2PacketError.invalidInvitationCapabilities
        }
        return try endpointIdentity(
            code: 0x01, endpointName: endpointName,
            productInstanceID: productInstanceID, capabilities: capabilities
        )
    }

    /// Decode the invitation/accepted/pending identity from M2-124-UM v1.0.1,
    /// tables 10, 12, and 13. Network permission is not decided here.
    public static func endpointIdentity(
        from command: NetworkMidi2Command
    ) throws -> (name: String, productID: String) {
        guard command.code == 0x01 || command.code == 0x10 || command.code == 0x11 else {
            throw NetworkMidi2PacketError.invalidEndpointName
        }
        let nameWordCount = Int(command.specificData >> 8)
        guard (1...25).contains(nameWordCount),
              command.payload.count >= nameWordCount + 1,
              command.payload.count <= 36 else {
            throw NetworkMidi2PacketError.invalidEndpointName
        }
        var bytes: [UInt8] = []
        for word in command.payload {
            bytes.append(UInt8((word >> 24) & 0xFF))
            bytes.append(UInt8((word >> 16) & 0xFF))
            bytes.append(UInt8((word >> 8) & 0xFF))
            bytes.append(UInt8(word & 0xFF))
        }
        func unpad(_ buffer: [UInt8]) -> [UInt8]? {
            guard let null = buffer.firstIndex(of: 0) else { return buffer }
            guard buffer[null...].allSatisfy({ $0 == 0 }) else { return nil }
            return Array(buffer[..<null])
        }
        guard let nameBytes = unpad(Array(bytes.prefix(nameWordCount * 4))),
              !nameBytes.isEmpty, nameBytes.count <= 98,
              let name = String(bytes: nameBytes, encoding: .utf8) else {
            throw NetworkMidi2PacketError.invalidEndpointName
        }
        guard let productBytes = unpad(Array(bytes.dropFirst(nameWordCount * 4))),
              !productBytes.isEmpty, productBytes.count <= 42,
              productBytes.allSatisfy({ (32...126).contains(Int($0)) }),
              let productID = String(bytes: productBytes, encoding: .ascii) else {
            throw NetworkMidi2PacketError.invalidProductInstanceID
        }
        return (name, productID)
    }

    public static func umpData(
        sequenceNumber: UInt16, words: [UInt32]
    ) throws -> NetworkMidi2Command {
        try NetworkMidi2Command(code: 0xFF, specificData: sequenceNumber, payload: words)
    }

    private static func padToWord(_ bytes: inout [UInt8]) {
        while bytes.count % 4 != 0 { bytes.append(0) }
    }

    private static func words(from bytes: [UInt8]) -> [UInt32] {
        stride(from: 0, to: bytes.count, by: 4).map { readWord(bytes, at: $0) }
    }

    private static func readWord(_ bytes: [UInt8], at i: Int) -> UInt32 {
        UInt32(bytes[i]) << 24 |
        UInt32(bytes[i + 1]) << 16 |
        UInt32(bytes[i + 2]) << 8 |
        UInt32(bytes[i + 3])
    }

    private static func append(_ word: UInt32, to bytes: inout [UInt8]) {
        bytes.append(UInt8((word >> 24) & 0xFF))
        bytes.append(UInt8((word >> 16) & 0xFF))
        bytes.append(UInt8((word >> 8) & 0xFF))
        bytes.append(UInt8(word & 0xFF))
    }
}
