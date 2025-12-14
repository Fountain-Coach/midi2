# Post-Merge Configuration Checklist

This document lists configuration items that need to be completed by repository maintainers after merging the comprehensive documentation PR.

## Required: Complete Before Next Release

### 1. Update Security Contact Information
**Priority:** 🔴 **Critical**

Update the following files with the actual security contact email:
- [ ] `SECURITY.md` - Line 23 (email address)
- [ ] `SECURITY.md` - Line 160 (email address in Contact section)
- [ ] `.github/ISSUE_TEMPLATE/security_report.yml` - Line 20 (email in notice)

**Current placeholder:** `security@fountain-coach.dev`

**Action:**
```bash
# Replace placeholder email with actual contact
sed -i 's/security@fountain-coach.dev/YOUR_ACTUAL_EMAIL/g' SECURITY.md
sed -i 's/security@fountain-coach.dev/YOUR_ACTUAL_EMAIL/g' .github/ISSUE_TEMPLATE/security_report.yml
```

### 2. Update CODEOWNERS with Actual Maintainer Handles
**Priority:** 🔴 **Critical**

Update `CODEOWNERS` to replace placeholder team with actual GitHub usernames:
- [ ] Replace `@Fountain-Coach/maintainers` with real GitHub handles
- [ ] Create GitHub team or use individual usernames

**Current placeholder:** `@Fountain-Coach/maintainers`

**Example:**
```
# Before:
* @Fountain-Coach/maintainers

# After (option 1 - individual users):
* @username1 @username2 @username3

# After (option 2 - GitHub team):
* @Fountain-Coach/core-maintainers
```

**Action:**
```bash
# Edit CODEOWNERS file
nano CODEOWNERS
# Replace all instances of @Fountain-Coach/maintainers
```

### 3. Enable Branch Protection Rules
**Priority:** 🟡 **High**

Enable branch protection on `main` branch:
- [ ] Go to: Settings → Branches → Add rule for `main`
- [ ] ☑ Require pull request reviews before merging (1 approval minimum)
- [ ] ☑ Require status checks to pass before merging
  - Required checks: `build-test`, `test (midi2.js)`, `Enforce coverage gate (>=80%)`
- [ ] ☑ Require conversation resolution before merging
- [ ] ☑ Include administrators
- [ ] ☑ Require linear history (optional, recommended)

**Instructions:**
1. Navigate to: https://github.com/Fountain-Coach/midi2/settings/branches
2. Click "Add branch protection rule"
3. Branch name pattern: `main`
4. Configure options as listed above
5. Click "Create" or "Save changes"

### 4. Enable GitHub Security Features
**Priority:** 🟡 **High**

Enable security scanning and alerts:
- [ ] Go to: Settings → Security & analysis
- [ ] ☑ Dependency graph (should already be enabled)
- [ ] ☑ Dependabot alerts
- [ ] ☑ Dependabot security updates
- [ ] ☑ Code scanning (CodeQL) - Click "Set up" and use default configuration
- [ ] ☑ Secret scanning

**Instructions:**
1. Navigate to: https://github.com/Fountain-Coach/midi2/settings/security_analysis
2. Enable each feature listed above
3. For CodeQL: Click "Set up" → "Default" → Commit workflow file

### 5. Remove Duplicate CI Workflow
**Priority:** 🟡 **High**

Remove redundant workflow file:
- [ ] Decision: Keep `midi2-js.yml` or `midi2js.yml`?
- [ ] Recommended: Keep `.github/workflows/midi2-js.yml` (more descriptive name)
- [ ] Delete: `.github/workflows/midi2js.yml`

**Action:**
```bash
# Remove duplicate workflow
git rm .github/workflows/midi2js.yml
git commit -m "chore(ci): Remove duplicate midi2.js workflow"
git push origin main
```

## Optional: Enhanced Configuration

### 6. Add PGP Key for Security Reports (Optional)
**Priority:** 🟢 **Low**

If offering PGP-encrypted security reports:
- [ ] Generate or obtain PGP public key
- [ ] Update `SECURITY.md` lines 33-34 with key fingerprint and location
- [ ] Upload public key to key server or repository

**Example:**
```markdown
#### PGP/GPG Encryption (Optional)
For highly sensitive reports, you may encrypt your message using our PGP key:
```
Fingerprint: 1234 5678 90AB CDEF 1234 5678 90AB CDEF 1234 5678
Public key: https://github.com/Fountain-Coach/midi2/blob/main/SECURITY_PGP.asc
```
```

### 7. Add Coverage Badge to README
**Priority:** 🟢 **Medium**

Integrate code coverage reporting:
- [ ] Sign up for Codecov (https://codecov.io/) or Coveralls
- [ ] Add Codecov/Coveralls token to GitHub Secrets
- [ ] Update CI workflows to upload coverage reports
- [ ] Add coverage badge to README.md

**Example badge:**
```markdown
[![Coverage](https://codecov.io/gh/Fountain-Coach/midi2/branch/main/graph/badge.svg)](https://codecov.io/gh/Fountain-Coach/midi2)
```

### 8. Configure Dependabot Auto-Merge (Optional)
**Priority:** 🟢 **Low**

Set up auto-merge for patch updates:
- [ ] Enable "Allow auto-merge" in repository settings
- [ ] Create GitHub Action to auto-approve Dependabot PRs
- [ ] Configure merge strategy (squash recommended)

**Example workflow:** https://github.com/dependabot/fetch-metadata#example-workflow

### 9. Set Up API Documentation Hosting (Optional)
**Priority:** 🟢 **Low**

Generate and publish API documentation:
- [ ] Swift: Enable DocC or jazzy, publish to GitHub Pages
- [ ] JavaScript: Enable TypeDoc, publish to GitHub Pages or npm docs
- [ ] Add documentation links to README.md

**Instructions:**
- Swift DocC: https://www.swift.org/documentation/docc/
- TypeDoc: https://typedoc.org/

### 10. Create Initial GitHub Release (Optional)
**Priority:** 🟢 **Medium**

Create a GitHub Release for current version:
- [ ] Go to: https://github.com/Fountain-Coach/midi2/releases/new
- [ ] Tag: `v0.7.0` (for midi2.js)
- [ ] Title: `v0.7.0`
- [ ] Copy release notes from CHANGELOG.md
- [ ] Publish release

---

## Verification Checklist

After completing the required items above, verify:
- [ ] Security contact email is valid and monitored
- [ ] CODEOWNERS file lists actual maintainer GitHub handles
- [ ] Branch protection is active on `main` branch (test by creating a PR)
- [ ] Dependabot alerts are visible in Security tab
- [ ] CodeQL scans are running (check Actions tab)
- [ ] No duplicate CI workflows running

---

## Commands Summary

```bash
# 1. Update security contact email
sed -i 's/security@fountain-coach.dev/YOUR_EMAIL/g' SECURITY.md .github/ISSUE_TEMPLATE/security_report.yml

# 2. Update CODEOWNERS (manual edit required)
nano CODEOWNERS

# 3-4. Enable via GitHub UI (Settings → Branches, Settings → Security)

# 5. Remove duplicate workflow
git rm .github/workflows/midi2js.yml
git commit -m "chore(ci): Remove duplicate workflow"
git push origin main

# Verify all changes
git status
```

---

**Last Updated:** 2025-12-14  
**Next Review:** After completing all required items or before next release
