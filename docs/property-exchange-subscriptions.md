# Property Exchange Subscription Lifecycle (Gap 2.2.1)

## Target flow
start → partial (optional, chunked) → full → notify* → end

- `subscriptionCommand`: `"start" | "partial" | "full" | "notify" | "end"`
- Flow-control ACK/NAK on chunked notify when `flowControl=true`.

## TypeScript implementation status
- `PeSubscriptionManager` now tracks lifecycle state per `subscriptionId`, enforcing order and emitting flow-control ACKs when negotiated.
- Helpers return `PropertyExchangeEvent` stubs; I/O wiring remains up to the caller.
- Tests cover lifecycle, missing IDs, out-of-order notify, unknown subscriptions.

## Swift status / TODO
- Added subscription state machine in `PropertyExchangeSession` (start/partial/full/notify/end, flow-control ACK/NAK for chunk order).
- Track `subscriptionId`, stage, and flow-control intent; reply with status codes (200/404/409) and ACK=17.
- TODO: add ACK timeout/retransmit policy and resource-level filtering.
