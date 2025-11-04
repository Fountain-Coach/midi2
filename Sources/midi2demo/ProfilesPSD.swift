import ArgumentParser
import MIDI2
import MIDI2CI

struct ProfilesPSD: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "profiles-psd",
        abstract: "Encode/decode Profile Specific Data (SysEx8)",
        discussion: "Builds a ProfileSpecificDataMessage, prints SysEx8 bytes and decodes them back."
    )

    @Option(name: .long, help: "Profile ID")
    var profile: String = "/org.midi/piano"

    @Option(name: .long, help: "Target: channel|group|functionBlock")
    var target: String = "channel"

    @Option(name: .long, parsing: .upToNextOption, help: "Channels (0-15)")
    var channels: [Int] = [0]

    @Argument(help: "Payload bytes as hex (e.g., 01 02 03)")
    var hex: [String]

    func run() throws {
        let t: MidiCiProfilesBody.Target?
        switch target.lowercased() {
        case "channel": t = .channel
        case "group": t = .group
        case "functionblock": t = .functionBlock
        case "none": t = nil
        default: throw ValidationError("Invalid target")
        }
        let chs: [Uint4]? = channels.isEmpty ? nil : try channels.map { v in
            guard let c = Uint4(UInt8(v)) else { throw ValidationError("Invalid channel \(v)") }
            return c
        }
        let data: [UInt8] = try hex.map { h in
            let s = h.hasPrefix("0x") ? String(h.dropFirst(2)) : h
            guard let b = UInt8(s, radix: 16) else { throw ValidationError("Bad hex byte: \(h)") }
            return b
        }
        let msg = ProfileSpecificDataMessage(profileId: profile, target: t, channels: chs, data: data)
        let bytes = msg.sysEx8Bytes()
        print(bytes.map { String(format: "%02X", $0) }.joined(separator: " "))
        let parsed = ProfileSpecificDataMessage(sysEx8Bytes: bytes)
        print("Decoded -> profile=\(parsed?.profileId ?? "-") target=\(parsed?.target?.rawValue.description ?? "-") dataLen=\(parsed?.data.count ?? 0)")
    }
}

