<!-- generated: Scripts/generate_spec_traceability.py -->
<!-- source-sha256: b38e461dbcc4d3003a6369a038339eeb895bc98baeec4248fa352a731e9a92e3 -->
# Spec Audit Log (generated)

The canonical schema is the authority. This audit view is generated from embedded `x-midi-spec` provenance.

| Schema definition | Specification | Page | Section | Requirement | Verification | Status |
|---|---|---:|---|---|---|---|
| `Uint4` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-uint4` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `Uint7` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-uint7` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `Uint8` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-uint8` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `Uint14` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-uint14` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `Uint16` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-uint16` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `Uint21` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-uint21` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `Uint28` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-uint28` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `Uint32` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-uint32` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `Int32` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-int32` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `ByteArray` | `M2-104-UM v1.1.2` | 20 | UMP field widths and numeric ranges | `ump-field-widths-bytearray` | `Scripts/verify_spec_provenance.py::schema-constraint-validation`  ✅ |
| `UmpMessageType` | `M2-104-UM v1.1.2` | 20 | UMP message types and packet sizes | `ump-packet-structure-umpmessagetype` | `Tests/MIDI2Tests/UmpPacketsTests.swift`  ✅ |
| `Group` | `M2-104-UM v1.1.2` | 37 | Figures 18-23 and stream messages | `ump-stream-structure-group` | `Tests/MIDI2Tests/StreamMappingTests.swift`  ✅ |
| `UmpHeader32` | `M2-104-UM v1.1.2` | 37 | Figures 18-23 and stream messages | `ump-stream-structure-umpheader32` | `Tests/MIDI2Tests/StreamMappingTests.swift`  ✅ |
| `UmpHeader64` | `M2-104-UM v1.1.2` | 37 | Figures 18-23 and stream messages | `ump-stream-structure-umpheader64` | `Tests/MIDI2Tests/StreamMappingTests.swift`  ✅ |
| `UmpHeader128` | `M2-104-UM v1.1.2` | 37 | Figures 18-23 and stream messages | `ump-stream-structure-umpheader128` | `Tests/MIDI2Tests/StreamMappingTests.swift`  ✅ |
| `UtilityOpcode` | `M2-104-UM v1.1.2` | 44 | Utility and System messages | `utility-system-structure-utilityopcode` | `Tests/MIDI2Tests/UtilityBodyTests.swift`  ✅ |
| `UtilityBody` | `M2-104-UM v1.1.2` | 44 | Utility and System messages | `utility-system-structure-utilitybody` | `Tests/MIDI2Tests/UtilityBodyTests.swift`  ✅ |
| `SystemStatus` | `M2-104-UM v1.1.2` | 44 | Utility and System messages | `utility-system-structure-systemstatus` | `Tests/MIDI2Tests/UtilityBodyTests.swift`  ✅ |
| `SystemCommonRealtimeBody` | `M2-104-UM v1.1.2` | 44 | Utility and System messages | `utility-system-structure-systemcommonrealtimebody` | `Tests/MIDI2Tests/UtilityBodyTests.swift`  ✅ |
| `Midi1StatusNibble` | `M2-104-UM v1.1.2` | 52 | MIDI 1.0 Channel Voice messages | `midi1-channel-voice-midi1statusnibble` | `Tests/MIDI2Tests/Midi1ChannelVoiceBodyTests.swift`  ✅ |
| `Midi1ChannelVoiceBody` | `M2-104-UM v1.1.2` | 52 | MIDI 1.0 Channel Voice messages | `midi1-channel-voice-midi1channelvoicebody` | `Tests/MIDI2Tests/Midi1ChannelVoiceBodyTests.swift`  ✅ |
| `SysEx7Packet` | `M2-104-UM v1.1.2` | 50 | SysEx and data messages | `data-message-structure-sysex7packet` | `Tests/MIDI2Tests/DataMessageBodyTests.swift`  ✅ |
| `SysEx7Body` | `M2-104-UM v1.1.2` | 50 | SysEx and data messages | `data-message-structure-sysex7body` | `Tests/MIDI2Tests/DataMessageBodyTests.swift`  ✅ |
| `Midi2StatusNibble` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2statusnibble` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `NoteAttributeType` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-noteattributetype` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2ChannelVoiceBody` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2channelvoicebody` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `DataMessageKind` | `M2-104-UM v1.1.2` | 50 | SysEx and data messages | `data-message-structure-datamessagekind` | `Tests/MIDI2Tests/DataMessageBodyTests.swift`  ✅ |
| `DataMessageBody` | `M2-104-UM v1.1.2` | 50 | SysEx and data messages | `data-message-structure-datamessagebody` | `Tests/MIDI2Tests/DataMessageBodyTests.swift`  ✅ |
| `FlexDataBody` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flexdatabody` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
| `StreamOpcode` | `M2-104-UM v1.1.2` | 37 | Figures 18-23 and stream messages | `ump-stream-structure-streamopcode` | `Tests/MIDI2Tests/StreamMappingTests.swift`  ✅ |
| `StreamBody` | `M2-104-UM v1.1.2` | 37 | Figures 18-23 and stream messages | `ump-stream-structure-streambody` | `Tests/MIDI2Tests/StreamMappingTests.swift`  ✅ |
| `DeltaClockstampConfig` | `M2-104-UM v1.1.2` | 44 | Utility and System messages | `utility-system-structure-deltaclockstampconfig` | `Tests/MIDI2Tests/UtilityBodyTests.swift`  ✅ |
| `ClipEnvelope` | `M2-116-U v1.0` | 12 | MIDI Clip message envelope | `clip-envelope-clipenvelope` | `Tests/MIDI2Tests/ClipEnvelopeTests.swift`  ✅ |
| `MidiCiEnvelope` | `M2-101-UM v1.2` | 45 | MIDI-CI message envelopes | `midi-ci-envelope-midicienvelope` | `Tests/MIDI2Tests/MidiCiEnvelopeTests.swift`  ✅ |
| `MidiCiDiscoveryBody` | `M2-101-UM v1.2` | 45 | MIDI-CI message envelopes | `midi-ci-envelope-midicidiscoverybody` | `Tests/MIDI2Tests/MidiCiEnvelopeTests.swift`  ✅ |
| `MidiCiAckNakBody` | `M2-101-UM v1.2` | 45 | MIDI-CI message envelopes | `midi-ci-envelope-midiciacknakbody` | `Tests/MIDI2Tests/MidiCiEnvelopeTests.swift`  ✅ |
| `MidiCiProfilesBody` | `M2-102-U v1.1` | 15 | Table 6 | `profiles-structure-midiciprofilesbody` | `Tests/MIDI2Tests/MidiCiProfilesBodyTests.swift`  ✅ |
| `MidiCiPropertyExchangeBody` | `M2-103-UM v1.2` | 28 | Tables 13-16 | `property-exchange-structure-midicipropertyexchangebody` | `Tests/MIDI2Tests/PropertyExchangeChunkingTests.swift`  ✅ |
| `MidiCiProcessInquiryBody` | `M2-101-UM v1.2` | 59 | Tables 40-45 | `process-inquiry-structure-midiciprocessinquirybody` | `Tests/MIDI2Tests/MidiCiProcessInquiryBodyTests.swift`  ✅ |
| `FunctionBlockNameNotification` | `M2-104-UM v1.1.2` | 37 | Figures 18-23 and stream messages | `ump-stream-structure-functionblocknamenotification` | `Tests/MIDI2Tests/StreamMappingTests.swift`  ✅ |
| `UmpPacket` | `M2-104-UM v1.1.2` | 20 | UMP message types and packet sizes | `ump-packet-structure-umppacket` | `Tests/MIDI2Tests/UmpPacketsTests.swift`  ✅ |
| `UmpPacket32` | `M2-104-UM v1.1.2` | 20 | UMP message types and packet sizes | `ump-packet-structure-umppacket32` | `Tests/MIDI2Tests/UmpPacketsTests.swift`  ✅ |
| `UmpPacket64` | `M2-104-UM v1.1.2` | 20 | UMP message types and packet sizes | `ump-packet-structure-umppacket64` | `Tests/MIDI2Tests/UmpPacketsTests.swift`  ✅ |
| `UmpPacket128` | `M2-104-UM v1.1.2` | 20 | UMP message types and packet sizes | `ump-packet-structure-umppacket128` | `Tests/MIDI2Tests/UmpPacketsTests.swift`  ✅ |
| `Midi2.NoteOff` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-noteoff` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.NoteOn` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-noteon` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.PolyPressure` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-polypressure` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.ControlChange` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-controlchange` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.ProgramChange` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-programchange` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.ChannelPressure` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-channelpressure` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.PitchBend` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-pitchbend` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.RPN` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-rpn` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.NRPN` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-nrpn` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.RPNRelative` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-rpnrelative` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.NRPNRelative` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-nrpnrelative` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.PerNoteManagement` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-pernotemanagement` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.RegPerNoteController` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-regpernotecontroller` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2.AssignPerNoteController` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2-assignpernotecontroller` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Midi2ChannelVoiceVariants` | `M2-104-UM v1.1.2` | 56 | MIDI 2.0 Channel Voice messages | `midi2-channel-voice-midi2channelvoicevariants` | `Tests/MIDI2Tests/Midi2ChannelVoiceBodyTests.swift`  ✅ |
| `Flex.Tempo` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flex-tempo` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
| `Flex.TimeSignature` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flex-timesignature` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
| `Flex.Metronome` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flex-metronome` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
| `Flex.KeySignature` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flex-keysignature` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
| `Flex.ChordName` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flex-chordname` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
| `Flex.Text` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flex-text` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
| `Flex.Lyric` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flex-lyric` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
| `Flex.Ruby` | `M2-104-UM v1.1.2` | 89 | Flex Data messages | `flex-data-structure-flex-ruby` | `Tests/MIDI2Tests/FlexDataBodyTests.swift`  ✅ |
