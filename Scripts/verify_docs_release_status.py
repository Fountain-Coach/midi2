#!/usr/bin/env python3
"""Date-bound source/release/publication consistency check for MIDI2.

This proves a structured source snapshot and site-generator contract, not
that npm/GitHub distribution or external hardware interoperability occurred.
"""
from __future__ import annotations

import importlib.util
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]

def check() -> None:
    status=json.loads((ROOT/"docs/release-status.json").read_text())
    baseline=json.loads((ROOT/"docs/release-spec-baseline.json").read_text())
    catalog=json.loads((ROOT/"docs/spec-provenance.json").read_text())
    npm=json.loads((ROOT/"midi2.js/package.json").read_text())
    lock=json.loads((ROOT/"midi2.js/package-lock.json").read_text())
    assert status["schemaVersion"]=="fountain-coach.midi2.release-status.v4"
    source=status["source"]
    assert source["branch"]=="main"
    assert re.fullmatch(r"[a-f0-9]{40}",source["versionIntroducedInCommit"])
    assert source["state"]=="signed-git-tag-and-github-source-release-published"
    assert source["packageVersion"]==baseline["release_candidate"]
    assert source["packageVersion"]==npm["version"]==lock["version"]
    assert source["packageVersion"]==lock["packages"][""]["version"]
    manifest=(ROOT/"Package.swift").read_text()
    assert f'let packageVersion = "{source["packageVersion"]}"' in manifest
    assert status["normativeCorpus"]["midiCi"]["version"]==catalog["specifications"]["M2-101-UM"]["version"]==baseline["declared_core_versions"]["M2-101-UM"]
    assert status["normativeCorpus"]["reviewedAt"]==baseline["catalog_reviewed_on"]
    assert status["reviewedAt"]==baseline["catalog_reviewed_on"]

    distribution=status["distribution"]
    assert distribution["swiftGitTagAvailable"] is True
    assert distribution["sourceReleaseComplete"] is True
    assert distribution["releaseAuthority"] == "signed-git-tag-and-public-github-release"
    assert distribution["javascriptDelivery"] == "versioned-git-source; build from midi2.js/"
    assert distribution["optionalRegistries"]["npm"]["requiredForSourceRelease"] is False
    assert distribution["optionalRegistries"]["npm"]["published"] is False
    assert distribution["gitTagSignatureVerifiedLocally"] is True
    assert distribution["gitHubSignatureVerification"] == "not-independently-established"
    assert distribution["gitTagTargetCommit"] == "fb007d34367de86414ad7621159741e2849c827a"
    assert distribution["gitHubReleaseState"] == "published"
    assert distribution["publishedGitHubReleaseTag"] == distribution["verifiedLatestGitHubRelease"]
    assert distribution["publishedGitHubReleaseUrl"] == "https://github.com/Fountain-Coach/midi2/releases/tag/v0.13.0"
    assert distribution["publishedGitHubReleaseAt"] == "2026-11-09T11:11:39Z"
    assert distribution["sourceReleaseComplete"] is True
    assert npm["name"] == "@fountain-coach/midi2"
    assert distribution["verifiedLatestGitTag"]=="v0.13.0"
    assert distribution["verifiedLatestGitHubRelease"]=="v0.13.0"
    assert status["implementation"]["physicalDeviceInterop"]=="not-claimed"
    assert status["implementation"]["m2_124UdpSession"]=="candidate-unmerged"
    for rel in status["evidence"].values():
        if not rel.startswith("https://"):
            assert (ROOT/rel).is_file(),rel

    script=ROOT/"Scripts/build_docs_site.py"
    spec=importlib.util.spec_from_file_location("midi2_build_docs_site",script)
    assert spec is not None and spec.loader is not None
    module=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    machine=set(module.MACHINE_FILES)
    assert "docs/release-status.json" in machine
    assert "docs/release-spec-baseline.json" in machine
    assert "Tests/Scenarios/midi-ci-v121-pe-flow-control.json" in machine
    runbook=(ROOT/"RELEASE.md").read_text()
    process_skill=(ROOT/".codex/skills/release-process/SKILL.md").read_text()
    assert "Package registries" in runbook and "OPTIONAL mirrors" in runbook
    assert "No npm registry account" in process_skill
    assert "npmAndPublishedGitHubReleaseComplete" not in (ROOT/"docs/release-status.json").read_text()
    overview=module.release_status_content(ROOT)
    assert "Versioned source. Public GitHub release." in overview
    for value in (source["packageVersion"],"MIDI-CI v1.2.1","v0.13.0","v0.13.0"):
        assert value in overview,value
    assert 'href="/docs/release-status.json"' in overview
    assert 'href="/docs/release-spec-baseline.json"' in overview
    assert "interoperability" in overview

if __name__=="__main__":
    check()
    print("MIDI2 RELEASE/PUBLICATION STATUS: PASS (dated source snapshot; not a published-release claim)")
