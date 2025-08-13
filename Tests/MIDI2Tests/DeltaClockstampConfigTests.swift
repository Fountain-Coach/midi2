import XCTest
@testable import MIDI2

final class DeltaClockstampConfigTests: XCTestCase {
    func testRoundTrip() {
        let ts = DeltaClockstampConfig.TimeSignature(numerator: 4, denominatorPow2: 2)!
        let config = DeltaClockstampConfig(dctpq: 480,
                                          initialTempoMicrosecPerQN: 500_000,
                                          timeSignature: ts)!
        let packet = config.encode()
        let decoded = DeltaClockstampConfig.decode(packet)
        XCTAssertEqual(decoded, config)
    }

    func testRangeChecking() {
        // dctpq must be at least 1
        XCTAssertNil(DeltaClockstampConfig(dctpq: 0, initialTempoMicrosecPerQN: 500_000))

        // numerator must be at least 1
        let badTS = DeltaClockstampConfig.TimeSignature(numerator: 0, denominatorPow2: 2)
        XCTAssertNil(badTS)

        // decode should fail for out-of-range fields
        let invalidPacket = Ump128(word0: UInt32(0xD << 28), word1: 0, word2: 0, word3: 0)!
        XCTAssertNil(DeltaClockstampConfig.decode(invalidPacket))
    }
}
