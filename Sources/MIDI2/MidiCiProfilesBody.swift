import Foundation

/// SysEx body for MIDI-CI Profile configuration messages.
public struct MidiCiProfilesBody: Equatable {
    /// Profile configuration command.
    public enum Command: UInt8, CaseIterable {
        case inquiry = 0
        case reply = 1
        case addedReport = 2
        case removedReport = 3
        case setOn = 4
        case setOff = 5
        case enabledReport = 6
        case disabledReport = 7
        case detailsInquiry = 8
        case detailsReply = 9
        case profileSpecificData = 10
    }

    public enum Target: UInt8, CaseIterable {
        case channel = 0
        case group = 1
        case functionBlock = 2
    }

    public var command: Command
    public var profileId: String
    public var target: Target?
    public var channels: [Uint4]?
    public var details: [String: UInt8]?

    public init(command: Command,
                profileId: String,
                target: Target? = nil,
                channels: [Uint4]? = nil,
                details: [String: UInt8]? = nil) {
        self.command = command
        self.profileId = profileId
        self.target = target
        self.channels = channels
        self.details = details
    }

    public func sysEx7Bytes() -> [UInt8] {
        var bytes: [UInt8] = [command.rawValue & 0x7F]
        let idBytes = profileId.utf8.map { $0 & 0x7F }
        bytes.append(UInt8(idBytes.count))
        bytes += idBytes
        if let target = target {
            bytes.append(target.rawValue & 0x7F)
        } else {
            bytes.append(0x7F)
        }
        if let channels = channels {
            bytes.append(UInt8(channels.count & 0x7F))
            bytes += channels.map { $0.rawValue & 0x0F }
        } else {
            bytes.append(0)
        }
        if let details = details,
           let json = try? JSONSerialization.data(withJSONObject: details, options: []),
           json.count < 0x80 {
            bytes.append(UInt8(json.count))
            bytes += json.map { $0 & 0x7F }
        } else {
            bytes.append(0)
        }
        return bytes
    }

    public func sysEx8Bytes() -> [UInt8] {
        var bytes: [UInt8] = [command.rawValue]
        let idBytes = Array(profileId.utf8)
        bytes.append(UInt8(idBytes.count))
        bytes += idBytes
        if let target = target {
            bytes.append(target.rawValue)
        } else {
            bytes.append(0xFF)
        }
        if let channels = channels {
            bytes.append(UInt8(channels.count))
            bytes += channels.map { $0.rawValue }
        } else {
            bytes.append(0)
        }
        if let details = details,
           let json = try? JSONSerialization.data(withJSONObject: details, options: []) {
            bytes.append(UInt8(json.count))
            bytes += json
        } else {
            bytes.append(0)
        }
        return bytes
    }

    public init(sysEx7Bytes bytes: [UInt8]) {
        var index = 0
        let cmd = Command(rawValue: bytes[safe: index] ?? 0) ?? .inquiry
        index += 1
        let idLen = Int(bytes[safe: index] ?? 0)
        index += 1
        guard bytes.count >= index + idLen else {
            self = MidiCiProfilesBody(command: cmd, profileId: "")
            return
        }
        let idBytes = Array(bytes[index..<index+idLen])
        index += idLen
        let profileId = String(bytes: idBytes, encoding: .utf8) ?? ""
        let targetRaw = bytes[safe: index] ?? 0x7F
        index += 1
        let target = (targetRaw <= 0x02) ? Target(rawValue: targetRaw) : nil
        let chanCount = Int(bytes[safe: index] ?? 0)
        index += 1
        if chanCount > 0x10 {
            self = MidiCiProfilesBody(command: cmd, profileId: "")
            return
        }
        var channels: [Uint4] = []
        for _ in 0..<chanCount {
            guard let chVal = bytes[safe: index], let ch = Uint4(chVal) else { break }
            channels.append(ch)
            index += 1
        }
        let detailsLen = Int(bytes[safe: index] ?? 0)
        index += 1
        var details: [String: UInt8]? = nil
        if detailsLen > 0, bytes.count >= index + detailsLen {
            let data = Data(bytes[index..<index+detailsLen])
            details = (try? JSONSerialization.jsonObject(with: data)) as? [String: UInt8]
        }
        guard !profileId.isEmpty else {
            self = MidiCiProfilesBody(command: cmd, profileId: "")
            return
        }
        self.command = cmd
        self.profileId = profileId
        self.target = target
        self.channels = channels.isEmpty ? nil : channels
        self.details = details
    }

    public init(sysEx8Bytes bytes: [UInt8]) {
        var index = 0
        let cmd = Command(rawValue: bytes[safe: index] ?? 0) ?? .inquiry
        index += 1
        let idLen = Int(bytes[safe: index] ?? 0)
        index += 1
        guard bytes.count >= index + idLen else {
            self = MidiCiProfilesBody(command: cmd, profileId: "")
            return
        }
        let idBytes = Array(bytes[index..<index+idLen])
        index += idLen
        let profileId = String(bytes: idBytes, encoding: .utf8) ?? ""
        let targetRaw = bytes[safe: index] ?? 0xFF
        index += 1
        let target = (targetRaw <= 0x02) ? Target(rawValue: targetRaw) : nil
        let chanCount = Int(bytes[safe: index] ?? 0)
        index += 1
        if chanCount > 0x10 {
            self = MidiCiProfilesBody(command: cmd, profileId: "")
            return
        }
        var channels: [Uint4] = []
        for _ in 0..<chanCount {
            guard let chVal = bytes[safe: index], let ch = Uint4(chVal) else { break }
            channels.append(ch)
            index += 1
        }
        let detailsLen = Int(bytes[safe: index] ?? 0)
        index += 1
        var details: [String: UInt8]? = nil
        if detailsLen > 0, bytes.count >= index + detailsLen {
            let data = Data(bytes[index..<index+detailsLen])
            details = (try? JSONSerialization.jsonObject(with: data)) as? [String: UInt8]
        }
        guard !profileId.isEmpty else {
            self = MidiCiProfilesBody(command: cmd, profileId: "")
            return
        }
        self.command = cmd
        self.profileId = profileId
        self.target = target
        self.channels = channels.isEmpty ? nil : channels
        self.details = details
    }
}
