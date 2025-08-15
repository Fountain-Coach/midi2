import Foundation
import TeatroAppleBridge

// Publish a virtual source and echo any events received.
let bridge = try AppleMIDIBridge()
try bridge.startVirtualSource(name: "EchoSource", protocol: ._1_0)

let receiver = try AppleMIDIReceiver()
try receiver.openInput(nameMatch: "EchoSource", protocol: ._1_0) { group, words, hostTime in
    print("group", group, "words", words.map { String(format: "0x%08X", $0) }, "time", hostTime)
}

// Publish a test note to trigger the echo path.
let now = MIDIClock.nowHostTime()
try bridge.publishUMP(words: [0x20903C64], hostTime: now)

// Keep alive briefly so async callbacks can fire.
Thread.sleep(forTimeInterval: 1.0)
