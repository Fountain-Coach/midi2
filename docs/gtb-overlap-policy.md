# GTB / Function Block Overlap Policy (Gap 4.2.2)

Baseline: Appendix I implies GTB group ranges should not overlap unless explicitly permitted. Our runtime defaults to **disallow overlap**.

## Policy
- **Default**: Reject overlaps. Swift/TS validators throw on intersecting group ranges.
- **Allow-overlap escape hatch**: Pass `allowOverlap=true` to validators when interoperating with devices that intentionally share groups. Use only when the device’s descriptor or spec addendum explicitly requires it.
- **Descriptor coverage**: All GTB descriptor groups must be covered by at least one Function Block; otherwise validation fails.

## Guidance
- Prefer non-overlapping Function Blocks/GTBs.
- If overlap is enabled, ensure downstream routing is deterministic (e.g., one block active, or priority rules defined by the device). This codebase does not currently encode priority; it merely skips the overlap rejection when `allowOverlap=true`.
