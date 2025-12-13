import Foundation

/// Simple representation of a USB GTB descriptor subset for allowed message types per group.
/// This is a local, config-driven source to seed GTB context; it does not alter UMP payloads.
public struct GtbDescriptor: Codable {
    public var groups: [UInt8: Set<UInt8>] = [:]

    public init(groups: [UInt8: Set<UInt8>] = [:]) {
        self.groups = groups
    }

    /// Convenience initializer from a dictionary of group -> array of MT nibbles.
    public init(raw: [UInt8: [UInt8]]) {
        var map: [UInt8: Set<UInt8>] = [:]
        for (g, mts) in raw {
            map[g & 0x0F] = Set(mts.map { $0 & 0x0F })
        }
        self.groups = map
    }

    enum CodingKeys: String, CodingKey {
        case groups
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let groupsContainer = try container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .groups)
        var parsed: [UInt8: Set<UInt8>] = [:]
        for key in groupsContainer.allKeys {
            let group = try Self.parseNibble(from: key.stringValue, label: "group")
            let mts = try groupsContainer.decode([GtbMessageTypeValue].self, forKey: key)
            parsed[group] = Set(mts.map { $0.value })
        }
        groups = parsed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var groupsContainer = container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .groups)
        for (group, mts) in groups {
            guard let key = DynamicCodingKeys(stringValue: String(group)) else { continue }
            try groupsContainer.encode(Array(mts).sorted(), forKey: key)
        }
    }

    /// Load a descriptor from JSON data (shape: `{ "groups": { "0": ["0xf", 5] } }`).
    public static func load(jsonData: Data) throws -> GtbDescriptor {
        do {
            return try JSONDecoder().decode(GtbDescriptor.self, from: jsonData)
        } catch {
            throw MIDIError.malformedPacket("Failed to decode GTB descriptor JSON: \(error.localizedDescription)")
        }
    }

    /// Load a descriptor from a JSON file URL.
    public static func load(from url: URL) throws -> GtbDescriptor {
        let data = try Data(contentsOf: url)
        return try load(jsonData: data)
    }

    private static func parseNibble(from text: String, label: String) throws -> UInt8 {
        let cleaned = text.lowercased()
        let radix: Int = cleaned.hasPrefix("0x") ? 16 : 10
        guard let value = UInt8(cleaned.replacingOccurrences(of: "0x", with: ""), radix: radix) else {
            throw MIDIError.malformedPacket("Invalid \(label) value '\(text)' in GTB descriptor JSON")
        }
        return value & 0x0F
    }
}

private struct GtbMessageTypeValue: Codable {
    let value: UInt8

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let num = try? container.decode(UInt8.self) {
            value = num & 0x0F
            return
        }
        let str = try container.decode(String.self)
        let cleaned = str.lowercased()
        let radix: Int = cleaned.hasPrefix("0x") ? 16 : 10
        guard let parsed = UInt8(cleaned.replacingOccurrences(of: "0x", with: ""), radix: radix) else {
            throw MIDIError.malformedPacket("Invalid MT value '\(str)' in GTB descriptor JSON")
        }
        value = parsed & 0x0F
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Int(value))
    }
}

private struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
