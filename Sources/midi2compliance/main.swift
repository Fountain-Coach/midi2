import Foundation
import MIDI2
import MIDI2CI

struct CheckResult: Codable {
    var name: String
    var passed: Bool
    var details: [String: String]
}

struct Report: Codable {
    var summary: String
    var passed: Bool
    var checks: [CheckResult]
}

@discardableResult
func runStreamChecks(_ out: inout [CheckResult]) -> Bool {
    var allOK = true
    // Endpoint Discovery mapping: data1 [major:4][minor:4]; data2 [reserved:4][max:4]
    do {
        let epReq = EndpointDiscoveryMessage(data1: 0x12, data2: 0x08)
        let ok = (epReq.majorVersion == 0x1 && epReq.minorVersion == 0x2 && epReq.maxGroups == 0x8)
        out.append(CheckResult(name: "Stream.EndpointDiscoveryMapping", passed: ok, details: [
            "major": String(epReq.majorVersion),
            "minor": String(epReq.minorVersion),
            "maxGroups": String(epReq.maxGroups)
        ]))
        allOK = allOK && ok
    }
    // Stream Configuration mapping: bit0 notification, bit1 jrTx, bit2 jrRx, bits5–6 protocol
    do {
        let scReq = StreamConfigurationMessage(data1: 0x26, data2: 0x00)
        let ok = (scReq.isNotification == false && scReq.jrTimestampsTx == true && scReq.jrTimestampsRx == true && scReq.protocolSelection == StreamConfigurationMessage.ProtocolSelection.midi2)
        out.append(CheckResult(name: "Stream.ConfigurationMapping", passed: ok, details: [
            "isNotif": String(scReq.isNotification),
            "jrTx": String(scReq.jrTimestampsTx),
            "jrRx": String(scReq.jrTimestampsRx),
            "proto": String(describing: scReq.protocolSelection)
        ]))
        allOK = allOK && ok
    }
    // Function Block info
    do {
        let fbInfo = FunctionBlockMessage(data1: 0x01, data2: 0xA3)
        let ok = (fbInfo.index == 0x01 && fbInfo.firstGroup == 0x0A && fbInfo.groupCount == 0x03)
        out.append(CheckResult(name: "Stream.FunctionBlockInfo", passed: ok, details: [
            "index": String(fbInfo.index),
            "firstGroup": String(fbInfo.firstGroup),
            "groupCount": String(fbInfo.groupCount)
        ]))
        allOK = allOK && ok
    }
    return allOK
}

@discardableResult
func runProfileChecks(_ out: inout [CheckResult]) -> Bool {
    var allOK = true
    let sess = ProfileSession(supportedProfiles: ["/org.midi/piano"])
    let target = MidiCiProfilesBody.Target.channel
    let ch0 = [Uint4(0)!]
    // Inquiry for supported profile
    do {
        let inq = MidiCiProfilesBody(command: .inquiry, profileId: "/org.midi/piano", target: target, channels: ch0, details: [:])
        let reps = sess.handle(inq)
        let ok = reps.count == 1 && reps[0].command == .reply && (reps[0].details?["supported"] == 1)
        out.append(CheckResult(name: "Profiles.InquirySupported", passed: ok, details: ["reply": String(describing: reps.first?.command)]))
        allOK = allOK && ok
    }
    // Enable then disable
    do {
        let on = MidiCiProfilesBody(command: .setOn, profileId: "/org.midi/piano", target: target, channels: ch0, details: [:])
        let onRep = sess.handle(on)
        let off = MidiCiProfilesBody(command: .setOff, profileId: "/org.midi/piano", target: target, channels: ch0, details: [:])
        let offRep = sess.handle(off)
        let ok = (onRep.first?.command == .enabledReport && offRep.first?.command == .disabledReport)
        out.append(CheckResult(name: "Profiles.EnableDisable", passed: ok, details: [:]))
        allOK = allOK && ok
    }
    return allOK
}

