import Foundation
import MIDI2

/// Minimal Process Inquiry session supporting capInquiry/capReply,
/// messageReport/messageReportReply, and endReport.
public final class ProcessInquirySession {
    /// Reported capabilities/filters (key -> level)
    public var filters: [String: UInt8]

    public init(filters: [String: UInt8] = [:]) {
        self.filters = filters
    }

    /// Handle a Process Inquiry body and return zero or one reply.
    public func handle(_ body: MidiCiProcessInquiryBody) -> MidiCiProcessInquiryBody? {
        switch body.command {
        case .capInquiry:
            return MidiCiProcessInquiryBody(command: .capReply, filters: filters)
        case .messageReport:
            // Echo back a filtered set as acknowledgement of report start
            return MidiCiProcessInquiryBody(command: .messageReportReply, filters: body.filters)
        case .endReport:
            // No payload expected in reply; end of reporting sequence acknowledged by no response
            return nil
        default:
            return nil
        }
    }
}
