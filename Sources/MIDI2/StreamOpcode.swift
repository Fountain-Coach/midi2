/// Opcode values for MIDI 2.0 Stream messages (message type ``0xF``).
///
/// The standard currently defines three opcodes used to manage endpoints and
/// function blocks during connection setup.
public enum StreamOpcode: UInt8, Equatable {
    /// Endpoint discovery message.
    case endpointDiscovery      = 0x00
    /// Stream configuration (request or notification).
    case streamConfiguration    = 0x01
    /// Function block discovery or information message.
    case functionBlock          = 0x02
}

