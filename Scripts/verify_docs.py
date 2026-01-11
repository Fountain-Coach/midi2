#!/usr/bin/env python3
import os, sys, json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def require_file(rel):
    p = os.path.join(ROOT, rel)
    if not os.path.isfile(p):
        print(f"MISSING: {rel}")
        return False
    return True

def require_readme_subcommands():
    readme = os.path.join(ROOT, 'README.md')
    with open(readme, 'r', encoding='utf-8') as f:
        t = f.read()
    needles = [
        'midi2demo pe-demo',
        'midi2demo profiles-demo',
        'midi2demo profiles-psd',
        'midi2demo stream-config endpoint',
        'midi2demo stream-config fb-discover',
        'midi2demo stream-config gtb'
    ]
    ok = True
    for n in needles:
        if n not in t:
            print(f"README missing example: {n}")
            ok = False
    return ok

def require_vrt_protocol_frames():
    required = [
        'docs/vrt-protocol/stream/endpoint_discovery.json',
        'docs/vrt-protocol/stream/stream_config_request.json',
        'docs/vrt-protocol/stream/stream_config_notification.json',
        'docs/vrt-protocol/stream/function_block_info.json',
        'docs/vrt-protocol/stream/function_block_discovery.json',
        'docs/vrt-protocol/stream/gtb.json',
        'docs/vrt-protocol/property-exchange/get_reply_chunked.json',
        'docs/vrt-protocol/property-exchange/set_chunked.json',
        'docs/vrt-protocol/property-exchange/notify_chunked.json',
        'docs/vrt-protocol/profiles/inquiry_reply.json',
        'docs/vrt-protocol/profiles/enabled_report.json',
        'docs/vrt-protocol/profiles/disabled_report.json',
        'docs/vrt-protocol/profiles/details_reply.json',
        'docs/vrt-protocol/profiles/profile_specific_data.json',
        'docs/vrt-protocol/jr/clock_timestamp.json',
        'docs/vrt-protocol/sysex8/invalid_cases.json',
        'docs/vrt-protocol/mds/invalid_cases.json',
        'docs/vrt-protocol/process-inquiry/flows.json'
    ]
    ok = True
    for rel in required:
        if not require_file(rel): ok = False
    return ok

def main():
    ok = True
    ok &= require_file('docs/dod-checklist.yaml')
    ok &= require_file('docs/traceability.md')
    ok &= require_readme_subcommands()
    ok &= require_vrt_protocol_frames()
    sys.exit(0 if ok else 1)

if __name__ == '__main__':
    main()
