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
}
