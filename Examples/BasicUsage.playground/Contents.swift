import MIDI2

// Encode a Control Change message and obtain its UMP representation.
let group = Uint4(0)!
let channel = Uint4(0)!
let control = Uint7(64)!
let cc = ControlChange(group: group, channel: channel, control: control, value: 0x7F)
let packet = cc.ump()
print(packet)
