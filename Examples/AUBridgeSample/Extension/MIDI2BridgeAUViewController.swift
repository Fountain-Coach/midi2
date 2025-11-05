import UIKit
import AudioToolbox
import CoreAudioKit
import MIDI2BridgeAUCore

public final class MIDI2BridgeAUViewController: AUViewController, AUAudioUnitFactory {
    private var au: MIDI2BridgeAudioUnit?
    private var embedded: MIDI2BridgeViewController?

    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        let unit = try MIDI2BridgeAudioUnit(componentDescription: componentDescription)
        self.au = unit
        return unit
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if let au {
            let vc = MIDI2BridgeViewController(audioUnit: au)
            addChild(vc)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(vc.view)
            NSLayoutConstraint.activate([
                vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                vc.view.topAnchor.constraint(equalTo: view.topAnchor),
                vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            vc.didMove(toParent: self)
            embedded = vc
        } else {
            let label = UILabel()
            label.text = "Audio Unit not initialized yet."
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
}

