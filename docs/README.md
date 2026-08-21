# Documentation

**Last Updated**: 2025-12-16 | **Version**: 0.9.0

## Quick Start

**New to this project?** Start here:
1. 📊 [**Spec Compliance Dashboard**](spec-compliance-dashboard.md) - Executive summary and quick metrics
2. 📖 [**Comprehensive Audit Report**](comprehensive-spec-audit-report.md) - Detailed analysis and recommendations
3. 📋 [**Gap Closure Tracker**](gap-closure-tracker.md) - Action items with acceptance criteria

## Specification Audit & Compliance (Updated Dec 2025)

### Bidirectional standards contract
- **[Normative Coverage Report](generated/normative-coverage.md)** - inverse ledger report with per-source dispositions and explicit unresolved items
- **[Normative Coverage Methodology](normative-coverage-methodology.md)** - extraction, status, scope, and claim boundaries
- **[Third-party Specification Sources](third-party-specification-sources.md)** - PDF hashes, attribution, and redistribution boundary
- **[MIDI vs Fountain Coach Extensions](midi-vs-fountain-extensions.md)** - normative authority and extension separation

### Overview Documents
- **[Spec Compliance Dashboard](spec-compliance-dashboard.md)** - Quick reference with visual progress bars, metrics, and roadmap
- **[Comprehensive Spec Audit Report](comprehensive-spec-audit-report.md)** - Full analysis covering:
  - UMP encode/decode implementation (84% complete)
  - MIDI-CI implementation (63% complete)
  - Stream configuration (57% complete)
  - Property Exchange (53% complete)
  - 21 identified gaps (11 closed, 52%)
  - Gap closure progress and remaining work
  - Success metrics and recommendations

### Detailed Tracking
- **[Gap Closure Tracker](gap-closure-tracker.md)** - Detailed action plan for each of 21 gaps:
  - Acceptance criteria
  - Implementation steps
  - Files to modify
  - Dependencies
  - Sprint allocation
  - Status tracking (🔴🟡🟢⏸️)

- **[Spec Traceability Matrix](spec-traceability-matrix.md)** - generated object-to-source definition mapping. It is not the inverse normative inventory; use the [Normative Coverage Report](generated/normative-coverage.md) for that.

## Existing Documentation

### Status & Conformance
- **[Conformance Checklist](conformance-checklist.md)** - Current implementation state against MIDI 2.0 specs
- **[Spec Audit Log](spec-audit.md)** - Generated page-level citations for the current schema mapping
- **[Traceability](traceability.md)** - Definition of Done traceability to code/tests

### Other Resources
- **[VRT-Protocol Quiet Frame Gap Closure Prompt](quiet-frame-gap-closure.yaml)** - Visual baseline testing

## Specification PDFs

For normative MIDI Association specification PDFs, see the repository root:
- M2-100-U v1.1 (MIDI 2.0 Overview)
- M2-101-UM v1.2 (MIDI-CI)
- M2-102-U v1.1 (Profiles)
- M2-103-UM v1.2 (Property Exchange)
- M2-104-UM v1.1.2 (UMP and Protocol)
- M2-116-U v1.0 (MIDI Clip File)

## Document Relationships

```
┌─────────────────────────────────────────────────────────┐
│  spec-compliance-dashboard.md (START HERE)              │
│  ↓ Quick metrics & roadmap                              │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│  comprehensive-spec-audit-report.md                     │
│  ↓ Detailed analysis of all components                  │
│  ↓ Gap identification & recommendations                 │
└─────────────────────────────────────────────────────────┘
           ↓                              ↓
┌──────────────────────────┐    ┌────────────────────────┐
│ gap-closure-tracker.md   │    │ spec-traceability-     │
│ ↓ Action plans           │    │   matrix.md            │
│ ↓ Acceptance criteria    │    │ ↓ Requirement mapping  │
│ ↓ Sprint allocation      │    │ ↓ Evidence paths       │
└──────────────────────────┘    └────────────────────────┘
           ↓                              ↓
┌─────────────────────────────────────────────────────────┐
│  spec-audit.md                                          │
│  ↓ Page-level PDF references                            │
│  ↓ Schema/OpenAPI mappings                              │
└─────────────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────────────┐
│  conformance-checklist.md + traceability.md             │
│  ↓ Current implementation evidence                      │
└─────────────────────────────────────────────────────────┘
```

## Maintenance

- **spec-compliance-dashboard.md**: Update weekly during active sprints
- **gap-closure-tracker.md**: Update status after each gap closure
- **comprehensive-spec-audit-report.md**: Update at major milestones
- **spec-traceability-matrix.md**: Update when specs change or gaps close
- **spec-audit.md**: Update when adding new spec references
- **conformance-checklist.md**: Update when implementation status changes

## Legacy Documents

The following documents in `legacy/` are archived for historical reference:
- `legacy/midi2-js-dod.md` - Original DoD criteria (superseded by gap-closure-tracker.md)
- `legacy/midi2-js-gap-plan.md` - Original gap plan (superseded by gap-closure-tracker.md)
- `legacy/AGENTS.md` - Original maintenance policy (superseded by root AGENTS.md)
- `legacy/midi2-js-AGENTS.md` - Original midi2.js AGENTS (superseded by midi2.js/README.md)

## Contributing

When updating these documents:
1. Keep metrics consistent across all documents
2. Update cross-references when moving content
3. Maintain the visual progress indicators
4. Add citations to spec pages for new requirements
5. Update the "Last Updated" timestamps
