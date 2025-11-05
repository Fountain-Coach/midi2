import Foundation
#if canImport(AudioToolbox)
import AudioToolbox
#endif
#if canImport(AVFoundation)
import AVFoundation
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(CoreMIDI)
import CoreMIDI
#endif

import TeatroAppleBridge

/// AUv3 MIDI processor core that bridges host MIDI events to external CoreMIDI
/// destinations (BLE/Wi‑Fi/USB) using MIDI 2.0 UMP when available.
///
/// This class is designed to be used inside an AUv3 extension target. It does
/// not perform any audio processing. The AU receives MIDI events from the host
/// and forwards them to a selected CoreMIDI destination via `AppleMIDIIO`. It
/// can also receive from CoreMIDI sources and emit events back to the host.
open class MIDI2BridgeAudioUnit: AUAudioUnit {
    // MARK: - IO & State
    private let io: AppleMIDIIO? = try? AppleMIDIIO(clientName: "MIDI2BridgeAU")

    /// Destination name substring to match when forwarding.
    public var destinationMatch: String = "" {
        didSet { destinationWasSet() }
    }

    /// Optional source name to subscribe and forward into host.
    public var sourceMatch: String? { didSet { sourceWasSet() } }

    private var midiOutBlock: AUMIDIOutputEventBlock?
    private var midiOutListBlock: AUMIDIEventListBlock?

    // Expose per‑note mapping control for down‑conversion.
    public var perNoteMapping: AppleMIDIIO.PerNoteMapping {
        get { io?.perNoteMapping ?? .polyPressure }
        set { io?.perNoteMapping = newValue }
    }

    // MARK: - AU Setup
    public override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)
        self.maximumFramesToRender = 512
    }

    public override var canProcessInPlace: Bool { true }

    public override func allocateRenderResources() throws {
        try super.allocateRenderResources()
    }

    public override func deallocateRenderResources() {
        super.deallocateRenderResources()
    }

    // Prefer receiving MIDI 2.0 from host if supported.
    public override var AudioUnitMIDIProtocol: MIDIProtocolID {
        if #available(iOS 15.0, macOS 12.0, *) {
            return ._2_0
        } else {
            return ._1_0
        }
    }

    // MARK: - MIDI 2.0 Event Routing
    public override var scheduleMIDIEventBlock: AUMIDIEventBlock? {
        // MIDI 1.0 style events; wrap into UMP mt=0x2 and forward.
        return { [weak self] _, _, _, length, data in
            guard let self, let io = self.io else { return noErr }
            guard length >= 1, let bytes = data else { return noErr }
            // Assume each callback is a single MIDI message (typical AU hosts). Build one 32‑bit UMP.
            // Determine second data byte presence from status nibble.
            let status = bytes[0]
            let nib = status >> 4
            let needTwoData = !(nib == 0xC || nib == 0xD)
            let d1: UInt8 = length > 1 ? bytes[1] : 0
            let d2: UInt8 = (needTwoData && length > 2) ? bytes[2] : 0
            let word: UInt32 = (0x2 << 28) | (0 /*group*/ << 24) | (UInt32(status) << 16) | (UInt32(d1) << 8) | UInt32(d2)
            do { try io.sendUMP(toDestinationNameContains: self.destinationMatch, words: [word], hostTime: 0) } catch {}
            return noErr
        }
    }

    public override var scheduleMIDI2EventBlock: AUMIDI2EventBlock? {
        return { [weak self] sampleTime, cable, length, words in
            guard let self, let io = self.io else { return noErr }
            // words points to a 32‑bit word array; copy to Swift array and forward
            let buffer = UnsafeBufferPointer(start: words, count: Int(length))
            let arr = Array(buffer)
            do {
                try io.sendUMP(toDestinationNameContains: self.destinationMatch, words: arr, hostTime: 0)
            } catch {
                // Swallow in demo; production should report errors via property or UI
            }
            return noErr
        }
    }

    public override var MIDIOutputEventBlock: AUMIDIOutputEventBlock? {
        get { midiOutBlock }
        set { midiOutBlock = newValue }
    }

    public override var MIDIOutputEventListBlock: AUMIDIEventListBlock? {
        get { midiOutListBlock }
        set { midiOutListBlock = newValue }
    }

    private func destinationWasSet() {
        // No-op: we resolve at send time by name substring.
    }

    private func sourceWasSet() {
        guard let sourceMatch, let io else { return }
        try? io.openInput(nameContains: sourceMatch) { [weak self] group, words, hostTime in
            // Prefer sending as MIDIEventList (UMP) back to host; host converts to desired protocol.
            if let outList = self?.midiOutListBlock {
                self?.withMIDIEventList(words: words) { listPtr in
                    _ = outList(0 /* now */, listPtr)
                }
                return
            }
            // Fallback: try legacy bytes by down‑converting a subset (channel voice & sys msgs).
            if let bytes = self?.downconvertToMIDI1Bytes(words: words), let out = self?.midiOutBlock {
                _ = bytes.withUnsafeBufferPointer { ptr in out(0, 0, ptr.count, ptr.baseAddress) }
            }
        }
    }

    // Build a MIDIEventList from UMP words.
    private func withMIDIEventList(words: [UInt32], _ body: (UnsafePointer<MIDIEventList>) -> Void) {
        let totalWords = words.count
        if #available(iOS 16.0, macOS 13.0, *) {
            let listSize = MIDIEventList.sizeInBytes(packetCount: 1, totalWords: totalWords)
            let rawPtr = UnsafeMutableRawPointer.allocate(byteCount: listSize, alignment: 8)
            defer { rawPtr.deallocate() }
            let listPtr = rawPtr.bindMemory(to: MIDIEventList.self, capacity: 1)
            listPtr.pointee.protocol = ._2_0
            listPtr.pointee.numPackets = 1
            let p = MIDIEventList.packetPtr(listPtr)
            p.pointee.timeStamp = 0
            p.pointee.wordCount = UInt32(totalWords)
            let dst = MIDIEventList.wordsPtr(p)
            for (i, w) in words.enumerated() { dst.advanced(by: i).pointee = w }
            body(UnsafePointer(listPtr))
        } else {
            // Legacy hosts: no MIDIEventList; nothing to do here.
        }
    }

    // Minimal UMP → MIDI 1.0 bytes down‑convert for CV + system.
    private func downconvertToMIDI1Bytes(words: [UInt32]) -> [UInt8] {
        var out: [UInt8] = []
        var i = 0
        while i < words.count {
            let w0 = words[i]
            let mt = UInt8((w0 >> 28) & 0x0F)
            switch mt {
            case 0x2:
                let status = UInt8((w0 >> 16) & 0xFF)
                let d1 = UInt8((w0 >> 8) & 0xFF)
                let d2 = UInt8(w0 & 0xFF)
                let nib = status >> 4
                if nib == 0xC || nib == 0xD { out += [status, d1] } else { out += [status, d1, d2] }
                i += 1
            case 0x1:
                let status = UInt8((w0 >> 16) & 0xFF)
                let d1 = UInt8((w0 >> 8) & 0xFF)
                let d2 = UInt8(w0 & 0xFF)
                let len: Int
                switch status { case 0xF1, 0xF3: len = 2; case 0xF2: len = 3; case 0xF6, 0xF8, 0xFA, 0xFB, 0xFC, 0xFE, 0xFF: len = 1; default: len = 1 }
                if len == 1 { out += [status] } else if len == 2 { out += [status, d1] } else { out += [status, d1, d2] }
                i += 1
            default:
                // Other types ignored here.
                i += 1
            }
        }
        return out
    }
}

