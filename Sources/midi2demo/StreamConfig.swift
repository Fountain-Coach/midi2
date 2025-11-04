import ArgumentParser
import MIDI2
import Foundation

struct StreamConfig: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "stream-config",
        abstract: "Demonstrate UMP Stream messages (Endpoint, Config, Function Block)",
        discussion: "Creates and decodes MIDI 2.0 Stream messages (mt=0xF) using typed wrappers. This is a scaffolding command; bitfield mapping follows the spec and will be filled in progressively."
    )

    func run() throws {
        throw CleanExit.message("Run a subcommand: endpoint | configure | fb")
    }
}

struct StreamEndpoint: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "endpoint",
        abstract: "Encode/decode Endpoint Discovery stream message"
    )

    @Option(name: .long, help: "Group (0-15)")
    var group: Int = 0

    @Option(name: .long, help: "Data1 byte (0-255)")
    var data1: Int = 0

    @Option(name: .long, help: "Data2 byte (0-255)")
    var data2: Int = 0

    func run() throws {
        guard let g = Uint4(UInt8(group)), (0...255).contains(data1), (0...255).contains(data2) else {
            throw ValidationError("Invalid group or data byte")
        }
        let msg = EndpointDiscoveryMessage(data1: UInt8(data1), data2: UInt8(data2))
        let pkt = msg.ump(group: g)
        print(String(format: "UMP: 0x%08X", pkt.word))
        let parsed = try EndpointDiscoveryMessage(parsingUMP: pkt)
        print("Decoded -> data1: \(parsed.data1) data2: \(parsed.data2)")
    }
}

struct StreamConfigure: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "configure",
        abstract: "Encode/decode Stream Configuration message"
    )

    @Option(name: .long, help: "Group (0-15)")
    var group: Int = 0

    @Option(name: .long, help: "Data1 byte (0-255)")
    var data1: Int = 0

    @Option(name: .long, help: "Data2 byte (0-255)")
    var data2: Int = 0

    func run() throws {
        guard let g = Uint4(UInt8(group)), (0...255).contains(data1), (0...255).contains(data2) else {
            throw ValidationError("Invalid group or data byte")
        }
        let msg = StreamConfigurationMessage(data1: UInt8(data1), data2: UInt8(data2))
        let pkt = msg.ump(group: g)
        print(String(format: "UMP: 0x%08X", pkt.word))
        let parsed = try StreamConfigurationMessage(parsingUMP: pkt)
        print("Decoded -> data1: \(parsed.data1) data2: \(parsed.data2)")
    }
}

struct StreamFunctionBlock: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "fb",
        abstract: "Encode/decode Function Block stream message"
    )

    @Option(name: .long, help: "Group (0-15)")
    var group: Int = 0

    @Option(name: .long, help: "Data1 byte (0-255)")
    var data1: Int = 0

    @Option(name: .long, help: "Data2 byte (0-255)")
    var data2: Int = 0

    func run() throws {
        guard let g = Uint4(UInt8(group)), (0...255).contains(data1), (0...255).contains(data2) else {
            throw ValidationError("Invalid group or data byte")
        }
        let msg = FunctionBlockMessage(data1: UInt8(data1), data2: UInt8(data2))
        let pkt = msg.ump(group: g)
        print(String(format: "UMP: 0x%08X", pkt.word))
        let parsed = try FunctionBlockMessage(parsingUMP: pkt)
        print("Decoded -> data1: \(parsed.data1) data2: \(parsed.data2)")
    }
}

