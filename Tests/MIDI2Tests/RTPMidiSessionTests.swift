import XCTest
@testable import MIDI2Transports

final class RTPMidiSessionTests: XCTestCase {
    func testResponderRepliesToSenderWithMultiPacketPayload() throws {
        let received = expectation(description: "reply returns to initiator")
        let payload: [UInt32] = [0x501E7E7E, 0x0D700101, 0x02030400, 0x7D004643,
                                 0x503B0001, 0x00010001, 0x07000008, 0]
        let responder = RTPMidiSession(localName: "reply-responder")
        responder.onReceiveUMP = { words in
            XCTAssertEqual(words, payload)
            do { try responder.send(umpWords: words) }
            catch { XCTFail("responder could not reply: \(error)") }
        }
        try responder.open(); try responder.waitUntilReady()
        let port = try XCTUnwrap(responder.port)
        let initiator = RTPMidiSession(localName: "reply-initiator")
        initiator.onReceiveUMP = { words in
            XCTAssertEqual(words, payload)
            received.fulfill()
        }
        try initiator.open(); try initiator.waitUntilReady()
        try initiator.connect(host: "127.0.0.1", port: port)
        defer {
            responder.onReceiveUMP = nil
            try? initiator.close(); try? responder.close()
        }
        try initiator.send(umpWords: payload)
        wait(for: [received], timeout: 2)
    }

    func testLoopbackCarriesUMPOverUDP() throws {
        let received = expectation(description: "UMP packets received")
        received.expectedFulfillmentCount = 3
        let responder = RTPMidiSession(localName: "test-responder")
        responder.onReceiveUMP = { words in
            XCTAssertTrue([1, 2, 4].contains(words.count))
            received.fulfill()
        }
        try responder.open(); try responder.waitUntilReady()
        guard let port = responder.port else { XCTFail("missing observed port"); return }
        let initiator = RTPMidiSession(localName: "test-initiator")
        try initiator.open(); try initiator.waitUntilReady(); try initiator.connect(host: "127.0.0.1", port: port)
        defer { try? initiator.close(); try? responder.close() }
        try initiator.send(umpWords: [0x10000000])
        try initiator.send(umpWords: [0x20000000, 0x30000000])
        try initiator.send(umpWords: [0x10000000, 0x20000000, 0x30000000, 0x40000000])
        wait(for: [received], timeout: 2)
    }

    func testListenerCanReplyToRequestingPeer() throws {
        let replyReceived = expectation(description: "listener reply received")
        let request: [UInt32] = [0x1000_0001]
        let reply: [UInt32] = [0x1000_0002]
        let responder = RTPMidiSession(localName: "test-reply-responder")
        responder.onReceiveUMP = { words in
            guard words == request else { return }
            try? responder.send(umpWords: reply)
        }
        try responder.open(); try responder.waitUntilReady()
        guard let port = responder.port else { XCTFail("missing observed port"); return }
        let initiator = RTPMidiSession(localName: "test-reply-initiator")
        initiator.onReceiveUMP = { words in
            if words == reply { replyReceived.fulfill() }
        }
        try initiator.open(); try initiator.waitUntilReady()
        try initiator.connect(host: "127.0.0.1", port: port)
        defer { try? initiator.close(); try? responder.close() }
        try initiator.send(umpWords: request)
        wait(for: [replyReceived], timeout: 2)
    }

    func testLoopbackCarriesContiguous128BitPacketSequenceInOneDatagram() throws {
        let received = expectation(description: "128-bit packet sequence received")
        let words: [UInt32] = [
            0x5000_0000, 0x0000_0001, 0x0000_0002, 0x0000_0003,
            0x5000_0000, 0x0000_0004, 0x0000_0005, 0x0000_0006
        ]
        let responder = RTPMidiSession(localName: "test-sequence-responder")
        responder.onReceiveUMP = { receivedWords in
            XCTAssertEqual(receivedWords, words)
            received.fulfill()
        }
        try responder.open(); try responder.waitUntilReady()
        guard let port = responder.port else { XCTFail("missing observed port"); return }
        let initiator = RTPMidiSession(localName: "test-sequence-initiator")
        try initiator.open(); try initiator.waitUntilReady(); try initiator.connect(host: "127.0.0.1", port: port)
        defer { try? initiator.close(); try? responder.close() }
        try initiator.send(umpWords: words)
        wait(for: [received], timeout: 2)
    }
}
