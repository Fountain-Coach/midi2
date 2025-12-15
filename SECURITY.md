# Security Policy

## Reporting a Vulnerability

The **Fountain-Coach/midi2** maintainers take security vulnerabilities seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, use one of the following methods:

#### Preferred: GitHub Security Advisories (Private Reporting)
1. Navigate to https://github.com/Fountain-Coach/midi2/security/advisories
2. Click "Report a vulnerability"
3. Fill in the vulnerability details
4. Submit the report

This creates a private security advisory that only the maintainers can see.

#### Alternative: Email
If you prefer email or cannot use GitHub's private reporting:
- **Email:** mail@benedikt-eickhoff.de
- **Subject line:** `[SECURITY] midi2 vulnerability: [brief description]`

**Include in your report:**
- Description of the vulnerability
- Steps to reproduce the issue
- Affected versions (if known)
- Potential impact and attack scenarios
- Any suggested fixes or mitigations

#### PGP/GPG Encryption (Optional)
If you prefer encrypted communication, request the current PGP public key via the security contact email and we will share the fingerprint and key location.

## Response Timeline

We aim to respond to security reports according to the following timeline:

- **Acknowledgment:** Within 24 hours of report submission
- **Initial assessment:** Within 72 hours (severity classification)
- **Status update:** Weekly updates until resolved
- **Fix timeline:** 
  - Critical (CVSS 9.0-10.0): 24 hours
  - High (CVSS 7.0-8.9): 72 hours
  - Medium (CVSS 4.0-6.9): 2 weeks
  - Low (CVSS 0.1-3.9): 1 month

## Disclosure Policy

We follow **coordinated disclosure** principles:

1. **Private fix development:** We develop fixes in private before public disclosure
2. **Coordination:** We coordinate with you (the reporter) on disclosure timing
3. **Default timeline:** 90 days from initial report to public disclosure
4. **Early disclosure:** Critical vulnerabilities may be disclosed earlier if actively exploited
5. **Credit:** We will credit you in the security advisory (unless you prefer anonymity)

### What to Expect

1. **Acknowledgment:** We confirm receipt and start investigation
2. **Validation:** We reproduce and assess the vulnerability
3. **Fix development:** We develop and test a fix in a private repository/branch
4. **Pre-release notification:** We notify you before publishing the fix
5. **Public disclosure:** We publish a security advisory and release patched versions
6. **CVE assignment:** We request a CVE identifier for qualifying vulnerabilities

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          | Notes                          |
| ------- | ------------------ | ------------------------------ |
| 0.8.x   | ✅ Yes             | Current stable release         |
| 0.7.x   | ⚠️ Limited         | Critical fixes only (90 days)  |
| < 0.7   | ❌ No              | Please upgrade to 0.8.x        |

**Policy:**
- **Current MINOR version:** Full support (patches, security updates)
- **Previous MINOR version:** Critical security fixes for 90 days after new release
- **Older versions:** No security updates; users must upgrade

## Security Best Practices

When using the **midi2** library:

### For Swift Developers
- **Keep dependencies updated:** Regularly update to the latest stable version
- **Validate MIDI input:** Always validate and sanitize untrusted MIDI data before processing
- **Limit resource usage:** Implement timeouts and rate limiting for MIDI processing
- **Avoid unsafe APIs:** Do not use deprecated or unsafe functions

### For JavaScript/TypeScript Developers
- **Use latest version:** Install via `npm install @fountain-coach/midi2@latest`
- **Audit dependencies:** Run `npm audit` regularly to check for vulnerabilities
- **Validate input:** Sanitize MIDI data from untrusted sources (WebMIDI, file uploads)
- **Content Security Policy:** Configure CSP headers when using midi2.js in web applications
- **Avoid eval/injection:** Do not pass untrusted data to dynamic code execution

### For CI/CD Pipelines
- **Enable Dependabot:** Use `.github/dependabot.yml` to auto-update dependencies
- **Run security scans:** Use CodeQL, npm audit, or Swift package audits in CI
- **Pin versions:** Use exact versions in production deployments
- **Monitor advisories:** Subscribe to GitHub security advisories for this repository

## Known Security Considerations

### MIDI Data Parsing
- **Malformed packets:** The library includes validation for UMP format, but always handle parse errors gracefully
- **Resource exhaustion:** Large SysEx messages or rapid message rates may cause memory/CPU spikes; implement rate limiting
- **Integer overflow:** MIDI timestamps use 64-bit integers; ensure your system handles large values

### Dependency Security
The **midi2** project depends on:
- **Swift:** `swift-argument-parser`, `swift-numerics`, `SwiftCheck` (dev)
- **JavaScript:** `vitest` (dev), `tsup` (dev), `typescript` (dev)

We monitor these dependencies for security advisories via Dependabot.

### Platform-Specific Concerns
- **iOS/macOS:** CoreMIDI bridging code runs with system MIDI permissions; validate all inputs
- **Linux:** ALSA bindings require native library access; ensure ALSA is up-to-date
- **Web browsers:** WebMIDI requires user permission; never bypass browser security policies

## Vulnerability History

Past security advisories will be listed here:

<!-- Example entry:
### [GHSA-xxxx-yyyy-zzzz] Integer Overflow in UMP Decoder (v0.5.2)
- **Severity:** Medium (CVSS 5.5)
- **Affected versions:** 0.4.0 - 0.5.1
- **Fixed in:** 0.5.2
- **Description:** Malformed UMP packets could cause integer overflow in timestamp parsing
- **Credit:** Security Researcher Name
- **Link:** https://github.com/Fountain-Coach/midi2/security/advisories/GHSA-xxxx-yyyy-zzzz
-->

*No security advisories published yet.*

## Security Update Notifications

To receive notifications about security updates:

1. **GitHub Watch:** Click "Watch" → "Custom" → ☑ "Security alerts" on the repository page
2. **GitHub Advisory Database:** Subscribe to https://github.com/advisories?query=ecosystem%3Anpm+@fountain-coach/midi2
3. **npm:** Security advisories are published via npm registry metadata
4. **Dependabot:** Automatically creates PRs for vulnerable dependencies

## Contact

For non-security issues, please use:
- **Bug reports:** https://github.com/Fountain-Coach/midi2/issues
- **Questions:** https://github.com/Fountain-Coach/midi2/discussions

For security-related inquiries only:
- **Email:** mail@benedikt-eickhoff.de
- **GitHub Security Advisories:** https://github.com/Fountain-Coach/midi2/security/advisories

## Attribution

This security policy is based on best practices from:
- [GitHub Security Advisories](https://docs.github.com/en/code-security/security-advisories)
- [OWASP Vulnerability Disclosure Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Vulnerability_Disclosure_Cheat_Sheet.html)
- [Carnegie Mellon CERT Coordinated Disclosure](https://vuls.cert.org/confluence/display/CVD)

---

*Last updated: 2025-12-14*
