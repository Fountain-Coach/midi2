import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class PropertyExchangeChunkedSetTests: XCTestCase {
    func testChunkedSetStoredAndNotifyChunked() throws {
        let resource = "/clip/title"
        let enc: MidiCiPropertyExchangeBody.Encoding = .json
        let session = PropertyExchangeSession(initialStore: [:], maxDataPerMessage: 50)

        // Subscribe to receive notify
        _ = session.handle(PropertyExchangeBuilder.makeSubscribe(resource: resource, requestId: 1, encoding: enc))

        // Prepare a large value (120 bytes)
        let value = Array(0..<120).map { UInt8($0 & 0xFF) }
        let total = value.count
        // Send three set chunks: 0..49, 50..99, 100..119
        let reqId: UInt32 = 42
        var replies: [MidiCiPropertyExchangeBody] = []
        var offset = 0
        var idx = 0
        while offset < total {
            let len = min(50, total - offset)
            let more = (offset + len) < total
            let header: [String: String] = [
                "res": resource,
                "total": String(total),
                "offset": String(offset),
                "length": String(len),
                "more": more ? "1" : "0"
            ]
            let body = MidiCiPropertyExchangeBody(command: .set,
                                                  requestId: reqId,
                                                  encoding: enc,
                                                  header: header,
                                                  data: Array(value[offset..<(offset+len)]))
            let r = session.handle(body)
            replies.append(contentsOf: r)
            offset += len
            idx += 1
        }

        // Expect: final handle returns setReply and chunked notify messages
        XCTAssertGreaterThanOrEqual(replies.count, 2)
        XCTAssertEqual(replies.first?.command, .setReply)
        XCTAssertEqual(replies.first?.header["ok"], "1")

        // Collect notify chunks and reassemble
        let notifies = replies.dropFirst().filter { $0.command == .notify }
        XCTAssertFalse(notifies.isEmpty)
        let rx = PropertyExchangeTransaction(requestId: reqId, resource: resource, encoding: enc)
        var done = false
        for n in notifies {
            done = try rx.ingest(reply: MidiCiPropertyExchangeBody(command: .getReply,
                                                                   requestId: reqId,
                                                                   encoding: enc,
                                                                   header: [
                                                                    "res": n.header["res"] ?? "",
                                                                    "total": n.header["total"] ?? "0",
                                                                    "offset": n.header["offset"] ?? "0",
                                                                    "length": n.header["length"] ?? "0",
                                                                    "more": n.header["more"] ?? "0",
                                                                   ],
                                                                   data: n.data))
        }
        XCTAssertTrue(done)
        XCTAssertEqual(rx.buffer, value)
    }

    func testChunkedSetOffsetErrorProducesFailureReply() throws {
        let resource = "/clip/title"
        let enc: MidiCiPropertyExchangeBody.Encoding = .json
        let session = PropertyExchangeSession(initialStore: [:], maxDataPerMessage: 50)
        let reqId: UInt32 = 9

        // First chunk ok
        let h1 = ["res": resource, "total": "10", "offset": "0", "length": "5", "more": "1"]
        let b1 = MidiCiPropertyExchangeBody(command: .set, requestId: reqId, encoding: enc, header: h1, data: [1,2,3,4,5])
        let r1 = session.handle(b1)
        XCTAssertTrue(r1.isEmpty)

        // Second chunk wrong offset => expect failure setReply
        let h2 = ["res": resource, "total": "10", "offset": "7", "length": "5", "more": "0"]
        let b2 = MidiCiPropertyExchangeBody(command: .set, requestId: reqId, encoding: enc, header: h2, data: [6,7,8,9,10])
        let r2 = session.handle(b2)
        XCTAssertEqual(r2.count, 1)
        XCTAssertEqual(r2.first?.command, .setReply)
        XCTAssertEqual(r2.first?.header["ok"], "0")
    }
}

