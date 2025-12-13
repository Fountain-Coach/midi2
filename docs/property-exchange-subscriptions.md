# Property Exchange Subscription Lifecycle (Gap 2.2.1)

## Target flow
start → partial (optional, chunked) → full → notify* → end

- `subscriptionCommand`: `"start" | "partial" | "full" | "notify" | "end"`
- Flow-control ACK/NAK on chunked notify when `flowControl=true`.

## TypeScript implementation status
- `PeSubscriptionManager` now tracks lifecycle state per `subscriptionId`, enforcing order and emitting flow-control ACKs when negotiated.
- Helpers return `PropertyExchangeEvent` stubs; I/O wiring remains up to the caller.
- Tests cover lifecycle, missing IDs, out-of-order notify, unknown subscriptions.

## Swift status
- Subscription state machine in `PropertyExchangeSession` (start/partial/full/notify/end) with flow-control ACK/NAK for chunk order, timeout NAKs with exponential backoff and retry cap, timeout->408 on exhaustion.
- Tracks `subscriptionId`, stage, flow-control intent, resource, chunk order; replies with status codes (200/404/409) and ACK=17/NAK=18 plus `retryAfterMs`.

## TypeScript status
- `PeSubscriptionManager` mirrors the same lifecycle, flow-control ACK/NAK, resource checks, exponential backoff and retry-capped timeout (408) behavior; tests cover lifecycle, resource mismatch, and retry/backoff.
