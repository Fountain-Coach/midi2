#!/usr/bin/env python3
import json
import sys
from pathlib import Path

def main():
    if len(sys.argv) != 3:
        print("Usage: generate_vrt_protocol.py <input-jsonl> <output-dir>")
        sys.exit(1)
    src = Path(sys.argv[1])
    dest = Path(sys.argv[2])
    dest.mkdir(parents=True, exist_ok=True)
    frames = []
    with src.open() as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            frames.append(json.loads(line))
    for idx, frame in enumerate(frames):
        out = dest / f"frame_{idx:04d}.json"
        out.write_text(json.dumps(frame, indent=2))

if __name__ == "__main__":
    main()
