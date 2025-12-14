# AGENTS - Repository Maintenance Policy

## Purpose and Scope

This document defines the long-term maintenance policy for the **Fountain-Coach/midi2** repository, which contains:
- Swift-based MIDI 2.0 reference implementation (UMP model, MIDI-CI, bridging libraries)
- TypeScript/JavaScript library `midi2.js` for cross-browser MIDI 2.0 protocol support
- Apple platform bridging packages (CoreMIDI, Audio Units)
- Example applications and compliance tools

The maintenance policy ensures:
- Consistent quality and security standards across releases
- Clear ownership and accountability for repository components
- Sustainable long-term development and support
- Rapid response to security incidents and breaking changes

## Roles and Responsibilities

### Maintainers
**Primary responsibilities:**
- Review and merge pull requests
- Triage and prioritize issues
- Enforce code quality standards and DoD compliance
- Manage releases and version bumps
- Monitor CI/CD pipeline health

**Required access:**
- Write access to the repository
- Access to GitHub Actions secrets for package publishing
- Listed in `CODEOWNERS` file

**Current maintainers:** See `.github/CODEOWNERS`

### Release Manager
**Primary responsibilities:**
- Execute release checklist (see `RELEASE.md`)
- Coordinate version bumps across Swift and JavaScript packages
- Publish packages to registries (npm, Swift Package Manager)
- Draft and publish GitHub Releases with changelog
- Verify CI passes and coverage gates before tagging

**Rotation:** Assigned per release cycle (typically every 2-4 weeks)

**Sign up:** Comment on the current release milestone or contact maintainers via GitHub Discussions

### Triage Lead
**Primary responsibilities:**
- Label incoming issues within 48 hours
- Assign priority labels: `priority/critical`, `priority/high`, `priority/normal`, `priority/low`
- Assign component labels: `area/swift`, `area/javascript`, `area/ci`, `area/docs`
- Route security issues to Security Contact
- Close stale or duplicate issues

**Rotation:** Weekly rotation among maintainers

**Sign up:** See maintainer rotation schedule in GitHub wiki or Discussions

### Security Contact
**Primary responsibilities:**
- Monitor security advisories and dependabot alerts
- Coordinate vulnerability disclosure and patching
- Trigger emergency releases for critical CVEs
- Maintain `SECURITY.md` and coordinate with GitHub Security Lab

**Contact:** See `SECURITY.md` for current security contact

### CI Owner
**Primary responsibilities:**
- Monitor CI pipeline health and resolve build failures
- Update GitHub Actions workflows and dependencies
- Maintain build matrix (Swift, Node.js versions)
- Enforce coverage gates and quality checks
- Review and approve dependabot PRs for GitHub Actions

**SLA:** Fix failing CI within 24 hours for `main` branch; 72 hours for feature branches

**Current CI Owner:** See `.github/CODEOWNERS` for `/.github/workflows/` ownership

## On-Call and Rotation Policy

### Rotation Schedule
- **Triage Lead:** Weekly rotation (Monday to Sunday)
- **Release Manager:** Per-release rotation (assigned when milestone created)
- **CI Owner:** Monthly rotation
- **Security Contact:** Fixed assignment, backup rotates quarterly

### Sign-up Process
1. Join the maintainers team (requires write access)
2. Add your availability to the rotation schedule in GitHub wiki
3. Comment on the pinned rotation issue to claim a slot
4. Receive handoff notes from previous rotation holder

### Typical Cadence
- **Daily:** Triage new issues/PRs (Triage Lead)
- **Weekly:** Review dependabot PRs, run `MAINTENANCE.md` weekly tasks
- **Monthly:** Release planning, dependency audits, CI health review
- **Quarterly:** Security audit, documentation refresh, archival review

## Triage Workflow

### Issue Triage (within 48 hours of creation)
1. **Validate:** Ensure issue has sufficient detail, reproducible steps, or use case
2. **Label:**
   - **Type:** `bug`, `enhancement`, `documentation`, `question`, `security`
   - **Area:** `area/swift`, `area/javascript`, `area/ci`, `area/docs`, `area/examples`
   - **Priority:** `priority/critical`, `priority/high`, `priority/normal`, `priority/low`
3. **Assign:** 
   - Critical/High priority: Assign to maintainer or next milestone
   - Normal/Low: Leave unassigned or add to backlog milestone
