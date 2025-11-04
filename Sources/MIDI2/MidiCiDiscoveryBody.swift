/// SysEx body for MIDI-CI Discovery messages.
public struct MidiCiDiscoveryBody: Equatable {
    /// Unique ID of the endpoint.
    public var muid: UInt32
    /// Manufacturer identifier (1 or 3 bytes).
    public var manufacturerId: [UInt8]
    /// Device family code.
    public var deviceFamily: UInt16
    /// Device model code.
    public var deviceModel: UInt16
    /// Software revision.
    public var softwareRev: UInt32
    /// Supported categories as booleans.
    public struct Categories: Equatable {
        public var profiles: Bool
        public var propertyExchange: Bool
        public var processInquiry: Bool
        public init(profiles: Bool, propertyExchange: Bool, processInquiry: Bool) {
            self.profiles = profiles
            self.propertyExchange = propertyExchange
            self.processInquiry = processInquiry
        }
    }
    public var categories: Categories
    /// Maximum SysEx payload in bytes.
    public var maxSysEx: UInt32

    public init(muid: UInt32,
                manufacturerId: [UInt8],
                deviceFamily: UInt16,
                deviceModel: UInt16,
                softwareRev: UInt32,
                categories: Categories,
                maxSysEx: UInt32) {
        self.muid = muid
        self.manufacturerId = manufacturerId
        self.deviceFamily = deviceFamily
        self.deviceModel = deviceModel
        self.softwareRev = softwareRev
        self.categories = categories
        self.maxSysEx = maxSysEx
    }

    public func validate() throws {
        // manufacturerId must be 1-byte (non-zero) or 3-byte starting with 0x00
        if manufacturerId.count == 1 {
            guard manufacturerId[0] != 0x00 else { throw MIDIError.malformedPacket("invalid 1-byte manufacturerId 0x00") }
        } else if manufacturerId.count == 3 {
            guard manufacturerId[0] == 0x00 else { throw MIDIError.malformedPacket("3-byte manufacturerId must start with 0x00") }
        } else {
            throw MIDIError.malformedPacket("manufacturerId must be 1 or 3 bytes")
        }
    }

    /// Serialize to SysEx7 payload bytes.
    public func sysEx7Bytes() -> [UInt8] {
        var bytes: [UInt8] = []
        bytes += MidiCiEncoding.encodeUInt32To7Bit(muid)
        bytes += manufacturerId
        bytes += MidiCiEncoding.encodeUInt16To7Bit(deviceFamily)
        bytes += MidiCiEncoding.encodeUInt16To7Bit(deviceModel)
        bytes += MidiCiEncoding.encodeUInt32To7Bit(softwareRev)
        var cat: UInt8 = 0
        if categories.profiles { cat |= 0x01 }
        if categories.propertyExchange { cat |= 0x02 }
        if categories.processInquiry { cat |= 0x04 }
        bytes.append(cat)
        bytes += MidiCiEncoding.encodeUInt32To7Bit(maxSysEx)
        return bytes
    }

    /// Serialize to SysEx8 payload bytes.
    public func sysEx8Bytes() -> [UInt8] {
        var bytes: [UInt8] = []
        bytes += MidiCiEncoding.encodeUInt32To8Bit(muid)
        bytes += manufacturerId
        bytes += MidiCiEncoding.encodeUInt16To8Bit(deviceFamily)
        bytes += MidiCiEncoding.encodeUInt16To8Bit(deviceModel)
        bytes += MidiCiEncoding.encodeUInt32To8Bit(softwareRev)
        var cat: UInt8 = 0
        if categories.profiles { cat |= 0x01 }
        if categories.propertyExchange { cat |= 0x02 }
        if categories.processInquiry { cat |= 0x04 }
        bytes.append(cat)
        bytes += MidiCiEncoding.encodeUInt32To8Bit(maxSysEx)
        return bytes
    }

    /// Deserialize from SysEx7 payload bytes.
    public init?(sysEx7Bytes bytes: [UInt8]) {
        var index = 0
        guard bytes.count >= 4 else { return nil }
        let muid = MidiCiEncoding.decodeUInt32From7Bit(bytes[index..<(index+4)])
        index += 4
        guard bytes.count > index else { return nil }
        let manufacturerId: [UInt8]
        if bytes[index] == 0x00 {
            guard bytes.count >= index + 3 else { return nil }
            manufacturerId = Array(bytes[index..<(index+3)])
            index += 3
        } else {
            manufacturerId = [bytes[index]]
            index += 1
        }
        guard bytes.count >= index + 2 else { return nil }
        let deviceFamily = MidiCiEncoding.decodeUInt16From7Bit(bytes[index..<(index+2)])
        index += 2
        guard bytes.count >= index + 2 else { return nil }
        let deviceModel = MidiCiEncoding.decodeUInt16From7Bit(bytes[index..<(index+2)])
        index += 2
        guard bytes.count >= index + 4 else { return nil }
        let softwareRev = MidiCiEncoding.decodeUInt32From7Bit(bytes[index..<(index+4)])
        index += 4
        guard bytes.count > index else { return nil }
        let catByte = bytes[index]
        index += 1
        let categories = Categories(profiles: (catByte & 0x01) != 0,
                                    propertyExchange: (catByte & 0x02) != 0,
                                    processInquiry: (catByte & 0x04) != 0)
        guard bytes.count >= index + 4 else { return nil }
        let maxSysEx = MidiCiEncoding.decodeUInt32From7Bit(bytes[index..<(index+4)])
        self.init(muid: muid,
                  manufacturerId: manufacturerId,
                  deviceFamily: deviceFamily,
                  deviceModel: deviceModel,
                  softwareRev: softwareRev,
                  categories: categories,
                  maxSysEx: maxSysEx)
    }

    /// Deserialize from SysEx8 payload bytes.
    public init?(sysEx8Bytes bytes: [UInt8]) {
        var index = 0
        guard bytes.count >= 4 else { return nil }
        let muid = MidiCiEncoding.decodeUInt32From8Bit(bytes[index..<(index+4)])
        index += 4
        guard bytes.count > index else { return nil }
        let manufacturerId: [UInt8]
        if bytes[index] == 0x00 {
            guard bytes.count >= index + 3 else { return nil }
            manufacturerId = Array(bytes[index..<(index+3)])
            index += 3
        } else {
            manufacturerId = [bytes[index]]
            index += 1
        }
        guard bytes.count >= index + 2 else { return nil }
        let deviceFamily = MidiCiEncoding.decodeUInt16From8Bit(bytes[index..<(index+2)])
        index += 2
        guard bytes.count >= index + 2 else { return nil }
        let deviceModel = MidiCiEncoding.decodeUInt16From8Bit(bytes[index..<(index+2)])
        index += 2
        guard bytes.count >= index + 4 else { return nil }
        let softwareRev = MidiCiEncoding.decodeUInt32From8Bit(bytes[index..<(index+4)])
        index += 4
        guard bytes.count > index else { return nil }
        let catByte = bytes[index]
        index += 1
        let categories = Categories(profiles: (catByte & 0x01) != 0,
                                    propertyExchange: (catByte & 0x02) != 0,
                                    processInquiry: (catByte & 0x04) != 0)
        guard bytes.count >= index + 4 else { return nil }
        let maxSysEx = MidiCiEncoding.decodeUInt32From8Bit(bytes[index..<(index+4)])
        self.init(muid: muid,
                  manufacturerId: manufacturerId,
                  deviceFamily: deviceFamily,
                  deviceModel: deviceModel,
                  softwareRev: softwareRev,
                  categories: categories,
                  maxSysEx: maxSysEx)
    }
}
