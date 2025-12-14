# Release Process

This document provides step-by-step instructions for releasing new versions of the **midi2** repository packages.

## Overview

The midi2 repository contains multiple packages that are versioned and released together:
- **Swift Package:** `MIDI2` (distributed via Swift Package Manager)
- **npm Package:** `@fountain-coach/midi2` (JavaScript/TypeScript library in `midi2.js/`)

Releases follow [Semantic Versioning 2.0.0](https://semver.org/):
- **MAJOR** (X.0.0): Breaking API changes
- **MINOR** (0.X.0): New features, backward-compatible additions
- **PATCH** (0.0.X): Bug fixes, backward-compatible changes

## Pre-Release Checklist

Before starting the release process, ensure:

- [ ] All CI checks are passing on `main` branch
- [ ] Code coverage meets or exceeds 80% threshold
- [ ] All planned features and fixes for the release are merged
- [ ] No open critical or high-priority issues blocking the release
- [ ] `CHANGELOG.md` "Unreleased" section is up-to-date with recent changes
- [ ] Documentation reflects current API state

## Version Bump Guidance

### Determining the Version Number

Review changes since the last release:
```bash
git log v0.7.0..HEAD --oneline
```

Apply semantic versioning rules:
- **MAJOR bump** (0.X.Y → 1.0.0): Breaking changes to public APIs
  - Removed public functions/types
  - Changed function signatures
  - Changed behavior that breaks existing usage
- **MINOR bump** (0.7.Y → 0.8.0): New features, backward-compatible
  - Added new public APIs
  - Extended protocol support (new MIDI-CI capabilities)
  - New examples or packages
- **PATCH bump** (0.7.0 → 0.7.1): Bug fixes only
  - Fixed incorrect behavior
  - Performance improvements
  - Documentation updates

### Version Files to Update

1. **Package.swift** (Swift package version):
   ```swift
   let packageVersion = "0.8.0"  // Line 4
   ```

2. **midi2.js/package.json** (npm package version):
   ```json
   {
     "version": "0.8.0"
   }
   ```

3. **midi2.js/package-lock.json** (auto-updated by npm):
   ```bash
   cd midi2.js
   npm install  # This updates package-lock.json
   ```

## Step-by-Step Release Procedure

### 1. Prepare the Release Branch

```bash
# Ensure you're on main and up-to-date
git checkout main
git pull origin main

# Create a release preparation branch
git checkout -b release/v0.8.0
```

### 2. Update CHANGELOG.md

1. Move items from "Unreleased" section to a new version section:
   ```markdown
   ## [Unreleased]
   <!-- Empty for next development cycle -->
   
   ## [0.8.0] - 2025-12-14
   ### Added
   - Feature X with API Y
   - New CLI command Z
   
   ### Changed
   - Improved performance of UMP encoding
   
   ### Fixed
   - Bug in SysEx8 fragmentation
   ```

2. Update the comparison links at the bottom:
   ```markdown
   [Unreleased]: https://github.com/Fountain-Coach/midi2/compare/v0.8.0...HEAD
   [0.8.0]: https://github.com/Fountain-Coach/midi2/compare/v0.7.0...v0.8.0
   ```

3. Verify the changelog follows [Keep a Changelog](https://keepachangelog.com/) format.

### 3. Bump Version Numbers

Update version in **Package.swift**:
```bash
# Edit line 4
sed -i 's/let packageVersion = "0.7.0"/let packageVersion = "0.8.0"/' Package.swift
```

Update version in **midi2.js/package.json**:
```bash
cd midi2.js
npm version 0.8.0 --no-git-tag-version
cd ..
```

### 4. Verify CI Passes

Commit changes and push to verify CI:
```bash
git add CHANGELOG.md Package.swift midi2.js/package.json midi2.js/package-lock.json
git commit -m "chore: Prepare release v0.8.0"
git push origin release/v0.8.0
```

Create a PR and ensure all checks pass:
- Swift build and tests
- TypeScript type checking and tests
- Coverage gate ≥80%
- Compliance tests (if applicable)

### 5. Merge to Main

Once PR is approved and CI is green:
```bash
# Merge via GitHub UI (squash-merge preferred)
# Or via command line:
git checkout main
git merge --squash release/v0.8.0
git commit -m "chore: Release v0.8.0"
git push origin main
```

### 6. Create and Push Git Tag

Create a signed tag (recommended) or regular tag:
```bash
# Signed tag (requires GPG key configured)
git tag -s v0.8.0 -m "Release v0.8.0"

# Or regular annotated tag
git tag -a v0.8.0 -m "Release v0.8.0"

# Push the tag
git push origin v0.8.0
```

### 7. Build and Verify Artifacts

#### Swift Package
No build artifact needed - distributed via Swift Package Manager from git tag.

Verify the package resolves correctly:
```bash
swift package resolve
swift build
swift test
```

#### npm Package
Build and verify the JavaScript package:
```bash
cd midi2.js

# Install dependencies
npm ci

# Run full build pipeline
npm run build

# Verify output in dist/
ls -la dist/
# Should contain: index.js, index.cjs, index.d.ts, and sourcemaps

# Run tests to ensure built package works
npm test

# Pack to verify package contents (dry run)
npm pack --dry-run
```

### 8. Publish to Package Registries

#### Publish to npm (midi2.js)

**Prerequisites:**
- npm account with publish access to `@fountain-coach/midi2`
- Logged in via `npm login`

**Publish:**
```bash
cd midi2.js

# Verify you're publishing the correct version
npm version

# Publish to npm
npm publish

# Verify publication
npm view @fountain-coach/midi2
```

**Troubleshooting:**
- If publish fails with permission error, request access from existing maintainer:
  ```bash
  npm owner add <your-username> @fountain-coach/midi2
  ```

#### Swift Package Manager
No action needed - package is distributed via git tags. Users will access via:
```swift
.package(url: "https://github.com/Fountain-Coach/midi2.git", from: "0.8.0")
```

### 9. Draft and Publish GitHub Release

1. Go to https://github.com/Fountain-Coach/midi2/releases/new
2. Select tag: `v0.8.0`
3. Release title: `v0.8.0`
4. Release notes (use template below):

```markdown
## What's New

<!-- High-level summary of the release -->

This release includes [brief summary], improving [area], and adding support for [feature].

## Highlights

- **Feature X**: Description of major new feature
- **Performance**: Improved UMP encoding by 20%
- **Bug Fixes**: Fixed critical issue with SysEx8 fragmentation

## Changes

<!-- Copy from CHANGELOG.md -->

### Added
- Feature X with API Y
- New CLI command Z

### Changed
- Improved performance of UMP encoding

### Fixed
- Bug in SysEx8 fragmentation

### Breaking Changes
<!-- List breaking changes if MAJOR version -->
None in this release.

## Installation

**Swift Package Manager:**
```swift
dependencies: [
    .package(url: "https://github.com/Fountain-Coach/midi2.git", from: "0.8.0")
]
```

**npm:**
```bash
npm install @fountain-coach/midi2@0.8.0
```

## Full Changelog

**Full diff:** https://github.com/Fountain-Coach/midi2/compare/v0.7.0...v0.8.0

## Contributors

Thank you to all contributors who made this release possible!
<!-- List contributors via: git log v0.7.0..v0.8.0 --format="%aN" | sort -u -->
```

5. Mark as pre-release if RC: ☑ "This is a pre-release"
6. Click "Publish release"

### 10. Rollback Procedure

If critical issues are discovered after release:

#### Option A: Hotfix Release (Preferred)
```bash
# Create hotfix branch from release tag
git checkout -b hotfix/v0.8.1 v0.8.0

# Fix the issue
# ... make changes ...

# Bump to patch version
sed -i 's/0.8.0/0.8.1/' Package.swift
cd midi2.js && npm version 0.8.1 --no-git-tag-version && cd ..

# Update CHANGELOG.md
# ... add [0.8.1] section ...

# Commit and tag
git commit -am "fix: Critical issue in v0.8.0"
git tag -s v0.8.1 -m "Hotfix release v0.8.1"

# Publish
git push origin hotfix/v0.8.1
git push origin v0.8.1
cd midi2.js && npm publish && cd ..

# Create GitHub release for v0.8.1
```

#### Option B: Deprecate and Rollback (Nuclear Option)
```bash
# Deprecate npm package
cd midi2.js
npm deprecate @fountain-coach/midi2@0.8.0 "Critical bug, use 0.8.1 or 0.7.0"

# Mark GitHub release as "pre-release" or delete
# Users on Swift Package Manager will need manual intervention to pin to 0.7.0
```

### 11. Post-Release Tasks

#### Immediate (within 24 hours)
- [ ] Verify npm package is available: `npm view @fountain-coach/midi2`
- [ ] Test installation in a clean project (Swift and npm)
- [ ] Announce release in GitHub Discussions
- [ ] Update project README badges if version shown
- [ ] Close release milestone on GitHub
- [ ] Start new "Unreleased" section in `CHANGELOG.md` for next cycle

#### Follow-up (within 1 week)
- [ ] Update documentation site (if applicable)
- [ ] Announce on social media / community channels
- [ ] Monitor GitHub issues for release-related bug reports
- [ ] Create next milestone for upcoming release

---

## Release Checklist Template

Copy this checklist into GitHub release notes or milestone:

```markdown
## Release v0.X.Y Checklist

### Pre-Release
- [ ] CI passing on main
- [ ] Coverage ≥80%
- [ ] CHANGELOG.md updated
- [ ] Version bumped in Package.swift
- [ ] Version bumped in midi2.js/package.json
- [ ] Release branch created and PR approved

### Release
- [ ] PR merged to main
- [ ] Git tag created and pushed (v0.X.Y)
- [ ] Swift package verified (swift build, swift test)
- [ ] npm package built (npm run build)
- [ ] npm package published (npm publish)
- [ ] GitHub Release drafted and published

### Post-Release
- [ ] npm package verified (npm view)
- [ ] Clean install tested (Swift + npm)
- [ ] Release announced (Discussions)
- [ ] Milestone closed
- [ ] Next milestone created
```

---

## Hotfix Process

For urgent patches to released versions:

1. **Branch from release tag:**
   ```bash
   git checkout -b hotfix/v0.8.1 v0.8.0
   ```

2. **Fix the issue** with minimal changes

3. **Bump patch version:**
   - Update `Package.swift` (0.8.0 → 0.8.1)
   - Update `midi2.js/package.json` (0.8.0 → 0.8.1)
   - Add hotfix entry to `CHANGELOG.md`

4. **Test thoroughly:**
   ```bash
   swift test
   cd midi2.js && npm ci && npm test
   ```

5. **Tag and release:**
   ```bash
   git commit -am "fix: Critical issue description"
   git tag -s v0.8.1 -m "Hotfix release v0.8.1"
   git push origin hotfix/v0.8.1
   git push origin v0.8.1
   ```

6. **Publish packages** (npm, GitHub Release)

7. **Merge hotfix back to main:**
   ```bash
   git checkout main
   git merge hotfix/v0.8.1
   git push origin main
   ```

---

## Troubleshooting

### CI Failures During Release
- **Coverage below 80%:** Add missing tests or adjust threshold in `.github/workflows/ci.yml` (not recommended)
- **Build errors:** Fix compilation issues before proceeding
- **Test failures:** Fix failing tests; do not skip tests to force release

### npm Publish Failures
- **Authentication error:** Run `npm login` and ensure you have publish access
- **Version already published:** Increment version and retry (cannot overwrite published versions)
- **Network timeout:** Retry publish; npm registry may be temporarily unavailable

### Git Tag Issues
- **Tag already exists:** Delete local and remote tag, then recreate:
  ```bash
  git tag -d v0.8.0
  git push origin :refs/tags/v0.8.0
  git tag -s v0.8.0 -m "Release v0.8.0"
  git push origin v0.8.0
  ```

### Swift Package Resolution Failures
- **Invalid tag:** Ensure tag is pushed and accessible
- **Invalid Package.swift:** Validate with `swift package resolve`
- **Dependency conflicts:** Update dependency versions in `Package.swift`

---

## Additional Resources

- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [npm Publishing Guide](https://docs.npmjs.com/creating-and-publishing-scoped-public-packages)
- [Swift Package Manager](https://www.swift.org/package-manager/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
