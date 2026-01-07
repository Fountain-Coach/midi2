# Release Process

## Purpose
Coordinate a versioned release across Swift and JavaScript packages with consistent changelog and tags.

## When to Use
- Preparing a scheduled release
- Shipping a hotfix or emergency patch

## Steps
1. Confirm CI is green and coverage meets the required threshold.
2. Update `CHANGELOG.md` from "Unreleased" into a versioned section.
3. Bump versions in `Package.swift` and `midi2.js/package.json`.
4. Build and test both Swift and JavaScript packages.
5. Create and push a signed git tag for the release.
6. Publish the npm package from `midi2.js/`.
7. Draft and publish the GitHub Release.

## Output Contract
- Version numbers and changelog are updated.
- Release tag exists and is pushed.
- npm package and GitHub Release are published.

## References
- `RELEASE.md` for full step-by-step commands and checklists.
