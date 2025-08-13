import MIDI2

// Fragment a SysEx7 payload into UMP packets and reassemble it.
let payload: [UInt8] = [0x01, 0x02, 0x03]
let packets = try SysEx7.fragment(manufacturerID: [0x7D], payload: payload)
let rebuilt = try SysEx7.reassemble(packets)
print(rebuilt)
