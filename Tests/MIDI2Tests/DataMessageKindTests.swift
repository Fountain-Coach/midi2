import XCTest
@testable import MIDI2

final class DataMessageKindTests: XCTestCase {
    func testKindFromBody() {
        let body = DataMessageBody.sysex8(manufacturerID: [0x7D], data: [0x01])
        XCTAssertEqual(body.kind, .sysex8)

        let chunk = MixedDataSet.Chunk(
            mdsID: Uint4(0x0)!,
            numberOfChunks: 1,
            chunkNumber: 1,
            manufacturerID: 0,
            deviceID: 0,
            subID1: 0,
            subID2: 0,
            data: []
        )
        let mds = DataMessageBody.mds(chunk)
        XCTAssertEqual(mds.kind, .mds)
    }
}
