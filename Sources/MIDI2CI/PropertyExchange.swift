import Foundation
import MIDI2

/// Property exchange packets modelled after `midi2.full.openapi.json` definitions.
public struct PropertyExchangeGetRequest: Codable {
    /// URI of the property being requested.
    public var resource: String
    public init(resource: String) { self.resource = resource }
}

public struct PropertyExchangeGetResponse: Codable {
    /// URI of the property.
    public var resource: String
    /// Optional value returned by the responder.
    public var value: String?
    public init(resource: String, value: String?) {
        self.resource = resource
        self.value = value
    }
}

// MARK: - Property Exchange Chunking & Transaction Management

/// Errors thrown by Property Exchange helpers.
public enum PropertyExchangeError: Error {
    case missingHeaders
    case inconsistentRequestId
    case wrongResource
    case invalidChunkOffset
    case invalidChunkLength
    case alreadyCompleted
}

/// Helper that emits chunked GET_REPLY messages for large property values.
public enum PropertyExchangeChunker {
    /// Split a large value into multiple GET_REPLY bodies with chunk metadata in the header.
    /// The header uses compact keys to minimize size for SysEx7:
    /// - "res": resource URI
    /// - "total": total payload length (decimal)
    /// - "offset": chunk start offset (decimal)
    /// - "length": chunk length (decimal)
    /// - "more": "1" if more chunks follow, otherwise "0"
    public static func chunkGetReply(resource: String,
                                     requestId: UInt32,
                                     encoding: MidiCiPropertyExchangeBody.Encoding,
                                     data: [UInt8],
                                     maxDataPerMessage: Int) -> [MidiCiPropertyExchangeBody] {
        precondition(maxDataPerMessage > 0, "maxDataPerMessage must be > 0")
        var offset = 0
        var bodies: [MidiCiPropertyExchangeBody] = []
        while offset < data.count {
            let length = min(maxDataPerMessage, data.count - offset)
            let chunk = Array(data[offset..<(offset + length)])
            let more = (offset + length) < data.count
            let header: [String: String] = [
                "res": resource,
                "total": String(data.count),
                "offset": String(offset),
                "length": String(length),
                "more": more ? "1" : "0"
            ]
            let body = MidiCiPropertyExchangeBody(
                command: .getReply,
                requestId: requestId,
                encoding: encoding,
                header: header,
                data: chunk
            )
            bodies.append(body)
            offset += length
        }
        return bodies
    }

    /// Split arbitrary data for Notify into multiple NOTIFY bodies with chunk metadata.
    /// Each chunk carries the same notification sequence number in header key "seq".
    public static func chunkNotify(resource: String,
                                   requestId: UInt32,
                                   encoding: MidiCiPropertyExchangeBody.Encoding,
                                   seq: Int,
                                   data: [UInt8],
                                   maxDataPerMessage: Int) -> [MidiCiPropertyExchangeBody] {
        precondition(maxDataPerMessage > 0, "maxDataPerMessage must be > 0")
        var offset = 0
        var bodies: [MidiCiPropertyExchangeBody] = []
        while offset < data.count {
            let length = min(maxDataPerMessage, data.count - offset)
            let chunk = Array(data[offset..<(offset + length)])
            let more = (offset + length) < data.count
            let header: [String: String] = [
                "res": resource,
                "seq": String(seq),
                "total": String(data.count),
                "offset": String(offset),
                "length": String(length),
                "more": more ? "1" : "0"
            ]
            let body = MidiCiPropertyExchangeBody(
                command: .notify,
                requestId: requestId,
                encoding: encoding,
                header: header,
                data: chunk
            )
            bodies.append(body)
            offset += length
        }
        return bodies
    }
}

/// Accumulates chunked GET_REPLY messages and reassembles the full value.
public final class PropertyExchangeTransaction {
    public let requestId: UInt32
    public let resource: String
    public let encoding: MidiCiPropertyExchangeBody.Encoding

    private(set) public var buffer: [UInt8] = []
    private var expectedTotal: Int?
    private var nextOffset: Int = 0
    private(set) public var completed: Bool = false

