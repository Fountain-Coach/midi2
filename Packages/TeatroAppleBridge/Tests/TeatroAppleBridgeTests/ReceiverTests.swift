import XCTest
@testable import TeatroAppleBridge

final class ReceiverTests: XCTestCase {
    func testVirtualSourceReceivesUMP() throws {
        let bridge = try AppleMIDIBridge()
        try bridge.startVirtualSource(name: "Loop", protocol: ._1_0)

        let recvExpectation = expectation(description: "received")
        let receiver = try AppleMIDIReceiver()
        try receiver.openInput(nameMatch: "Loop", protocol: ._1_0) { group, words, _ in
            XCTAssertEqual(group, 0)
            XCTAssertEqual(words[0], 0x20093C64)
            recvExpectation.fulfill()
        }

        try bridge.publishUMP(words: [0x20093C64], hostTime: 1234)
        wait(for: [recvExpectation], timeout: 1.0)
    }
}
