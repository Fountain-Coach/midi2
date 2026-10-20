# AGENTS — Repository Policy (FCIS RFC 0001)

## FCIS Goal Fidelity and Non-Invention (mandatory)

Follow the [FCIS founding conduct standard](https://github.com/Fountain-Coach/.github/blob/main/docs/FCIS-Non-Invention-and-Goal-Fidelity.md) before planning or changing scope. The requested observable outcome is fixed. Inspect existing accepted runtime and Git history before designing anything.

**A new blocker is valid only with:** the requested outcome, a reproduced failed operation, an already applicable binding requirement, and the smallest correction with an original-path acceptance test. Missing proof, historical concern, a hypothetical risk or a desired improvement is **not** automatically a blocker.

Do not build alternate authorization, host, transport, storage or test machinery merely because it could be useful. Passing tests of your invention does not establish its necessity. Do not expand the Definition of Done unless the user changes the goal or a demonstrated defect directly invalidates its acceptance. Continue work without repeatedly asking the user to say 'proceed accordingly'. Correct unjustified expansions by reversible cleanup, preserving unrelated work. Respect real security/legal constraints and report completion only with the requested live evidence.

This clause has precedence when interpreting this repository's procedural requirements and proof-bounded development rules.


## Purpose and Scope
This document defines the behavioral invariants and routing rules for **Fountain-Coach/midi2**. It is policy-only and contains no procedures or tool configuration.

## Behavioral Invariants
- All changes land via pull request; the default branch is protected by required status checks.
- Coverage targets remain at or above 80% for Swift and JavaScript test suites.
- Releases follow Semantic Versioning and include a changelog update and a signed tag.
- Security reports are handled per `SECURITY.md` with coordinated disclosure.
- Dependency updates follow the documented Dependabot policy and severity SLAs.
- Breaking changes are allowed only in major releases; deprecations persist for at least one minor release with migration guidance.
- Staleness policy applies: issues close after 90 days of inactivity, PRs after 30 days, unless `keep-open` is applied.
- This repo does not require MCP configuration for correctness.

## Roles and Ownership
- **Maintainers:** Review/merge PRs, enforce quality standards, manage releases, monitor CI.
- **Release Manager:** Coordinate version bumps and package publishing per release cycle.
- **Triage Lead:** Label and prioritize issues within SLA; route security issues.
- **Security Contact:** Own vulnerability intake and disclosure coordination.
- **CI Owner:** Maintain CI health, workflows, and coverage gates.

## Cadence and SLAs
- Issue labeling within 48 hours.
- PR initial review within 72 hours.
- Critical CI failures fixed within 24 hours on `main`.

## Routing (Where to Go for What)

### Planning Protocol
- Use `PLANS.md` for any multi-step or high-risk work. Plans capture intent and acceptance criteria, not procedures.

### Execution Runbooks (Skills)
- Triage workflow: `.codex/skills/triage-workflow/SKILL.md`
- Release process: `.codex/skills/release-process/SKILL.md`
- Dependency maintenance: `.codex/skills/dependency-maintenance/SKILL.md`
- CI operations: `.codex/skills/ci-operations/SKILL.md`
- Security incident response: `.codex/skills/security-incident-response/SKILL.md`
- Onboarding maintainers: `.codex/skills/onboarding-maintainers/SKILL.md`
- Maintenance cadence: `.codex/skills/maintenance-cadence/SKILL.md`
- Deprecation lifecycle: `.codex/skills/deprecation-lifecycle/SKILL.md`
- Sunsetting/archival: `.codex/skills/sunsetting/SKILL.md`
- Spec PDF to schema mapping: `.codex/skills/spec-pdf-to-schema/SKILL.md`
- midi2.js workflow: `.codex/skills/midi2-js-workflow/SKILL.md`

### Operational References
- Release checklist: `RELEASE.md`
- Maintenance commands: `MAINTENANCE.md`
- Contribution workflow: `CONTRIBUTING.md`
- Security policy: `SECURITY.md`
- Issue/PR templates: `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md`

### Roadmap
- Product/status roadmap: `PLAN.md` (non-FCIS planning)

### Legacy Notes
- `legacy/AGENTS.md` and `legacy/midi2-js-AGENTS.md` are archival references; current policy is defined here.
