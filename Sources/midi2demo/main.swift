import ArgumentParser
import MIDI2
import MIDI2CI

struct NoteOn: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "note-on",
        abstract: "Encode and decode a MIDI 2.0 Note On message."
    )

    @Option(name: [.short, .long], help: "Group number (0-15).")
    var group: UInt8 = 0

    @Option(name: [.short, .long], help: "Channel number (0-15).")
    var channel: UInt8 = 0

    @Argument(help: "Note number (0-127).")
    var note: UInt8

    @Argument(help: "Velocity value (0-65535).")
    var velocity: UInt16

    func run() throws {
        guard let groupVal = Uint4(group),
              let channelVal = Uint4(channel),
              let noteVal = Uint7(note) else {
            throw ValidationError("Group, channel, or note out of range")
        }

        let message = Midi2NoteOn(
            group: groupVal,
            channel: channelVal,
            note: noteVal,
            velocity: velocity
        )
        let packet = message.ump()
        print(String(format: "UMP: 0x%08X 0x%08X", packet.word0, packet.word1))
        if let decoded = Midi2NoteOn(ump: packet) {
            print("Decoded -> group: \(decoded.group.rawValue) channel: \(decoded.channel.rawValue) note: \(decoded.note.rawValue) velocity: \(decoded.velocity)")
        }
    }
}

struct Midi2Demo: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Teaching-oriented MIDI 2.0 demo CLI",
        subcommands: [NoteOn.self, SysEx7Command.self, SysEx8Command.self]
    )
}

Midi2Demo.main()
