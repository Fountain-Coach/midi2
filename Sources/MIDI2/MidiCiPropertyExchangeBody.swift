import Foundation

/// SysEx body for MIDI-CI Property Exchange messages.
public struct MidiCiPropertyExchangeBody: Equatable {
    public enum Command: UInt8, CaseIterable {
        case capInquiry = 0
        case capReply = 1
        case get = 2
        case getReply = 3
        case set = 4
        case setReply = 5
        case subscribe = 6
        case subscribeReply = 7
        case notify = 8
        case terminate = 9
    }

    public enum Encoding: UInt8, CaseIterable {
        case json = 0
        case binary = 1
        case jsonZlib = 2
        case binaryZlib = 3
        case mcoded7 = 4
    }

    public var command: Command
    public var requestId: UInt32
    public var encoding: Encoding
    public var header: [String: String]
    public var data: [UInt8]

    public init(command: Command,
                requestId: UInt32,
                encoding: Encoding,
                header: [String: String],
                data: [UInt8]) {
        self.command = command
        self.requestId = requestId
        self.encoding = encoding
        self.header = header
        self.data = data
    }

    public func sysEx7Bytes() -> [UInt8] {
        var bytes: [UInt8] = [command.rawValue & 0x7F]
        bytes += MidiCiEncoding.encodeUInt32To7Bit(requestId)
        bytes.append(encoding.rawValue & 0x7F)
        if let h = try? JSONSerialization.data(withJSONObject: header, options: []), h.count < 0x80 {
            bytes.append(UInt8(h.count))
            bytes += h.map { $0 & 0x7F }
        } else {
            bytes.append(0)
        }
        bytes.append(UInt8(data.count & 0x7F))
        bytes += data.map { $0 & 0x7F }
        return bytes
    }

    public func sysEx8Bytes() -> [UInt8] {
        var bytes: [UInt8] = [command.rawValue]
        bytes += MidiCiEncoding.encodeUInt32To8Bit(requestId)
        bytes.append(encoding.rawValue)
        if let h = try? JSONSerialization.data(withJSONObject: header, options: []) {
            bytes.append(UInt8(h.count))
            bytes += h
        } else {
            bytes.append(0)
        }
        bytes.append(UInt8(data.count))
        bytes += data
        return bytes
    }

    public init(sysEx7Bytes bytes: [UInt8]) {
        var index = 0
        let cmd = Command(rawValue: bytes[index]) ?? .capInquiry
        index += 1
        let requestId = MidiCiEncoding.decodeUInt32From7Bit(bytes[index..<(index+4)])
        index += 4
        let encoding = Encoding(rawValue: bytes[index]) ?? .json
        index += 1
        let headerLen = Int(bytes[index])
        index += 1
        var header: [String: String] = [:]
        if headerLen > 0 {
            let data = Data(bytes[index..<index+headerLen])
            header = (try? JSONSerialization.jsonObject(with: data)) as? [String: String] ?? [:]
        }
        index += headerLen
        let dataLen = Int(bytes[index])
        index += 1
        let payload = Array(bytes[index..<index+dataLen])
        self.command = cmd
        self.requestId = requestId
        self.encoding = encoding
        self.header = header
        self.data = payload
    }

    public init(sysEx8Bytes bytes: [UInt8]) {
        var index = 0
        let cmd = Command(rawValue: bytes[index]) ?? .capInquiry
        index += 1
        let requestId = MidiCiEncoding.decodeUInt32From8Bit(bytes[index..<(index+4)])
        index += 4
        let encoding = Encoding(rawValue: bytes[index]) ?? .json
        index += 1
        let headerLen = Int(bytes[index])
        index += 1
        var header: [String: String] = [:]
        if headerLen > 0 {
            let data = Data(bytes[index..<index+headerLen])
            header = (try? JSONSerialization.jsonObject(with: data)) as? [String: String] ?? [:]
        }
        index += headerLen
        let dataLen = Int(bytes[index])
        index += 1
        let payload = Array(bytes[index..<index+dataLen])
        self.command = cmd
        self.requestId = requestId
        self.encoding = encoding
        self.header = header
        self.data = payload
    }
}