    public init(requestId: UInt32,
                resource: String,
                encoding: MidiCiPropertyExchangeBody.Encoding) {
        self.requestId = requestId
        self.resource = resource
        self.encoding = encoding
    }

    /// Ingest a GET_REPLY body. Returns true when the full value has been assembled.
    @discardableResult
    public func ingest(reply: MidiCiPropertyExchangeBody) throws -> Bool {
        guard reply.command == .getReply else { throw PropertyExchangeError.missingHeaders }
        if completed { throw PropertyExchangeError.alreadyCompleted }
        guard reply.requestId == requestId else { throw PropertyExchangeError.inconsistentRequestId }
        guard reply.encoding == encoding else { throw PropertyExchangeError.missingHeaders }

        guard let res = reply.header["res"], res == resource,
              let totalStr = reply.header["total"], let total = Int(totalStr),
              let offsetStr = reply.header["offset"], let offset = Int(offsetStr),
              let lengthStr = reply.header["length"], let length = Int(lengthStr),
              let moreStr = reply.header["more"], (moreStr == "0" || moreStr == "1")
        else { throw PropertyExchangeError.missingHeaders }

        if let expected = expectedTotal {
            if expected != total { throw PropertyExchangeError.invalidChunkLength }
        } else {
            expectedTotal = total
            buffer.reserveCapacity(total)
        }

        guard offset == nextOffset else { throw PropertyExchangeError.invalidChunkOffset }
        guard length == reply.data.count else { throw PropertyExchangeError.invalidChunkLength }

        buffer.append(contentsOf: reply.data)
        nextOffset += length

        let more = (moreStr == "1")
        if !more {
            // final chunk must match expected total length
            if let expected = expectedTotal, buffer.count == expected {
                completed = true
                return true
            } else {
                throw PropertyExchangeError.invalidChunkLength
            }
        }
        return false
    }
}

// MARK: - Builder helpers for Property Exchange bodies

public enum PropertyExchangeBuilder {
    public static func makeGet(resource: String,
                               requestId: UInt32,
                               encoding: MidiCiPropertyExchangeBody.Encoding = .json) -> MidiCiPropertyExchangeBody {
        MidiCiPropertyExchangeBody(
            command: .get,
            requestId: requestId,
            encoding: encoding,
            header: ["res": resource],
            data: []
        )
    }

    public static func makeSet(resource: String,
                               requestId: UInt32,
                               encoding: MidiCiPropertyExchangeBody.Encoding = .json,
                               data: [UInt8]) -> MidiCiPropertyExchangeBody {
        MidiCiPropertyExchangeBody(
            command: .set,
            requestId: requestId,
            encoding: encoding,
            header: ["res": resource],
            data: data
        )
    }

    public static func makeSubscribe(resource: String,
                                     requestId: UInt32,
                                     encoding: MidiCiPropertyExchangeBody.Encoding = .json) -> MidiCiPropertyExchangeBody {
        MidiCiPropertyExchangeBody(
            command: .subscribe,
            requestId: requestId,
            encoding: encoding,
            header: ["res": resource],
            data: []
        )
    }

    public static func makeTerminate(resource: String,
                                     requestId: UInt32,
                                     encoding: MidiCiPropertyExchangeBody.Encoding = .json) -> MidiCiPropertyExchangeBody {
        MidiCiPropertyExchangeBody(
            command: .terminate,
            requestId: requestId,
            encoding: encoding,
            header: ["res": resource],
            data: []
        )
    }
}

