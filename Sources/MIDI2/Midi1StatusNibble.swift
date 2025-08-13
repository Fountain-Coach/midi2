/// 0x8..0xE
public enum Midi1StatusNibble: UInt8 {
    case noteOff        = 0x8
    case noteOn         = 0x9
    case polyPressure   = 0xA
    case controlChange  = 0xB
    case programChange  = 0xC
    case channelPressure = 0xD
    case pitchBend      = 0xE

    public init?(_ raw: UInt8) {
        self.init(rawValue: raw)
    }
}
