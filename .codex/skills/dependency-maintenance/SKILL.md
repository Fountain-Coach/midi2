# Dependency Maintenance

## Purpose
Keep dependencies up to date and respond to security advisories with minimal risk.

## When to Use
- Weekly dependabot review
- Security alerts or CVE responses
- Scheduled monthly dependency audits

## Steps
1. Review Dependabot PRs and categorize by patch/minor/major impact.
2. Verify CI results before approving merges.
3. For manual updates, update dependencies and run relevant tests.
4. Document significant dependency changes in `CHANGELOG.md`.
5. Prioritize critical/high security fixes per SLA.

## Output Contract
- Dependency updates are merged with passing CI.
- High-risk changes are reviewed and tested.
- Security fixes meet SLA timelines.

## References
- `MAINTENANCE.md` for command-level procedures.
- `.github/dependabot.yml` for configuration.
