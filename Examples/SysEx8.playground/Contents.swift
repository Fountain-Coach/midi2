import MIDI2

// Fragment a SysEx8 payload into UMP packets and reassemble it.
let payload: [UInt8] = [0x10, 0x20, 0x30]
let packets = try SysEx8.fragment(manufacturerID: [0x00, 0x20, 0x33], payload: payload)
let (mfr, rebuilt) = try SysEx8.reassemble(packets)
print(mfr, rebuilt)
