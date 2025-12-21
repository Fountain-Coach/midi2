import Foundation

public enum MidiClipFileError: Error {
    case invalidDctpq
    case invalidGroup
}

public struct MidiClipTimedEvent: Equatable {
    public let ticks: UInt32
    public let words: [UInt32]

    public init(ticks: UInt32, words: [UInt32]) {
        self.ticks = ticks
        self.words = words
    }
}

public enum MidiClipFileWriter {
    public static let headerBytes: [UInt8] = [0x53, 0x4D, 0x46, 0x32, 0x43, 0x4C, 0x49, 0x50] // "SMF2CLIP"
    public static let maxDeltaTicks: UInt32 = 0xFFFFF

    public static func ticks(for seconds: Double, dctpq: UInt16, tempoMicrosecPerQN: UInt32) -> UInt32 {
        guard seconds.isFinite, seconds >= 0, dctpq > 0, tempoMicrosecPerQN > 0 else { return 0 }
        let secondsPerQN = Double(tempoMicrosecPerQN) / 1_000_000.0
        let ticksPerSecond = Double(dctpq) / secondsPerQN
        let raw = seconds * ticksPerSecond
        if raw <= 0 { return 0 }
        return UInt32(min(raw.rounded(), Double(UInt32.max)))
    }

    public static func build(
        dctpq: UInt16,
        events: [MidiClipTimedEvent],
        group: UInt8 = 0
    ) throws -> Data {
        guard dctpq >= 1 else { throw MidiClipFileError.invalidDctpq }
        guard group <= 0xF, let groupNibble = Uint4(group) else { throw MidiClipFileError.invalidGroup }

        var packets: [UInt32] = []
        packets.reserveCapacity(events.count * 3 + 6)

        func appendDcs(_ value: UInt32) {
            packets.append(UtilityBody(opcode: .deltaClockstamp, value: value).ump().word)
        }

        func appendNoop() {
            packets.append(UtilityBody(opcode: .noop, value: 0).ump().word)
        }

        // Clip configuration header: DCS(0) + DCTPQ.
        appendDcs(0)
        packets.append(UtilityBody(opcode: .dctpq, value: UInt32(dctpq)).ump().word)

        // Clip sequence data: DCS(0) + Start of Clip.
        appendDcs(0)
        packets.append(StreamBody(opcode: .startOfClip).ump(group: groupNibble).word)

        let ordered = events.enumerated().sorted {
            if $0.element.ticks == $1.element.ticks { return $0.offset < $1.offset }
            return $0.element.ticks < $1.element.ticks
        }

        var lastTick: UInt32 = 0
        for entry in ordered {
            let event = entry.element
            var delta = event.ticks >= lastTick ? event.ticks - lastTick : 0
            while delta > maxDeltaTicks {
                appendDcs(maxDeltaTicks)
                appendNoop()
                delta -= maxDeltaTicks
                lastTick &+= maxDeltaTicks
            }
            appendDcs(delta)
            packets.append(contentsOf: event.words)
            lastTick = event.ticks
        }

        // End of Clip (same tick as last event by default).
        appendDcs(0)
        packets.append(StreamBody(opcode: .endOfClip).ump(group: groupNibble).word)

        var data = Data(headerBytes)
        for word in packets {
            var be = word.bigEndian
            withUnsafeBytes(of: &be) { data.append(contentsOf: $0) }
        }
        return data
    }

    public static func build(
        dctpq: UInt16,
        tempoMicrosecPerQN: UInt32,
        eventsInSeconds: [(timeSeconds: Double, words: [UInt32])],
        group: UInt8 = 0
    ) throws -> Data {
        let events = eventsInSeconds.map {
            MidiClipTimedEvent(ticks: ticks(for: $0.timeSeconds, dctpq: dctpq, tempoMicrosecPerQN: tempoMicrosecPerQN), words: $0.words)
        }
        return try build(dctpq: dctpq, events: events, group: group)
    }
}
