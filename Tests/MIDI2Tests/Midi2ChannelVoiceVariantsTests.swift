import XCTest
@testable import MIDI2

final class Midi2ChannelVoiceVariantsTests: XCTestCase {
    func testRoundTrip() {
        let variants: [Midi2ChannelVoiceVariants] = [
            .noteOff(NoteOff(group: Uint4(1)!, channel: Uint4(0)!, noteNumber: Uint7(60)!, velocity: 0x4000)),
            .noteOn(Midi2NoteOn(group: Uint4(1)!, channel: Uint4(1)!, note: Uint7(64)!, velocity: 0x5000)),
            .polyPressure(PolyPressure(group: Uint4(2)!, channel: Uint4(3)!, noteNumber: Uint7(65)!, pressure: 0x01020304)),
            .controlChange(ControlChange(group: Uint4(0)!, channel: Uint4(2)!, control: Uint7(10)!, value: 0x11223344)),
            .programChange(ProgramChange(group: Uint4(3)!, channel: Uint4(1)!, program: Uint7(5)!, bankMsb: Uint7(1)!, bankLsb: Uint7(2)!)),
            .channelPressure(Midi2ChannelPressure(group: Uint4(0)!, channel: Uint4(0)!, pressure: 0x55667788)),
            .pitchBend(PitchBend(group: Uint4(2)!, channel: Uint4(2)!, value: 0x10203040)),
            .perNoteManagement(Midi2PerNoteManagement(group: Uint4(1)!, channel: Uint4(2)!, noteNumber: Uint7(70)!, detach: true, reset: false)),
            .regPerNoteController(Midi2RegPerNoteController(group: Uint4(1)!, channel: Uint4(0)!, noteNumber: Uint7(55)!, controller: 0x10, value: 0x0A0B0C0D)),
            .assignPerNoteController(Midi2AssignPerNoteController(group: Uint4(2)!, channel: Uint4(1)!, noteNumber: Uint7(50)!, controller: 0x90, value: 0x0E0F1011))
        ]

        for variant in variants {
            let pkt = variant.ump()
            let decoded = Midi2ChannelVoiceVariants(ump: pkt)
            XCTAssertEqual(decoded, variant)
        }
    }
}
