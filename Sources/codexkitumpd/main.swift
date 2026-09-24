import Foundation
#if os(Linux)
@preconcurrency import UMPALSA
import MIDI2
import MIDI2CI
import MIDI2Transports
import FountainCodexLaneKit

private let instrumentID = "fountaincoach.codexkit@0.1.0"
private let instrumentVersion = "1"
private let instrumentResource = "midi-ci/property-exchange/instrument-profile"
private let operations = [
    "codex/account.status", "codex/thread.list", "codex/thread.create", "codex/thread.resume",
    "codex/thread.inspect", "codex/turn.submit", "codex/turn.cancel", "codex/approval.respond",
    "codex/session.status", "codex/session.resume"
]

struct FlexEnvelope: Codable {
    let v: Int
    let ts: UInt64
    let corr: String
    let intent: String
    let body: JSONValue
}

struct WireEnvelope: Codable {
    let topic: String
    let schemaVersion: String
    let correlationId: String
    let timestamp: UInt64
    let qos: String
    let sessionId: String
    let capabilityMask: UInt64
    let resumeToken: String?
    let ttlMs: UInt32?
    let payload: [String: String]
    let arguments: [String: String]?
}

struct RuntimeResult {
    let phase: String
    let summary: String
    let threadID: String?
    let turnID: String?
}

