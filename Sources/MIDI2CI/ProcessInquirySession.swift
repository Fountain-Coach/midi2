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

    private func isValidDeviceId(_ id: UInt8) -> Bool {
        id <= 0x0F || id == 0x7E || id == 0x7F
    }

    /// Clamp requested filters to what this session supports (min of requested/support) and drop unsupported keys.
    private func clampFilters(_ requested: [String: UInt8]?) -> [String: UInt8] {
        guard let requested else { return [:] }
        var reply: [String: UInt8] = [:]
        for (key, reqVal) in requested {
            guard let supportedVal = filters[key], supportedVal > 0 else { continue }
            reply[key] = min(reqVal, supportedVal)
        }
        return reply
    }

    /// Handle a Process Inquiry body and return zero or one reply.
    public func handle(_ body: MidiCiProcessInquiryBody) -> MidiCiProcessInquiryBody? {
        // Validate Device ID scope (M2-101-UM Table 40)
        guard isValidDeviceId(deviceId) else { return nil }
        switch body.command {
        case .capInquiry:
            return MidiCiProcessInquiryBody(command: .capReply, filters: filters)
        case .messageReport:
            // Acknowledge start by echoing the intersection of requested and supported filters
            let clamped = clampFilters(body.filters)
            return MidiCiProcessInquiryBody(command: .messageReportReply, filters: clamped)
        case .endReport:
            // No payload expected in reply; end of reporting sequence acknowledged by no response
            return nil
        default:
            return nil
        }
    }
}