4. **Security issues:** Immediately label `security`, remove public visibility if needed, contact Security Contact
5. **Duplicate/Invalid:** Close with reference to original issue or explanation

### Pull Request Triage (within 24 hours of creation)
1. **Validate:**
   - CI must be green (Swift tests, TypeScript tests, coverage gate ≥80%)
   - PR description includes context and links to related issue
   - Changes include tests if modifying behavior
2. **Review:**
   - Assign at least one maintainer for code review
   - Request changes if DoD not met (see `CONTRIBUTING.md`)
   - Security-sensitive changes require Security Contact approval
3. **Merge:**
   - Squash-merge for feature PRs
   - Require status checks: `build-test`, `test (midi2.js)`, coverage gate
   - Update `CHANGELOG.md` "Unreleased" section before merging

### Staleness Policy
- **Issues:** Auto-close after 90 days of inactivity with `stale` label and 14-day warning
- **PRs:** Auto-close after 30 days of inactivity with `stale` label and 7-day warning
- **Override:** Apply `keep-open` label to exempt from staleness automation

## Release Process Overview

See **`RELEASE.md`** for detailed step-by-step checklist.

**Summary:**
1. Ensure CI is green and coverage ≥80%
2. Update `CHANGELOG.md` from "Unreleased" to version section
3. Bump version in `Package.swift` and `midi2.js/package.json`
4. Create signed git tag: `git tag -s v0.X.Y -m "Release v0.X.Y"`
5. Push tag: `git push origin v0.X.Y`
6. Build and publish npm package: `cd midi2.js && npm run build && npm publish`
7. Draft GitHub Release with changelog excerpt
8. Announce release in GitHub Discussions and relevant channels

