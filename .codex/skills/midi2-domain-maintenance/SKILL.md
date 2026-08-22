---
name: midi2-domain-maintenance
description: Maintain a MIDI 2.0 repository and its human, machine-readable, and evidence-backed documentation surfaces as one versioned contract.
metadata:
  short-description: Maintain MIDI2 code, contracts, docs, and evidence
---

# MIDI2 domain maintenance

Use this skill for changes to a MIDI 2.0 repository that affect implementation, schemas, normative coverage, package documentation, release evidence, or public documentation projections.

The repository is the source of truth. A publication host is only a delivery target. Never make a domain, URL, DNS layout, or hosting provider part of the MIDI2 contract.

## Outcomes

Keep these surfaces synchronized:

1. **Human surface** — the root README, package READMEs, documentation index, tutorials, and release notes explain what the project is, how to use it, and where its boundaries are.
2. **Machine surface** — schemas, OpenAPI or equivalent projections, normative ledgers, behavior models, runtime boundaries, and generated reports are canonical and reproducible.
3. **Evidence surface** — source hashes, provenance, tests, negative tests, runtime evidence, claims, and known limitations support exactly what is stated.

## Operating rules

- Inspect the current repository state and the relevant generated artifacts before editing.
- Treat the MIDI Association source corpus as normative authority; treat project-specific extensions as explicitly namespaced additions.
- Preserve bidirectional traceability: source requirement to representation, and representation to authoritative source.
- Keep semantic coverage, runtime completeness, and physical-device interoperability as separate claims.
- Do not turn an unresolved, ambiguous, excluded, or untested item into a success claim.
- Prefer machine-resolvable repository paths, JSON Pointers, symbols, and test references over prose-only links.
- Regenerate derived reports from their canonical inputs; do not hand-edit generated artifacts.
- Keep package documentation aligned with the bounded claim register. Avoid “full,” “complete,” or “spec-accurate” language unless the named evidence supports that exact scope.
- When a change affects both Swift and TypeScript surfaces, update and test both or record the precise boundary.
- Do not claim hardware interoperability from software tests, fixtures, or protocol models.

## Workflow

### Inspect

Read the root `AGENTS.md`, package guidance, `README.md`, `docs/README.md`, claim register, runtime boundary, and the relevant canonical contract before deciding what to change. Check the current version and generated-artifact status.

### Implement

Make the smallest coherent change across code, contracts, tests, and documentation. If a normative requirement is affected, update its ledger disposition and representation references in the same change. If a public claim changes, update both its machine-readable and human-readable claim records.

### Verify

Run the focused checks first, then the repository gates relevant to the change:

- schema/provenance verification;
- normative coverage and generated-report freshness;
- runtime-completeness verification;
- Swift tests and TypeScript tests/build;
- documentation/link checks;
- claim-register verification.

Report which gates ran and which were intentionally out of scope. A passing documentation check does not establish runtime or hardware behavior.

### Publish

Publication is optional and must be explicitly requested. Build a sanitized projection from repository-owned sources, preserve version and commit provenance, and verify the delivered target after publication. The publication target must be supplied by project configuration or the user; this skill does not assume a particular domain, subdomain, DNS provider, or deployment system.

For the publication adapter contract, read [references/publication-adapter.md](references/publication-adapter.md).

## Stop conditions

Stop before claiming completion when any of these occurs:

- the canonical source, schema, ledger, or generated artifact is missing or inconsistent;
- a referenced file, symbol, JSON Pointer, or test does not exist;
- a requirement is unresolved or ambiguous without an explicit disposition;
- the documentation makes a broader claim than the evidence register;
- publication credentials, target identity, or release authorization are not available;
- a live target cannot be independently verified after delivery.

When stopped, report the exact missing evidence and the smallest next action.
