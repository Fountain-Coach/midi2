import MIDI2

// Build a Mixed Data Set chunk and round-trip through UMP packets.
let chunk = MixedDataSet.Chunk(
    mdsID: Uint4(1)!,
    numberOfChunks: 1,
    chunkNumber: 1,
    manufacturerID: 0x7D00,
    deviceID: 0x0001,
    subID1: 0x0002,
    subID2: 0x0003,
    data: [0x01, 0x02, 0x03]
)
let packets = try MixedDataSet.fragment(chunk: chunk)
let rebuilt = try MixedDataSet.reassemble(packets)
print(rebuilt)