// MARK: - Session handling for Set / Subscribe / Notify

    /// Minimal in-memory Property Exchange session.
    /// Manages a property store, subscriptions by resource, and produces replies.
    public final class PropertyExchangeSession {
        public var store: [String: [UInt8]]
        private let subscriptionManager = PropertyExchangeSubscriptionManager()
    private var notifySeq: Int = 0
    public var maxDataPerMessage: Int
    private let setAllowed: (String, [UInt8]) -> Bool
    private struct SetAccumulator {
        var requestId: UInt32
        var resource: String
        var encoding: MidiCiPropertyExchangeBody.Encoding
        var expectedTotal: Int?
        var nextOffset: Int
        var buffer: [UInt8]
    }
    private var setAccumulators: [UInt32: SetAccumulator] = [:]

    public init(initialStore: [String: [UInt8]] = [:],
                maxDataPerMessage: Int = 80,
                setAllowed: @escaping (String, [UInt8]) -> Bool = { _, _ in true }) {
        self.store = initialStore
        self.maxDataPerMessage = max(1, maxDataPerMessage)
        self.setAllowed = setAllowed
    }

    /// Emit flow-control NAKs for stalled subscriptions (if any).
    public func collectSubscriptionTimeouts(now: Date = Date(), timeout: TimeInterval = 1.0) -> [MidiCiPropertyExchangeBody] {
        subscriptionManager.collectTimeouts(now: now, timeout: timeout)
    }

    /// Handle a single request and return zero or more reply/notify messages.
    public func handle(_ request: MidiCiPropertyExchangeBody) -> [MidiCiPropertyExchangeBody] {
        func failureSetReply(_ res: String, _ req: MidiCiPropertyExchangeBody, code: String, msg: String) -> [MidiCiPropertyExchangeBody] {
            let replyHeader = ["res": res, "ok": "0", "err": code, "msg": msg]
            return [MidiCiPropertyExchangeBody(command: .setReply,
                                               requestId: req.requestId,
                                               encoding: req.encoding,
                                               header: replyHeader,
                                               data: [])]
        }
        // Subscription lifecycle handling (applies to subscribe/notify/terminate with subscriptionCommand headers).
        if request.command == .subscribe || request.command == .notify || request.command == .terminate {
            if request.header["subscriptionId"] != nil || request.header["subscriptionCommand"] != nil {
                return subscriptionManager.handle(request)
            }
        }
        switch request.command {
        case .get:
            let res = request.header["res"] ?? ""
            let value = store[res] ?? []
            if value.isEmpty {
                // send empty getReply to signify not found
                let header: [String: String] = [
                    "res": res,
                    "total": "0",
                    "offset": "0",
                    "length": "0",
                    "more": "0"
                ]
                return [MidiCiPropertyExchangeBody(command: .getReply, requestId: request.requestId, encoding: request.encoding, header: header, data: [])]
            } else {
                return PropertyExchangeChunker.chunkGetReply(resource: res,
                                                             requestId: request.requestId,
                                                             encoding: request.encoding,
                                                             data: value,
                                                             maxDataPerMessage: maxDataPerMessage)
            }
        case .set:
            let res = request.header["res"] ?? ""
            // Attempt to parse chunking headers if present
            if let totalStr = request.header["total"],
               let offStr = request.header["offset"],
               let lenStr = request.header["length"],
               let moreStr = request.header["more"],
               let total = Int(totalStr), let offset = Int(offStr), let length = Int(lenStr),
               (moreStr == "0" || moreStr == "1") {
                // Chunked SET flow
                var acc = setAccumulators[request.requestId] ?? SetAccumulator(requestId: request.requestId,
                                                                               resource: res,
                                                                               encoding: request.encoding,
                                                                               expectedTotal: nil,
                                                                               nextOffset: 0,
                                                                               buffer: [])
                // Validate consistency
                if acc.resource != res || acc.encoding != request.encoding {
                    return failureSetReply(res, request, code: "wrong_resource_or_encoding", msg: "resource or encoding mismatch across chunks")
                }
                if let expected = acc.expectedTotal, expected != total {
                    return failureSetReply(res, request, code: "total_mismatch", msg: "declared total changed across chunks")
                }
                if acc.expectedTotal == nil {
                    acc.expectedTotal = total
                    acc.buffer.reserveCapacity(total)
                }
                guard offset == acc.nextOffset, length == request.data.count else {
                    return failureSetReply(res, request, code: "offset_length_mismatch", msg: "invalid offset or length")
                }
                acc.buffer.append(contentsOf: request.data)
                acc.nextOffset += length
                let more = (moreStr == "1")
                if more {
                    setAccumulators[request.requestId] = acc
                    return []
                } else {
                    // final chunk: commit and clear
                    setAccumulators.removeValue(forKey: request.requestId)
                    // guard length matches expected total
                    if let expected = acc.expectedTotal, acc.buffer.count == expected, setAllowed(res, acc.buffer) {
                        store[res] = acc.buffer
                        let replyHeader = ["res": res, "ok": "1"]
                        var replies = [MidiCiPropertyExchangeBody(command: .setReply,
                                                                 requestId: request.requestId,
                                                                 encoding: request.encoding,
                                                                 header: replyHeader,
                                                                 data: [])]
                        if subscriptionManager.isActive(resource: res) {
                            notifySeq &+= 1
                            // Chunk notify if needed
                            let notifies = PropertyExchangeChunker.chunkNotify(resource: res,
                                                                              requestId: request.requestId,
                                                                              encoding: request.encoding,
                                                                              seq: notifySeq,
                                                                              data: acc.buffer,
                                                                              maxDataPerMessage: maxDataPerMessage)
                            replies.append(contentsOf: notifies)
                        }
                        return replies
                    } else {
                        return failureSetReply(res, request, code: "commit_failed", msg: "total mismatch or policy denied")
                    }
                }
            } else {
                // Unchunked SET
                if setAllowed(res, request.data) {
                    store[res] = request.data
                    let replyHeader = ["res": res, "ok": "1"]
                    var replies = [MidiCiPropertyExchangeBody(command: .setReply,
                                                             requestId: request.requestId,
                                                             encoding: request.encoding,
                                                             header: replyHeader,
                                                             data: [])]
                    if subscriptionManager.isActive(resource: res) {
                        notifySeq &+= 1
                        let notifies = PropertyExchangeChunker.chunkNotify(resource: res,
                                                                          requestId: request.requestId,
                                                                          encoding: request.encoding,
                                                                          seq: notifySeq,
                                                                          data: request.data,
                                                                          maxDataPerMessage: maxDataPerMessage)
                        replies.append(contentsOf: notifies)
                    }
                    return replies
                } else {
                    return failureSetReply(res, request, code: "policy_denied", msg: "set not allowed")
                }
            }
        case .subscribe:
            return subscriptionManager.handle(request)
        case .terminate:
            return subscriptionManager.handle(request)
        default:
            return []
        }
    }
}

