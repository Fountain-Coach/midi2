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
        let cmd = Command(rawValue: bytes.first ?? 0) ?? .capInquiry
        self.command = cmd
        let len = Int(bytes.dropFirst().first ?? 0)
        if len > 0 {
            let slice = bytes.dropFirst(2).prefix(len)
            let data = Data(slice)
            self.filters = (try? JSONSerialization.jsonObject(with: data)) as? [String: UInt8]
        } else {
            self.filters = nil
        }
    }

    public init(sysEx8Bytes bytes: [UInt8]) {
        let cmd = Command(rawValue: bytes.first ?? 0) ?? .capInquiry
        self.command = cmd
        let len = Int(bytes.dropFirst().first ?? 0)
        if len > 0 {
            let slice = bytes.dropFirst(2).prefix(len)
            let data = Data(slice)
            self.filters = (try? JSONSerialization.jsonObject(with: data)) as? [String: UInt8]
        } else {
            self.filters = nil
        }
    }
}
