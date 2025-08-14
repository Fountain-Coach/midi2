import ArgumentParser
import MIDI2
import Foundation

struct InspectCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "inspect",
        abstract: "Decode a Universal MIDI Packet from hex words.",
        discussion: "Provide one, two, or four hexadecimal words representing a 32-, 64-, or 128-bit UMP. The packet is decoded into a human-readable form. See midi2demo(1) for examples."
    )

    @Argument(help: "One or more hex words (8 or 16 digits each)")
    var words: [String]

    func run() throws {
        guard !words.isEmpty else {
            throw ValidationError("Provide at least one word")
        }
        let parsedWords = try parse(words: words)
        switch parsedWords.count {
        case 1:
            let pkt = UmpPacket32(word: parsedWords[0])
            try decode32(pkt)
        case 2:
            guard let pkt = UmpPacket64(words: parsedWords) else {
                throw ValidationError("Invalid 64-bit packet")
            }
            try decode64(pkt)
        case 4:
            guard let pkt = Ump128(words: parsedWords) else {
                throw ValidationError("Invalid 128-bit packet")
            }
            try decode128(pkt)
        default:
            throw ValidationError("Provide 1, 2, or 4 words totaling 32, 64, or 128 bits")
        }
    }

    private func parse(words: [String]) throws -> [UInt32] {
        var result: [UInt32] = []
        for word in words {
            var clean = word.replacingOccurrences(of: "0x", with: "")
            clean = clean.replacingOccurrences(of: "_", with: "")
            let count = clean.count
            if count == 8 {
                guard let val = UInt32(clean, radix: 16) else {
                    throw ValidationError("Invalid hex word \(word)")
                }
                result.append(val)
            } else if count == 16 {
                let hi = String(clean.prefix(8))
                let lo = String(clean.suffix(8))
                guard let w0 = UInt32(hi, radix: 16), let w1 = UInt32(lo, radix: 16) else {
                    throw ValidationError("Invalid hex word \(word)")
                }
                result.append(w0)
                result.append(w1)
            } else {
                throw ValidationError("Hex words must be 8 or 16 digits")
            }
        }
        return result
    }

    private func decode32(_ packet: UmpPacket32) throws {
        let mt = UInt8((packet.word >> 28) & 0xF)
        print("Unsupported 32-bit message type 0x\(String(mt, radix: 16))")
    }

    private func decode64(_ packet: UmpPacket64) throws {
        let mt = packet.messageType
        switch mt {
        case 0x4:
            if let v = Midi2ChannelVoiceVariants(ump: packet) {
                print(String(describing: v))
            } else {
                print("Unrecognized MIDI 2.0 Channel Voice message")
            }
        case 0x3:
            if let syx = SysEx7Packet(ump: packet) {
                let dataHex = syx.data.map { String(format: "%02X", $0) }.joined(separator: " ")
                print("SysEx7 group \(syx.group.rawValue) status \(syx.status) data \(dataHex)")
            } else {
                print("Malformed SysEx7 packet")
            }
        default:
            print("Unsupported message type 0x\(String(mt, radix: 16))")
        }
    }

    private func decode128(_ packet: Ump128) throws {
        let mt = packet.messageType
        switch mt {
        case 0x5:
            do {
                let (mfr, payload) = try SysEx8.reassemble([packet.rawBytes])
                let mfrHex = mfr.map { String(format: "%02X", $0) }.joined(separator: " ")
                let payloadHex = payload.map { String(format: "%02X", $0) }.joined(separator: " ")
                print("SysEx8 manufacturer \(mfrHex) payload \(payloadHex)")
            } catch {
                print("SysEx8 reassemble failed: \(error)")
            }
        case 0xD:
            if let body = FlexDataBody(packet: packet) {
                print(String(describing: body))
            } else {
                print("Unsupported Flex Data packet")
            }
        default:
            print("Unsupported message type 0x\(String(mt, radix: 16))")
        }
    }
}

