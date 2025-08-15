import Foundation
#if canImport(Dispatch)
import Dispatch
#endif

/// Internal router connecting virtual sources to receivers within tests.
///
/// This emulates Core MIDI's virtual connections in a lightweight,
/// cross‑platform manner so the package can be tested on non‑Apple
/// platforms. Each virtual source is identified by name; receivers may
/// subscribe using a substring match. Published UMP messages are delivered
/// to all subscribed handlers.
struct VirtualMIDIRouter {
    typealias Handler = @Sendable (_ group: UInt8, _ words: [UInt32], _ hostTime: UInt64) -> Void

    #if canImport(Dispatch)
    private static let queue = DispatchQueue(label: "VirtualMIDIRouterQueue")
    #endif
    nonisolated(unsafe) private static var sources: [String: [Handler]] = [:]

    /// Registers a new virtual source by name.
    static func registerSource(name: String) {
        #if canImport(Dispatch)
        queue.sync {
            sources[name] = sources[name] ?? []
        }
        #else
        sources[name] = sources[name] ?? []
        #endif
    }

    /// Returns the first source name that contains the given substring.
    static func sourceName(matching substring: String) -> String? {
        #if canImport(Dispatch)
        return queue.sync {
            sources.keys.first { $0.contains(substring) }
        }
        #else
        return sources.keys.first { $0.contains(substring) }
        #endif
    }

    /// Subscribes a handler to the first source whose name contains the
    /// provided substring.
    /// - Returns: Boolean indicating whether a source was found.
    static func subscribe(nameMatch: String, handler: @escaping Handler) -> Bool {
        #if canImport(Dispatch)
        return queue.sync {
            guard let name = sources.keys.first(where: { $0.contains(nameMatch) }) else { return false }
            sources[name, default: []].append(handler)
            return true
        }
        #else
        guard let name = sources.keys.first(where: { $0.contains(nameMatch) }) else { return false }
        sources[name, default: []].append(handler)
        return true
        #endif
    }

    /// Publishes UMP words to all handlers registered for the named source.
    static func publish(name: String, group: UInt8, words: [UInt32], hostTime: UInt64) {
        let handlers: [Handler]
        #if canImport(Dispatch)
        handlers = queue.sync { sources[name] ?? [] }
        #else
        handlers = sources[name] ?? []
        #endif
        for handler in handlers {
            handler(group, words, hostTime)
        }
    }
}

