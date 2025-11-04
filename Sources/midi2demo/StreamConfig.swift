import ArgumentParser
import MIDI2
import Foundation

struct StreamConfig: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "stream-config",
        abstract: "Demonstrate UMP Stream messages (Endpoint, Config, Function Block)",
        discussion: "Creates and decodes MIDI 2.0 Stream messages (mt=0xF) using typed wrappers. This is a scaffolding command; bitfield mapping follows the spec and will be filled in progressively."
    )

    func run() throws { throw CleanExit.message("Run a subcommand: endpoint | configure | fb | fb-discover | handshake") }
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
        let parsed = try StreamConfigurationMessage(parsingUMP: pkt)
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
        let parsed = try FunctionBlockMessage(parsingUMP: pkt)
        print("Decoded -> data1: \(parsed.data1) data2: \(parsed.data2)")
        print("  index=\(parsed.index) firstGroup=\(parsed.firstGroup) groupCount=\(parsed.groupCount)")
    }
}

struct StreamFunctionBlockDiscover: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "fb-discover",
        abstract: "Encode/decode Function Block discovery filter bitmap"
    )

    @Option(name: .long, help: "Group (0-15)")
    var group: Int = 0

    @Option(name: .long, help: "Filter bitmap (e.g., 0x0000000F or 15)")
    var filter: String

    func run() throws {
        guard let g = Uint4(UInt8(group)) else {
            throw ValidationError("Invalid group")
        }
        // Parse decimal or hex (0x...)
        let value: UInt32
        if filter.lowercased().hasPrefix("0x") {
            let hex = String(filter.dropFirst(2))
            guard let v = UInt32(hex, radix: 16) else { throw ValidationError("Invalid hex filter value") }
            value = v
        } else {
            guard let v = UInt32(filter) else { throw ValidationError("Invalid filter value") }
            value = v
        }

        let fbDisc = FunctionBlockDiscovery(filterBitmap: value)
        let pkts = fbDisc.umps(group: g)
        for (i, pkt) in pkts.enumerated() {
            print(String(format: "FB Discover pkt%u: 0x%08X", i, pkt.word))
        }
        let parsed = try FunctionBlockDiscovery(parsingUMPs: pkts)
        print(String(format: "Decoded filter: 0x%08X", parsed.filterBitmap))
    }
}

struct StreamGTB: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "gtb",
        abstract: "Encode/decode Group Terminal Blocks using Function Block info packets"
    )

    @Option(name: .long, help: "Group (0-15)")
    var group: Int = 0

    @Argument(help: "Block specs 'index:firstGroup,count' ... (space-separated)")
    var blocks: [String] = []

    func parseBlock(_ spec: String) throws -> GroupTerminalBlock {
        let parts = spec.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { throw ValidationError("Invalid block spec: \(spec)") }
        guard let idx = UInt8(parts[0]) else { throw ValidationError("Invalid index in: \(spec)") }
        let rg = parts[1].split(separator: ",", maxSplits: 1).map(String.init)
        guard rg.count == 2, let fg = UInt8(rg[0]), let gc = UInt8(rg[1]), fg < 16, gc < 16 else {
            throw ValidationError("Invalid firstGroup,count in: \(spec)")
        }
        return GroupTerminalBlock(index: idx, firstGroup: fg, groupCount: gc)
    }

    func run() throws {
        guard let g = Uint4(UInt8(group)) else { throw ValidationError("Invalid group") }
        let blocks: [GroupTerminalBlock] = try blocks.map(parseBlock)
        let gtb = GroupTerminalBlocks(blocks: blocks)
        let pkts = gtb.umps(group: g)
        for (i, pkt) in pkts.enumerated() {
            print(String(format: "GTB pkt%u: 0x%08X", i, pkt.word))
        }
        let parsed = try GroupTerminalBlocks(parsingUMPs: pkts)
        for blk in parsed.blocks {
            print("  index=\(blk.index) firstGroup=\(blk.firstGroup) groupCount=\(blk.groupCount)")
        }
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
        let epReq = EndpointDiscoveryMessage(majorVersion: 1, minorVersion: 0, maxGroups: 8)
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
