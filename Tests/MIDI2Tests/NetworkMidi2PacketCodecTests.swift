import Foundation
import XCTest
@testable import MIDI2Transports

/// M2-124-UM v1.0.1 source tests, pp. 21-24, 28-30, 42, 51-52.
/// Local wire-frame behavior only; not UDP session or interoperability evidence.
final class NetworkMidi2PacketCodecTests: XCTestCase {
    func testAppendixAInvitationExactBytes() throws {
        let invitation = try NetworkMidi2PacketCodec.invitation(
            endpointName: "MyDev", productInstanceID: "8shYe3h5"
        )
        let expected: [UInt8] = [
            0x4D, 0x49, 0x44, 0x49, 0x01, 0x04, 0x02, 0x00,
            0x4D, 0x79, 0x44, 0x65, 0x76, 0x00, 0x00, 0x00,
            0x38, 0x73, 0x68, 0x59, 0x65, 0x33, 0x68, 0x35
        ]
        XCTAssertEqual(Array(try NetworkMidi2PacketCodec.encode([invitation])), expected)
        XCTAssertEqual(try NetworkMidi2PacketCodec.decode(Data(expected)), [invitation])
    }

    func testAppendixAClockUMPExactBytes() throws {
        let command = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0x0010, words: [0x10F8_0000]
        )
        let reference: [UInt8] = [
            0x4D, 0x49, 0x44, 0x49, 0xFF, 0x01, 0x00, 0x10,
            0x10, 0xF8, 0x00, 0x00
        ]
        XCTAssertEqual(Array(try NetworkMidi2PacketCodec.encode([command])), reference)
        XCTAssertEqual(try NetworkMidi2PacketCodec.decode(Data(reference)), [command])
        XCTAssertEqual(command.umpSequenceNumber, 0x0010)
    }

    func testAppendixATwoUMPNotesOneCommand() throws {
        let words: [UInt32] = [
            0x4691_4000, 0x1234_0000, 0x4681_4000, 0x0100_0000
        ]
        let command = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0x0011, words: words
        )
        let datagram = try NetworkMidi2PacketCodec.encode([command])
        XCTAssertEqual(Array(datagram.prefix(8)),
                       [0x4D, 0x49, 0x44, 0x49, 0xFF, 0x04, 0x00, 0x11])
        XCTAssertEqual(try NetworkMidi2PacketCodec.decode(datagram), [command])
    }

    func testMultipleCommandsAndSequenceWrapValues() throws {
        let first = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0xFFFF, words: [0x10F8_0000]
        )
        let second = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0x0000, words: []
        )
        let datagram = try NetworkMidi2PacketCodec.encode([first, second])
        XCTAssertEqual(try NetworkMidi2PacketCodec.decode(datagram), [first, second])
    }

    func testBigEndianAndUnknownCommandPreserved() throws {
        let ping = try NetworkMidi2Command(code: 0x20, payload: [0x0102_0304])
        let unknown = try NetworkMidi2Command(
            code: 0x3E, specificData: 0xCAFE, payload: [0xAABB_CCDD]
        )
        let datagram = try NetworkMidi2PacketCodec.encode([ping, unknown])
        XCTAssertEqual(Array(datagram), [
            0x4D, 0x49, 0x44, 0x49,
            0x20, 0x01, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04,
            0x3E, 0x01, 0xCA, 0xFE, 0xAA, 0xBB, 0xCC, 0xDD
        ])
        XCTAssertEqual(try NetworkMidi2PacketCodec.decode(datagram), [ping, unknown])
    }

    func testMalformedSignatureAndTruncatedHeaderOrPayload() {
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.decode(Data([0x4D, 0x49, 0x44]))) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .invalidPacketLength)
        }
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.decode(Data([0x00, 0x49, 0x44, 0x49]))) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .invalidSignature)
        }
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.decode(Data([
            0x4D, 0x49, 0x44, 0x49, 0x20, 0x02, 0x00
        ]))) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .truncatedCommand)
        }
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.decode(Data([
            0x4D, 0x49, 0x44, 0x49, 0x20, 0x02, 0x00, 0x00,
            0x12, 0x34, 0x56, 0x78
        ]))) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .truncatedCommand)
        }
    }

    func testUMPWordCountLimitIncludingIncomingPackets() throws {
        XCTAssertNoThrow(try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0, words: Array(repeating: 0x10F8_0000, count: 64)
        ))
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0, words: Array(repeating: 0x10F8_0000, count: 65)
        )) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .commandPayloadTooLarge)
        }
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.decode(Data([
            0x4D, 0x49, 0x44, 0x49, 0xFF, 0x41, 0x00, 0x00
        ]))) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .commandPayloadTooLarge)
        }
        let oversized = Data([
            0x4D, 0x49, 0x44, 0x49, 0xFF, 0x41, 0x00, 0x00
        ] + Array(repeating: 0, count: 65 * 4))
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.decode(oversized)) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .commandPayloadTooLarge)
        }
    }

    func testInvitationIdentityRestrictions() throws {
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.invitation(
            endpointName: "", productInstanceID: "ID"
        ))
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.invitation(
            endpointName: String(repeating: "x", count: 99), productInstanceID: "ID"
        ))
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.invitation(
            endpointName: "ok", productInstanceID: "ümlaut"
        ))
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.invitation(
            endpointName: "ok", productInstanceID: String(repeating: "X", count: 43)
        ))
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.invitation(
            endpointName: "one", productInstanceID: "two", capabilities: 0x04
        )) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .invalidInvitationCapabilities)
        }
        let capabilities = try NetworkMidi2PacketCodec.invitation(
            endpointName: "one", productInstanceID: "two", capabilities: 0x03
        )
        XCTAssertEqual(capabilities.specificData, 0x0103)
    }

    func testBoundedDatagramEmissionAndWordLength() throws {
        let maxField = try NetworkMidi2Command(
            code: 0x20, payload: Array(repeating: 0xFFFF_FFFF, count: 255)
        )
        XCTAssertEqual(
            try NetworkMidi2PacketCodec.decode(
                NetworkMidi2PacketCodec.encode([maxField])
            ), [maxField]
        )
        XCTAssertThrowsError(try NetworkMidi2Command(
            code: 0x20, payload: Array(repeating: 0, count: 256)
        ))
        XCTAssertThrowsError(try NetworkMidi2PacketCodec.encode([maxField, maxField])) {
            XCTAssertEqual($0 as? NetworkMidi2PacketError, .udpPacketTooLarge)
        }
    }

    func test1400IsSenderPolicyNotReceiverMustReject() throws {
        let maxField = try NetworkMidi2Command(
            code: 0x20, payload: Array(repeating: 0, count: 255)
        )
        let one = try NetworkMidi2PacketCodec.encode([maxField])
        let commands = Array(one.dropFirst(4))
        let received = Data([0x4D, 0x49, 0x44, 0x49] + commands + commands)
        XCTAssertGreaterThan(received.count, 1400)
        XCTAssertEqual(try NetworkMidi2PacketCodec.decode(received), [maxField, maxField])
    }
}
