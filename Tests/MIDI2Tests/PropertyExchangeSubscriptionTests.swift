import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class PropertyExchangeSubscriptionTests: XCTestCase {
    private func body(_ cmd: MidiCiPropertyExchangeBody.Command, header: [String: String] = [:]) -> MidiCiPropertyExchangeBody {
        MidiCiPropertyExchangeBody(command: cmd, requestId: 1, encoding: .json, header: header, data: [])
    }

    func testLifecycleStartFullNotifyEnd() throws {
        let session = PropertyExchangeSession()
        var replies = session.handle(body(.subscribe, header: ["subscriptionId": "sub1", "subscriptionCommand": "start", "flowControl": "true"]))
        XCTAssertFalse(replies.isEmpty)
        let startStatus = try XCTUnwrap(replies.first?.header["status"])
        XCTAssertEqual(startStatus, "200")
        replies = session.handle(body(.notify, header: ["subscriptionId": "sub1", "subscriptionCommand": "full"]))
        XCTAssertFalse(replies.isEmpty)
        let fullStatus = try XCTUnwrap(replies.first?.header["status"])
        XCTAssertEqual(fullStatus, "200")
        replies = session.handle(body(.notify, header: ["subscriptionId": "sub1", "subscriptionCommand": "notify", "flowControl": "true", "length": "4", "chunkNumber": "0"]))
        XCTAssertFalse(replies.isEmpty)
        let ackStatus = try XCTUnwrap(replies.first?.header["status"])
        XCTAssertEqual(ackStatus, "17")
        // Out-of-order chunk should NAK
        replies = session.handle(body(.notify, header: ["subscriptionId": "sub1", "subscriptionCommand": "notify", "flowControl": "true", "length": "4", "chunkNumber": "5"]))
        XCTAssertEqual(replies.first?.header["status"], "18")
        replies = session.handle(body(.terminate, header: ["subscriptionId": "sub1", "subscriptionCommand": "end"]))
        XCTAssertFalse(replies.isEmpty)
        let endStatus = try XCTUnwrap(replies.first?.header["status"])
        XCTAssertEqual(endStatus, "200")
    }

    func testNotifyRejectedWhenUnknownOrOutOfOrder() throws {
        let session = PropertyExchangeSession()
        var replies = session.handle(body(.notify, header: ["subscriptionId": "missing", "subscriptionCommand": "notify"]))
        XCTAssertFalse(replies.isEmpty)
        let missingStatus = try XCTUnwrap(replies.first?.header["status"])
        XCTAssertEqual(missingStatus, "404")
        _ = session.handle(body(.subscribe, header: ["subscriptionId": "sub2", "subscriptionCommand": "start"]))
        replies = session.handle(body(.notify, header: ["subscriptionId": "sub2", "subscriptionCommand": "notify"]))
        XCTAssertFalse(replies.isEmpty)
        let orderStatus = try XCTUnwrap(replies.first?.header["status"])
        XCTAssertEqual(orderStatus, "409")
    }
}
