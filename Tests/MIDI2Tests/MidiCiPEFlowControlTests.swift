import XCTest
@testable import MIDI2

/// M2-101-UM v1.2.1 §§5.10.2, 5.11.2, Tables 14/16, pp.34,36.
/// Verifies typed ACK/NAK details; no SysEx/MUID/physical-peer claim.
final class MidiCiPEFlowControlTests: XCTestCase {
    func testAckSendNextChunksExactStatusFields() throws {
        let value = try MidiCiPEFlowControl(
            action: .sendNextChunks,
            originalTransactionSubID2: 0x34,
            peStreamID: 0x05,
            peChunkNumber: 0x0134
        )
        XCTAssertEqual(value.subID2, 0x7D)
        XCTAssertEqual(value.statusCode, 0x11)
        XCTAssertEqual(value.statusData, 0)
        XCTAssertEqual(value.statusFields(),
                       [0x34, 0x11, 0, 0x05, 0x34, 0x02, 0, 0])
        XCTAssertEqual(try MidiCiPEFlowControl.decode(
            subID2: 0x7D, statusFields: value.statusFields()), value)
    }

    func testNakResendMostRecentChunkExactStatusFields() throws {
        let value = try MidiCiPEFlowControl(
            action: .resendMostRecentChunk,
            originalTransactionSubID2: 0x35,
            peStreamID: 0x7F,
            peChunkNumber: 0x3FFF
        )
        XCTAssertEqual(value.subID2, 0x7F)
        XCTAssertEqual(value.statusCode, 0x12)
        XCTAssertEqual(value.statusFields(),
                       [0x35, 0x12, 0, 0x7F, 0x7F, 0x7F, 0, 0])
        XCTAssertEqual(try MidiCiPEFlowControl.decode(
            subID2: 0x7F, statusFields: value.statusFields()), value)
    }

    func testInvalidOrLegacyNotifyDoesNotBecomeFlowControl() throws {
        let valid = try MidiCiPEFlowControl(
            action: .sendNextChunks, originalTransactionSubID2: 0x34,
            peStreamID: 1, peChunkNumber: 1
        )
        XCTAssertThrowsError(try MidiCiPEFlowControl.decode(
            subID2: 0x3F, statusFields: valid.statusFields())) {
            XCTAssertEqual($0 as? MidiCiPEFlowControl.ValidationError, .invalidSubID)
        }
        XCTAssertThrowsError(try MidiCiPEFlowControl.decode(
            subID2: 0x7F, statusFields: valid.statusFields()))
        XCTAssertThrowsError(try MidiCiPEFlowControl.decode(
            subID2: 0x7D, statusFields: [0x34, 0x11, 1, 1, 1, 0, 0, 0])) {
            XCTAssertEqual($0 as? MidiCiPEFlowControl.ValidationError, .invalidStatusData)
        }
        XCTAssertThrowsError(try MidiCiPEFlowControl.decode(
            subID2: 0x7D, statusFields: [0x34, 0x11, 0]))
    }

    func testRejectOutOfRangeIdentifiersAndChunks() {
        XCTAssertThrowsError(try MidiCiPEFlowControl(
            action: .sendNextChunks, originalTransactionSubID2: 0x20,
            peStreamID: 0, peChunkNumber: 1))
        XCTAssertThrowsError(try MidiCiPEFlowControl(
            action: .sendNextChunks, originalTransactionSubID2: 0x34,
            peStreamID: 128, peChunkNumber: 1))
        XCTAssertThrowsError(try MidiCiPEFlowControl(
            action: .resendMostRecentChunk, originalTransactionSubID2: 0x34,
            peStreamID: 1, peChunkNumber: 0x4000))
    }
}