actor CodexKitRuntime {
    private let instrument: CodexKitInstrument
    private var events: AsyncStream<CodexKitEvent>?
    private var threadID: String?

    init(executable: URL, codexHome: URL, runtimeDigest: String, protocolRevision: String) {
        instrument = CodexKitInstrument(
            descriptor: CodexRuntimeDescriptor(
                executableURL: executable,
                protocolRevision: protocolRevision,
                runtimeDigest: runtimeDigest,
                codexHome: codexHome),
            instrumentID: instrumentID,
            laneID: "codex")
    }

    func start() async throws {
        guard events == nil else { return }
        events = await instrument.events()
        try await instrument.start()
    }

    func execute(_ request: WireEnvelope) async throws -> RuntimeResult {
        try await start()
        let operation = request.payload["operation"] ?? ""
        let correlation = request.correlationId
        let execution = request.payload["executionId"] ?? correlation
        switch operation {
        case "codex/account.status":
            let result = try await instrument.request(method: "account/read", params: [
                "refreshToken": .bool(request.payload["refresh"] == "true")
            ], operation: operation, correlationID: correlation, executionID: execution)
            return RuntimeResult(phase: "succeeded", summary: "Codex account status returned (redacted).", threadID: nil, turnID: nil)
        case "codex/thread.list":
            _ = try await instrument.request(method: "thread/list", params: [:], operation: operation, correlationID: correlation, executionID: execution)
            return RuntimeResult(phase: "succeeded", summary: "Codex thread list returned.", threadID: nil, turnID: nil)
        case "codex/thread.create":
            var params: [String: JSONValue] = ["experimentalRawEvents": .bool(false)]
            if let cwd = request.payload["cwd"], !cwd.isEmpty { params["cwd"] = .string(cwd) }
            let result = try await instrument.request(method: "thread/start", params: params, operation: operation, correlationID: correlation, executionID: execution)
            let id = object(result["thread"])?["id"].flatMap(string)
            threadID = id
            return RuntimeResult(phase: "succeeded", summary: "Codex thread created.", threadID: id, turnID: nil)
        case "codex/thread.resume":
            let id = try require(request.payload["threadId"], name: "threadId")
            var params: [String: JSONValue] = ["threadId": .string(id)]
            if let token = request.payload["resumeToken"], !token.isEmpty { params["resumeToken"] = .string(token) }
            let result = try await instrument.request(method: "thread/resume", params: params, operation: operation, correlationID: correlation, executionID: execution)
            let resumed = object(result["thread"])?["id"].flatMap(string) ?? id
            threadID = resumed
            return RuntimeResult(phase: "resumed", summary: "Codex thread resumed.", threadID: resumed, turnID: nil)
        case "codex/thread.inspect":
            let id = try require(request.payload["threadId"], name: "threadId")
            _ = try await instrument.request(method: "thread/read", params: ["threadId": .string(id)], operation: operation, correlationID: correlation, executionID: execution)
            return RuntimeResult(phase: "succeeded", summary: "Codex thread inspected.", threadID: id, turnID: nil)
        case "codex/approval.respond":
            let id = try require(request.payload["approvalId"], name: "approvalId")
            let decision = try require(request.payload["decision"], name: "decision")
            guard decision == "approve" || decision == "reject" else { throw RuntimeError.invalid("decision") }
            _ = try await instrument.request(method: "approval/respond", params: ["requestId": .string(id), "decision": .string(decision)], operation: operation, correlationID: correlation, executionID: execution)
            return RuntimeResult(phase: "succeeded", summary: "Codex approval response submitted.", threadID: nil, turnID: nil)
        case "codex/session.status":
            return RuntimeResult(phase: "succeeded", summary: "Codex session is started=(events != nil).", threadID: threadID, turnID: nil)
        case "codex/session.resume":
            let id = request.payload["threadId"]
            if let id, !id.isEmpty {
                _ = try await instrument.request(method: "thread/resume", params: ["threadId": .string(id)], operation: operation, correlationID: correlation, executionID: execution)
                threadID = id
            }
            return RuntimeResult(phase: "resumed", summary: "Codex session resumed.", threadID: threadID, turnID: nil)
        case "codex/turn.submit":
            let prompt = try require(request.payload["prompt"], name: "prompt")
            let id = threadID ?? {
                return nil
            }()
            if id == nil {
                let created = try await instrument.request(method: "thread/start", params: ["experimentalRawEvents": .bool(false)], operation: "codex/thread.create", correlationID: correlation, executionID: execution)
                threadID = object(created["thread"])?["id"].flatMap(string)
            }
            guard let thread = threadID else { throw RuntimeError.invalid("thread unavailable") }
            let started = try await instrument.request(method: "turn/start", params: [
                "threadId": .string(thread),
                "input": .array([.object(["type": .string("text"), "text": .string(prompt)])])
            ], operation: operation, correlationID: correlation, executionID: execution)
            guard let turn = object(started["turn"]), let turnID = string(turn["id"]) else { throw RuntimeError.invalid("turn response") }
            guard let stream = events else { throw RuntimeError.invalid("event stream") }
            for await event in stream {
                guard event.method == "turn/completed", let params = object(event.payload["params"]),
                      string(params["threadId"]) == thread, let completed = object(params["turn"]),
                      string(completed["id"]) == turnID else { continue }
                let text = agentMessageText(completed["items"])
                guard !text.isEmpty else { throw RuntimeError.invalid("empty agent message") }
                return RuntimeResult(phase: "succeeded", summary: text, threadID: thread, turnID: turnID)
            }
            throw RuntimeError.invalid("event stream ended")
        case "codex/turn.cancel":
            let thread = try require(request.payload["threadId"], name: "threadId")
            let turn = try require(request.payload["turnId"], name: "turnId")
            _ = try await instrument.request(method: "turn/interrupt", params: ["threadId": .string(thread), "turnId": .string(turn)], operation: operation, correlationID: correlation, executionID: execution)
            return RuntimeResult(phase: "canceled", summary: "Codex turn cancellation submitted.", threadID: thread, turnID: turn)
        default:
            throw RuntimeError.invalid("unsupported operation")
        }
    }

    private func object(_ value: JSONValue?) -> [String: JSONValue]? { guard case .object(let value)? = value else { return nil }; return value }
    private func string(_ value: JSONValue?) -> String? { guard case .string(let value)? = value else { return nil }; return value }
    private func require(_ value: String?, name: String) throws -> String { guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw RuntimeError.invalid("missing (name)") }; return value }
    private func agentMessageText(_ value: JSONValue?) -> String { guard case .array(let items)? = value else { return "" }; return items.compactMap { item in guard case .object(let object) = item, string(object["type"]) == "agentMessage" else { return nil }; return string(object["text"]) }.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) }
}

enum RuntimeError: Error { case invalid(String) }

@MainActor
final class InstrumentHost {
    let session: RTPMidiSession
    let runtime: CodexKitRuntime
    let profile: Data
    var sysex: [UInt8: [UmpPacket128]] = [:]

