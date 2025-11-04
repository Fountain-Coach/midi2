import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class PropertyExchangeChunkingTests: XCTestCase {
    func testChunkingAndReassembly() throws {
        let resource = "/device/name"
        let requestId: UInt32 = 42
        let encoding: MidiCiPropertyExchangeBody.Encoding = .json
        let payload = Array(0..<300).map { UInt8($0 & 0xFF) }

        // create chunks of at most 60 bytes
        let replies = PropertyExchangeChunker.chunkGetReply(
            resource: resource,
            requestId: requestId,
            encoding: encoding,
            data: payload,
            maxDataPerMessage: 60
        )
        XCTAssertEqual(replies.count, Int(ceil(300.0 / 60.0)))
        // check headers monotonicity
        var offset = 0
        for (i, r) in replies.enumerated() {
            XCTAssertEqual(r.command, .getReply)
            XCTAssertEqual(r.requestId, requestId)
            XCTAssertEqual(r.encoding, encoding)
            XCTAssertEqual(r.header["res"], resource)
            XCTAssertEqual(Int(r.header["offset"] ?? "-1"), offset)
            if i < replies.count - 1 {
                XCTAssertEqual(r.header["more"], "1")
            } else {
                XCTAssertEqual(r.header["more"], "0")
            }
            offset += r.data.count
        }

        // reassemble using transaction
        let tx = PropertyExchangeTransaction(requestId: requestId, resource: resource, encoding: encoding)
        var done = false
        for r in replies {
            done = try tx.ingest(reply: r)
        }
        XCTAssertTrue(done)
        XCTAssertTrue(tx.completed)
        XCTAssertEqual(tx.buffer, payload)
    }

    func testOutOfOrderRejected() throws {
        let resource = "/device/name"
        let requestId: UInt32 = 7
        let encoding: MidiCiPropertyExchangeBody.Encoding = .json
        let payload = Array(0..<100).map { UInt8($0 & 0xFF) }
        let replies = PropertyExchangeChunker.chunkGetReply(
            resource: resource,
            requestId: requestId,
            encoding: encoding,
            data: payload,
            maxDataPerMessage: 25
        )
        let tx = PropertyExchangeTransaction(requestId: requestId, resource: resource, encoding: encoding)
        // feed second chunk first to trigger offset error
        XCTAssertThrowsError(try tx.ingest(reply: replies[1]))
    }
}

