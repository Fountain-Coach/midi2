# Definition of Done Traceability

- Library coverage
  - Stream §5 wrappers + validation → Sources/MIDI2/Stream/*.swift; Tests/MIDI2Tests/Stream*; VRT-Protocol stream/*
  - Profiles session + PSD → Sources/MIDI2CI/ProfileSession.swift, ProfileSpecificData.swift; Tests/Profile*; VRT-Protocol profiles/*
  - Property Exchange chunking/compression → Sources/MIDI2CI/PropertyExchange.swift, CompressionCodec.swift; Tests/PropertyExchange*; VRT-Protocol property-exchange/*
  - JR receiver → Sources/MIDI2/System/JitterReductionReceiver.swift; Tests/System/JitterReductionTests.swift

- CLI completeness
  - Subcommands registered → Sources/midi2demo/main.swift
  - Handshake demos → Sources/midi2demo/CIHandshake.swift, StreamConfig.swift, PropertyExchangeDemo.swift, ProfilesDemo.swift, ProfilesPSD.swift

- Tests and VRT-Protocol baselines
  - Stream → Tests/MIDI2Tests/Stream*; docs/vrt-protocol/stream/*
  - Profiles → Tests/MIDI2Tests/Profile*; docs/vrt-protocol/profiles/*
  - PE → Tests/MIDI2Tests/PropertyExchange*; docs/vrt-protocol/property-exchange/*
  - SysEx7/8/MDS → Tests/MIDI2Tests/SysEx* and DataMessageBodyTests; (VRT-Protocol pending for edge sequences)
  - JR → Tests/MIDI2Tests/System/JitterReductionTests.swift; (VRT-Protocol pending)

- Docs
  - Conformance and gaps → docs/conformance-checklist.md, docs/quiet-frame-gap-closure.yaml
  - PDF/image extraction → when spec facts are only present in diagrams/bitfield tables, render the exact pages to PNG (see AGENTS for the `gs` command), read the image content manually, and record the page/section reference alongside the corresponding updates in `midi2.full.closed.schema.json` and `midi2.full.openapi.json`.
  - Spec audit log → docs/spec-audit.md tracks page-level citations and schema/OpenAPI mapping.

- Tooling and quality gates
  - CI workflow → .github/workflows/ci.yml
  - VRT-Protocol checker → Scripts/verify_docs.py

Status notes: items marked “pending” in DoD checklist are tracked as open tasks in Issues or commits.
