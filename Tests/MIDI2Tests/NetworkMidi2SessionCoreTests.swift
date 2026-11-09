import XCTest
@testable import MIDI2Transports

/// M2-124-UM v1.0.1 sections 5.5, 6.1-6.17, 7.1-7.2.
final class NetworkMidi2SessionCoreTests: XCTestCase {
    private func establishedPair() throws -> (NetworkMidi2SessionCore, NetworkMidi2SessionCore) {
        var client = try NetworkMidi2SessionCore(role: .client,
            endpointName: "Client", productInstanceID: "A1")
        var host = try NetworkMidi2SessionCore(role: .host,
            endpointName: "Host", productInstanceID: "B1")
        guard case .send(let invitation) = try client.beginInvitation() else {
            throw NetworkMidi2SessionError.invalidState
        }
        let answer = try host.receive(invitation, transportPeerPermitted: true)
        guard case .send(let accepted) = answer[0] else {
            throw NetworkMidi2SessionError.invalidState
        }
        XCTAssertEqual(answer.last, .transportEstablished)
        XCTAssertEqual(try client.receive(accepted), [.transportEstablished])
        XCTAssertEqual(client.phase, .established)
        XCTAssertEqual(host.phase, .established)
        return (client, host)
    }

    func testPeerDiscoveryCannotAuthorizeTransportOrInstrument() throws {
        var client = try NetworkMidi2SessionCore(role: .client,
            endpointName: "Client", productInstanceID: "A1")
        var host = try NetworkMidi2SessionCore(role: .host,
            endpointName: "Host", productInstanceID: "B1")
        guard case .send(let invitation) = try client.beginInvitation() else {
            return XCTFail("missing invitation")
        }
        let refused = try host.receive(invitation) // Default: not permitted
        guard case .send(let bye) = refused[0] else { return XCTFail("missing refusal") }
        XCTAssertEqual(bye.code, 0xF0)
        XCTAssertEqual(bye.specificData, 0x4200)
        XCTAssertEqual(host.phase, .idle)
        XCTAssertNotEqual(client.phase, .established)
    }

    func testInvitationAcceptedAndDuplicateReplyIsIgnored() throws {
        var (client, host) = try establishedPair()
        let response = try NetworkMidi2PacketCodec.invitation(
            endpointName: "Host", productInstanceID: "B1"
        )
        let accepted = try NetworkMidi2Command(code: 0x10,
            specificData: response.specificData & 0xFF00,
            payload: response.payload)
        XCTAssertEqual(try client.receive(accepted), [])
        XCTAssertEqual(client.phase, .established)
        XCTAssertEqual(try host.receive(try NetworkMidi2PacketCodec.invitation(
            endpointName: "Client", productInstanceID: "A1"), transportPeerPermitted: true
        ).first, .send(accepted))
    }

    func testUMPDeliveryIsOrderedAndDuplicateSafe() throws {
        var (client, host) = try establishedPair()
        guard case .send(let first) = try client.sendUMP([0x10F8_0000]) else {
            return XCTFail("missing first UMP")
        }
        XCTAssertEqual(first.specificData, 0)
        XCTAssertEqual(try host.receive(first), [.umpPayloadForValidation([0x10F8_0000])])
        XCTAssertEqual(try host.receive(first), [.ignoredDuplicate(sequence: 0)])
        let future = try NetworkMidi2PacketCodec.umpData(sequenceNumber: 2, words: [0x10F8_0000])
        XCTAssertEqual(try host.receive(future),
                       [.missingSequence(expected: 1, received: 2)])
        guard case .send(let second) = try client.sendUMP([]) else {
            return XCTFail("missing idle UMP")
        }
        XCTAssertEqual(second.specificData, 1)
        XCTAssertEqual(try host.receive(second), [.idleUMP])
        XCTAssertEqual(try host.receive(future), [.umpPayloadForValidation([0x10F8_0000])])
        XCTAssertEqual(host.expectedInboundSequence, 3)
    }

    func testPingWorksWithoutEstablishedSession() throws {
        var host = try NetworkMidi2SessionCore(role: .host,
            endpointName: "H", productInstanceID: "ID")
        let ping = try NetworkMidi2Command(code: 0x20, payload: [0xDEAD_BEEF])
        XCTAssertEqual(try host.receive(ping),
            [.send(try NetworkMidi2Command(code: 0x21, payload: [0xDEAD_BEEF]))])
        XCTAssertEqual(host.phase, .idle)
        var client = try NetworkMidi2SessionCore(role: .client,
            endpointName: "C", productInstanceID: "ID")
        _ = try client.beginPing(id: 0xDEAD_BEEF)
        XCTAssertEqual(try client.receive(try NetworkMidi2Command(code: 0x21,
            payload: [0xDEAD_BEEF])), [.pingMatched(0xDEAD_BEEF)])
    }

    func testUnknownCommandProducesNotSupportedNAK() throws {
        var host = try NetworkMidi2SessionCore(role: .host,
            endpointName: "H", productInstanceID: "ID")
        let unknown = try NetworkMidi2Command(code: 0x75, specificData: 0x1234)
        let result = try host.receive(unknown)
        guard case .send(let nak) = result[0] else { return XCTFail("missing NAK") }
        XCTAssertEqual(nak.code, 0x8F)
        XCTAssertEqual(nak.specificData, 0x0100)
        XCTAssertEqual(nak.payload, [0x7500_1234])
    }

