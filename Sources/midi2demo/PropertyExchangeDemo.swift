import ArgumentParser
import MIDI2
import MIDI2CI

struct PropertyExchangeDemo: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pe-demo",
        abstract: "Simulate chunked Property Exchange Set/Get/Notify",
        discussion: "Creates an in-memory Property Exchange session, subscribes to a resource, sends a chunked Set, receives a chunked Notify, and performs a chunked Get reassembled to verify integrity."
    )

    @Option(name: .long, help: "Resource URI")
    var resource: String = "/clip/title"

    @Option(name: .long, help: "Payload size (bytes)")
    var size: Int = 120

    @Option(name: .long, help: "Max bytes per message (chunk)")
    var chunk: Int = 50

    @Option(name: .long, help: "Encoding (json|jsonZlib|binary|binaryZlib)")
    var encoding: String = "json"

    func run() throws {
        let payloadSize = max(0, size)
        let chunkSize = max(1, chunk)
        let enc: MidiCiPropertyExchangeBody.Encoding
        switch encoding.lowercased() {
        case "json": enc = .json
        case "jsonzlib": enc = .jsonZlib
        case "binary": enc = .binary
        case "binaryzlib": enc = .binaryZlib
        default: throw ValidationError("Invalid encoding")
        }
        let session = PropertyExchangeSession(initialStore: [:], maxDataPerMessage: chunkSize)

        // Subscribe
        _ = session.handle(PropertyExchangeBuilder.makeSubscribe(resource: resource, requestId: 1, encoding: enc))

        // Build payload
        let clear = Array(0..<payloadSize).map { UInt8($0 & 0xFF) }
        let payload = PropertyExchangeCodec.encode(clear, using: enc)
        let total = payload.count
        let reqId: UInt32 = 42

        // Chunked Set
        var offset = 0
        var setReplies: [[MidiCiPropertyExchangeBody]] = []
        while offset < total {
            let len = min(chunkSize, total - offset)
            let more = (offset + len) < total
            let hdr: [String: String] = [
                "res": resource,
                "total": String(total),
                "offset": String(offset),
                "length": String(len),
                "more": more ? "1" : "0"
            ]
            let body = MidiCiPropertyExchangeBody(command: .set, requestId: reqId, encoding: enc, header: hdr, data: Array(payload[offset..<(offset+len)]))
            let replies = session.handle(body)
            setReplies.append(replies)
            offset += len
        }

        // Print Set reply + Notify chunks
        let finalReplies = setReplies.last ?? []
        for r in finalReplies {
            print("SET reply: \(r.command) header=\(r.header) dataLen=\(r.data.count)")
        }
        let notifies = finalReplies.filter { $0.command == .notify }
        let rxNotify = PropertyExchangeTransaction(requestId: reqId, resource: resource, encoding: enc)
        var notifyDone = false
        for n in notifies {
            let shim = MidiCiPropertyExchangeBody(command: .getReply,
                                                  requestId: reqId,
                                                  encoding: enc,
                                                  header: [
                                                    "res": n.header["res"] ?? "",
                                                    "total": n.header["total"] ?? "0",
                                                    "offset": n.header["offset"] ?? "0",
                                                    "length": n.header["length"] ?? "0",
                                                    "more": n.header["more"] ?? "0",
                                                  ],
                                                  data: n.data)
            notifyDone = try rxNotify.ingest(reply: shim)
        }
        print("Notify reassembled: done=\(notifyDone) bytes=\(rxNotify.buffer.count)")

        // GET and reassemble
        let getReplies = session.handle(PropertyExchangeBuilder.makeGet(resource: resource, requestId: 100, encoding: enc))
        let rxGet = PropertyExchangeTransaction(requestId: 100, resource: resource, encoding: enc)
        var getDone = false
        for r in getReplies {
            getDone = try rxGet.ingest(reply: r)
        }
        print("GET reassembled: done=\(getDone) bytes=\(rxGet.buffer.count)")
        let decodedGet = PropertyExchangeCodec.decode(rxGet.buffer, using: enc)
        if decodedGet == clear { print("OK: payloads match") } else { print("ERROR: payloads differ") }
    }
}
