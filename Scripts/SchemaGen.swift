import Foundation

struct Schema: Decodable {
    struct Definition: Decodable {
        let description: String?
    }

    let defs: [String: Definition]

    enum CodingKeys: String, CodingKey {
        case defs = "$defs"
    }
}

func typeName(from rawName: String) -> String {
    let parts = rawName.split { !$0.isLetter && !$0.isNumber }
    return parts.map { part in
        part.prefix(1).uppercased() + part.dropFirst()
    }.joined()
}

let fm = FileManager.default
let baseURL = URL(fileURLWithPath: fm.currentDirectoryPath)
let schemaURL = baseURL.appendingPathComponent("midi2.full.closed.schema.json")
let sourcesURL = baseURL.appendingPathComponent("Sources/MIDI2", isDirectory: true)
let testsURL = baseURL.appendingPathComponent("Tests/MIDI2Tests", isDirectory: true)

try fm.createDirectory(at: sourcesURL, withIntermediateDirectories: true)
try fm.createDirectory(at: testsURL, withIntermediateDirectories: true)

let data = try Data(contentsOf: schemaURL)
let schema = try JSONDecoder().decode(Schema.self, from: data)

for (rawName, def) in schema.defs {
    let name = typeName(from: rawName)

    var lines: [String] = []
    if let desc = def.description {
        for line in desc.split(separator: "\n") {
            lines.append("/// \(line)")
        }
    }
    lines.append("public struct \(name) {")
    lines.append("}")
    let source = lines.joined(separator: "\n") + "\n"
    let sourceURL = sourcesURL.appendingPathComponent("\(name).swift")
    try source.write(to: sourceURL, atomically: true, encoding: .utf8)

    let testLines = [
        "import XCTest",
        "@testable import MIDI2",
        "",
        "final class \(name)Tests: XCTestCase {",
        "    func testPlaceholder() {",
        "        // TODO: Test \(name)",
        "    }",
        "}",
        ""
    ]
    let testURL = testsURL.appendingPathComponent("\(name)Tests.swift")
    try testLines.joined(separator: "\n").write(to: testURL, atomically: true, encoding: .utf8)
}

print("Generated \(schema.defs.count) definitions.")
