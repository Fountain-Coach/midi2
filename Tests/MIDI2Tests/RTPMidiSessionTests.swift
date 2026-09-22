import XCTest
@testable import MIDI2Transports

final class RTPMidiSessionTests: XCTestCase {
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
