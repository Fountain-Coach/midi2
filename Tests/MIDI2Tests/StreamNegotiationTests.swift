import XCTest
@testable import MIDI2

final class StreamNegotiationTests: XCTestCase {
    func testNegotiationMIDI2Accepted() {
        let session = StreamNegotiationSession(responderCaps: .init(supportsMIDI2: true, jrTx: true, jrRx: false))
        let ep = EndpointDiscoveryMessage(majorVersion: 1, minorVersion: 0, maxGroups: 8)
        _ = session.onEndpointDiscovery(ep)
        let req = StreamConfigurationMessage(isNotification: false, jrTimestampsTx: true, jrTimestampsRx: true, protocolSelection: .midi2)
        let reply = session.onStreamConfigRequest(req)
        XCTAssertTrue(reply.isNotification)
        XCTAssertEqual(reply.protocolSelection, .midi2)
        XCTAssertTrue(reply.jrTimestampsTx)
        XCTAssertFalse(reply.jrTimestampsRx)
    }

    func testNegotiationFallsBackToMIDI1() {
        let session = StreamNegotiationSession(responderCaps: .init(supportsMIDI2: false, jrTx: true, jrRx: true))
        let req = StreamConfigurationMessage(isNotification: false, jrTimestampsTx: true, jrTimestampsRx: true, protocolSelection: .midi2)
        let reply = session.onStreamConfigRequest(req)
        XCTAssertEqual(reply.protocolSelection, .midi1)
    }
}

