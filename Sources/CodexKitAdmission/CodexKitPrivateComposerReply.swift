import Foundation

/// Real model output is sealed inside the session, never emitted as a public
/// MIDI2 lifecycle summary. The Composer is its only display surface.
public struct CodexKitPrivateComposerReply: Codable, Equatable, Sendable {
    public let text: String
    public let threadID: String?
    public let turnID: String?

    public init(text: String, threadID: String?, turnID: String?) {
        self.text = text
        self.threadID = threadID
        self.turnID = turnID
    }
}
