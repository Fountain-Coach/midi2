# PB-VRT Baselines

Purpose: canonical “golden” frames for protocol traffic. Used to diff encoder/decoder changes and guard against regressions.

Layout:
- `stream/` — stream config, GTB, function block discovery/info.
- `profiles/` — profile inquiry/enable/disable/detail frames.
- `process-inquiry/` — capability/message report flows.
- `property-exchange/` — chunked GET/SET/NOTIFY.
- `jr/`, `sysex8/`, `mds/` — existing JR/SysEx8/MDS frames.

Generation: place newline-delimited JSON frames in an input file, then:
```
Scripts/generate_pb_vrt.py input.jsonl docs/pb-vrt/<category>/
```

Usage in CI (Gap 8.2.1):
- Commit baselines to `docs/pb-vrt/**`.
- Add a CI step to compare current encoder/decoder output to baselines.
