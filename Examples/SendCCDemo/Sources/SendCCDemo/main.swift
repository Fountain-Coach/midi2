import TeatroAppleBridge

// Send a few Control Change and Note On/Off events to a virtual destination.
let bridge = try AppleMIDIBridge()
try bridge.startVirtualSource(name: "SendDest", protocol: ._1_0)
try bridge.selectDestination(.init(matchContains: "SendDest", group: 0, protocol: ._1_0))

let start = MIDIClock.nowHostTime()
for i in 0..<8 {
    let t = MIDIClock.secondsToHostTime(Double(i) * 0.1) + start
    try bridge.sendCC(channel: 0, cc: 7, value: UInt8(i * 16), group: 0, hostTime: t)
}
let noteTime = MIDIClock.secondsToHostTime(1.0) + start
try bridge.sendNoteOn(channel: 0, note: 60, velocity: 100, group: 0, hostTime: noteTime)
try bridge.sendNoteOff(channel: 0, note: 60, velocity: 0, group: 0, hostTime: noteTime + MIDIClock.secondsToHostTime(0.5))

print("Sent", bridge.sentEvents.count, "events")
