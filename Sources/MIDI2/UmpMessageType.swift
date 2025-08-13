/// UMP Message Type nibble: 0=Utility,1=System,2=MIDI1 Ch Voice,3=SysEx7,4=MIDI2 Ch Voice,5=SysEx8/MDS,13=Flex,15=Stream.
public enum UmpMessageType: UInt8, Equatable {
    /// Utility messages (type `0x0`).
    case utility            = 0x0
    /// System messages (type `0x1`).
    case system             = 0x1
    /// MIDI 1.0 Channel Voice messages (type `0x2`).
    case midi1ChannelVoice  = 0x2
    /// SysEx 7-bit messages (type `0x3`).
    case sysEx7             = 0x3
    /// MIDI 2.0 Channel Voice messages (type `0x4`).
    case midi2ChannelVoice  = 0x4
    /// Data messages such as SysEx8 and MDS (type `0x5`).
    case data               = 0x5
    /// Flex Data messages (type `0xD`).
    case flex               = 0xD
    /// Stream messages (type `0xF`).
    case stream             = 0xF

    /// Initialise from a raw nibble value.
    public init?(_ raw: UInt8) {
        self.init(rawValue: raw)
    }

    /// Convenience flag indicating if this is any kind of channel voice message.
    public var isChannel: Bool {
        switch self {
        case .midi1ChannelVoice, .midi2ChannelVoice:
            return true
        default:
            return false
        }
    }
}
