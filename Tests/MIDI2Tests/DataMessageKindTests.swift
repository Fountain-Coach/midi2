import XCTest
@testable import MIDI2

final class DataMessageKindTests: XCTestCase {
    func testKindFromBody() {
        let body = DataMessageBody.sysex8(manufacturerID: [0x7D], data: [0x01])
        XCTAssertEqual(body.kind, .sysex8)

        let mds = DataMessageBody.mds
        XCTAssertEqual(mds.kind, .mds)
    }
}
