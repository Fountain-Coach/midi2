import XCTest
@testable import MIDI2

final class MidiCiDiscoveryBodyTests: XCTestCase {
    func testRoundTripSysEx7() {
        let body = MidiCiDiscoveryBody(
            muid: 0x1234567,
            manufacturerId: [0x00, 0x01, 0x02],
            deviceFamily: 0x2345,
            deviceModel: 0x1234,
            softwareRev: 0x010203,
            categories: .init(profiles: true, propertyExchange: false, processInquiry: true),
            maxSysEx: 0x0ABCDEF
        )
        let bytes = body.sysEx7Bytes()
        let parsed = MidiCiDiscoveryBody(sysEx7Bytes: bytes)
        XCTAssertEqual(parsed, body)
    }

    func testRoundTripSysEx8() {
        let body = MidiCiDiscoveryBody(
            muid: 0x01020304,
            manufacturerId: [0x7D],
            deviceFamily: 0x1111,
            deviceModel: 0x2222,
            softwareRev: 0x33333333,
            categories: .init(profiles: false, propertyExchange: true, processInquiry: false),
            maxSysEx: 0x44444444
        )
        let bytes = body.sysEx8Bytes()
        let parsed = MidiCiDiscoveryBody(sysEx8Bytes: bytes)
        XCTAssertEqual(parsed, body)
    }
}