    func testMalformedPingAndUMPOutsideSession() throws {
        var host = try NetworkMidi2SessionCore(role: .host,
            endpointName: "H", productInstanceID: "ID")
        guard case .send(let nak) = try host.receive(
            NetworkMidi2Command(code: 0x20))[0] else { return XCTFail("missing NAK") }
        XCTAssertEqual(nak.specificData, 0x0300)
        let ump = try NetworkMidi2PacketCodec.umpData(
            sequenceNumber: 0, words: [0x10F8_0000])
        guard case .send(let bye) = try host.receive(ump)[0] else {
            return XCTFail("missing Bye")
        }
        XCTAssertEqual(bye.specificData, 0x0500)
        XCTAssertEqual(host.phase, .idle)
    }

    func testByeResponseAndReset() throws {
        var (client, host) = try establishedPair()
        guard case .send(let reset) = try client.beginReset() else {
            return XCTFail("missing reset")
        }
        guard case .send(let resetReply) = try host.receive(reset)[0] else {
            return XCTFail("missing reset reply")
        }
        XCTAssertEqual(resetReply.code, 0x83)
        XCTAssertEqual(try client.receive(resetReply), [])
        XCTAssertEqual(client.phase, .established)
        guard case .send(let bye) = try client.beginBye() else {
            return XCTFail("missing Bye")
        }
        guard case .send(let byeReply) = try host.receive(bye)[0] else {
            return XCTFail("missing Bye Reply")
        }
        XCTAssertEqual(byeReply.code, 0xF1)
        XCTAssertEqual(host.phase, .idle)
        XCTAssertEqual(try client.receive(byeReply), [.transportClosed])
        XCTAssertEqual(client.phase, .idle)
        XCTAssertEqual(try host.receive(bye)[0], .send(byeReply))
    }

    func testAuthenticationRequestIsExplicitlyUnsupported() throws {
        var client = try NetworkMidi2SessionCore(role: .client,
            endpointName: "C", productInstanceID: "ID")
        _ = try client.beginInvitation()
        guard case .send(let bye) = try client.receive(
            NetworkMidi2Command(code: 0x12))[0] else {
            return XCTFail("missing unsupported-auth Bye")
        }
        XCTAssertEqual(bye.specificData, 0x4500)
        XCTAssertEqual(client.phase, .idle)
    }

    func testUnsolicitedAcceptCannotEstablishSession() throws {
        var client = try NetworkMidi2SessionCore(role: .client,
            endpointName: "C", productInstanceID: "ID")
        let invite = try NetworkMidi2PacketCodec.invitation(
            endpointName: "H", productInstanceID: "ID"
        )
        let accepted = try NetworkMidi2Command(code: 0x10,
            specificData: invite.specificData & 0xFF00,
            payload: invite.payload)
        guard case .send(let bye) = try client.receive(accepted)[0] else {
            return XCTFail("missing Bye")
        }
        XCTAssertEqual(bye.specificData, 0x0600)
        XCTAssertEqual(client.phase, .idle)
    }

    func testSourceBackedTwoPeerDatagramScenarioWithoutSockets() throws {
        // Exercises both separate role instances through the real packet codec.
        // This is deterministic software-model evidence, not network interop.
        var client = try NetworkMidi2SessionCore(role: .client,
            endpointName: "Client", productInstanceID: "Client-ID")
        var host = try NetworkMidi2SessionCore(role: .host,
            endpointName: "Host", productInstanceID: "Host-ID")
        guard case .send(let invite) = try client.beginInvitation() else {
            return XCTFail("no invitation")
        }
        let onWireInvitation = try NetworkMidi2PacketCodec.encode([invite])
        let hostCommands = try NetworkMidi2PacketCodec.decode(onWireInvitation)
        let hostEffects = try host.receive(hostCommands[0], transportPeerPermitted: true)
        guard case .send(let accepted) = hostEffects[0] else {
            return XCTFail("no accepted response")
        }
        let onWireAccepted = try NetworkMidi2PacketCodec.encode([accepted])
        XCTAssertEqual(try client.receive(
            NetworkMidi2PacketCodec.decode(onWireAccepted)[0]), [.transportEstablished])
        guard case .send(let data) = try client.sendUMP([0x10F8_0000]) else {
            return XCTFail("no data command")
        }
        let onWireData = try NetworkMidi2PacketCodec.encode([data])
        XCTAssertEqual(try host.receive(
            NetworkMidi2PacketCodec.decode(onWireData)[0]),
            [.umpPayloadForValidation([0x10F8_0000])])
        XCTAssertEqual(host.phase, .established)
    }

    func testMalformedInvitationCannotCreateHostSession() throws {
        var host = try NetworkMidi2SessionCore(role: .host,
            endpointName: "Host", productInstanceID: "ID")
        let malformed = try NetworkMidi2Command(
            code: 0x01, specificData: 0x0100,
            payload: [0x0000_0000, 0x0000_0000])
        let effects = try host.receive(malformed, transportPeerPermitted: true)
        guard case .send(let bye) = effects[0] else {
            return XCTFail("malformed identity was not rejected")
        }
        XCTAssertEqual(bye.specificData, 0x0700)
        XCTAssertEqual(host.phase, .idle)
    }

    func testMalformedPendingReplyCannotEstablishTransport() throws {
        var client = try NetworkMidi2SessionCore(role: .client,
            endpointName: "Client", productInstanceID: "ID")
        _ = try client.beginInvitation()
        let malformedPending = try NetworkMidi2Command(
            code: 0x11, specificData: 0x0100, payload: [0x0000_0000, 0x0000_0000])
        let result = try client.receive(malformedPending)
        guard case .send(let bye) = result[0] else {
            return XCTFail("malformed pending reply was not rejected")
        }
        XCTAssertEqual(bye.specificData, 0x0700)
        XCTAssertEqual(client.phase, .idle)
    }
}
