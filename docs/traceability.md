# Definition of Done Traceability

- Library coverage
  - Stream §5 wrappers + validation → Sources/MIDI2/Stream/*.swift; Tests/MIDI2Tests/Stream*; PB-VRT stream/*
  - Profiles session + PSD → Sources/MIDI2CI/ProfileSession.swift, ProfileSpecificData.swift; Tests/Profile*; PB-VRT profiles/*
  - Property Exchange chunking/compression → Sources/MIDI2CI/PropertyExchange.swift, CompressionCodec.swift; Tests/PropertyExchange*; PB-VRT property-exchange/*
  - JR receiver → Sources/MIDI2/System/JitterReductionReceiver.swift; Tests/System/JitterReductionTests.swift

- CLI completeness
  - Subcommands registered → Sources/midi2demo/main.swift
  - Handshake demos → Sources/midi2demo/CIHandshake.swift, StreamConfig.swift, PropertyExchangeDemo.swift, ProfilesDemo.swift, ProfilesPSD.swift

- Tests and PB-VRT baselines
  - Stream → Tests/MIDI2Tests/Stream*; docs/pb-vrt/stream/*
  - Profiles → Tests/MIDI2Tests/Profile*; docs/pb-vrt/profiles/*
  - PE → Tests/MIDI2Tests/PropertyExchange*; docs/pb-vrt/property-exchange/*
  - SysEx7/8/MDS → Tests/MIDI2Tests/SysEx* and DataMessageBodyTests; (PB-VRT pending for edge sequences)
  - JR → Tests/MIDI2Tests/System/JitterReductionTests.swift; (PB-VRT pending)

- Docs
  - Conformance and gaps → docs/conformance-checklist.md, docs/quiet-frame-gap-closure.yaml
  - PDF/image extraction → when spec facts are only present in diagrams/bitfield tables, render the exact pages to PNG (see AGENTS for the `gs` command), read the image content manually, and record the page/section reference alongside the corresponding updates in `midi2.full.closed.schema.json` and `midi2.full.openapi.json`.
  - Spec audit log → docs/spec-audit.md tracks page-level citations and schema/OpenAPI mapping.

- Tooling and quality gates
  - CI workflow → .github/workflows/ci.yml
  - PB-VRT checker → Scripts/verify_docs.py

Status notes: items marked “pending” in DoD checklist are tracked as open tasks in Issues or commits.
