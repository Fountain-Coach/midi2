import Foundation

/// SysEx body for MIDI-CI Process Inquiry messages.
public struct MidiCiProcessInquiryBody: Equatable {
    /// Process Inquiry command.
    public enum Command: UInt8, CaseIterable {
        case capInquiry = 0
        case capReply = 1
        case messageReport = 2
        case messageReportReply = 3
        case endReport = 4
    }

    public var command: Command
    /// Optional bitmap/filters for message classes reported.
    public var filters: [String: UInt8]?

    public init(command: Command, filters: [String: UInt8]? = nil) {
        self.command = command
        self.filters = filters
    }

    public func sysEx7Bytes() -> [UInt8] {
        var bytes: [UInt8] = [command.rawValue & 0x7F]
        if let filters = filters,
           let json = try? JSONSerialization.data(withJSONObject: filters, options: []),
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
        if let filters = filters,
           let json = try? JSONSerialization.data(withJSONObject: filters, options: []) {
            bytes.append(UInt8(json.count))
            bytes += json
        } else {
            bytes.append(0)
        }
        return bytes
    }

    public init(sysEx7Bytes bytes: [UInt8]) {
        self = (try? MidiCiProcessInquiryBody(validatingSysEx7Bytes: bytes)) ?? MidiCiProcessInquiryBody(command: .capInquiry, filters: nil)
    }

    public init(sysEx8Bytes bytes: [UInt8]) {
        self = (try? MidiCiProcessInquiryBody(validatingSysEx8Bytes: bytes)) ?? MidiCiProcessInquiryBody(command: .capInquiry, filters: nil)
    }

    public init(validatingSysEx7Bytes bytes: [UInt8]) throws {
        try self.init(validatingBytes: bytes, sevenBit: true)
    }

    public init(validatingSysEx8Bytes bytes: [UInt8]) throws {
        try self.init(validatingBytes: bytes, sevenBit: false)
    }

    private init(validatingBytes bytes: [UInt8], sevenBit: Bool) throws {
        guard let cmd = Command(rawValue: bytes.first ?? 0) else {
            throw MIDIError.malformedPacket("invalid Process Inquiry command")
        }
        let len = Int(bytes.dropFirst().first ?? 0)
        guard bytes.count >= 2 + len else {
            throw MIDIError.malformedPacket("invalid Process Inquiry length")
        }
        let payload = bytes.dropFirst(2).prefix(len)
        if sevenBit {
            let sanitized = payload.map { $0 & 0x7F }
            let data = Data(sanitized)
            self.filters = (try? JSONSerialization.jsonObject(with: data)) as? [String: UInt8]
        } else {
            let data = Data(payload)
            self.filters = (try? JSONSerialization.jsonObject(with: data)) as? [String: UInt8]
        }
        self.command = cmd
    }
}
