import XCTest
@testable import MIDI2

final class JitterReductionTests: XCTestCase {
    func testInterleavedClockAndTimestamp() {
        let sequence: [Utility] = [
            .jrClock(0x1000),
            .jrTimestamp(0x0010),
            .jrTimestamp(0x0020),
            .jrClock(0x2000),
            .jrTimestamp(0x0005)
        ]

        var base: UInt32 = 0
        var reconstructed: [UInt32] = []
        for msg in sequence {
            switch msg {
            case .jrClock(let value):
                base = UInt32(value)
            case .jrTimestamp(let value):
                reconstructed.append(base + UInt32(value))
            default:
                XCTFail("unexpected message")
            }
        }

        XCTAssertEqual(reconstructed, [0x1010, 0x1020, 0x2005])
    }
}