// MARK: - Subscription state machine

private final class PropertyExchangeSubscriptionManager {
    private enum Stage {
        case start, partial, full, active
    }

    private struct Subscription {
        var id: String
        var stage: Stage
        var flowControl: Bool
        var lastChunk: Int
        var resource: String?
        var lastActivity: Date
    }

    private var subs: [String: Subscription] = [:]

    /// Convenience helper for state check used by notify senders.
    func isActive(resource: String) -> Bool {
        subs.values.contains(where: { $0.resource == nil || $0.resource == resource })
    }

    /// Emit NAKs when flow-control chunks are stalled beyond timeout.
    func collectTimeouts(now: Date = Date(), timeout: TimeInterval = 1.0) -> [MidiCiPropertyExchangeBody] {
        var out: [MidiCiPropertyExchangeBody] = []
        for (id, sub) in subs {
            guard sub.flowControl, sub.stage == .active else { continue }
            if now.timeIntervalSince(sub.lastActivity) >= timeout {
                let chunkNumber = sub.lastChunk + 1
                let dummy = MidiCiPropertyExchangeBody(command: .notify,
                                                       requestId: 0,
                                                       encoding: .json,
                                                       header: ["subscriptionId": id, "chunkNumber": String(chunkNumber)],
                                                       data: [])
                out.append(flowControlNak(for: dummy, chunkNumber: chunkNumber))
                var updated = sub
                updated.lastActivity = now
                subs[id] = updated
            }
        }
        return out
    }

