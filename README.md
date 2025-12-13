# midi2

Lightweight Swift library and reference implementations for the Universal MIDI Packet (UMP) model and bridging between MIDI 2.0 and legacy CoreMIDI hosts.

This repository contains reusable packages and examples used to build MIDI 2.0-aware components and adapters for Apple platforms and Linux.

## Overview

- Implements the midi2 UMP model, utilities for sequencing and clocking, and adapter layers to interoperate with Apple's Core MIDI and Audio Unit APIs.
- Includes AUv3 helper classes for bridging host MIDI to CoreMIDI destinations with automatic UMP ↔ 1.0 conversion.

## Packages

- **[Packages/MIDI2BridgeAUCore](Packages/MIDI2BridgeAUCore/README.md)** — Core classes to build an AUv3 MIDI Processor that forwards host MIDI to external CoreMIDI destinations. See the README for integration instructions.
- **[Packages/TeatroAppleBridge](Packages/TeatroAppleBridge/README.md)** — Adapter package that maps the midi2 UMP model to Core MIDI and Apple sequencing APIs. See the README for examples.

## Examples

- **[Examples/AUBridgeSample](Examples/AUBridgeSample/README.md)** — Minimal iOS host app + AUv3 MIDI Processor extension demonstrating MIDI2BridgeAUCore.

## Documentation

The primary, canonical documentation for this repository lives in the **[docs/](docs/)** directory. For design notes, conformance checklists, and audit material, see:

- **[docs/README.md](docs/README.md)** — Documentation landing page
- **[docs/spec-compliance-dashboard.md](docs/spec-compliance-dashboard.md)** — Spec compliance dashboard
- **[docs/comprehensive-spec-audit-report.md](docs/comprehensive-spec-audit-report.md)** — Comprehensive spec audit report
- **[docs/spec-traceability-matrix.md](docs/spec-traceability-matrix.md)** — Spec traceability matrix

## Contributing

See the **[docs/](docs/)** directory for contribution guidelines and the conformance checklist.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
