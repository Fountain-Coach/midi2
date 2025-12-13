import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class PropertyExchangeStateTests: XCTestCase {
    func testSubscribeSetNotifyFlow() throws {
        let resource = "/device/name"
        let encoding: MidiCiPropertyExchangeBody.Encoding = .json
        let session = PropertyExchangeSession(initialStore: [:])

        // Subscribe
        let subReq = PropertyExchangeBuilder.makeSubscribe(resource: resource, requestId: 1, encoding: encoding)
        let subReplies = session.handle(subReq)
        XCTAssertEqual(subReplies.count, 1)
        XCTAssertEqual(subReplies.first?.command, .subscribeReply)
        XCTAssertEqual(subReplies.first?.header["status"], "200")
        XCTAssertEqual(subReplies.first?.header["subscriptionCommand"], "start")

        // Set new value, expect setReply + notify
        let newValue = Array("Grand Piano".utf8)
        let setReq = PropertyExchangeBuilder.makeSet(resource: resource, requestId: 2, encoding: encoding, data: newValue)
        let setReplies = session.handle(setReq)
        XCTAssertEqual(setReplies.count, 2)
        XCTAssertEqual(setReplies[0].command, .setReply)
        XCTAssertEqual(setReplies[0].header["ok"], "1")
        XCTAssertEqual(setReplies[1].command, .notify)
        XCTAssertEqual(setReplies[1].data, newValue)

        // Get should return the updated value (single or chunked)
        let getReq = PropertyExchangeBuilder.makeGet(resource: resource, requestId: 3, encoding: encoding)
        let getReplies = session.handle(getReq)
        // Reassemble using transaction
        let rx = PropertyExchangeTransaction(requestId: 3, resource: resource, encoding: encoding)
        var done = false
        for r in getReplies {
            XCTAssertEqual(r.command, .getReply)
            done = try rx.ingest(reply: r)
        }
        XCTAssertTrue(done)
        XCTAssertEqual(rx.buffer, newValue)
    }

    func testTerminateStopsNotify() throws {
        let resource = "/device/name"
        let session = PropertyExchangeSession(initialStore: [:])
        let enc: MidiCiPropertyExchangeBody.Encoding = .json

        _ = session.handle(PropertyExchangeBuilder.makeSubscribe(resource: resource, requestId: 1, encoding: enc))
        _ = session.handle(PropertyExchangeBuilder.makeTerminate(resource: resource, requestId: 2, encoding: enc))
        let setReplies = session.handle(PropertyExchangeBuilder.makeSet(resource: resource, requestId: 3, encoding: enc, data: [1,2,3]))
        // only setReply expected, no notify
        XCTAssertEqual(setReplies.count, 1)
        XCTAssertEqual(setReplies.first?.command, .setReply)
    }
}
