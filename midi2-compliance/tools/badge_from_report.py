#!/usr/bin/env python3
import sys, json

def main(inp, out):
    try:
        data = json.load(open(inp))
        # Very naive check: expect top-level "summary" with pass/fail
        status = "PASS" if str(data).lower().find("fail") == -1 else "WARN"
        color = "brightgreen" if status == "PASS" else "orange"
    except Exception:
        status, color = "UNKNOWN", "lightgrey"
    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="240" height="20">
  <linearGradient id="b" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <mask id="a">
    <rect width="240" height="20" rx="3" fill="#fff"/>
  </mask>
  <g mask="url(#a)">
    <rect width="140" height="20" fill="#555"/>
    <rect x="140" width="100" height="20" fill="#4c1"/>
    <rect width="240" height="20" fill="url(#b)"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11">
    <text x="70" y="14">MIDI2.0 Compliance</text>
    <text x="190" y="14">{status}</text>
  </g>
</svg>'''.replace("#4c1", {"brightgreen":"#4c1","orange":"#fe7d37","lightgrey":"#9f9f9f"}[color])
    open(out, "w").write(svg)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: badge_from_report.py <report.json> <badge.svg>")
        sys.exit(2)
    main(sys.argv[1], sys.argv[2])
