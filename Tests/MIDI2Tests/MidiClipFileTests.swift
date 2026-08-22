import XCTest
@testable import MIDI2

final class MidiClipFileTests: XCTestCase {
    private func words(_ data: Data) -> [UInt32] {
        stride(from: 8, to: data.count, by: 4).map { offset in
            data[offset..<offset + 4].reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
        }
    }

    func testWritesHeaderBoundariesAndStableOrder() throws {
        let clip = try MidiClipFileWriter.build(dctpq: 480, events: [
            MidiClipTimedEvent(ticks: 20, words: [0x22222222]),
            MidiClipTimedEvent(ticks: 10, words: [0x11111111]),
            MidiClipTimedEvent(ticks: 10, words: [0x33333333])
        ], group: 2)
        XCTAssertEqual(Array(clip.prefix(8)), MidiClipFileWriter.headerBytes)
        let packetWords = words(clip)
        XCTAssertEqual(Array(packetWords.prefix(4)), [0x00400000, 0x003001e0, 0x00400000, 0xf2200000])
        XCTAssertTrue(packetWords.contains(0x11111111))
        XCTAssertTrue(packetWords.contains(0x33333333))
        XCTAssertTrue(packetWords.contains(0x22222222))
        XCTAssertEqual(packetWords.last, 0xf2210000)
    }

    func testChunksLargeDeltaAtProtocolMaximum() throws {
        let clip = try MidiClipFileWriter.build(dctpq: 96, events: [
            MidiClipTimedEvent(ticks: MidiClipFileWriter.maxDeltaTicks + 2, words: [0xabcdef01])
        ])
        let packetWords = words(clip)
        XCTAssertTrue(packetWords.contains(0x004fffff))
        XCTAssertTrue(packetWords.contains(0x00000000))
        XCTAssertTrue(packetWords.contains(0x00400002))
        XCTAssertTrue(packetWords.contains(0xabcdef01))
    }

    func testConvertsSecondsUsingDctpqAndTempo() throws {
        XCTAssertEqual(MidiClipFileWriter.ticks(for: 0.5, dctpq: 480, tempoMicrosecPerQN: 500_000), 480)
        let clip = try MidiClipFileWriter.build(dctpq: 480, tempoMicrosecPerQN: 500_000, eventsInSeconds: [
            (timeSeconds: 0.5, words: [0x12345678])
        ])
        XCTAssertTrue(words(clip).contains(0x12345678))
    }

    func testRejectsInvalidConfiguration() {
        XCTAssertThrowsError(try MidiClipFileWriter.build(dctpq: 0, events: []))
        XCTAssertThrowsError(try MidiClipFileWriter.build(dctpq: 480, events: [], group: 16))
    }
}
