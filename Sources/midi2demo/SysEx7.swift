import ArgumentParser
import MIDI2
import Foundation

struct SysEx7Command: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sysex7",
        abstract: "Fragment and reassemble a SysEx7 payload.",
        discussion: "Specify the target group with --group and the manufacturer ID with --manufacturer using comma-separated hex bytes. Provide the payload as hex bytes or a continuous hex string. See midi2demo(1) for examples."
    )

    @Option(name: .long, help: "Group number (0-15).")
    var group: UInt8 = 0

    @Option(name: .long, help: "Comma-separated hex bytes of the manufacturer ID.")
    var manufacturer: String

    @Argument(help: "Payload bytes as hex.")
    var payload: String

    func run() throws {
        guard let g = Uint4(group) else {
            throw ValidationError("Group out of range")
        }
        let manufacturerID = try parseManufacturer(manufacturer)
        let payloadBytes = try parsePayload(payload)

        let packets = try SysEx7.fragment(
            manufacturerID: manufacturerID,
            payload: payloadBytes,
            group: g.rawValue
        )

        for packet in packets {
            let hex = packet.map { String(format: "%02X", $0) }.joined(separator: " ")
            print(hex)
        }

        let (mfr, data) = try SysEx7.reassemble(packets)
        guard mfr == manufacturerID && data == payloadBytes else {
            throw ValidationError("Reassembled data does not match original.")
        }
        print("Round-trip OK")
    }

    private func parseManufacturer(_ string: String) throws -> [UInt8] {
        let parts = string.split(separator: ",")
        let bytes = parts.compactMap { UInt8($0, radix: 16) }
        guard bytes.count == parts.count else {
            throw ValidationError("Invalid manufacturer ID")
        }
        guard bytes.count == 1 || bytes.count == 3 else {
            throw ValidationError("Manufacturer ID must be 1 or 3 bytes")
        }
        return bytes
    }

    private func parsePayload(_ string: String) throws -> [UInt8] {
        if string.contains(" ") || string.contains(",") {
            let separators = CharacterSet(charactersIn: " ,")
            let parts = string.split { ch in
                ch.unicodeScalars.contains(where: { separators.contains($0) })
            }
            let bytes = parts.compactMap { UInt8($0, radix: 16) }
            guard bytes.count == parts.count else {
                throw ValidationError("Invalid payload hex")
            }
            guard !bytes.isEmpty else {
                throw ValidationError("Payload cannot be empty")
            }
            return bytes
        } else {
            let clean = string.trimmingCharacters(in: .whitespaces)
            guard clean.count % 2 == 0 else {
                throw ValidationError("Payload must have even number of hex digits")
            }
            var bytes: [UInt8] = []
            var index = clean.startIndex
            while index < clean.endIndex {
                let next = clean.index(index, offsetBy: 2)
                let byteStr = clean[index..<next]
                guard let byte = UInt8(byteStr, radix: 16) else {
                    throw ValidationError("Invalid payload hex")
                }
                bytes.append(byte)
                index = next
            }
            guard !bytes.isEmpty else {
                throw ValidationError("Payload cannot be empty")
            }
            return bytes
        }
    }
}

