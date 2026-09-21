import Foundation

/// A transport for complete UMP messages.
public protocol MIDITransport: AnyObject, Sendable {
    var onReceiveUMP: (([UInt32]) -> Void)? { get set }
    func open() throws
    func close() throws
    func send(umpWords: [UInt32]) throws
}
