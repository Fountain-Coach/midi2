import XCTest
@testable import MIDI2
@testable import MIDI2CI

final class MidiCiDiscoveryResponderTests: XCTestCase {
    func testDiscoveryRequestProducesAdvertisedInstrumentResponse() throws {
        let advertisement = MidiCiDiscoveryBody(
            muid: 0x0A0B0C0D,
            manufacturerId: [0x00, 0x20, 0x33],
            deviceFamily: 0x1234,
            deviceModel: 0x5678,
            softwareRev: 0x00010001,
            categories: .init(profiles: true, propertyExchange: true, processInquiry: true),
            maxSysEx: 2048
        )
        let responder = try MidiCiDiscoveryResponder(advertisement: advertisement)
        let requestBody = MidiCiDiscoveryBody(
            muid: 0,
            manufacturerId: [0x7D],
            deviceFamily: 0,
            deviceModel: 0,
            softwareRev: 0,
            categories: .init(profiles: false, propertyExchange: false, processInquiry: false),
            maxSysEx: 512
        )
        let request = MidiCiEnvelope(
            scope: .nonRealtime,
            subId2: 0x70,
            body: .discovery(requestBody)
        )

        let response = try XCTUnwrap(responder.respond(to: request))
        guard case .discovery(let body) = response.body else {
            return XCTFail("expected MIDI-CI Discovery response")
        }
        XCTAssertEqual(body, advertisement)
        XCTAssertEqual(response.sysEx8Payload(), try XCTUnwrap(
            MidiCiEnvelope(sysEx8Payload: response.sysEx8Payload()).sysEx8Payload()
        ))
    }

    func testResponderDoesNotClaimOtherCIOperations() throws {
        let responder = try MidiCiDiscoveryResponder(advertisement: MidiCiDiscoveryBody(
            muid: 1,
            manufacturerId: [0x7D],
            deviceFamily: 0,
            deviceModel: 0,
            softwareRev: 1,
            categories: .init(profiles: false, propertyExchange: false, processInquiry: false),
            maxSysEx: 128
        ))
        let request = MidiCiEnvelope(
            scope: .nonRealtime,
            subId2: 0x72,
            body: .profiles(MidiCiProfilesBody(
                command: .inquiry,
                profileId: "com.example.profile",
                target: .channel,
                channels: [Uint4(0)!]
            ))
        )

        XCTAssertNil(responder.respond(to: request))
    }
}