**Versioning:** Follow [Semantic Versioning 2.0.0](https://semver.org/)
- MAJOR: Breaking API changes
- MINOR: New features, backward-compatible
- PATCH: Bug fixes, backward-compatible

## Dependency Maintenance

### Dependabot Configuration
- **Location:** `.github/dependabot.yml`
- **Ecosystems:** `github-actions`, `npm` (midi2.js), `swift` (Package.swift)
- **Frequency:** Weekly checks (Mondays at 09:00 UTC)
- **Auto-merge policy:**
  - Patch updates: Auto-approve if CI passes
  - Minor updates: Require maintainer review
  - Major updates: Require maintainer review and migration testing

### Security Overrides
- **Critical CVEs:** Merge immediately after CI passes, trigger patch release within 24 hours
- **High-severity:** Merge within 72 hours, include in next scheduled release
- **Moderate/Low:** Review in next weekly triage, include in next release

### Manual Dependency Updates
- Run `npm audit` weekly in `midi2.js/` and address high/critical vulnerabilities
- Review Swift package updates quarterly
- Check for outdated GitHub Actions monthly: `gh api repos/:owner/:repo/actions/workflows --jq '.workflows[].path' | xargs -I {} grep 'uses:' {}`

## CI and Testing Ownership

### CI Pipeline Components
1. **Swift CI** (`.github/workflows/ci.yml`): Build, test, coverage (≥80%)
2. **TypeScript CI** (`.github/workflows/midi2-js.yml`): Type check, test, build, coverage
3. **Compliance Tests** (`.github/workflows/midi2-compliance.yml`, `compliance-swift.yml`): MIDI Association Workbench validation

### CI Owner Responsibilities
- Monitor failing builds on `main` branch
- Fix CI failures within 24 hours (main), 72 hours (PRs)
- Update build matrix when new Swift/Node.js versions release
- Review and approve dependabot PRs for GitHub Actions
- Maintain build cache efficiency

### Required Status Checks
Enable branch protection on `main` with required status checks:
```
Settings → Branches → main → Require status checks to pass before merging:
  ✓ build-test
  ✓ test (midi2.js)
  ✓ Enforce coverage gate (>=80%)
```

### Test Infrastructure Ownership
- **Swift tests:** Located in `Tests/`, use `swift test` to run
- **TypeScript tests:** Located in `midi2.js/src/`, use `npm test` in `midi2.js/` directory
- **Coverage reporting:** Enforced at ≥80% for both ecosystems

## Security Incident Response

### Contact
See **`SECURITY.md`** for current security contact email and PGP key.

### Severity Levels
- **Critical (CVSS 9.0-10.0):** Immediate response, patch within 24 hours, emergency release
- **High (CVSS 7.0-8.9):** Patch within 72 hours, include in next scheduled release or hotfix
- **Medium (CVSS 4.0-6.9):** Patch within 2 weeks, include in next minor release
- **Low (CVSS 0.1-3.9):** Patch within 1 month, include in next release

### CVE and Patching Workflow
1. **Report received:** Acknowledge within 24 hours via security contact
2. **Validation:** Reproduce vulnerability and assess severity
3. **Private fix:** Develop patch in private fork or security advisory draft
4. **Disclosure coordination:** Coordinate with reporter on disclosure timeline (typically 90 days)
5. **Release:** Publish patched version, GitHub Security Advisory, and CVE if applicable
6. **Announcement:** Post security advisory to GitHub Discussions and update `SECURITY.md`

### GitHub Security Features to Enable
```
Settings → Security & analysis:
  ✓ Dependency graph
  ✓ Dependabot alerts
  ✓ Dependabot security updates
  ✓ Code scanning (CodeQL)
  ✓ Secret scanning
```

## Deprecation and Breaking Change Policy

### Deprecation Process
1. **Announce:** Add deprecation notice in code comments and documentation
2. **Timeline:** Maintain deprecated APIs for at least one MINOR version (e.g., if deprecated in v0.7.0, remove in v0.9.0)
3. **Warnings:** Emit warnings or compile-time notices where feasible
4. **Migration guide:** Provide migration examples in `CHANGELOG.md` and documentation
5. **Removal:** Remove in next MAJOR version with clear CHANGELOG entry

### Breaking Changes
- **Permitted in:** MAJOR version bumps only (v1.0.0 → v2.0.0)
- **Documentation:** List all breaking changes in `CHANGELOG.md` under "Breaking" section
- **Migration guide:** Provide step-by-step migration instructions in release notes
- **Pre-release testing:** Tag release candidates (e.g., v2.0.0-rc.1) and request community feedback

## Archival and Sunsetting Policy

### Archival Criteria
A repository or package may be archived if:
- No commits for 12 consecutive months
- Maintainers unanimously vote to sunset
- Critical security vulnerability cannot be patched
- Technology stack becomes unsupported (e.g., Swift 6 EOL)

### Sunsetting Process
1. **Announcement:** Post intent to archive in GitHub Discussions and README (90-day notice)
2. **Final release:** Tag final version with clear "end-of-life" notice in release notes
3. **Documentation update:** Add deprecation banner to README and docs
4. **Archive:** Mark repository as archived in GitHub settings
5. **Registry:** Deprecate npm package if applicable: `npm deprecate @fountain-coach/midi2 "No longer maintained"`

## Onboarding Guide for New Maintainers

### Minimum Required Access
- **GitHub:** Write access to `Fountain-Coach/midi2` repository
- **npm:** Publish access to `@fountain-coach/midi2` package (request from existing maintainer)
- **Communication:** Access to maintainer Slack/Matrix/Discord (if applicable)

### Onboarding Steps
1. **Read documentation:** Review `README.md`, `CONTRIBUTING.md`, `RELEASE.md`, this file
2. **Local setup:**
   ```bash
   git clone https://github.com/Fountain-Coach/midi2.git
   cd midi2
   
   # Swift setup
   swift build
   swift test
   
   # JavaScript setup
   cd midi2.js
   npm install
   npm run check
   npm test
   ```
3. **Access requests:**
   - Request write access from existing maintainer
   - Request npm publish access: `npm owner add <username> @fountain-coach/midi2`
   - Request addition to `.github/CODEOWNERS`
4. **Shadow rotation:** Pair with existing Triage Lead or Release Manager for one cycle
5. **First tasks:**
   - Triage 5 issues
   - Review 3 pull requests
   - Perform weekly maintenance checklist (see `MAINTENANCE.md`)

## Escalation Matrix and Communication Channels

### GitHub-based Communication (primary)
- **Issues:** Bug reports, feature requests, questions
- **Pull Requests:** Code reviews, implementation discussions
- **Discussions:** General Q&A, announcements, RFCs
- **Security Advisories:** Private vulnerability reports (see `SECURITY.md`)

### External Channels (if configured)
- **Slack/Matrix:** Real-time maintainer coordination (URL: TBD - update when configured)
- **Email:** Security contact (see `SECURITY.md`), maintainer mailing list (TBD)

### Escalation Path
1. **Issue author → Triage Lead** (via issue comments)
2. **Triage Lead → Maintainers** (via @-mention in issue or Discussions)
3. **Maintainers → Security Contact** (for security issues)
4. **Security Contact → GitHub Security Lab** (for critical vulnerabilities affecting broader ecosystem)

### Response Time Expectations
- **Triage:** 48 hours for issue labeling
- **PR review:** 72 hours for initial review
- **Security report:** 24 hours for acknowledgment
- **Critical CI failure:** 24 hours for fix on `main` branch

## Monthly and Quarterly Maintenance Tasks

### Weekly Tasks (run every Monday, see `MAINTENANCE.md` for commands)
- Review new issues and PRs (Triage Lead)
- Review and merge dependabot PRs
- Check CI health and flaky tests
- Update `CHANGELOG.md` if features merged

### Monthly Tasks
- **Dependency audit:** Run `npm audit` in `midi2.js/`, check Swift package updates
- **CI review:** Review GitHub Actions usage, update runner versions if needed
- **Documentation sync:** Ensure README, CONTRIBUTING, and API docs reflect current state
- **Release planning:** Create next milestone, review backlog

### Quarterly Tasks (run first week of Q1, Q2, Q3, Q4)
- **Security audit:** Review dependabot alerts, run `npm audit --production`, check for Swift CVEs
- **Performance review:** Profile critical paths (UMP encoding/decoding, scheduler)
- **Documentation refresh:** Update examples, fix broken links, refresh badges
- **Archival review:** Close stale issues/PRs, archive outdated branches
- **Compliance review:** Verify spec adherence with latest MIDI 2.0 specifications

---

## Templates

### Issue Template: Bug Report
**File:** `.github/ISSUE_TEMPLATE/bug_report.md`
```markdown
---
name: Bug Report
about: Report a bug or unexpected behavior
labels: bug
---

## Description
<!-- Clear description of the bug -->

## Steps to Reproduce
1. 
2. 
3. 

## Expected Behavior
<!-- What should happen -->

## Actual Behavior
<!-- What actually happens -->

## Environment
- OS: [e.g., macOS 13.5, Ubuntu 22.04, Windows 11]
- Swift version (if applicable): [e.g., 6.2.1]
- Node.js version (if applicable): [e.g., 20.10.0]
- Package version: [e.g., midi2 0.7.0]

## Additional Context
<!-- Logs, screenshots, related issues -->
```

### Issue Template: Feature Request
**File:** `.github/ISSUE_TEMPLATE/feature_request.md`
```markdown
---
name: Feature Request
about: Suggest a new feature or enhancement
labels: enhancement
---

## Problem Statement
<!-- What problem does this feature solve? -->

## Proposed Solution
<!-- How should this feature work? -->

## Alternatives Considered
<!-- Other approaches you've considered -->

## Additional Context
<!-- Use cases, examples, references -->
```

### Issue Template: Security Vulnerability
**File:** `.github/ISSUE_TEMPLATE/security_report.md`
```markdown
---
name: Security Vulnerability
about: Report a security vulnerability (use private reporting if possible)
labels: security
---

## ⚠️ Security Notice
**Please do not report security vulnerabilities publicly.**

Use GitHub's private security advisory feature or email the security contact listed in [SECURITY.md](../SECURITY.md).

This template is for tracking public security discussions only.
```

### Maintenance Checklist Template
**Copy into maintenance tracking issue or project board:**
```markdown
## Weekly Maintenance Checklist
- [ ] Review new issues (triage lead)
- [ ] Review new PRs (maintainers)
- [ ] Merge dependabot PRs if CI passes
- [ ] Check CI health dashboard
- [ ] Update CHANGELOG.md if features merged

## Monthly Maintenance Checklist
- [ ] Run `npm audit` in midi2.js/
- [ ] Check Swift package dependency updates
- [ ] Review GitHub Actions versions
- [ ] Create next release milestone
- [ ] Review backlog and close stale issues

## Quarterly Maintenance Checklist
- [ ] Security audit (dependabot + manual review)
- [ ] Performance profiling
- [ ] Documentation refresh (README, badges, examples)
- [ ] Archival review (close stale items)
- [ ] Compliance review (MIDI 2.0 spec updates)
```
