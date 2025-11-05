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

    private func destinationWasSet() {
        // No-op: we resolve at send time by name substring.
    }

    private func sourceWasSet() {
        guard let sourceMatch, let io else { return }
        try? io.openInput(nameContains: sourceMatch) { [weak self] group, words, hostTime in
            guard let output = self?.midiOutBlock else { return }
            let res = words.withUnsafeBufferPointer { ptr in
                output(0 /* now */, 0 /* cable */, ptr.count, ptr.baseAddress)
            }
            _ = res
        }
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
