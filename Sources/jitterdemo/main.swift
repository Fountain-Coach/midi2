import Foundation
import MIDI2

@main
struct JitterDemo {
    static func main() {
        let period: UInt16 = 1000 // arbitrary units
        var clock: UInt16 = 0

        for cycle in 0..<3 {
            let clockMsg = Utility.jrClock(clock)
            let clockWord = clockMsg.ump().word
            print("cycle \(cycle) clock 0x\(String(clock, radix:16)) ->", String(format: "%08X", clockWord))

            for offset in [UInt16(10), UInt16(50)] {
                usleep(useconds_t(UInt32.random(in: 0...5000)))
                let tsMsg = Utility.jrTimestamp(offset)
                let abs = clock &+ offset
                let tsWord = tsMsg.ump().word
                print("  event offset \(offset) abs \(abs) ->", String(format: "%08X", tsWord))
            }

            clock &+= period
            usleep(useconds_t(period))
        }
    }
}
