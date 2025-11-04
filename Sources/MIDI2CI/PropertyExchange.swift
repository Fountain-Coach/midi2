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
    private var subscriptions: Set<String>
    private var notifySeq: Int = 0
    public var maxDataPerMessage: Int

    public init(initialStore: [String: [UInt8]] = [:], maxDataPerMessage: Int = 80) {
        self.store = initialStore
        self.subscriptions = []
        self.maxDataPerMessage = max(1, maxDataPerMessage)
    }

    /// Handle a single request and return zero or more reply/notify messages.
    public func handle(_ request: MidiCiPropertyExchangeBody) -> [MidiCiPropertyExchangeBody] {
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
            store[res] = request.data
            let replyHeader = ["res": res, "ok": "1"]
            var replies = [MidiCiPropertyExchangeBody(command: .setReply,
                                                     requestId: request.requestId,
                                                     encoding: request.encoding,
                                                     header: replyHeader,
                                                     data: [])]
            if subscriptions.contains(res) {
                notifySeq &+= 1
                let notifyHeader = ["res": res, "seq": String(notifySeq)]
                let notify = MidiCiPropertyExchangeBody(command: .notify,
                                                        requestId: request.requestId,
                                                        encoding: request.encoding,
                                                        header: notifyHeader,
                                                        data: request.data)
                replies.append(notify)
            }
            return replies
        case .subscribe:
            let res = request.header["res"] ?? ""
            subscriptions.insert(res)
            let replyHeader = ["res": res, "ok": "1"]
            return [MidiCiPropertyExchangeBody(command: .subscribeReply,
                                               requestId: request.requestId,
                                               encoding: request.encoding,
                                               header: replyHeader,
                                               data: [])]
        case .terminate:
            let res = request.header["res"] ?? ""
            subscriptions.remove(res)
            let replyHeader = ["res": res, "ok": "1"]
            return [MidiCiPropertyExchangeBody(command: .subscribeReply,
                                               requestId: request.requestId,
                                               encoding: request.encoding,
                                               header: replyHeader,
                                               data: [])]
        default:
            return []
        }
    }
}
