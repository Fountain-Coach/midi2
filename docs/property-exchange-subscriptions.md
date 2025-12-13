# Property Exchange Subscription Lifecycle (Gap 2.2.1)

## Target flow
start → partial (optional, chunked) → full → notify* → end

- `subscriptionCommand`: `"start" | "partial" | "full" | "notify" | "end"`
- Flow-control ACK/NAK on chunked notify when `flowControl=true`.

## TypeScript implementation status
- `PeSubscriptionManager` now tracks lifecycle state per `subscriptionId`, enforcing order and emitting flow-control ACKs when negotiated.
- Helpers return `PropertyExchangeEvent` stubs; I/O wiring remains up to the caller.
- Tests cover lifecycle, missing IDs, out-of-order notify, unknown subscriptions.

## Swift TODO
- Add a subscription state machine to `PropertyExchangeSession` (or dedicated tracker) mirroring the TS lifecycle.
- Track `subscriptionId`, stage, flow-control intent, last chunk number.
- Emit `subscribeReply`, flow-control ACK/NAK, and errors (404/409) per spec tables.
- Add tests for lifecycle sequences, ACK timeout, and NAK retransmit policy.
