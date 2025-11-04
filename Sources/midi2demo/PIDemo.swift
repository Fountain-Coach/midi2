import ArgumentParser
import MIDI2
import MIDI2CI

struct PIDemo: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "pi-demo",
        abstract: "Demonstrate MIDI-CI Process Inquiry capability and report flows"
    )

    @Option(name: .long, parsing: .upToNextOption, help: "Initial capability filters (key=value)")
    var filter: [String] = []

    func run() throws {
        var caps: [String: UInt8] = [:]
        for f in filter {
            let parts = f.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2, let v = UInt8(parts[1]) else { throw ValidationError("Bad filter: \(f)") }
            caps[parts[0]] = v
        }
        let session = ProcessInquirySession(filters: caps)
        // Capability inquiry
        let capReply = session.handle(MidiCiProcessInquiryBody(command: .capInquiry))
        print("capReply: \(capReply?.filters ?? [:])")
        // Message report start
        let report = session.handle(MidiCiProcessInquiryBody(command: .messageReport, filters: ["sysex": 2, "ci": 1]))
        print("messageReportReply: \(report?.filters ?? [:])")
        // End report
        _ = session.handle(MidiCiProcessInquiryBody(command: .endReport))
        print("endReport acknowledged")
    }
}

