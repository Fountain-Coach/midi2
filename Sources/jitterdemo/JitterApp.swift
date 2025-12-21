import Foundation
import MIDI2

/// Actor responsible for running the jitter demonstration.
actor JitterApp {
    func run() async throws {
        let period: UInt32 = 1000 // microseconds
        var clock: UInt32 = 0

        for cycle in 0..<3 {
            let clockMsg = Utility.jrClock(clock)
            let clockWord = clockMsg.ump().word
            print("cycle \(cycle) clock 0x\(String(clock, radix: 16)) ->", String(format: "%08X", clockWord))

            for offset in [UInt32(10), UInt32(50)] {
                let delay = UInt64(UInt32.random(in: 0...5000)) * 1_000 // microseconds → nanoseconds
                try await Task.sleep(nanoseconds: delay)
                let tsMsg = Utility.jrTimestamp(offset)
                let abs = clock &+ offset
                let tsWord = tsMsg.ump().word
                print("  event offset \(offset) abs \(abs) ->", String(format: "%08X", tsWord))
            }

            clock &+= period
            try await Task.sleep(nanoseconds: UInt64(period) * 1_000) // microseconds → nanoseconds
        }
    }
}
