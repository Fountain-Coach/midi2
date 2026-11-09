# Third-party MIDI specification sources

The six MIDI 2.0 PDFs named in `docs/spec-provenance.json` are third-party normative source material attributed to the MIDI Association. The repository records their exact filenames, versions, and SHA-256 hashes so the audited inputs are reproducible.

The repository’s MIT license applies only to Fountain Coach-owned code and documentation. It does not grant rights to redistribute the MIDI Association PDFs. The repository does not infer redistribution permission from the presence of a PDF; licensing and redistribution status remain **not independently established here** unless the repository contains direct evidence. If a source must move outside the public repository, the hash manifest remains the identity of the audited artifact.

The MIDI Association remains the normative authority. Fountain Coach’s schema, ledgers, reports, and extensions are representations and engineering artifacts, not replacements for the source specifications.

## Latest MIDI-CI source handling (2026-11-09)

The current declared M2-101-UM revision is v1.2.1, published 2025-12-18. Its SHA-256 is `f3c3c63d768f049a387c79998081da284a1baf8605ca10d246e9a52258056e6f`. The prior v1.2 source remains historical and is recorded in `docs/spec-provenance.json` under `versioned_updates`. The current PDF is fetched by `Scripts/fetch_spec_sources.py` into a gitignored local or CI workspace and is **not** included in the public repository, generated documentation, or release package. Download availability is an external prerequisite; a missing or mismatched source prevents verification rather than silently downgrading the corpus.
