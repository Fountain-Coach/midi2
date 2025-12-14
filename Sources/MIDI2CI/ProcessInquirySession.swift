import Foundation
import MIDI2

/// Minimal Process Inquiry session supporting capInquiry/capReply,
/// messageReport/messageReportReply, and endReport.
public final class ProcessInquirySession {
    /// Reported capabilities/filters (key -> level)
    public var filters: [String: UInt8]
    /// Device ID scope for replies (0x00-0x0F, 0x7E, 0x7F)
    public var deviceId: UInt8

    public init(filters: [String: UInt8] = [:], deviceId: UInt8 = 0x7F) {
        self.filters = filters
        self.deviceId = deviceId
    }

    /// Handle a Process Inquiry body and return zero or one reply.
    public func handle(_ body: MidiCiProcessInquiryBody) -> MidiCiProcessInquiryBody? {
        // Validate Device ID scope (M2-101-UM Table 40)
        guard deviceId <= 0x0F || deviceId == 0x7E || deviceId == 0x7F else { return nil }
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
