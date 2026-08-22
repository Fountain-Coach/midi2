import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class ModeledFrontierTests: XCTestCase {
    func testCompatibilityReportsMissingFeatures() {
        let result = CompatibilitySelection(requested: ["midi2", "jr"], supported: ["midi2"])
        XCTAssertFalse(result.compatible)
        XCTAssertEqual(result.selected, ["midi2"])
        XCTAssertEqual(result.missing, ["jr"])
    }

    func testMidiCITransactionFailureIsTerminal() throws {
        let transaction = MidiCITransaction()
        try transaction.sendRequest()
        try transaction.acceptRequest()
        try transaction.timeout()
        XCTAssertEqual(transaction.state, .timedOut)
        XCTAssertThrowsError(try transaction.receiveResponse())
    }

    func testProfileChannelAllocationRequiresInquiry() throws {
        let allocation = try ProfileChannelAllocation(profileId: "/org.midi/piano", channels: [0, 15])
        XCTAssertThrowsError(try allocation.accept())
        try allocation.inquire()
        try allocation.beginNegotiation()
        try allocation.accept()
        try allocation.release()
        XCTAssertEqual(allocation.state, .released)
    }

    func testPropertyExchangeInvalidResourceCannotComplete() throws {
        let transaction = try PropertyExchangeResourceTransaction(resource: "/device/name", requestId: 7)
        try transaction.request()
        try transaction.invalidate(reason: "unsupported-resource")
        XCTAssertEqual(transaction.state, .invalid)
        XCTAssertThrowsError(try transaction.complete())
    }

    func testUmpOrderingAndReservedValidation() {
        let validator = UmpOrderingValidator()
        XCTAssertEqual(validator.validate(packet: [0x40000000], sequence: 1), .outOfOrder(expected: 0, actual: 1))
        XCTAssertEqual(validator.validate(packet: [0xD0000000], sequence: 0), .reserved)
        XCTAssertEqual(validator.validate(packet: [0x40000000], sequence: 0), .accepted(sequence: 0))
    }
}
