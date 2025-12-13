import ArgumentParser
import MIDI2
import Foundation

struct Flex: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "flex",
        abstract: "Emit Flex Data messages",
        discussion: "Choose a subcommand to send a specific Flex Data message. See midi2demo(1) for a complete list of messages and examples.",
        subcommands: [
            Tempo.self,
            TimeSignature.self,
            Key.self,
            Lyric.self,
            Metronome.self,
            ChordName.self,
            Text.self,
            Ruby.self
        ]
    )
}

extension Flex {
    struct Tempo: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Send a Flex Tempo message",
            discussion: "Use --group to choose the destination group and provide the tempo in BPM as an argument. See midi2demo(1) for examples."
        )

        @Option(name: .long, help: "Group number (0-15).")
        var group: UInt8 = 0

        @Argument(help: "Tempo in beats per minute")
        var bpm: Double

        func run() throws {
            guard let g = Uint4(group) else {
                throw ValidationError("Group out of range")
            }
            guard bpm >= 1 else {
                throw ValidationError("Tempo must be at least 1 BPM")
            }
            let tempo = try FlexDataTempo(beatsPerMinute: bpm)
            let packet = tempo.encode(group: g.rawValue)
            print(String(format: "UMP: 0x%08X 0x%08X 0x%08X 0x%08X",
                         packet.word0, packet.word1, packet.word2, packet.word3))
            if let decoded = FlexDataTempo.decode(packet) {
                print("Decoded -> BPM: \(decoded.beatsPerMinute)")
            }
        }
    }

    struct TimeSignature: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "time",
            abstract: "Send a Flex Time Signature message",
            discussion: "Use --group to choose the destination group and optionally --channel. Provide the numerator and denominator as arguments; the denominator must be a power of two. See midi2demo(1) for examples."
        )

        @Option(name: .long, help: "Group number (0-15).")
        var group: UInt8 = 0

        @Option(name: .long, help: "Channel number (0-15).")
        var channel: UInt8?

        @Argument(help: "Numerator")
        var numerator: UInt8

        @Argument(help: "Denominator (power of two, e.g. 4, 8)")
        var denominator: UInt8

        func run() throws {
            guard let g = Uint4(group) else {
                throw ValidationError("Group out of range")
            }
            let address: FlexTimeSignature.Address
            if let chVal = channel {
                guard let ch = Uint4(chVal) else {
                    throw ValidationError("Channel out of range")
                }
                address = .channel(group: g, channel: ch)
            } else {
                address = .group(g)
            }
            guard denominator != 0 && (denominator & (denominator - 1)) == 0 else {
                throw ValidationError("Denominator must be power of two")
            }
            let denomPow2 = UInt8(log2(Double(denominator)))
            let msg = try FlexTimeSignature(address: address, numerator: numerator, denominatorPow2: denomPow2)
            let packet = msg.encode()
            print(String(format: "UMP: 0x%08X 0x%08X 0x%08X 0x%08X",
                         packet.word0, packet.word1, packet.word2, packet.word3))
            if let decoded = FlexTimeSignature.decode(packet) {
                let denom = 1 << decoded.denominatorPow2
                switch decoded.address {
                case .group(let g):
                    print("Decoded -> group: \(g.rawValue) meter: \(decoded.numerator)/\(denom)")
                case .channel(let g, let c):
                    print("Decoded -> group: \(g.rawValue) channel: \(c.rawValue) meter: \(decoded.numerator)/\(denom)")
                }
            }
        }
    }

    struct Key: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Send a Flex Key Signature message",
            discussion: "Use --group to choose the destination group and optionally --channel. Provide the key signature text (e.g. C, Gm) as an argument. See midi2demo(1) for examples."
        )

        @Option(name: .long, help: "Group number (0-15).")
        var group: UInt8 = 0

        @Option(name: .long, help: "Channel number (0-15).")
        var channel: UInt8?

        @Argument(help: "Key signature text (e.g. C, Gm)")
        var key: String

        func run() throws {
            guard let g = Uint4(group) else {
                throw ValidationError("Group out of range")
            }
            guard !key.isEmpty else {
                throw ValidationError("Key signature cannot be empty")
            }
            let address: FlexKeySignature.Address
            if let chVal = channel {
                guard let ch = Uint4(chVal) else {
                    throw ValidationError("Channel out of range")
                }
                address = .channel(group: g, channel: ch)
            } else {
                address = .group(g)
            }
            let msg = FlexKeySignature(address: address, key: key)
            let packet = msg.encode()
            print(String(format: "UMP: 0x%08X 0x%08X 0x%08X 0x%08X",
                         packet.word0, packet.word1, packet.word2, packet.word3))
            if let decoded = FlexKeySignature.decode(packet) {
                switch decoded.address {
                case .group(let g):
                    print("Decoded -> group: \(g.rawValue) key: \(decoded.key)")
                case .channel(let g, let c):
                    print("Decoded -> group: \(g.rawValue) channel: \(c.rawValue) key: \(decoded.key)")
                }
            }
        }
    }

    struct Lyric: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Send a Flex Lyric message",
            discussion: "Use --group to choose the destination group and optionally --channel. Provide the lyric text as an argument. See midi2demo(1) for examples."
        )

        @Option(name: .long, help: "Group number (0-15).")
        var group: UInt8 = 0

        @Option(name: .long, help: "Channel number (0-15).")
        var channel: UInt8?

        @Argument(help: "Lyric text")
        var text: String

        func run() throws {
            guard let g = Uint4(group) else {
                throw ValidationError("Group out of range")
            }
            guard !text.isEmpty else {
                throw ValidationError("Lyric text cannot be empty")
            }
            let address: FlexLyric.Address
            if let chVal = channel {
                guard let ch = Uint4(chVal) else {
                    throw ValidationError("Channel out of range")
                }
                address = .channel(group: g, channel: ch)
            } else {
                address = .group(g)
            }
            let msg = FlexLyric(address: address, lyric: text)
            let packet = msg.encode()
            print(String(format: "UMP: 0x%08X 0x%08X 0x%08X 0x%08X",
                         packet.word0, packet.word1, packet.word2, packet.word3))
            if let decoded = FlexLyric.decode(packet) {
                switch decoded.address {
                case .group(let g):
                    print("Decoded -> group: \(g.rawValue) lyric: \(decoded.lyric)")
                case .channel(let g, let c):
                    print("Decoded -> group: \(g.rawValue) channel: \(c.rawValue) lyric: \(decoded.lyric)")
                }
            }
        }
    }

    // Placeholder subcommands for future extensions
    struct Metronome: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Flex Metronome (not yet implemented)",
            discussion: "Placeholder for future Metronome Flex Data support. See midi2demo(1) for current capabilities."
        )
        func run() throws {
            print("Metronome command not implemented yet")
        }
    }

    struct ChordName: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "chord",
            abstract: "Flex Chord Name (not yet implemented)",
            discussion: "Placeholder for future Chord Name Flex Data support. See midi2demo(1) for current capabilities."
        )
        func run() throws {
            print("ChordName command not implemented yet")
        }
    }

    struct Text: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Flex Text (not yet implemented)",
            discussion: "Placeholder for future Text Flex Data support. See midi2demo(1) for current capabilities."
        )
        func run() throws {
            print("Text command not implemented yet")
        }
    }

    struct Ruby: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Flex Ruby (not yet implemented)",
            discussion: "Placeholder for future Ruby annotation Flex Data support. See midi2demo(1) for current capabilities."
        )
        func run() throws {
            print("Ruby command not implemented yet")
        }
    }
}