    init(runtime: CodexKitRuntime, session: RTPMidiSession) {
        self.runtime = runtime
        self.session = session
        profile = (try? JSONSerialization.data(withJSONObject: [
            "identity": instrumentID, "version": instrumentVersion, "displayName": "Remote CodexKit",
            "role": "governed remote Codex execution peer", "operations": operations,
            "invokeTopic": "reframe/capability.invoke", "traits": [
                "midi-ci-discovery", "property-exchange", "rtp-midi2", "typed-lifecycle",
                "correlated-session", "disconnect-resume", "app-server-boundary", "store-evidence-required"
            ], "softwarePeer": true, "propertyExchangeResource": instrumentResource
        ])) ?? Data()
    }

    func receive(_ words: [UInt32]) {
        guard let first = words.first else { return }
        let group = UInt8((first >> 24) & 0xF)
        let type = UInt8((first >> 28) & 0xF)
        if type == 0xF, words.count == 1 { handleStream(group: group, word: first); return }
        guard type == 0x5, words.count.isMultiple(of: 4) else { return }
        for index in stride(from: 0, to: words.count, by: 4) {
            guard let packet = UmpPacket128(words: Array(words[index..<(index + 4)])) else { continue }
            var packets = sysex[group] ?? []; packets.append(packet)
            guard let body = DataMessageBody(sysex8Packets: packets) else { sysex[group] = packets; continue }
            sysex[group] = []
            guard case .sysex8(let manufacturer, let data) = body,
                  manufacturer == [0x7D] || manufacturer == [0x7E] else { continue }
            if let flex = try? JSONDecoder().decode(FlexEnvelope.self, from: Data(data)) { handleFlex(flex, group: group) }
            else if let ci = try? MidiCiEnvelope(sysEx8Payload: data) { handleCI(ci, group: group) }
        }
    }

    private func handleStream(group: UInt8, word: UInt32) {
        guard let body = StreamBody(ump: UmpPacket32(word: word)) else { return }
        if body.opcode == .endpointDiscovery { send([StreamBody(opcode: .endpointDiscovery, data1: 1, data2: 8).ump(group: Uint4(group)!).word]) }
        if body.opcode == .functionBlockDiscovery { send([StreamBody(opcode: .functionBlockDiscovery, data1: 0, data2: 1).ump(group: Uint4(group)!).word]) }
    }

    private func handleCI(_ envelope: MidiCiEnvelope, group: UInt8) {
        switch envelope.body {
        case .discovery:
            let adv = MidiCiDiscoveryBody(muid: 0x0A0B0C0E, manufacturerId: [0x00, 0x20, 0x33], deviceFamily: 0x1490, deviceModel: 0x0001, softwareRev: 0x00010000, categories: .init(profiles: true, propertyExchange: true, processInquiry: true), maxSysEx: 2048)
            if let responder = try? MidiCiDiscoveryResponder(advertisement: adv), let reply = responder.respond(to: envelope) { sendCI(reply, group: group) }
        case .profiles(let body) where body.command == .inquiry:
            let reply = MidiCiProfilesBody(command: .reply, profileId: body.profileId, target: body.target, details: body.profileId == instrumentID ? ["supported": 1] : ["supported": 0])
            sendCI(MidiCiEnvelope(scope: .nonRealtime, subId2: 0x72, version: 1, body: .profiles(reply)), group: group)
        case .propertyExchange(let body) where body.command == .get && body.header["res"] == instrumentResource:
            let replies = PropertyExchangeChunker.chunkGetReply(resource: instrumentResource, requestId: body.requestId, encoding: body.encoding, data: Array(profile), maxDataPerMessage: 80)
            for reply in replies { sendCI(MidiCiEnvelope(scope: .nonRealtime, subId2: 0x7C, version: 1, body: .propertyExchange(reply)), group: group) }
        case .processInquiry(let body):
            let processInquiry = ProcessInquirySession(filters: ["messageDataControl": 0x7F])
            if let reply = processInquiry.handle(body) {
                sendCI(MidiCiEnvelope(scope: .nonRealtime, subId2: 0x7E, version: 1, body: .processInquiry(reply)), group: group)
            }
        default: break
        }
    }

