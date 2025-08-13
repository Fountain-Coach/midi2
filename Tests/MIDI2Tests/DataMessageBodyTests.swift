import XCTest
@testable import MIDI2

final class DataMessageBodyTests: XCTestCase {
    func testRoundTripSysEx8() throws {
        let body = DataMessageBody.sysex8(manufacturerID: [0x7D], data: [0x01,0x02,0x03,0x04,0x05])
        let packets = try body.umpPackets(group: Uint4(0x0)!)
        let decoded = DataMessageBody(sysex8Packets: packets)
        XCTAssertEqual(decoded, body)
    }

    func testRoundTripMDS() throws {
        let payload = (1...20).map { UInt8($0) }
        let chunk = MixedDataSet.Chunk(
            mdsID: Uint4(0x2)!,
            numberOfChunks: 1,
            chunkNumber: 1,
            manufacturerID: 0x1234,
            deviceID: 0x5678,
            subID1: 0x9ABC,
            subID2: 0xDEF0,
            data: payload
        )
        let body = DataMessageBody.mds(chunk)
        let packets = try body.umpPackets(group: Uint4(0x0)!)
        let decoded = DataMessageBody(mdsPackets: packets)
        XCTAssertEqual(decoded, body)
    }

    func testMDSInvalidMismatchedID() throws {
        let chunk = MixedDataSet.Chunk(
            mdsID: Uint4(0x1)!,
            numberOfChunks: 1,
            chunkNumber: 1,
            manufacturerID: 0x0001,
            deviceID: 0x0002,
            subID1: 0x0003,
            subID2: 0x0004,
            data: [0x10, 0x11, 0x12]
        )
        let body = DataMessageBody.mds(chunk)
        var packets = try body.umpPackets(group: Uint4(0x0)!)
        // tamper with MDS ID in payload packet
        if packets.count > 1 {
            var raw = packets[1].rawBytes
            raw[1] = (raw[1] & 0xF0) | 0x0
            packets[1] = UmpPacket128(rawBytes: raw)!
        }
        let decoded = DataMessageBody(mdsPackets: packets)
        XCTAssertNil(decoded)
    }

    func testMDSInvalidMissingData() throws {
        let chunk = MixedDataSet.Chunk(
            mdsID: Uint4(0x3)!,
            numberOfChunks: 1,
            chunkNumber: 1,
            manufacturerID: 0x0001,
            deviceID: 0x0002,
            subID1: 0x0003,
            subID2: 0x0004,
            data: [0x20, 0x21]
        )
        let body = DataMessageBody.mds(chunk)
        var packets = try body.umpPackets(group: Uint4(0x0)!)
        // remove payload packet so data is missing
        packets.removeLast()
        let decoded = DataMessageBody(mdsPackets: packets)
        XCTAssertNil(decoded)
    }
}
