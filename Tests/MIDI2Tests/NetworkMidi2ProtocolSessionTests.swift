import Foundation
import XCTest
@testable import MIDI2Transports

/// M2-124-UM v1.0.1 session-control behavior, pp. 24-30 and 37-42.
/// These are in-memory protocol tests, NOT UDP, independent-peer or hardware proof.
final class NetworkMidi2ProtocolSessionTests: XCTestCase {
    private func client() throws -> NetworkMidi2ProtocolSession {
        try NetworkMidi2ProtocolSession(
            role: .client, endpointName: "Client", productInstanceID: "C1"
        )
    }

    private func host() throws -> NetworkMidi2ProtocolSession {
        try NetworkMidi2ProtocolSession(
            role: .host, endpointName: "Host", productInstanceID: "H1"
        )
    }

    func testExplicitAdmissionThenBidirectionalUMPAndBye() throws {
        var client = try client()
        var host = try host()
        let invitation = try client.beginInvitation()
        XCTAssertEqual(client.state, .pendingInvitation)
        let response = try host.receive(invitation, hostAdmission: .allow)
        XCTAssertEqual(host.state, .established)
        XCTAssertEqual(response.outgoing.first?.code, 0x10)
        XCTAssertEqual(host.remoteIdentity?.endpointName, "Client")
        XCTAssertEqual(host.remoteIdentity?.productInstanceID, "C1")
        _ = try client.receive(try XCTUnwrap(response.outgoing.first))
        XCTAssertEqual(client.state, .established)
        XCTAssertEqual(client.remoteIdentity?.endpointName, "Host")

        let outbound = try client.makeUMPData(words: [0x4090_3C00, 0x7FFF_FFFF])
        XCTAssertEqual(outbound.umpSequenceNumber, 0)
        let received = try host.receive(outbound)
        XCTAssertEqual(received.incomingUMPWords, [0x4090_3C00, 0x7FFF_FFFF])
        XCTAssertTrue(received.outgoing.isEmpty)
        let second = try client.makeUMPData(words: [0x10F8_0000])
        XCTAssertEqual(second.umpSequenceNumber, 1)

        let hostOutbound = try host.makeUMPData(words: [0x4080_3C00, 0])
        XCTAssertEqual(hostOutbound.umpSequenceNumber, 0)
        XCTAssertEqual(try client.receive(hostOutbound).incomingUMPWords, [0x4080_3C00, 0])

        let bye = try client.beginBye()
        XCTAssertEqual(bye.code, 0xF0)
        let byeReply = try XCTUnwrap(host.receive(bye).outgoing.first)
        XCTAssertEqual(host.state, .idle)
        XCTAssertEqual(byeReply.code, 0xF1)
        _ = try client.receive(byeReply)
        XCTAssertEqual(client.state, .idle)
        XCTAssertNil(client.remoteIdentity)
        XCTAssertThrowsError(try client.makeUMPData(words: [0x10F8_0000]))
    }

    func testInvitationWithoutHostAdmissionDoesNotAuthorize() throws {
        var client = try client()
        var host = try host()
        let invite = try client.beginInvitation()
        XCTAssertThrowsError(try host.receive(invite)) {
            XCTAssertEqual($0 as? NetworkMidi2ProtocolSession.SessionError,
                           .admissionDecisionRequired)
        }
        XCTAssertEqual(host.state, .idle)
        XCTAssertNil(host.remoteIdentity)
        XCTAssertEqual(client.state, .pendingInvitation)
    }

    func testPendingHostPermissionThenAdmission() throws {
        var client = try client()
        var host = try host()
        let invite = try client.beginInvitation()
        let pending = try XCTUnwrap(host.receive(
            invite, hostAdmission: .pending
        ).outgoing.first)
        XCTAssertEqual(pending.code, 0x11)
        XCTAssertEqual(host.state, .pendingInvitation)
        _ = try client.receive(pending)
        XCTAssertEqual(client.state, .pendingInvitation)
        let accepted = try XCTUnwrap(host.receive(
            invite, hostAdmission: .allow
        ).outgoing.first)
        _ = try client.receive(accepted)
        XCTAssertEqual(host.state, .established)
        XCTAssertEqual(client.state, .established)
        XCTAssertEqual(try host.receive(invite).outgoing.first?.code, 0x10)
    }

    func testCapacityAndUserRefusalRemainTerminal() throws {
        let invite = try NetworkMidi2PacketCodec.invitation(
            endpointName: "Client", productInstanceID: "C1"
        )
        for (decision, reason) in [
            (NetworkMidi2ProtocolSession.HostAdmission.rejectTooManySessions, UInt16(0x4000)),
            (.rejectByUser, UInt16(0x4200))
        ] {
            var host = try host()
            let refusal = try XCTUnwrap(host.receive(
                invite, hostAdmission: decision
            ).outgoing.first)
            XCTAssertEqual(refusal.code, 0xF0)
            XCTAssertEqual(refusal.specificData, reason)
            XCTAssertEqual(host.state, .idle)
            XCTAssertNil(host.remoteIdentity)
        }
    }

    func testPingWorksInIdleAndBadReplyIsNAK() throws {
        var client = try client()
        var host = try host()
        let outgoing = try client.makePing(id: 0x89AB_CDEF)
        XCTAssertEqual(outgoing.code, 0x20)
        let reply = try XCTUnwrap(host.receive(outgoing).outgoing.first)
        XCTAssertEqual(reply.code, 0x21)
        XCTAssertEqual(reply.payload, [0x89AB_CDEF])
        XCTAssertEqual(host.state, .idle)
        let bad = try XCTUnwrap(client.receive(
            try NetworkMidi2Command(code: 0x21, payload: [1])
        ).outgoing.first)
        XCTAssertEqual(bad.code, 0x8F)
        XCTAssertEqual(bad.specificData, 0x2000)
        XCTAssertTrue(try client.receive(reply).outgoing.isEmpty)
    }

