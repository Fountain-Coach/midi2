import XCTest
@testable import MIDI2

final class MidiCiDiscoveryBodyValidationTests: XCTestCase {
    func testInvalidManufacturerIdLengthsThrow() {
        // 2-byte ID invalid
        let b2 = MidiCiDiscoveryBody(muid: 0, manufacturerId: [0x01, 0x02], deviceFamily: 0, deviceModel: 0, softwareRev: 0, categories: .init(profiles: false, propertyExchange: false, processInquiry: false), maxSysEx: 0)
        XCTAssertThrowsError(try b2.validate())
    }

    func testInvalidOneByteZeroThrows() {
        let b = MidiCiDiscoveryBody(muid: 0, manufacturerId: [0x00], deviceFamily: 0, deviceModel: 0, softwareRev: 0, categories: .init(profiles: false, propertyExchange: false, processInquiry: false), maxSysEx: 0)
        XCTAssertThrowsError(try b.validate())
    }

    func testInvalidThreeByteFirstNotZeroThrows() {
        let b = MidiCiDiscoveryBody(muid: 0, manufacturerId: [0x01, 0x02, 0x03], deviceFamily: 0, deviceModel: 0, softwareRev: 0, categories: .init(profiles: false, propertyExchange: false, processInquiry: false), maxSysEx: 0)
        XCTAssertThrowsError(try b.validate())
    }
}

