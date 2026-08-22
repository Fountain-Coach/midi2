# midi2

[![CI](https://github.com/Fountain-Coach/midi2/workflows/CI/badge.svg)](https://github.com/Fountain-Coach/midi2/actions/workflows/ci.yml)
[![npm version](https://badge.fury.io/js/@fountain-coach%2Fmidi2.svg)](https://www.npmjs.com/package/@fountain-coach/midi2)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
<!-- TODO: Add coverage badge when coverage reporting is configured -->

Lightweight Swift library and reference implementations for the Universal MIDI Packet (UMP) model and bridging between MIDI 2.0 and legacy CoreMIDI hosts. Also includes **midi2.js**, a cross-browser, CoreMIDI-free TypeScript/JavaScript MIDI 2.0 protocol library.

The repository's runtime claim is deliberately bounded: the named Swift and TypeScript core software surfaces are tested and runtime-complete within the declared boundary. This does not claim every optional MIDI 2.0 extension, host adapter, or physical-device interoperability.

This repository contains reusable packages and examples used to build MIDI 2.0-aware components and adapters for Apple platforms, Linux, and web browsers.

## Agent maintenance — read this first

Agents maintaining this repository should use the public [`midi2-domain-maintenance`](.codex/skills/midi2-domain-maintenance/SKILL.md) skill. It keeps implementation, machine-readable contracts, human documentation, provenance, tests, claims, and optional publication projections aligned.

The skill is repository-scoped and domain-agnostic: publication hosts, subdomains, DNS, and delivery providers are supplied as external configuration. The repository remains the source of truth. Its [publication adapter contract](.codex/skills/midi2-domain-maintenance/references/publication-adapter.md) explains how a project may connect sanitized documentation projections without coupling the MIDI2 maintenance workflow to a particular web estate.

## Overview

**Swift Packages:**
- Implements the MIDI 2.0 UMP model, MIDI-CI protocol support, utilities for sequencing and clocking, and adapter layers to interoperate with Apple's Core MIDI and Audio Unit APIs.
- Includes AUv3 helper classes for bridging host MIDI to CoreMIDI destinations with automatic UMP ↔ 1.0 conversion.
- Supports macOS 13+, iOS 16+, and Linux.

**JavaScript/TypeScript Library:**
- **[midi2.js](midi2.js/)** — Cross-browser MIDI 2.0 library with UMP encoding/decoding, SysEx7/8 fragmentation, MIDI-CI envelopes, jitter-aware scheduler, and adapters for WebAudio/Three.js/Cannon.js.
- Available on npm: `@fountain-coach/midi2`

## Packages

**Swift Packages:**
- **[Packages/MIDI2BridgeAUCore](Packages/MIDI2BridgeAUCore/README.md)** — Core classes to build an AUv3 MIDI Processor that forwards host MIDI to external CoreMIDI destinations. See the README for integration instructions.
- **[Packages/TeatroAppleBridge](Packages/TeatroAppleBridge/README.md)** — Adapter package that maps the midi2 UMP model to Core MIDI and Apple sequencing APIs. See the README for examples.

**JavaScript/TypeScript:**
- **[midi2.js](midi2.js/)** — Cross-browser MIDI 2.0 protocol library. See [midi2.js/README.md](midi2.js/README.md) for API documentation.

## Examples

- **[Examples/AUBridgeSample](Examples/AUBridgeSample/README.md)** — Minimal iOS host app + AUv3 MIDI Processor extension demonstrating MIDI2BridgeAUCore.

## Installation

### Swift Package Manager

Add to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/Fountain-Coach/midi2.git", from: "0.11.0")
]
```

Or add via Xcode: **File → Add Packages** and enter the repository URL.

### npm (JavaScript/TypeScript)

```bash
npm install @fountain-coach/midi2
```

Then import in your project:
```typescript
import { encodeNoteOn, decodeMIDI2Message } from '@fountain-coach/midi2';
```

## Quickstart

### Swift

```swift
import MIDI2

// Create a MIDI 2.0 Note On message
let noteOn = MIDI2.noteOn(channel: 0, note: 60, velocity: 0.8)

// Encode/decode UMP packets
let packet = UMPPacket(/* ... */)
```

See the repository's [documentation index](docs/README.md) for the canonical API, conformance, provenance, and runtime-boundary documentation. The reviewed public projection is published at [midi2.fountain.coach](https://midi2.fountain.coach/); generated hosted API documentation is not currently published.

### JavaScript/TypeScript

```typescript
import { encodeNoteOn, scheduleMIDI } from '@fountain-coach/midi2';

// Create and schedule a Note On message
const msg = encodeNoteOn({ channel: 0, note: 60, velocity: 32768 });
scheduleMIDI(msg, performance.now() + 100);
```

See [midi2.js/README.md](midi2.js/README.md) for complete documentation.

## Building and Testing

### Swift

```bash
# Build the project
swift build

# Run tests
swift test

# Build in release mode
swift build -c release

# Run with coverage
swift test --enable-code-coverage
```

### CLI demos

Common `midi2demo` scenarios (see `midi2demo --help` for full list):
- `midi2demo pe-demo`
- `midi2demo profiles-demo`
- `midi2demo profiles-psd`
- `midi2demo stream-config endpoint`
- `midi2demo stream-config fb-discover`
- `midi2demo stream-config gtb`

### JavaScript/TypeScript

```bash
cd midi2.js

# Install dependencies
npm install

# Type check
npm run check

# Run tests
npm test

# Build
npm run build

# Run tests with coverage
npm run coverage
```

## Documentation

The primary, canonical documentation for this repository lives in the **[docs/](docs/)** directory. For design notes, conformance checklists, and audit material, see:

The public publication estate is linked semantically: [Fountain Coach](https://fountain.coach/) · [Book of Reframe](https://book.fountain.coach/) · [Reframe Governance](https://governance.fountain.coach/) · [MIDI2 documentation](https://midi2.fountain.coach/) · [Instruments](https://instruments.fountain.coach/) · [Status](https://status.fountain.coach/).

The standards contract is bidirectional: [source provenance](docs/spec-provenance.json) records object-to-source traceability, while the [normative coverage report](docs/generated/normative-coverage.md) records the inverse ledger. Structural rules live in the closed schema; verified behavioral slices live in the [normative behavior model](docs/normative-behavior.json). See the [coverage methodology](docs/normative-coverage-methodology.md) for the limits of semantic, runtime, and hardware claims.

- **[docs/README.md](docs/README.md)** — Documentation landing page
- **[docs/spec-compliance-dashboard.md](docs/spec-compliance-dashboard.md)** — Spec compliance dashboard
- **[docs/claim-register.md](docs/claim-register.md)** — Evidence-backed public claim boundary
- **[docs/runtime-completeness.md](docs/runtime-completeness.md)** — Machine-checked owned core software runtime boundary
- **[docs/conformance-checklist.md](docs/conformance-checklist.md)** — Feature-level implementation and validation evidence
- **[docs/negative-test-matrix.md](docs/negative-test-matrix.md)** — Reserved, malformed, and unsupported-value coverage
- **[docs/comprehensive-spec-audit-report.md](docs/comprehensive-spec-audit-report.md)** — Comprehensive spec audit report
- **[docs/spec-traceability-matrix.md](docs/spec-traceability-matrix.md)** — Spec traceability matrix
- **[docs/publication-estate-audit.md](docs/publication-estate-audit.md)** — Reproducible crawl and source-history audit of the published estate
- **[Scripts/build_docs_site.py](Scripts/build_docs_site.py)** — Reproducible static documentation-site builder
- **[Scripts/publish_docs_site.sh](Scripts/publish_docs_site.sh)** — Guarded publication helper for the configured documentation target

## Contributing

We welcome contributions! Please see:
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — Development workflow, coding standards, and PR process
- **[AGENTS.md](AGENTS.md)** — Repository maintenance policy and roles
- **[docs/](docs/)** directory for conformance checklists and design documentation

### Quick Contribution Guide

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes and add tests
4. Ensure CI passes: `swift test` and/or `cd midi2.js && npm test`
5. Update `CHANGELOG.md` in the "Unreleased" section
6. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Maintenance and Security

- **Maintenance Policy:** See [AGENTS.md](AGENTS.md) for roles, rotation schedule, and SLAs
- **Security Policy:** See [SECURITY.md](SECURITY.md) for vulnerability reporting
- **Release Process:** See [RELEASE.md](RELEASE.md) for release checklist and procedures

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
