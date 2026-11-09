#!/usr/bin/env ruby
# frozen_string_literal: true

# Contract/projection check for the candidate M2-124 software-peer scenario.
# This is not a transport implementation or a conformance certificate.
require "yaml"
require "json"

ROOT = File.expand_path("..", __dir__)
SOURCE = File.join(ROOT, "Tests/Scenarios/network-midi2-udp-peer.yaml")
PROJECTION = File.join(ROOT, "Tests/Scenarios/network-midi2-udp-peer.json")

def fail_contract(message)
  warn "scenario-contract: #{message}"
  exit 1
end

raw = YAML.safe_load(File.read(SOURCE), permitted_classes: [], aliases: false)
fail_contract("missing scenario root") unless raw.is_a?(Hash) && raw["scenario"].is_a?(Hash)
scenario = raw["scenario"]
expected_json = JSON.pretty_generate(raw) + "\n"

if ARGV.include?("--write")
  File.write(PROJECTION, expected_json)
  puts "scenario-projection: wrote #{PROJECTION}"
  exit 0
end

unless File.file?(PROJECTION) && File.read(PROJECTION) == expected_json
  fail_contract("checked JSON projection does not match YAML; regenerate using --write")
end

fail_contract("wrong identity") unless scenario["id"] == "midi2.network-udp.two-software-peers"
fail_contract("wrong target kind") unless scenario["kind"] == "system-boundary"
fail_contract("wrong owner") unless scenario["owner"] == "Fountain-Coach/midi2"
fail_contract("non-candidate status") unless scenario["status"] == "candidate"

spec = scenario.fetch("specification")
implementation = scenario.fetch("implementation")
topology = scenario.fetch("topology")
claim = scenario.fetch("claim_boundary")
fail_contract("wrong spec/version") unless spec["document"] == "M2-124-UM" && spec["required_version"] == "1.0.1"
manifest_path = spec["source_manifest"]
fail_contract("wrong or missing source manifest path") unless manifest_path == "docs/network-midi2-udp-source.json"
manifest = JSON.parse(File.read(File.join(ROOT, manifest_path)))
source = manifest.fetch("document")
fail_contract("source ID/version drift") unless source["id"] == spec["document"] && source["version"] == spec["required_version"]
fail_contract("source hash or version evidence drift") unless spec["source_verified"] == true &&
  source["sha256"] == spec["source_hash"] && source["sha256"].match?(/\A[0-9a-f]{64}\z/) &&
  source["pdfCommitted"] == false && source["redistributionRightsEstablished"] == false
fail_contract("missing source page evidence") unless spec["source_page_map"].is_a?(Hash) &&
  spec["source_page_map"]["framing"] && spec["source_page_map"]["ump_data"] &&
  spec["source_page_map"]["multiple_clients"]
fail_contract("transport namespace changes IDL") unless implementation["requires_new_idl_topic"] == false && implementation["changes_existing_idl"] == false
fail_contract("incumbent RTP implementation missing from boundary") unless implementation["incumbent_transport"] == "Sources/MIDI2Transports/RTPMidiSession.swift"
fail_contract("no independent peer topology") unless topology.dig("initiator", "process") != topology.dig("responder", "process")
fail_contract("missing independent witnesses") unless topology.fetch("witnesses").include?("independent-packet-capture")
fail_contract("missing hardware exclusion") unless claim.fetch("excluded").include?("physical-device interoperability")
fail_contract("insufficient negative cases") unless scenario.fetch("negative_cases").length >= 7
fail_contract("no honest blocker") unless scenario.fetch("terminal_predicates").fetch("blocked").include?("missing-authoritative-versioned-source")
fail_contract("no source/build/run evidence") unless scenario.fetch("evidence").fetch("required").include?("source-revision-and-resolved-dependencies")

if ARGV.include?("--admission")
  blockers = []
  blockers << "M2-124-UM v1.0.1 source hash and page mapping absent" unless spec["source_verified"] && spec["source_hash"].to_s.match?(/\A[0-9a-f]{64}\z/) && spec["source_page_map"]
  blockers << "standards-facing NetworkMidi2Session not implemented" unless File.file?(File.join(ROOT, implementation["target"]))
  receipt = scenario.fetch("evidence")["independent_software_peer_receipt"]
  valid_receipt = receipt.is_a?(Hash) && receipt["independent_software_peer"] == true &&
    receipt["initiator_executable_sha256"].to_s.match?(/\A[0-9a-f]{64}\z/) &&
    receipt["responder_executable_sha256"].to_s.match?(/\A[0-9a-f]{64}\z/) &&
    receipt["packet_capture_sha256"].to_s.match?(/\A[0-9a-f]{64}\z/) &&
    receipt["run_id"].to_s.length > 0
  blockers << "independent software-peer acceptance receipt absent or incomplete" unless valid_receipt
  unless blockers.empty?
    blockers.each { |blocker| warn "not-established: #{blocker}" }
    exit 2
  end
end

puts "scenario-contract: checked YAML/JSON parity, identity, transport boundary, negative cases, and claim exclusions"
puts "scenario-status: candidate (not a runnable protocol acceptance or instrument release)"
