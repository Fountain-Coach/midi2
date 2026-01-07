# Deprecation Lifecycle

## Purpose
Manage deprecations and breaking changes with clear timelines and migration guidance.

## When to Use
- Deprecating APIs or behavior
- Planning a breaking change for a major version

## Steps
1. Announce deprecation in code comments and documentation.
2. Maintain deprecated APIs for at least one minor version.
3. Provide migration guidance in `CHANGELOG.md` and release notes.
4. Remove deprecated APIs only in a major release.

## Output Contract
- Deprecations are announced and documented.
- Migrations are documented and timed to major releases.
