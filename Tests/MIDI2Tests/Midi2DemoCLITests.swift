import XCTest
@testable import midi2demo

final class Midi2DemoCLITests: XCTestCase {
    func testNoteOnInvalidGroup() {
        XCTAssertThrowsError(try NoteOn.parse(["--group", "16", "--channel", "0", "60", "100"]).run())
    }

    func testSysEx7InvalidManufacturer() {
        XCTAssertThrowsError(try SysEx7Command.parse(["--manufacturer", "GG", "00"]).run())
    }

    func testSysEx8GroupOutOfRange() {
        XCTAssertThrowsError(try SysEx8Command.parse(["--group", "16", "--manufacturer", "00", "01"]).run())
    }

    func testFlexTempoNegative() {
        XCTAssertThrowsError(try Flex.Tempo.parse(["--group", "0", "0.5"]).run())
    }

    func testFlexTimeSignatureBadDenominator() {
        XCTAssertThrowsError(try Flex.TimeSignature.parse(["--group", "0", "4", "3"]).run())
    }

    func testFlexKeyEmpty() {
        XCTAssertThrowsError(try Flex.Key.parse(["--group", "0", ""]).run())
    }

    func testFlexLyricEmpty() {
        XCTAssertThrowsError(try Flex.Lyric.parse(["--group", "0", ""]).run())
    }

    func testInspectInvalidWord() {
        XCTAssertThrowsError(try InspectCommand.parse(["ZZ"]).run())
    }

    func testCIHandshakeFlags() {
        XCTAssertNoThrow(try CIHandshakeCommand.parse(["--no-common-protocol", "--unsupported-profile", "--missing-property"]).run())
    }

    func testStreamConfigHandshakeRuns() {
        XCTAssertNoThrow(try StreamHandshake.parse(["--group", "0"]).run())
    }
}
