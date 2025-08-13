/// Enumeration of UMP data message kinds used with message type ``0x5``.
///
/// - `sysex8`: 8‑bit clean System Exclusive data.
/// - `mds`: Mixed Data Set transfer.
public enum DataMessageKind: String, Equatable {
    case sysex8
    case mds
}

