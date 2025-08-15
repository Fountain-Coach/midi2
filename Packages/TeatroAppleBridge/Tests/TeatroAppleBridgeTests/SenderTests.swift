import XCTest
@testable import TeatroAppleBridge

final class SenderTests: XCTestCase {
    func testSendConvenienceBuildsUMP() throws {
        let bridge = try AppleMIDIBridge()
        try bridge.startVirtualSource(name: "TestDest", protocol: ._1_0)
        try bridge.selectDestination(.init(matchContains: "TestDest", group: 0, protocol: ._1_0))

        let t = MIDIClock.nowHostTime()
        try bridge.sendCC(channel: 1, cc: 7, value: 64, group: 0, hostTime: t)
        try bridge.sendNoteOn(channel: 2, note: 60, velocity: 100, group: 0, hostTime: t)
        try bridge.sendNoteOff(channel: 2, note: 60, velocity: 0, group: 0, hostTime: t)

        XCTAssertEqual(bridge.sentEvents.count, 3)
        XCTAssertEqual(bridge.sentEvents[0].words[0], 0x20B10740)
        XCTAssertEqual(bridge.sentEvents[1].words[0], 0x20923C64)
        XCTAssertEqual(bridge.sentEvents[2].words[0], 0x20823C00)
    }
}
