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

def require_pbrvt_frames():
    required = [
        'docs/pb-vrt/stream/endpoint_discovery.json',
        'docs/pb-vrt/stream/stream_config_request.json',
        'docs/pb-vrt/stream/stream_config_notification.json',
        'docs/pb-vrt/stream/function_block_info.json',
        'docs/pb-vrt/stream/function_block_discovery.json',
        'docs/pb-vrt/stream/gtb.json',
        'docs/pb-vrt/property-exchange/get_reply_chunked.json',
        'docs/pb-vrt/property-exchange/set_chunked.json',
        'docs/pb-vrt/property-exchange/notify_chunked.json',
        'docs/pb-vrt/profiles/inquiry_reply.json',
        'docs/pb-vrt/profiles/enabled_report.json',
        'docs/pb-vrt/profiles/disabled_report.json',
        'docs/pb-vrt/profiles/details_reply.json',
        'docs/pb-vrt/profiles/profile_specific_data.json',
        'docs/pb-vrt/jr/clock_timestamp.json',
        'docs/pb-vrt/sysex8/invalid_cases.json',
        'docs/pb-vrt/mds/invalid_cases.json',
        'docs/pb-vrt/process-inquiry/flows.json'
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
    ok &= require_pbrvt_frames()
    sys.exit(0 if ok else 1)

if __name__ == '__main__':
    main()
