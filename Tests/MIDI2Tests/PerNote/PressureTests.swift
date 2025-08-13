import XCTest
@testable import MIDI2

final class PerNotePressureTests: XCTestCase {
    func testEncodingDecoding() {
        guard let pressure = PerNotePressure(0xDEADBEEF) else { return XCTFail("init failed") }
        let encoded = pressure.encode()
        let decoded = PerNotePressure.decode(encoded)
        XCTAssertEqual(decoded, pressure)
    }

    func testBounds() {
        XCTAssertNotNil(PerNotePressure(0))
        XCTAssertNotNil(PerNotePressure(Swift.UInt64(Swift.UInt32.max)))
        XCTAssertNil(PerNotePressure(Swift.UInt64(Swift.UInt32.max) + 1))
    }
}
