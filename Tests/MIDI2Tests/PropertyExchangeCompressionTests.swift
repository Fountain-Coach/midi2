import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class PropertyExchangeCompressionTests: XCTestCase {
    func testZlibRoundTripIfAvailable() {
        let data = Array("Hello MIDI-CI".utf8)
        let enc: MidiCiPropertyExchangeBody.Encoding = .jsonZlib
        let compressed = PropertyExchangeCodec.encode(data, using: enc)
        let decoded = PropertyExchangeCodec.decode(compressed, using: enc)
        XCTAssertEqual(decoded, data)
    }

    func testSessionGetCompressedFlowRoundtrip() throws {
        let resource = "/clip/title"
        let clear = Array("Hello CI".utf8)
        let enc: MidiCiPropertyExchangeBody.Encoding = .jsonZlib
        // store compressed value
        let compressed = PropertyExchangeCodec.encode(clear, using: enc)
        let session = PropertyExchangeSession(initialStore: [resource: compressed], maxDataPerMessage: 32)
        // GET with jsonZlib
        let replies = session.handle(PropertyExchangeBuilder.makeGet(resource: resource, requestId: 7, encoding: enc))
        let rx = PropertyExchangeTransaction(requestId: 7, resource: resource, encoding: enc)
        var done = false
        for r in replies { done = try rx.ingest(reply: r) }
        XCTAssertTrue(done)
        let decoded = PropertyExchangeCodec.decode(rx.buffer, using: enc)
        XCTAssertEqual(decoded, clear)
    }

    func testSubscribeTerminateEdges() {
        let res = "/x"
        let session = PropertyExchangeSession(initialStore: [:], maxDataPerMessage: 10)
        let enc: MidiCiPropertyExchangeBody.Encoding = .json
        // subscribe twice
        _ = session.handle(PropertyExchangeBuilder.makeSubscribe(resource: res, requestId: 1, encoding: enc))
        _ = session.handle(PropertyExchangeBuilder.makeSubscribe(resource: res, requestId: 2, encoding: enc))
        // set should yield exactly one notify stream (chunked count depends on size)
        let setReplies = session.handle(PropertyExchangeBuilder.makeSet(resource: res, requestId: 3, encoding: enc, data: Array(repeating: 1, count: 21)))
        let notifyCount = setReplies.filter { $0.command == .notify }.count
        XCTAssertEqual(notifyCount, 3) // 21 bytes with chunk=10 -> 3 chunks
        // terminate twice
        _ = session.handle(PropertyExchangeBuilder.makeTerminate(resource: res, requestId: 4, encoding: enc))
        _ = session.handle(PropertyExchangeBuilder.makeTerminate(resource: res, requestId: 5, encoding: enc))
        // set now yields only setReply
        let after = session.handle(PropertyExchangeBuilder.makeSet(resource: res, requestId: 6, encoding: enc, data: [1,2,3]))
        XCTAssertEqual(after.count, 1)
        XCTAssertEqual(after.first?.command, .setReply)
    }
}
