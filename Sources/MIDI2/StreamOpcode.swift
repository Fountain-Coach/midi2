/// Opcode values for MIDI 2.0 Stream messages (message type ``0xF``).
///
/// The standard defines the following opcodes (status field) for Stream messages (M2-104-UM v1.1.2 p.120).
public enum StreamOpcode: UInt8, Equatable {
    /// Endpoint discovery message.
    case endpointDiscovery               = 0x00
    /// Endpoint Info Notification.
    case endpointInfoNotification        = 0x01
    /// Device Identity Notification.
    case deviceIdentityNotification      = 0x02
    /// Endpoint Name Notification.
    case endpointNameNotification        = 0x03
    /// Product Instance Id Notification.
    case productInstanceIdNotification   = 0x04
    /// Stream Configuration Request.
    case streamConfigurationRequest      = 0x05
    /// Stream Configuration Notification.
    case streamConfigurationNotification = 0x06
    /// Function Block Discovery.
    case functionBlockDiscovery          = 0x10
    /// Function Block Info Notification.
    case functionBlockInfoNotification   = 0x11
    /// Function Block Name Notification.
    case functionBlockNameNotification   = 0x12
    /// Start of Clip.
    case startOfClip                     = 0x20
    /// End of Clip.
    case endOfClip                       = 0x21
}
