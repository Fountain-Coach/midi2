import Foundation

/// The bounded, sans-I/O UDP command framing defined by M2-124-UM v1.0.1
/// sections 5.1-5.6. The wire codec is not a session implementation, a
/// discovery mechanism, or a claim of peer interoperability.
public enum NetworkMidi2PacketError: Error, Equatable, Sendable {
    case invalidSignature
    case truncatedCommand
    case invalidPacketLength
    case commandPayloadTooLarge
    case udpPacketTooLarge
    case invalidEndpointName
    case invalidProductInstanceID
}

public struct NetworkMidi2Command: Equatable, Sendable {
    public let code: UInt8
    public let specificData: UInt16
    /// The complete command payload, in 32-bit network-byte-order words.
    /// For code 0xFF, these are UMP words, whose message boundaries must be
    /// verified by the owning UMP runtime before dispatch.
    public let payload: [UInt32]

    public init(code: UInt8, specificData: UInt16 = 0, payload: [UInt32] = []) throws {
        guard payload.count <= 255 else { throw NetworkMidi2PacketError.commandPayloadTooLarge }
        // M2-124-UM v1.0.1 section 7.1: at most 64 UMP words per command.
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
    public static let signature: UInt32 = 0x4D49_4449 // "MIDI"
    /// Source section 5.1.1 recommends a datagram not exceeding 1400 bytes.
    public static let maximumEmissionBytes = 1400

    /// Encode one or more command packets behind the single UDP signature.
    /// This method has no socket, session, authentication or instrument authority.
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

    /// Decode a datagram into framing-level commands without dispatching them.
    /// Unknown commands are preserved for the future session layer to NAK.
    /// As required by section 5.3, reserved fields and trailing command words
    /// remain available instead of being treated as framing errors.
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
            let payloadWordCount = Int(bytes[offset + 1])
            let specificData = UInt16(bytes[offset + 2]) << 8 | UInt16(bytes[offset + 3])
            offset += 4
            let payloadBytes = payloadWordCount * 4
            guard bytes.count - offset >= payloadBytes else {
                throw NetworkMidi2PacketError.truncatedCommand
            }
            var words: [UInt32] = []
            words.reserveCapacity(payloadWordCount)
            for index in 0..<payloadWordCount {
                words.append(readWord(bytes, at: offset + index * 4))
            }
            offset += payloadBytes
            commands.append(try NetworkMidi2Command(
                code: code, specificData: specificData, payload: words
            ))
        }
        return commands
    }

    /// M2-124-UM v1.0.1 section 6.4, table 10: non-empty UMP endpoint
    /// name (UTF-8, at most 98 bytes) and product instance ID
    /// (ASCII 32...126, at most 42 bytes).
    public static func invitation(
        endpointName: String, productInstanceID: String, capabilities: UInt8 = 0
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
        let nameWords = nameBytes.count / 4
        let specificData = UInt16(nameWords) << 8 | UInt16(capabilities)
        return try NetworkMidi2Command(
            code: 0x01,
            specificData: specificData,
            payload: words(from: nameBytes + productBytes)
        )
    }

    /// Section 7.1: sequence belongs to the sender's established session.
    /// Validation of whole UMP messages and ordering belongs to the runtime.
    public static func umpData(sequenceNumber: UInt16, words: [UInt32]) throws -> NetworkMidi2Command {
        try NetworkMidi2Command(code: 0xFF, specificData: sequenceNumber, payload: words)
    }

    private static func padToWord(_ bytes: inout [UInt8]) {
        while bytes.count % 4 != 0 { bytes.append(0) }
    }

    private static func words(from bytes: [UInt8]) -> [UInt32] {
        stride(from: 0, to: bytes.count, by: 4).map { readWord(bytes, at: $0) }
    }

    private static func readWord(_ bytes: [UInt8], at index: Int) -> UInt32 {
        UInt32(bytes[index]) << 24 |
        UInt32(bytes[index + 1]) << 16 |
        UInt32(bytes[index + 2]) << 8 |
        UInt32(bytes[index + 3])
    }

    private static func append(_ word: UInt32, to bytes: inout [UInt8]) {
        bytes.append(UInt8((word >> 24) & 0xFF))
        bytes.append(UInt8((word >> 16) & 0xFF))
        bytes.append(UInt8((word >> 8) & 0xFF))
        bytes.append(UInt8(word & 0xFF))
    }
}
