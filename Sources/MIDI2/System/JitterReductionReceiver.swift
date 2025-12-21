/// Receiver-side reconstruction for JR Clock/Timestamp messages.
public final class JRReceiver {
    private var lastClock: UInt32?
    private var fullTime: UInt64 = 0

    public init() {}

    /// Ingest a Utility.jrClock value and advance the base time.
    public func ingestClock(_ value: UInt32) {
        let masked = value & 0xFFFFF
        if let prev = lastClock {
            let delta = (masked &- prev) & 0xFFFFF
            // Treat large deltas (interpreted as backward wrap) as 0 progression.
            if delta <= 0x7FFFF {
                fullTime &+= UInt64(delta)
            }
            lastClock = masked
        } else {
            lastClock = masked
        }
    }

    /// Compute an absolute time for a Utility.jrTimestamp value based on the last clock.
    /// Returns nil if no clock has been received yet.
    public func eventTime(for timestamp: UInt32) -> UInt64? {
        guard let base = lastClock else { return nil }
        let masked = timestamp & 0xFFFFF
        let offset = (masked &- base) & 0xFFFFF
        return fullTime &+ UInt64(offset)
    }
}
