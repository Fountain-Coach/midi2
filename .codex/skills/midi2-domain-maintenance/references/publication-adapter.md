# Publication adapter contract

This skill is deliberately independent of any particular domain topology. A project that publishes documentation may provide an adapter with these inputs:

| Input | Required meaning |
|---|---|
| source root | The repository commit and sanitized source projection to publish |
| target identity | The explicitly selected host, repository, bucket, or delivery target |
| route map | The public paths and their semantic relationship |
| metadata | Version, source commit, generated-at time, and canonical project identity |
| verification | The checks used to confirm the delivered target |
| rollback | The recoverable prior release or documented failure path |

The adapter must:

- keep target-specific URLs and navigation in adapter configuration, not in the MIDI2 skill;
- publish only sanitized, repository-owned material;
- preserve links back to canonical source artifacts where public and appropriate;
- verify status, content, metadata, and critical links after delivery;
- report the exact target, source commit, version, and verification result;
- never reinterpret a publication success as software, semantic, or hardware conformance.

For multiple public projections, the adapter should expose a semantic map such as:

```json
{
  "project": "<project identity>",
  "version": "<release version>",
  "source_commit": "<commit>",
  "projections": [
    {
      "id": "<projection id>",
      "target": "<configured delivery target>",
      "purpose": "<human-readable purpose>",
      "entrypoint": "<public path>",
      "backlinks": ["<canonical source or sibling projection>"]
    }
  ]
}
```

The placeholder values are configuration data, not defaults. An adapter must resolve them before any external mutation.
