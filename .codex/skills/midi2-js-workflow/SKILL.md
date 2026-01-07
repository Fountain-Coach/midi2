# midi2.js Workflow

## Purpose
Keep the JavaScript/TypeScript library workflow consistent with tests, builds, and documentation expectations.

## When to Use
- Making changes under `midi2.js/`
- Updating protocol surface area in the JS library

## Steps
1. Run type checks and tests:
   - `npm run check`
   - `npm test`
2. Build artifacts when needed:
   - `npm run build`
3. Keep core logic platform-agnostic; adapters remain under `src/adapters/`.
4. Update documentation and gap tracking when public APIs or protocol coverage change.

## Output Contract
- Tests and type checks pass for `midi2.js` changes.
- Build artifacts are reproducible.
- Docs and gap tracking remain aligned with API surface changes.

## References
- `midi2.js/README.md`
- `docs/gap-closure-tracker.md`