// MARK: - Minimal UI Controller

#if canImport(UIKit)
/// Simple UI for selecting a destination and opening BLE pairing UI.
public final class MIDI2BridgeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let au: MIDI2BridgeAudioUnit
    private let table = UITableView()
    private var endpoints: [AppleMIDIIO.Endpoint] = []
    private let io = try? AppleMIDIIO(clientName: "MIDI2BridgeAU")
    private let mapping = UISegmentedControl(items: ["Off", "Poly", "Chan"])    

    public init(audioUnit: MIDI2BridgeAudioUnit) {
        self.au = audioUnit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Select Destination (MIDI 2.0 preferred)"
        title.font = .preferredFont(forTextStyle: .headline)

        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.heightAnchor.constraint(equalToConstant: 240).isActive = true

        let refresh = UIButton(type: .system)
        refresh.setTitle("Refresh Endpoints", for: .normal)
        refresh.addTarget(self, action: #selector(refreshEndpoints), for: .touchUpInside)

        let ble = UIButton(type: .system)
        ble.setTitle("Bluetooth MIDI…", for: .normal)
        ble.addTarget(self, action: #selector(openBLE), for: .touchUpInside)

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(table)
        stack.addArrangedSubview(refresh)
        stack.addArrangedSubview(ble)
        mapping.selectedSegmentIndex = 1
        mapping.addTarget(self, action: #selector(mappingChanged), for: .valueChanged)
        stack.addArrangedSubview(mapping)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])

        refreshEndpoints()
    }

    @objc private func refreshEndpoints() {
        endpoints = (try? io?.enumerateEndpoints()) ?? []
        table.reloadData()
    }

    @objc private func openBLE() {
        #if canImport(CoreAudioKit)
        if let vc = io?.makeBluetoothPairingViewController() {
            vc.modalPresentationStyle = .formSheet
            present(vc, animated: true, completion: nil)
        }
        #endif
    }

    @objc private func mappingChanged() {
        switch mapping.selectedSegmentIndex {
        case 0: au.perNoteMapping = .off
        case 1: au.perNoteMapping = .polyPressure
        case 2: au.perNoteMapping = .channelPressure
        default: au.perNoteMapping = .polyPressure
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { endpoints.count }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ep = endpoints[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = ep.name + (ep.supportsMIDI2 ? " (M2)" : " (M1)")
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ep = endpoints[indexPath.row]
        au.destinationMatch = ep.name
    }
}
#endif

// MARK: - MIDIEventList helpers (local copy)

#if canImport(CoreMIDI)
@available(iOS 16.0, macOS 13.0, *)
fileprivate extension MIDIEventList {
    static func sizeInBytes(packetCount: Int, totalWords: Int) -> Int {
        let header = MemoryLayout<MIDIEventList>.size
        let packetHeader = MemoryLayout<MIDIEventPacket>.size
        let wordsBytes = totalWords * MemoryLayout<UInt32>.size
        return header + packetHeader + wordsBytes
    }

    static func packetPtr(_ list: UnsafeMutablePointer<MIDIEventList>) -> UnsafeMutablePointer<MIDIEventPacket> {
        return withUnsafeMutableBytes(of: &list.pointee) { raw in
            let base = raw.baseAddress!.advanced(by: MemoryLayout<MIDIEventList>.size)
            return base.bindMemory(to: MIDIEventPacket.self, capacity: 1)
        }
    }

    static func wordsPtr(_ packet: UnsafeMutablePointer<MIDIEventPacket>) -> UnsafeMutablePointer<UInt32> {
        let addr = UnsafeMutableRawPointer(packet)
            .advanced(by: MemoryLayout<MIDIEventPacket>.size)
        return addr.bindMemory(to: UInt32.self, capacity: Int(packet.pointee.wordCount))
    }
}
#endif
