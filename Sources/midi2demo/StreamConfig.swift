import ArgumentParser
import MIDI2
import Foundation

struct StreamConfig: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "stream-config",
        abstract: "Demonstrate UMP Stream messages (Endpoint, Config, Function Block)",
        discussion: "Creates and decodes MIDI 2.0 Stream messages (mt=0xF) using typed wrappers. This is a scaffolding command; bitfield mapping follows the spec and will be filled in progressively."
    )

    func run() throws { throw CleanExit.message("Run a subcommand: endpoint | configure | fb | handshake") }
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
        var parsed = try EndpointDiscoveryMessage(parsingUMP: pkt)
        print("Decoded -> data1: \(parsed.data1) data2: \(parsed.data2)")
        print("  major=\(parsed.majorVersion) minor=\(parsed.minorVersion) maxGroups=\(parsed.maxGroups)")
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
        var parsed = try StreamConfigurationMessage(parsingUMP: pkt)
        print("Decoded -> data1: \(parsed.data1) data2: \(parsed.data2)")
        print("  isNotification=\(parsed.isNotification) jrTx=\(parsed.jrTimestampsTx) jrRx=\(parsed.jrTimestampsRx) proto=\(parsed.protocolSelection == .midi2 ? "midi2" : "midi1")")
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
        var parsed = try FunctionBlockMessage(parsingUMP: pkt)
        print("Decoded -> data1: \(parsed.data1) data2: \(parsed.data2)")
        print("  index=\(parsed.index) firstGroup=\(parsed.firstGroup) groupCount=\(parsed.groupCount)")
    }
}

struct StreamHandshake: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "handshake",
        abstract: "Simulate a stream config handshake (endpoint → configure → function block)"
    )

    @Option(name: .long, help: "Group (0-15)")
    var group: Int = 0

    func run() throws {
        guard let g = Uint4(UInt8(group)) else { throw ValidationError("Invalid group") }

        // 1) Endpoint Discovery (initiator → responder)
        var epReq = EndpointDiscoveryMessage(majorVersion: 1, minorVersion: 0, maxGroups: 8)
        let epPkt = epReq.ump(group: g)
        print(String(format: "Endpoint Discovery (req): 0x%08X", epPkt.word))
        print("  major=\(epReq.majorVersion) minor=\(epReq.minorVersion) maxGroups=\(epReq.maxGroups)")

        // 2) Stream Configuration Request (initiator → responder)
        let scReq = StreamConfigurationMessage(isNotification: false,
                                               jrTimestampsTx: true,
                                               jrTimestampsRx: true,
                                               protocolSelection: .midi2)
        let scReqPkt = scReq.ump(group: g)
        print(String(format: "Stream Config (req):    0x%08X", scReqPkt.word))
        let scReqParsed = try StreamConfigurationMessage(parsingUMP: scReqPkt)
        print("  isNotification=\(scReqParsed.isNotification) jrTx=\(scReqParsed.jrTimestampsTx) jrRx=\(scReqParsed.jrTimestampsRx) proto=\(scReqParsed.protocolSelection == .midi2 ? "midi2" : "midi1")")

        // 3) Stream Configuration Notification (responder → initiator)
        let scReply = StreamConfigurationMessage(isNotification: true,
                                                 jrTimestampsTx: true,
                                                 jrTimestampsRx: true,
                                                 protocolSelection: .midi2)
        let scPkt = scReply.ump(group: g)
        print(String(format: "Stream Config (reply):  0x%08X", scPkt.word))
        let scParsed = try StreamConfigurationMessage(parsingUMP: scPkt)
        print("  isNotification=\(scParsed.isNotification) jrTx=\(scParsed.jrTimestampsTx) jrRx=\(scParsed.jrTimestampsRx) proto=\(scParsed.protocolSelection == .midi2 ? "midi2" : "midi1")")

        // 4) Function Block information (responder → initiator)
        // Example: two function blocks
        let fbInfo = FunctionBlockMessage(index: 0x00, firstGroup: 0x0, groupCount: 0x4)
        let fbPkt = fbInfo.ump(group: g)
        print(String(format: "Function Block (info):  0x%08X", fbPkt.word))
        print("  index=\(fbInfo.index) firstGroup=\(fbInfo.firstGroup) groupCount=\(fbInfo.groupCount)")

        let fbInfo2 = FunctionBlockMessage(index: 0x01, firstGroup: 0x4, groupCount: 0x4)
        let fbPkt2 = fbInfo2.ump(group: g)
        print(String(format: "Function Block (info):  0x%08X", fbPkt2.word))
        print("  index=\(fbInfo2.index) firstGroup=\(fbInfo2.firstGroup) groupCount=\(fbInfo2.groupCount)")
    }
}
