/// Receiver-side reconstruction for JR Clock/Timestamp messages.
public final class JRReceiver {
    private var lastClock: UInt16?
    private var fullTime: UInt64 = 0

    public init() {}

    /// Ingest a Utility.jrClock value and advance the base time.
    public func ingestClock(_ value: UInt16) {
        if let prev = lastClock {
            let delta = UInt16(value &- prev)
            fullTime &+= UInt64(delta)
            lastClock = value
        } else {
            lastClock = value
        }
    }

    /// Compute an absolute time for a Utility.jrTimestamp value based on the last clock.
    /// Returns nil if no clock has been received yet.
    public func eventTime(for timestamp: UInt16) -> UInt64? {
        guard let base = lastClock else { return nil }
        let offset = UInt16(timestamp &- base)
        return fullTime &+ UInt64(offset)
    }
}