    func handle(_ req: MidiCiPropertyExchangeBody) -> [MidiCiPropertyExchangeBody] {
        let cmd = req.command
        let subId = req.header["subscriptionId"] ?? req.header["res"] ?? ""
        guard !subId.isEmpty else {
            return [reply(command: .subscribeReply, req: req, status: 400, extra: ["msg": "missing subscriptionId"])]
        }
        let subCmd = req.header["subscriptionCommand"] ?? (cmd == .subscribe ? "start" : cmd == .terminate ? "end" : nil)
        let resource = req.header["res"] ?? req.header["resource"]
        switch subCmd {
        case "start":
            let wantsFC = (req.header["flowControl"] == "true")
            subs[subId] = Subscription(id: subId, stage: .start, flowControl: wantsFC, lastChunk: -1, resource: resource, lastActivity: Date())
            return [reply(command: .subscribeReply, req: req, status: 200, extra: ["subscriptionCommand": "start", "flowControl": wantsFC ? "true" : "false"])]
        case "partial":
            guard var s = subs[subId] else { return [reply(command: .notify, req: req, status: 404)] }
            s.stage = .partial
            s.lastActivity = Date()
            subs[subId] = s
            return []
        case "full":
            guard var s = subs[subId] else { return [reply(command: .notify, req: req, status: 404)] }
            s.stage = .full
            s.lastActivity = Date()
            subs[subId] = s
            return [reply(command: .subscribeReply, req: req, status: 200, extra: ["subscriptionCommand": "full"])]
        case "notify":
            guard var s = subs[subId] else { return [reply(command: .notify, req: req, status: 404)] }
            if let res = resource, let subRes = s.resource, res != subRes {
                return [reply(command: .notify, req: req, status: 409)]
            }
            guard s.stage == .full || s.stage == .active else { return [reply(command: .notify, req: req, status: 409)] }
            s.stage = .active
            if s.flowControl, let chunkStr = req.header["chunkNumber"], let chunk = Int(chunkStr) {
                if chunk != s.lastChunk + 1 {
                    s.lastChunk = chunk
                    s.lastActivity = Date()
                    subs[subId] = s
                    return [flowControlNak(for: req, chunkNumber: chunk)]
                }
                s.lastChunk = chunk
            }
            s.lastActivity = Date()
            subs[subId] = s
            if s.flowControl, let lengthStr = req.header["length"], let len = Int(lengthStr) {
                return [flowControlAck(for: req, length: len)]
            }
            return []
        case "end":
            subs.removeValue(forKey: subId)
            return [reply(command: .subscribeReply, req: req, status: 200, extra: ["subscriptionCommand": "end"])]
        default:
            return [reply(command: .subscribeReply, req: req, status: 400, extra: ["msg": "unknown subscriptionCommand"])]
        }
    }

    private func reply(command: MidiCiPropertyExchangeBody.Command,
                       req: MidiCiPropertyExchangeBody,
                       status: Int,
                       extra: [String: String] = [:]) -> MidiCiPropertyExchangeBody {
        var header: [String: String] = ["status": String(status)]
        header.merge(extra) { _, new in new }
        return MidiCiPropertyExchangeBody(command: command,
                                          requestId: req.requestId,
                                          encoding: req.encoding,
                                          header: header,
                                          data: [])
    }

    private func flowControlAck(for req: MidiCiPropertyExchangeBody, length: Int) -> MidiCiPropertyExchangeBody {
        let chunkNum = Int(req.header["chunkNumber"] ?? "") ?? 0
        let hdr: [String: String] = [
            "status": "17",
            "chunkNumber": String(chunkNum),
            "messageLength": String(length)
        ]
        return MidiCiPropertyExchangeBody(command: .notify,
                                          requestId: req.requestId,
                                          encoding: req.encoding,
                                          header: hdr,
                                          data: [])
    }

    private func flowControlNak(for req: MidiCiPropertyExchangeBody, chunkNumber: Int) -> MidiCiPropertyExchangeBody {
        let hdr: [String: String] = [
            "status": "18",
            "chunkNumber": String(chunkNumber)
        ]
        return MidiCiPropertyExchangeBody(command: .notify,
                                          requestId: req.requestId,
                                          encoding: req.encoding,
                                          header: hdr,
                                          data: [])
    }

}