    func testUnknownCommandProducesNAKWithOriginalHeader() throws {
        var host = try host()
        let unknown = try NetworkMidi2Command(
            code: 0x72, specificData: 0xBEEF, payload: [0x0123_4567]
        )
        let nak = try XCTUnwrap(host.receive(unknown).outgoing.first)
        XCTAssertEqual(nak.code, 0x8F)
        XCTAssertEqual(nak.specificData, 0x0100)
        XCTAssertEqual(nak.payload, [0x7201_BEEF])
    }

    func testNoUMPBeforeSessionAndWrongRoleInvitationIsRefused() throws {
        var host = try host()
        let premature = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0, words: [0x10F8_0000]
        )
        let bye = try XCTUnwrap(host.receive(premature).outgoing.first)
        XCTAssertEqual(bye.code, 0xF0)
        XCTAssertEqual(bye.specificData, 0x0500)
        var client = try client()
        let invite = try NetworkMidi2PacketCodec.invitation(
            endpointName: "Other", productInstanceID: "P"
        )
        let wrongRoleNAK = try XCTUnwrap(client.receive(invite).outgoing.first)
        XCTAssertEqual(wrongRoleNAK.code, 0x8F)
        XCTAssertEqual(wrongRoleNAK.specificData, 0x0200)
    }

    func testInvalidInvitationAndOutOfStateAccepted() throws {
        var host = try host()
        let invalid = try NetworkMidi2Command(code: 0x01, payload: [])
        let bye = try XCTUnwrap(host.receive(invalid, hostAdmission: .allow).outgoing.first)
        XCTAssertEqual(bye.code, 0xF0)
        XCTAssertEqual(bye.specificData, 0x0700)
        XCTAssertEqual(host.state, .idle)

        var client = try client()
        let response = try NetworkMidi2Command(code: 0x10, payload: [])
        let noPending = try XCTUnwrap(client.receive(response).outgoing.first)
        XCTAssertEqual(noPending.code, 0xF0)
        XCTAssertEqual(noPending.specificData, 0x0600)
    }

    func testDifferentIdentityCannotReplaceAdmittedPeer() throws {
        var host = try host()
        let original = try NetworkMidi2PacketCodec.invitation(
            endpointName: "Client", productInstanceID: "C1"
        )
        _ = try host.receive(original, hostAdmission: .allow)
        XCTAssertEqual(host.remoteIdentity?.productInstanceID, "C1")
        let changed = try NetworkMidi2PacketCodec.invitation(
            endpointName: "Impostor", productInstanceID: "C2"
        )
        let rejected = try XCTUnwrap(host.receive(changed).outgoing.first)
        XCTAssertEqual(rejected.code, 0xF0)
        XCTAssertEqual(rejected.specificData, 0x0700)
        XCTAssertEqual(host.state, .idle)
        XCTAssertNil(host.remoteIdentity)
    }

    func testPrematureDataCancelsPendingInvitation() throws {
        var host = try host()
        let invite = try NetworkMidi2PacketCodec.invitation(
            endpointName: "Client", productInstanceID: "C1"
        )
        _ = try host.receive(invite, hostAdmission: .pending)
        XCTAssertEqual(host.state, .pendingInvitation)
        let data = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0, words: [0x10F8_0000]
        )
        let bye = try XCTUnwrap(host.receive(data).outgoing.first)
        XCTAssertEqual(bye.code, 0xF0)
        XCTAssertEqual(bye.specificData, 0x0500)
        XCTAssertEqual(host.state, .idle)
    }

    func testDuplicateUMPSequenceIsNotDeliveredTwice() throws {
        var host = try host()
        let invitation = try NetworkMidi2PacketCodec.invitation(
            endpointName: "Client", productInstanceID: "C1"
        )
        _ = try host.receive(invitation, hostAdmission: .allow)
        let packet = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0, words: [0x10F8_0000]
        )
        XCTAssertEqual(try host.receive(packet).incomingUMPWords, [0x10F8_0000])
        XCTAssertTrue(try host.receive(packet).incomingUMPWords.isEmpty)
        let next = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 1, words: [0x10FA_0000]
        )
        XCTAssertEqual(try host.receive(next).incomingUMPWords, [0x10FA_0000])
        XCTAssertTrue(try host.receive(packet).incomingUMPWords.isEmpty)
    }

    func testSequenceWrapDoesNotDiscardLegitimateZero() throws {
        var host = try host()
        let invitation = try NetworkMidi2PacketCodec.invitation(
            endpointName: "Client", productInstanceID: "C1"
        )
        _ = try host.receive(invitation, hostAdmission: .allow)
        let last = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0xFFFF, words: [0x10F8_0000]
        )
        let wrapped = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0, words: [0x10FA_0000]
        )
        XCTAssertEqual(try host.receive(last).incomingUMPWords, [0x10F8_0000])
        XCTAssertEqual(try host.receive(wrapped).incomingUMPWords, [0x10FA_0000])
        XCTAssertTrue(try host.receive(wrapped).incomingUMPWords.isEmpty)
    }

    func testByeAcknowledgedEvenWithoutSession() throws {
        var host = try host()
        let bye = try NetworkMidi2Command(code: 0xF0, specificData: 0x0400)
        XCTAssertEqual(try host.receive(bye).outgoing.first?.code, 0xF1)
        XCTAssertEqual(try host.receive(bye).outgoing.first?.code, 0xF1)
        XCTAssertEqual(host.state, .idle)
    }
}
