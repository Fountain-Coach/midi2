/// Clip configuration timing as used in MIDI Clip Files.
///
/// This models the timing header described in the MIDI Clip specification
/// which defines the delta clock resolution, initial tempo and optional
/// time signature for a clip.  Each field is range checked according to the
/// specification.
public struct DeltaClockstampConfig: Equatable {
    /// Time signature expressed as ``numerator`` over ``2^denominatorPow2``.
    public struct TimeSignature: Equatable {
        /// Numerator of the time signature.  Must be at least ``1``.
        public var numerator: UInt8
        /// Denominator expressed as a power of two (``2^denominatorPow2``).
        public var denominatorPow2: UInt8

        /// Creates a time signature ensuring the numerator is in range.
        public init?(numerator: UInt8, denominatorPow2: UInt8) {
            guard numerator >= 1 else { return nil }
            self.numerator = numerator
            self.denominatorPow2 = denominatorPow2
        }
    }

    /// Delta Clockstamp ticks per quarter note (DCTPQ).  Must be ``>= 1``.
    public var dctpq: UInt16

    /// Initial tempo expressed as microseconds per quarter note.
    public var initialTempoMicrosecPerQN: UInt32

    /// Optional time signature for the clip.
    public var timeSignature: TimeSignature?

    /// Creates a configuration with the supplied values.
    public init?(dctpq: UInt16,
                 initialTempoMicrosecPerQN: UInt32,
                 timeSignature: TimeSignature? = nil) {
        guard dctpq >= 1 else { return nil }
        if let ts = timeSignature, ts.numerator < 1 { return nil }
        self.dctpq = dctpq
        self.initialTempoMicrosecPerQN = initialTempoMicrosecPerQN
        self.timeSignature = timeSignature
    }

    /// Encodes the configuration into a 128‑bit UMP packet.
    ///
    /// The format is:
    /// - word0: message type ``0xD`` | group | DCTPQ
    /// - word1: initial tempo (µs per quarter note)
    /// - word2: optional time signature (numerator, denominatorPow2)
    /// - word3: reserved ``0``
    public func encode(group: UInt8 = 0) -> Ump128 {
        var word0 = UInt32(0xD << 28) | UInt32(group & 0xF) << 24
        word0 |= UInt32(dctpq)

        let word1 = initialTempoMicrosecPerQN

        let word2: UInt32
        if let ts = timeSignature {
            word2 = UInt32(ts.numerator) << 24 |
                    UInt32(ts.denominatorPow2) << 16
        } else {
            word2 = 0
        }

        return Ump128(word0: word0, word1: word1, word2: word2, word3: 0)!
    }

    /// Decodes a configuration from a 128‑bit UMP packet.
    /// Returns ``nil`` if the packet does not represent a valid configuration.
    public static func decode(_ packet: Ump128) -> DeltaClockstampConfig? {
        guard packet.messageType == 0xD else { return nil }

        let dctpq = UInt16(packet.word0 & 0xFFFF)
        guard dctpq >= 1 else { return nil }

        let tempo = packet.word1

        var timeSig: TimeSignature? = nil
        let numerator = UInt8((packet.word2 >> 24) & 0xFF)
        let denom = UInt8((packet.word2 >> 16) & 0xFF)
        if numerator != 0 || denom != 0 {
            guard let ts = TimeSignature(numerator: numerator, denominatorPow2: denom) else { return nil }
            timeSig = ts
        }

        return DeltaClockstampConfig(dctpq: dctpq,
                                     initialTempoMicrosecPerQN: tempo,
                                     timeSignature: timeSig)
    }
}
