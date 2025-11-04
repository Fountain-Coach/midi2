import MIDI2

/// Profile-specific data message (SysEx 7/8), carrying opaque payload for a profile.
public struct ProfileSpecificDataMessage: Equatable {
    public var profileId: String
    public var target: MidiCiProfilesBody.Target?
    public var channels: [Uint4]?
    public var data: [UInt8]

    public init(profileId: String, target: MidiCiProfilesBody.Target? = nil, channels: [Uint4]? = nil, data: [UInt8]) {
        self.profileId = profileId
        self.target = target
        self.channels = channels
        self.data = data
    }

    public func sysEx7Bytes() -> [UInt8] {
        var bytes: [UInt8] = [MidiCiProfilesBody.Command.profileSpecificData.rawValue & 0x7F]
        let id = profileId.utf8.map { $0 & 0x7F }
        bytes.append(UInt8(id.count & 0x7F))
        bytes += id
        if let target = target { bytes.append(target.rawValue & 0x7F) } else { bytes.append(0x7F) }
        if let channels = channels {
            bytes.append(UInt8(channels.count & 0x7F))
            bytes += channels.map { $0.rawValue & 0x0F }
        } else {
            bytes.append(0)
        }
        let len = min(0x7F, data.count)
        bytes.append(UInt8(len))
        bytes += data.prefix(len).map { $0 & 0x7F }
        return bytes
    }

    public func sysEx8Bytes() -> [UInt8] {
        var bytes: [UInt8] = [MidiCiProfilesBody.Command.profileSpecificData.rawValue]
        let id = Array(profileId.utf8)
        bytes.append(UInt8(id.count))
        bytes += id
        if let target = target { bytes.append(target.rawValue) } else { bytes.append(0xFF) }
        if let channels = channels {
            bytes.append(UInt8(channels.count))
            bytes += channels.map { $0.rawValue }
        } else { bytes.append(0) }
        let len = min(0xFF, data.count)
        bytes.append(UInt8(len))
        bytes += data.prefix(len)
        return bytes
    }

    public init?(sysEx7Bytes bytes: [UInt8]) {
        var idx = 0
        guard bytes.count >= 2 else { return nil }
        guard MidiCiProfilesBody.Command(rawValue: bytes[idx] & 0x7F) == .profileSpecificData else { return nil }
        idx += 1
        let idLen = Int(bytes[idx] & 0x7F)
        idx += 1
        guard bytes.count >= idx + idLen + 2 else { return nil }
        let idBytes = Array(bytes[idx..<(idx+idLen)])
        idx += idLen
        let profileId = String(bytes: idBytes, encoding: .utf8) ?? ""
        let target = MidiCiProfilesBody.Target(rawValue: bytes[idx] & 0x7F)
        idx += 1
        let chanCount = Int(bytes[idx] & 0x7F)
        idx += 1
        var channels: [Uint4] = []
        if chanCount > 0 {
            guard bytes.count >= idx + chanCount else { return nil }
            for _ in 0..<chanCount { channels.append(Uint4(bytes[idx] & 0x0F)!) ; idx += 1 }
        }
        guard bytes.count > idx else { return nil }
        let dataLen = Int(bytes[idx] & 0x7F)
        idx += 1
        guard bytes.count >= idx + dataLen else { return nil }
        let payload = bytes[idx..<(idx+dataLen)].map { $0 & 0x7F }
        self.init(profileId: profileId, target: target, channels: channels.isEmpty ? nil : channels, data: payload)
    }

    public init?(sysEx8Bytes bytes: [UInt8]) {
        var idx = 0
        guard bytes.count >= 2 else { return nil }
        guard MidiCiProfilesBody.Command(rawValue: bytes[idx]) == .profileSpecificData else { return nil }
        idx += 1
        let idLen = Int(bytes[idx])
        idx += 1
        guard bytes.count >= idx + idLen + 2 else { return nil }
        let idBytes = Array(bytes[idx..<(idx+idLen)])
        idx += idLen
        let profileId = String(bytes: idBytes, encoding: .utf8) ?? ""
        let target = MidiCiProfilesBody.Target(rawValue: bytes[idx])
        idx += 1
        let chanCount = Int(bytes[idx])
        idx += 1
        var channels: [Uint4] = []
        if chanCount > 0 {
            guard bytes.count >= idx + chanCount else { return nil }
            for _ in 0..<chanCount { channels.append(Uint4(bytes[idx])!) ; idx += 1 }
        }
        guard bytes.count > idx else { return nil }
        let dataLen = Int(bytes[idx])
        idx += 1
        guard bytes.count >= idx + dataLen else { return nil }
        let payload = Array(bytes[idx..<(idx+dataLen)])
        self.init(profileId: profileId, target: target, channels: channels.isEmpty ? nil : channels, data: payload)
    }
}

