#!/usr/bin/env ruby
# frozen_string_literal: true
require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
SOURCE = File.join(ROOT, "Tests/Scenarios/midi-ci-v121-pe-flow-control.yaml")
PROJECTION = File.join(ROOT, "Tests/Scenarios/midi-ci-v121-pe-flow-control.json")
def check(condition, message)
  abort("MIDI-CI-SCENARIO: FAIL: #{message}") unless condition
end

data = YAML.safe_load(File.read(SOURCE), permitted_classes: [], aliases: false)
s = data.fetch("scenario")
manifest = JSON.parse(File.read(File.join(ROOT, "docs/spec-provenance.json")))
source = manifest.fetch("specifications").fetch("M2-101-UM")
baseline = JSON.parse(File.read(File.join(ROOT, "docs/release-spec-baseline.json")))
check(s["id"] == "midi2.midi-ci-1-2-1.property-exchange-flow-control", "wrong scenario")
check(s["owner"] == "Fountain-Coach/midi2" && s["status"] == "candidate", "ownership/status")
check(s.dig("authority", "document") == "M2-101-UM", "document")
check(s.dig("authority", "version") == source["version"], "version mismatch")
check(s.dig("authority", "sha256") == source["sha256"], "source hash mismatch")
check(s.dig("implementation", "release_candidate") == baseline["release_candidate"], "package version drift")
check(s.dig("implementation", "schema_pointer") == "#/$defs/MidiCiPEFlowControl", "schema authority drift")
check(s.dig("release_boundary", "full-spec-compliance-claim") == false, "cannot certify full runtime")
check(s.fetch("terminal_predicates").fetch("external_or_full_runtime_not_established").include?("hardware-interoperability"), "missing hardware exclusion")
check(s.fetch("cases").length == 6, "positive/negative scenario inventory drift")
check(s.fetch("cases")[0].dig("expected", "fields") == [52, 17, 0, 5, 52, 2, 0, 0], "ACK vector drift")
check(s.fetch("cases")[1].dig("expected", "fields") == [53, 18, 0, 127, 127, 127, 0, 0], "NAK vector drift")
s.fetch("witnesses").each_value do |path|
  check(File.file?(File.join(ROOT, path)), "missing witness #{path}")
end
json = JSON.pretty_generate(data) + "\n"
if ARGV.include?("--write")
  File.write(PROJECTION, json)
  puts "MIDI-CI-SCENARIO: wrote checked JSON projection"
elsif File.file?(PROJECTION) && File.read(PROJECTION) == json
  puts "MIDI-CI-SCENARIO: PASS (source/versions/vectors/witnesses/exclusions)"
else
  abort("MIDI-CI-SCENARIO: FAIL (JSON projection drift)")
end
