# FCIS-VRT Protocol Baselines

Purpose: canonical “golden” frames for protocol traffic. VRT-Protocol is the FCIS-VRT mode for protocol baselines, used to diff encoder/decoder changes and guard against regressions.

Layout:
- `stream/` — stream config, GTB, function block discovery/info.
- `profiles/` — profile inquiry/enable/disable/detail frames.
- `process-inquiry/` — capability/message report flows.
- `property-exchange/` — chunked GET/SET/NOTIFY.
- `jr/`, `sysex8/`, `mds/` — existing JR/SysEx8/MDS frames.

Generation: place newline-delimited JSON frames in an input file, then:
```
Scripts/generate_vrt_protocol.py input.jsonl docs/vrt-protocol/<category>/
```

Usage in CI (Gap 8.2.1):
- Commit baselines to `docs/vrt-protocol/**`.
- Add a CI step to compare current encoder/decoder output to baselines.