@discardableResult
func runPEChecks(_ out: inout [CheckResult]) -> Bool {
    var allOK = true
    // Chunked GET/NOTIFY & session
    do {
        let payload = Array("Hello-Property-Exchange-Chunking".utf8)
        let sess = PropertyExchangeSession(initialStore: ["/clip/title": payload], maxDataPerMessage: 10)
        let getReq = PropertyExchangeBuilder.makeGet(resource: "/clip/title", requestId: 1)
        let replies = sess.handle(getReq)
        let reasm = PropertyExchangeTransaction(requestId: 1, resource: "/clip/title", encoding: .json)
        var done = false
        for r in replies { done = try reasm.ingest(reply: r) || done }
        let ok = done && reasm.buffer == payload
        out.append(CheckResult(name: "PE.GetChunkedRoundTrip", passed: ok, details: ["chunks": String(replies.count)]))
        allOK = allOK && ok
    } catch {
        out.append(CheckResult(name: "PE.GetChunkedRoundTrip", passed: false, details: ["error": String(describing: error)]))
        allOK = false
    }
    // Chunked SET with subscribe -> notify
    do {
        let payload = Array("ABCDEFGHIJ0123456789".utf8)
        let sess = PropertyExchangeSession(maxDataPerMessage: 7)
        _ = sess.handle(PropertyExchangeBuilder.makeSubscribe(resource: "/x", requestId: 7))
        // chunked set emulation
        var offset = 0, seq = 0, replies: [MidiCiPropertyExchangeBody] = []
        while offset < payload.count {
            let len = min(7, payload.count - offset)
            let chunk = Array(payload[offset..<(offset+len)])
            let header: [String: String] = ["res": "/x", "total": String(payload.count), "offset": String(offset), "length": String(len), "more": (offset+len < payload.count) ? "1" : "0"]
            let body = MidiCiPropertyExchangeBody(command: .set, requestId: 9, encoding: .json, header: header, data: chunk)
            let r = sess.handle(body)
            replies.append(contentsOf: r)
            offset += len
            seq &+= 1
        }
        let ok = replies.first?.command == .setReply && replies.first?.header["ok"] == "1" && replies.dropFirst().map{ $0.command }.allSatisfy{ $0 == .notify }
        out.append(CheckResult(name: "PE.SetChunkedSubscribeNotify", passed: ok, details: ["replies": String(replies.count)]))
        allOK = allOK && ok
    }
    return allOK
}

@discardableResult
func runJRChecks(_ out: inout [CheckResult]) -> Bool {
    var allOK = true
    let rx = JRReceiver()
    rx.ingestClock(0x0001)
    rx.ingestClock(0x0006) // +5
    rx.ingestClock(0x80006) // backward wrap (20-bit), ignored
    let abs = rx.eventTime(for: 0x80006) ?? UInt64.max
    let ok = (abs == 5)
    out.append(CheckResult(name: "JR.WrapIgnored", passed: ok, details: ["abs": String(abs)]))
    allOK = allOK && ok
    return allOK
}

@discardableResult
func runPIChecks(_ out: inout [CheckResult]) -> Bool {
    var allOK = true
    let pi = ProcessInquirySession(filters: ["noteOn": 1])
    let cap = MidiCiProcessInquiryBody(command: .capInquiry, filters: [:])
    let capRep = pi.handle(cap)
    let ok1 = (capRep?.command == .capReply)
    let rep = MidiCiProcessInquiryBody(command: .messageReport, filters: ["noteOn": 1])
    let repAck = pi.handle(rep)
    let ok2 = (repAck?.command == .messageReportReply)
    out.append(CheckResult(name: "PI.CapInquiry", passed: ok1, details: [:]))
    out.append(CheckResult(name: "PI.MessageReport", passed: ok2, details: [:]))
    allOK = allOK && ok1 && ok2
    return allOK
}

func writeReport(_ path: String, _ report: Report) throws {
    let enc = JSONEncoder()
    enc.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try enc.encode(report)
    try FileManager.default.createDirectory(atPath: (path as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
    try data.write(to: URL(fileURLWithPath: path))
}

// Entry
var exportPath = "out/report.json"
if let i = CommandLine.arguments.firstIndex(of: "--export"), i+1 < CommandLine.arguments.count {
    exportPath = CommandLine.arguments[i+1]
}

var checks: [CheckResult] = []
let okStream = runStreamChecks(&checks)
let okProfiles = runProfileChecks(&checks)
let okPE = runPEChecks(&checks)
let okJR = runJRChecks(&checks)
let okPI = runPIChecks(&checks)

let passed = okStream && okProfiles && okPE && okJR && okPI
let summary = passed ? "PASS" : "FAIL"
let report = Report(summary: summary, passed: passed, checks: checks)
do {
    try writeReport(exportPath, report)
    print("[midi2compliance] Report written to \(exportPath)")
} catch {
    fputs("Failed to write report: \(error)\n", stderr)
    exit(2)
}
exit(passed ? 0 : 1)
