# Maintenance Guide

This document provides practical commands and procedures for routine maintenance tasks described in [AGENTS.md](AGENTS.md).

## Table of Contents
- [Weekly Tasks](#weekly-tasks)
- [Monthly Tasks](#monthly-tasks)
- [Quarterly Tasks](#quarterly-tasks)
- [Dependency Management](#dependency-management)
- [CI Health Monitoring](#ci-health-monitoring)
- [Documentation Updates](#documentation-updates)
- [Performance Profiling](#performance-profiling)

## Weekly Tasks

Run these tasks every Monday (or beginning of week):

### 1. Review New Issues and PRs

```bash
# List open issues created in the last week
gh issue list --state open --created ">$(date -d '7 days ago' +%Y-%m-%d)"

# List open PRs created in the last week
gh pr list --state open --created ">$(date -d '7 days ago' +%Y-%m-%d)"
```

**Actions:**
- Apply labels: `bug`, `enhancement`, `documentation`, `security`
- Apply area labels: `area/swift`, `area/javascript`, `area/ci`, `area/docs`
- Apply priority: `priority/critical`, `priority/high`, `priority/normal`, `priority/low`
- Assign to maintainers or milestones

### 2. Review Dependabot PRs

```bash
# List dependabot PRs
gh pr list --author app/dependabot --state open

# For each PR:
# 1. Review changes (check for breaking changes)
# 2. Ensure CI passes
# 3. Merge if patch or minor update and CI green
```

**Auto-merge policy:**
- ✅ Patch updates: Auto-approve if CI passes
- ⚠️ Minor updates: Review changelog, merge if compatible
- 🛑 Major updates: Full review required, may need code changes

### 3. Check CI Health

```bash
# View recent workflow runs
gh run list --limit 20

# Check for failures
gh run list --status failure --limit 10
```

**Actions:**
- Investigate failed runs
- Re-run flaky tests
- Fix CI issues within 24 hours for `main` branch

### 4. Update CHANGELOG.md

If features were merged this week, update `CHANGELOG.md`:

```bash
# Review commits since last update
git log --oneline --since="7 days ago" origin/main

# Edit CHANGELOG.md
# Add entries to "Unreleased" section
```

---

## Monthly Tasks

Run these tasks on the first Monday of each month:

### 1. Dependency Audit

**Swift dependencies:**
```bash
# Check for outdated packages
swift package show-dependencies --format json | jq '.dependencies'

# Update to latest compatible versions
swift package update

# Run tests after updating
swift test
```

**JavaScript dependencies:**
```bash
cd midi2.js

# Check for outdated packages
npm outdated

# Run security audit
npm audit

# Fix vulnerabilities (review changes before committing)
npm audit fix

# Run tests after updating
npm test
```

**Actions:**
- Address high/critical vulnerabilities within 72 hours
- Test updates thoroughly before merging
- Update `CHANGELOG.md` if dependencies change significantly

### 2. CI Health Review

```bash
# Check GitHub Actions versions
find .github/workflows -name "*.yml" -exec grep -H "uses:" {} \;

# List Actions with version pins
grep -r "uses:.*@v" .github/workflows/
```

**Actions:**
- Update GitHub Actions to latest stable versions
- Review deprecated actions (check GitHub changelog)
- Update runner versions (e.g., `ubuntu-latest`, `macos-latest`)

### 3. Documentation Sync

**Check for broken links:**
```bash
# Install markdown-link-check (if not installed)
npm install -g markdown-link-check

# Check all markdown files
find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" \
  -exec markdown-link-check {} \;
```

**Review documentation:**
- README.md reflects current features
- CONTRIBUTING.md is up-to-date
- Examples in docs/ match current API

### 4. Release Planning

```bash
# Review unreleased changes
git log --oneline $(git describe --tags --abbrev=0)..HEAD

# Create next milestone (if not exists)
gh milestone create "v0.X.Y" --due "YYYY-MM-DD"
```

**Actions:**
- Triage issues into next milestone
- Review backlog and close stale issues
- Plan features for next release

---

## Quarterly Tasks

Run these tasks in the first week of Q1, Q2, Q3, Q4 (January, April, July, October):

### 1. Security Audit

**Automated scans:**
```bash
# Swift: Check for known vulnerabilities (manual review)
swift package show-dependencies --format json > /tmp/swift-deps.json
# Review dependencies against CVE databases

# JavaScript: Full audit
cd midi2.js
npm audit --production
npm audit --audit-level=moderate
```

**GitHub Security:**
```bash
# List security advisories
gh api repos/:owner/:repo/security-advisories

# Check Dependabot alerts
gh api repos/:owner/:repo/dependabot/alerts
```

**Actions:**
- Address all critical/high vulnerabilities
- Update `SECURITY.md` if contact/policy changes
- Run CodeQL scans (enable in Settings → Security)

### 2. Performance Review

**Profile critical paths:**

**Swift profiling:**
```bash
# Build with optimizations
swift build -c release

# Run performance tests (if available)
swift test -c release --filter PerformanceTests

# Use Instruments on macOS for detailed profiling
# xcode-select --install (if needed)
# instruments -t "Time Profiler" .build/release/midi2demo
```

**JavaScript profiling:**
```bash
cd midi2.js

# Run benchmarks (if available)
npm run bench  # (add script if needed)

# Profile with Node.js
node --prof node_modules/.bin/vitest run
node --prof-process isolate-*.log > profile.txt
```

**Actions:**
- Identify performance regressions
- Optimize hot paths (UMP encoding/decoding, scheduler)
- Add performance tests to prevent regressions

### 3. Documentation Refresh

**Update README badges:**
```bash
# Check CI badge status
# Update version badge to latest release
# Verify license badge
# Add/update coverage badge (if available)
```

**Update examples:**
```bash
# Build and test all examples
cd Examples/AUBridgeSample
xcodebuild -scheme AUBridgeSample build

# Test CLI examples in README
# Verify all code snippets still work
```

**Actions:**
- Update outdated screenshots
- Refresh API examples
- Fix broken links
- Update version numbers in install instructions

### 4. Archival Review

**Close stale issues:**
```bash
# List issues inactive for 90+ days
gh issue list --state open --json number,title,updatedAt \
  --jq '.[] | select(.updatedAt < (now - 90*24*3600 | strftime("%Y-%m-%d"))) | "\(.number): \(.title)"'

# Close with comment
gh issue close <number> --comment "Closing due to inactivity. Please reopen if still relevant."
```

**Close stale PRs:**
```bash
# List PRs inactive for 30+ days
gh pr list --state open --json number,title,updatedAt \
  --jq '.[] | select(.updatedAt < (now - 30*24*3600 | strftime("%Y-%m-%d"))) | "\(.number): \(.title)"'

# Close with comment
gh pr close <number> --comment "Closing due to inactivity. Please reopen if you plan to continue."
```

**Clean up branches:**
```bash
# List merged branches
git branch -r --merged origin/main

# Delete merged remote branches (careful!)
# git push origin --delete <branch-name>
```

### 5. Compliance Review

**Check MIDI 2.0 spec updates:**
- Visit https://www.midi.org/specifications
- Download latest specification PDFs if updated
- Review changes and identify required updates
- Create issues for spec compliance gaps

**Verify conformance:**
```bash
# Run compliance tests
.github/workflows/midi2-compliance.yml  # (manually trigger or review results)

# Review DoD checklist
cat docs/midi2-js-dod.md  # (or equivalent for Swift)
```

---

## Dependency Management

### Swift Package Updates

**Update all dependencies:**
```bash
swift package update
swift test  # Verify nothing broke
git add Package.resolved
git commit -m "chore(deps): Update Swift package dependencies"
```

**Update specific dependency:**
```bash
# Edit Package.swift to change version constraint
swift package resolve
swift test
```

**Check for security advisories:**
- Monitor GitHub Security Advisories
- Subscribe to Swift forums security category
- Review dependencies periodically

### npm Package Updates

**Update all dependencies:**
```bash
cd midi2.js

# Update within semver constraints
npm update

# Or update to latest (may include breaking changes)
npm install <package>@latest

npm test  # Verify nothing broke
git add package.json package-lock.json
git commit -m "chore(deps): Update JavaScript dependencies"
```

**Update specific package:**
```bash
cd midi2.js
npm install <package>@<version>
npm test
```

**Security updates:**
```bash
cd midi2.js

# Auto-fix vulnerabilities (careful with breaking changes)
npm audit fix

# Manual fix for major updates
npm audit fix --force  # (review changes carefully!)

npm test
```

---

## CI Health Monitoring

### View Workflow Status

```bash
# List all workflows
gh workflow list

# View runs for specific workflow
gh run list --workflow=ci.yml --limit 10

# View logs for failed run
gh run view <run-id> --log-failed
```

### Re-run Failed Workflows

```bash
# Re-run failed jobs
gh run rerun <run-id> --failed

# Re-run entire workflow
gh run rerun <run-id>
```

### Update GitHub Actions

**Check for Action updates:**
```bash
# List all actions used
grep -r "uses:" .github/workflows/ | grep -oE "[a-z/-]+@v[0-9]+" | sort -u

# Check for latest versions manually on GitHub Marketplace
```

**Update actions:**
```bash
# Example: Update actions/checkout from v3 to v4
sed -i 's/actions\/checkout@v3/actions\/checkout@v4/g' .github/workflows/*.yml

# Test by triggering workflow
git add .github/workflows/
git commit -m "chore(ci): Update GitHub Actions to latest versions"
git push
```

---

## Documentation Updates

### Regenerate API Docs

**Swift:**
```bash
# Generate documentation with DocC (if configured)
swift package generate-documentation

# Or use jazzy (if installed)
jazzy --module MIDI2 --output docs/api/swift
```

**JavaScript/TypeScript:**
```bash
cd midi2.js

# Generate TypeDoc (if configured)
npx typedoc src/index.ts --out docs/api/js

# Or use built-in TypeScript declaration files
npm run build  # Generates .d.ts files in dist/
```

### Update README Badges

**CI badge:**
```markdown
[![CI](https://github.com/Fountain-Coach/midi2/workflows/CI/badge.svg)](https://github.com/Fountain-Coach/midi2/actions/workflows/ci.yml)
```

**npm version badge:**
```markdown
[![npm version](https://badge.fury.io/js/@fountain-coach%2Fmidi2.svg)](https://www.npmjs.com/package/@fountain-coach/midi2)
```

**License badge:**
```markdown
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

---

## Performance Profiling

### Swift Profiling

**Instruments (macOS):**
```bash
# Build release version
swift build -c release

# Profile with Instruments Time Profiler
instruments -t "Time Profiler" .build/release/midi2demo <args>

# Or use Xcode Instruments GUI
open -a Instruments
```

**Manual timing:**
```swift
import Foundation

let start = CFAbsoluteTimeGetCurrent()
// Code to profile
let elapsed = CFAbsoluteTimeGetCurrent() - start
print("Time: \(elapsed) seconds")
```

### JavaScript Profiling

**Node.js profiler:**
```bash
cd midi2.js

# Generate profiling data
node --prof node_modules/.bin/vitest run

# Process profiling log
node --prof-process isolate-*.log > profile.txt
cat profile.txt
```

**Chrome DevTools:**
```javascript
// In browser console
console.time('label');
// Code to profile
console.timeEnd('label');
```

---

## Troubleshooting

### Swift Build Issues

```bash
# Clean build artifacts
swift package clean
rm -rf .build

# Reset package cache
rm -rf ~/Library/Caches/org.swift.swiftpm
swift package resolve

# Verbose build
swift build -v
```

### npm Issues

```bash
cd midi2.js

# Clear cache
npm cache clean --force

# Remove and reinstall
rm -rf node_modules package-lock.json
npm install

# Verify integrity
npm audit fix
npm test
```

### CI Failures

1. **Check logs:** `gh run view <run-id> --log-failed`
2. **Reproduce locally:** Run same commands as CI
3. **Check for flaky tests:** Re-run workflow
4. **Update dependencies:** May be outdated Action or runner

---

## Useful Commands Reference

```bash
# Git shortcuts
alias gst='git status'
alias glo='git log --oneline --graph'
alias gd='git diff'

# Swift shortcuts
alias sb='swift build'
alias st='swift test'
alias sbc='swift build -c release'

# npm shortcuts (in midi2.js/)
alias ni='npm install'
alias nt='npm test'
alias nb='npm run build'
alias nc='npm run check'

# GitHub CLI shortcuts
alias ghil='gh issue list'
alias ghpl='gh pr list'
alias ghrl='gh run list'
```

---

*For more details on maintenance policies, see [AGENTS.md](AGENTS.md).*