    private func handleFlex(_ flex: FlexEnvelope, group: UInt8) {
        guard case .object(let object) = flex.body,
              let data = try? JSONEncoder().encode(JSONValue.object(object)),
              let request = try? JSONDecoder().decode(WireEnvelope.self, from: data) else { return }
        if request.topic == "reframe/capability.discover" {
            var payload = request.payload
            payload["phase"] = "admitted"
            payload["sessionId"] = request.sessionId
            payload["corpusId"] = "remote-codexkit-peer-acceptance"
            payload["sourceDocumentId"] = "remote-codexkit:instrument-profile"
            payload["midiCIInstrument"] = profile.base64EncodedString()
            payload["instrumentProfiles"] = profile.base64EncodedString()
            sendFlex(response(for: request, phase: "admitted", summary: "CodexKit MIDI2 instrument discovered.", threadID: nil, turnID: nil, payload: payload), group: group)
            return
        }
        guard request.payload["instrumentId"] == instrumentID else { return }
        let admitted = response(for: request, phase: "admitted", summary: "CodexKit MIDI2 instrument admitted.", threadID: nil, turnID: nil)
        sendFlex(admitted, group: group)
        Task { @MainActor in
            do {
                let result = try await runtime.execute(request)
                sendFlex(response(for: request, phase: result.phase, summary: result.summary, threadID: result.threadID, turnID: result.turnID), group: group)
            } catch {
                sendFlex(response(for: request, phase: "failed", summary: "CodexKit instrument failed: \(error)", threadID: nil, turnID: nil), group: group)
            }
        }
    }

    private func response(for request: WireEnvelope, phase: String, summary: String, threadID: String?, turnID: String?, payload suppliedPayload: [String: String]? = nil) -> WireEnvelope {
        var payload = suppliedPayload ?? request.payload; payload["phase"] = phase; payload["summary"] = summary; payload["operation"] = payload["operation"] ?? ""; if let threadID { payload["threadId"] = threadID }; if let turnID { payload["turnId"] = turnID }; payload["terminal"] = ["succeeded", "resumed", "failed", "canceled"].contains(phase) ? "true" : "false"
        return WireEnvelope(topic: "reframe/capability.event", schemaVersion: "reframe-midi2/1", correlationId: request.correlationId, timestamp: UInt64(Date().timeIntervalSince1970 * 1_000_000_000), qos: request.qos, sessionId: request.sessionId, capabilityMask: request.capabilityMask, resumeToken: request.resumeToken, ttlMs: request.ttlMs, payload: payload, arguments: nil)
    }

    private func sendCI(_ envelope: MidiCiEnvelope, group: UInt8) {
        guard let bytes = try? envelope.sysEx8Payload(),
              let frames = try? SysEx8.fragment(manufacturerID: [0x7E], payload: bytes, group: group) else { return }
        let packets = frames.compactMap { UmpPacket128(rawBytes: $0) }
        send(packets.flatMap(\.words))
    }

    private func sendFlex(_ envelope: WireEnvelope, group: UInt8) {
        guard let data = try? JSONEncoder().encode(envelope),
              let frames = try? SysEx8.fragment(manufacturerID: [0x7D], payload: [UInt8](data), group: group) else { return }
        let packets = frames.compactMap { UmpPacket128(rawBytes: $0) }
        send(packets.flatMap(\.words))
    }
    private func send(_ words: [UInt32]) { try? session.send(umpWords: words) }
}

let args = CommandLine.arguments
func argument(_ name: String, default value: String) -> String { guard let index = args.firstIndex(of: name), index + 1 < args.count else { return value }; return args[index + 1] }
let port = UInt16(argument("--rtp-port", default: "5004")) ?? 5004
let executable = URL(fileURLWithPath: argument("--codex-executable", default: "/usr/local/bin/codex"))
let codexHome = URL(fileURLWithPath: argument("--codex-home", default: "/var/lib/fountaincoach/codex"))
let runtime = CodexKitRuntime(executable: executable, codexHome: codexHome, runtimeDigest: argument("--runtime-digest", default: "unsealed"), protocolRevision: argument("--protocol-revision", default: "v2"))
let session = RTPMidiSession(localName: "Fountain Coach CodexKit", listenPort: port)
let host = InstrumentHost(runtime: runtime, session: session)
session.onReceiveUMP = { words in Task { @MainActor in host.receive(words) } }
try session.open()
FileHandle.standardOutput.write(Data("codexkitumpd instrument=\(instrumentID) rtp-port=\(session.port ?? port)\n".utf8))
if ump_alsa_open() != 0 { exit(1) }
dispatchMain()
#else
print("codexkitumpd is Linux-only")
#endif
