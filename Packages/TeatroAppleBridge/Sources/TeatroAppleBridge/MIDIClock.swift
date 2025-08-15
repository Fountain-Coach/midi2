import Foundation
#if canImport(Dispatch)
import Dispatch
#endif

/// Helpers for working with host time on Apple platforms.
public enum MIDIClock {
    /// Returns the current host time in nanoseconds.
    public static func nowHostTime() -> UInt64 {
        #if canImport(Dispatch)
        return DispatchTime.now().uptimeNanoseconds
        #else
        return UInt64(Date().timeIntervalSince1970 * 1_000_000_000)
        #endif
    }

    /// Converts seconds into host time units.
    /// - Parameter seconds: Duration in seconds.
    /// - Returns: Equivalent host time in nanoseconds.
    public static func secondsToHostTime(_ seconds: Double) -> UInt64 {
        UInt64(seconds * 1_000_000_000)
    }
}
