# Stream Configuration Negotiation Scheme

**Spec References**: M2-104-UM v1.1.2 §5.2, Figures 18/19; §7.2.2.3 (JR fallback guidance)  
**Applies To**: `StreamNegotiationSession` (Swift) and demo CLI `stream handshake`

## State Machine
- **Input**: Stream Configuration *Request* (mt=0xF, opcode=0x05) carries protocol + JR Tx/Rx flags.
- **Evaluate**: Intersect the request with responder capabilities (`supportsMIDI2`, `jrTx`, `jrRx`).
- **Select protocol**: MIDI 2.0 if both sides support it, otherwise downgrade to MIDI 1.0.
- **JR fallback**: Clear unsupported JR directions while preserving supported ones.
- **Persist**: Update `currentConfiguration` and expose `lastMismatchReasons` + `lastConfigMismatch`.
- **Notify**: Emit a Stream Configuration *Notification* when:
  - First negotiation (no prior config), or
  - Any mismatch exists (protocol downgrade, JR Tx/Rx rejected), or
  - Protocol switches compared to the last accepted configuration, or
  - Caller forces it (`forceNotification=true`).

## Mismatch Map
- `protocolDowngraded(requested, selected)` — requester asked for MIDI 2.0 but responder only supports MIDI 1.0.
- `jrTxRejected` — requester asked to transmit JR timestamps; responder cannot receive them.
- `jrRxRejected` — requester asked to receive JR timestamps; responder cannot transmit them.

`StreamNegotiationSession.negotiateStreamConfig` returns a `StreamConfigNegotiationResult` with:
- `notification` — the exact Stream Config Notification to send.
- `mismatches` — array of reasons (empty means accepted as-requested).
- `switchedProtocol` — true when protocol differs from last accepted config.
- `shouldNotifyPeer` — true when the peer must be informed (per policy above).

## Discovery/Notification Payload Examples
- MIDI 2.0 + JR Tx/Rx both enabled (request): `0xF0052600` (group 0, opcode 0x05, data1=0x26, data2=0x00).
- Downgraded reply (MIDI 1.0, JR disabled): `0xF0060000` (notification opcode 0x06, data1=0x00).

## Where Configuration Lives
- **Spec-driven**: The request payload is defined by M2-104-UM Figures 18/19; no extra local config file is required.
- **Responder caps**: Set via `StreamNegotiationSession.Capabilities` (protocol + JR support).
- **USB/descriptor tie-in**: When available, map descriptor-advertised capabilities into `Capabilities` and Function Blocks; fallbacks are handled by the negotiation state machine above to avoid blocking when descriptors are incomplete.
