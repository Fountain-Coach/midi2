import Foundation
import TeatroAppleBridge

func listEndpoints() {
    if let io = try? AppleMIDIIO(clientName: "IOBridgeDemo") {
        let eps = (try? io.enumerateEndpoints()) ?? []
        print("Sources:")
        for ep in eps.filter({ $0.isSource }) {
            print(" - \(ep.name) [\(ep.supportsMIDI2 ? "M2" : "M1")] id=\(ep.uniqueID)")
        }
        print("Destinations:")
        for ep in eps.filter({ $0.isDestination }) {
            print(" - \(ep.name) [\(ep.supportsMIDI2 ? "M2" : "M1")] id=\(ep.uniqueID)")
        }
    } else {
        print("CoreMIDI not available; running on virtual router only.")
    }
}

func sendTestNote(to nameContains: String) {
    if let io = try? AppleMIDIIO(clientName: "IOBridgeDemo") {
        // Simple MIDI 2.0 Note On (mt=0x2, group 0, status 0x90 ch0, note 60, vel 0x64)
        let words: [UInt32] = [0x20903C64]
        do {
            try io.sendUMP(toDestinationNameContains: nameContains, words: words, hostTime: 0)
            print("Sent UMP to \(nameContains)")
        } catch {
            print("Failed to send: \(error)")
        }
    }
}

let args = CommandLine.arguments
if args.count == 1 || args.contains("list") {
    listEndpoints()
} else if args.count >= 3 && args[1] == "send" {
    let needle = args.dropFirst(2).joined(separator: " ")
    sendTestNote(to: needle)
} else {
    print("Usage:\n  IOBridgeDemo list\n  IOBridgeDemo send <destination substring>")
}

