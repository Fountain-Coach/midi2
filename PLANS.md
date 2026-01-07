# PLANS Protocol (FCIS RFC 0001)

## Purpose
Define the planning protocol for multi-step or high-risk work in this repository. Plans capture intent, scope, and acceptance criteria before implementation begins.

## When a Plan Is Required
A plan is required when work is:
- Multi-step or cross-cutting across packages
- Release-related or security-sensitive
- Likely to change public APIs, CI, or compliance artifacts
- Non-trivial refactors or migrations

## Plan Format (Template)
A plan must answer **what** and **why**, not **how**. Use this template in issues, PRs, or planning docs:

```
Goal:
Scope:
Non-goals:
Constraints:
Dependencies:
Risks:
Steps:
  - [ ] Step 1 (intent + outcome)
  - [ ] Step 2 (intent + outcome)
Validation:
Acceptance Criteria:
```

## Status Conventions
- `pending` / `in_progress` / `completed`
- One `in_progress` step at a time

## Storage
Plans may live in:
- The PR description
- An issue description
- A dedicated planning document referenced by the PR

## Relationship to Skills
Execution details belong in `.codex/skills/*/SKILL.md`. Plans should link to relevant skills rather than include procedures.
