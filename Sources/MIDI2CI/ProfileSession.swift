import MIDI2

/// Minimal in-memory Profiles session implementing enable/disable flows and inquiry.
public final class ProfileSession {
    /// Profiles that the device supports (by profileId).
    public var supportedProfiles: Set<String>
    /// Enabled profiles keyed by target and optional channel list string key.
    /// Key format: "T:<target>|C:<comma-separated channels or *>".
    private var enabled: [String: Set<String>] = [:]
    /// Optional hook invoked when a profile is enabled/disabled; set by host to update FB associations.
    public var onProfileAssociationChange: ((String, MidiCiProfilesBody.Target?, [Uint4]?, Bool) -> Void)?

    public init(supportedProfiles: Set<String> = []) {
        self.supportedProfiles = supportedProfiles
    }

    private func channelMaskBytes(_ channels: [Uint4]?) -> (UInt8, UInt8) {
        guard let channels, !channels.isEmpty else { return (0, 0) }
        var mask: UInt16 = 0
        for ch in channels { mask |= (1 << UInt16(ch.rawValue)) }
        let low = UInt8(mask & 0x00FF)
        let high = UInt8((mask >> 8) & 0x00FF)
        return (low, high)
    }

    /// Emit an addedReport for a newly available profile at the given scope.
    public func reportAdded(profileId: String, target: MidiCiProfilesBody.Target?, channels: [Uint4]?) -> MidiCiProfilesBody {
        let (cmL, cmH) = channelMaskBytes(channels)
        let details: [String: UInt8] = ["ok": 1, "cmL": cmL, "cmH": cmH]
        return MidiCiProfilesBody(command: .addedReport, profileId: profileId, target: target, channels: channels, details: details)
    }

    /// Emit a removedReport for a no-longer-available profile at the given scope.
    public func reportRemoved(profileId: String, target: MidiCiProfilesBody.Target?, channels: [Uint4]?) -> MidiCiProfilesBody {
        let (cmL, cmH) = channelMaskBytes(channels)
        let details: [String: UInt8] = ["ok": 1, "cmL": cmL, "cmH": cmH]
        return MidiCiProfilesBody(command: .removedReport, profileId: profileId, target: target, channels: channels, details: details)
    }

    private func key(for target: MidiCiProfilesBody.Target?, channels: [Uint4]?) -> String {
        let t = target?.rawValue ?? 0xFF
        let c: String
        if let channels = channels, !channels.isEmpty {
            c = channels.map { String($0.rawValue) }.joined(separator: ",")
        } else {
            c = "*"
        }
        return "T:\(t)|C:\(c)"
    }

    /// Handle a single Profiles message and return any reports/replies.
    public func handle(_ body: MidiCiProfilesBody) -> [MidiCiProfilesBody] {
        switch body.command {
        case .inquiry:
            let k = key(for: body.target, channels: body.channels)
            let isSupported = supportedProfiles.contains(body.profileId)
            let isEnabled = enabled[k]?.contains(body.profileId) ?? false
            let (cmL, cmH) = channelMaskBytes(body.channels)
            let details: [String: UInt8] = [
                "ver": 1,
                "supported": isSupported ? 1 : 0,
                "enabled": isEnabled ? 1 : 0,
                "cmL": cmL,
                "cmH": cmH
            ]
            return [MidiCiProfilesBody(command: .reply, profileId: body.profileId, target: body.target, channels: body.channels, details: details)]

        case .setOn:
            guard supportedProfiles.contains(body.profileId) else {
                // Unsupported -> disabled report with ok=0
                let (cmL, cmH) = channelMaskBytes(body.channels)
                let details: [String: UInt8] = ["ok": 0, "cmL": cmL, "cmH": cmH]
                return [MidiCiProfilesBody(command: .disabledReport, profileId: body.profileId, target: body.target, channels: body.channels, details: details)]
            }
            let k = key(for: body.target, channels: body.channels)
            var set = enabled[k] ?? []
            set.insert(body.profileId)
            enabled[k] = set
            onProfileAssociationChange?(body.profileId, body.target, body.channels, true)
            let (cmL, cmH) = channelMaskBytes(body.channels)
            let details: [String: UInt8] = ["ok": 1, "cmL": cmL, "cmH": cmH]
            return [MidiCiProfilesBody(command: .enabledReport, profileId: body.profileId, target: body.target, channels: body.channels, details: details)]

        case .setOff:
            let k = key(for: body.target, channels: body.channels)
            if var set = enabled[k] {
                set.remove(body.profileId)
                enabled[k] = set
            }
            onProfileAssociationChange?(body.profileId, body.target, body.channels, false)
            let (cmL, cmH) = channelMaskBytes(body.channels)
            let details: [String: UInt8] = ["ok": 1, "cmL": cmL, "cmH": cmH]
            return [MidiCiProfilesBody(command: .disabledReport, profileId: body.profileId, target: body.target, channels: body.channels, details: details)]

        case .detailsInquiry:
            guard !body.profileId.isEmpty else { return [] }
            // Provide details: version and channel mask for the addressed scope
            let (cmL, cmH) = channelMaskBytes(body.channels)
            return [MidiCiProfilesBody(command: .detailsReply, profileId: body.profileId, target: body.target, channels: body.channels, details: ["ver": 1, "cmL": cmL, "cmH": cmH])]

        default:
            return []
        }
    }
}
