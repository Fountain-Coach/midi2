# FCIS Compliance Plan (RFC 0001)

## Goal & Scope
Bring `Fountain-Coach/midi2` into FCIS RFC 0001 compliance by separating policy (AGENTS), planning protocol (PLANS), and execution techniques (Skills) with minimal, non-destructive edits.

## Minimal-Change Strategy
- Keep existing docs (e.g., `RELEASE.md`, `MAINTENANCE.md`, `CONTRIBUTING.md`) intact.
- Extract runbooks from `AGENTS.md`/`PLAN.md` into focused Skills.
- Convert `AGENTS.md` into declarative invariants and routing only.
- Add `PLANS.md` as the required planning protocol; keep `PLAN.md` as roadmap/status.

## Phased Plan with Acceptance Criteria

### Phase 0: Safety (no behavior change)
**Steps**
- Verify repository is allowlisted and working tree is clean.
- Create a feature branch for compliance work.

**Files**: none

**Acceptance criteria**
- Branch `fcs/rfc0001-compliance` exists; no direct `main` edits.

### Phase 1: Establish required files/structure
**Steps**
1. Create `PLANS.md` with FCIS plan protocol (purpose, when-to-use, required sections, status tracking).
2. Create `.codex/skills/*/SKILL.md` modules for runbooks currently embedded in `AGENTS.md` and `PLAN.md`.

**Files**
- Create `PLANS.md`
- Create `.codex/skills/triage-workflow/SKILL.md`
- Create `.codex/skills/release-process/SKILL.md`
- Create `.codex/skills/dependency-maintenance/SKILL.md`
- Create `.codex/skills/ci-operations/SKILL.md`
- Create `.codex/skills/security-incident-response/SKILL.md`
- Create `.codex/skills/onboarding-maintainers/SKILL.md`
- Create `.codex/skills/maintenance-cadence/SKILL.md`
- Create `.codex/skills/deprecation-lifecycle/SKILL.md`
- Create `.codex/skills/sunsetting/SKILL.md`
- Create `.codex/skills/spec-pdf-to-schema/SKILL.md`
- Create `.codex/skills/midi2-js-workflow/SKILL.md`

**Acceptance criteria**
- `PLANS.md` exists and is referenced from `AGENTS.md`.
- Each skill has purpose, when-to-use, steps, and output contract.

### Phase 2: Refactor content for orthogonality
**Steps**
1. Rewrite `AGENTS.md` as declarative policy and routing (no procedures or templates).
2. Remove step-by-step procedures from `AGENTS.md`, referencing Skills instead.
3. Update `PLAN.md` to clarify it is a roadmap/status doc and remove execution commands.
4. Trim legacy AGENTS files to archival stubs that point to Skills (procedures preserved in skills).

**Files**
- Edit `AGENTS.md` (remove procedures, add routing to `PLANS.md` + skills)
- Edit `PLAN.md` (roadmap only, no commands)
- Edit `legacy/AGENTS.md`, `legacy/midi2-js-AGENTS.md` (archival stubs + pointers)

**Acceptance criteria**
- `AGENTS.md` contains no step lists, commands, or templates.
- `PLAN.md` contains only intent/status content.
- Legacy AGENTS files no longer contain procedures.

### Phase 3: Validation & enforcement notes
**Steps**
1. Ensure AGENTS explicitly states: use `PLANS.md` for multi-step/high-risk work; Skills are the sole execution runbooks.
2. Ensure no MCP dependency is introduced.
3. Record compliance status update in `FCIS_AUDIT.md` if needed.

**Files**
- Confirm `AGENTS.md` references `PLANS.md` and `.codex/skills/*`.
- (Optional) Update `FCIS_AUDIT.md` note about remediation.

**Acceptance criteria**
- FCIS layers are orthogonal and discoverable.
- Repo does not require MCP to operate.
