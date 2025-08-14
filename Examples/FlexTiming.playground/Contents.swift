import MIDI2

// Create a Flex tempo message and decode it.
let tempo = FlexDataTempo(beatsPerMinute: 120.0)
let packet = tempo.encode(group: 0)
let decoded = FlexDataTempo.decode(packet)
print(decoded?.beatsPerMinute ?? 0)
