## Description

<!-- Provide a clear and concise description of your changes -->

## Motivation and Context

<!-- Why is this change needed? What problem does it solve? -->
<!-- If it fixes an open issue, please link to the issue here -->

Fixes #(issue number)
Related to #(issue number)

## Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring (no functional changes)
- [ ] CI/Build system change
- [ ] Other (please describe):

## Component

<!-- Which part of the repository is affected? -->

- [ ] Swift Package (MIDI2, MIDI2CI)
- [ ] JavaScript/TypeScript (midi2.js)
- [ ] Examples
- [ ] Documentation
- [ ] CI/Build System
- [ ] Other:

## Testing

<!-- Describe the tests you ran to verify your changes -->
<!-- Include details of your test configuration -->

### Test Coverage

- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Coverage maintained or improved (≥80%)
- [ ] Manual testing performed

### Testing Checklist

**Swift (if applicable):**
- [ ] `swift build` passes
- [ ] `swift test` passes
- [ ] `swift build -Xswiftc -warnings-as-errors` passes
- [ ] Code coverage checked

**JavaScript/TypeScript (if applicable):**
- [ ] `npm run check` passes (type checking)
- [ ] `npm test` passes
- [ ] `npm run build` passes
- [ ] Code coverage checked

## Documentation

- [ ] Code comments added/updated
- [ ] API documentation updated (doc strings)
- [ ] README.md updated (if needed)
- [ ] CHANGELOG.md updated (added to "Unreleased" section)
- [ ] Examples updated (if API changed)

## Breaking Changes

<!-- If this is a breaking change, list what breaks and provide migration instructions -->

### Migration Guide

<!-- How should users update their code? -->

```swift
// Before:


// After:

```

## Checklist

<!-- Mark completed items with an "x" -->

- [ ] My code follows the style guidelines of this project (see [CONTRIBUTING.md](../CONTRIBUTING.md))
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published in downstream modules
- [ ] I have updated the CHANGELOG.md file

## Additional Notes

<!-- Any additional information that reviewers should know -->

## Screenshots (if applicable)

<!-- Add screenshots to show visual changes -->

## Performance Impact

<!-- If this change affects performance, describe the impact -->

- [ ] No performance impact expected
- [ ] Performance improvement (describe below)
- [ ] Potential performance regression (describe below and justify)

<!-- Performance benchmarks or profiling results (if applicable) -->

---

**For Maintainers:**

Review checklist:
- [ ] Code quality and style
- [ ] Test coverage adequate
- [ ] Documentation complete
- [ ] Breaking changes justified and documented
- [ ] CI passes
- [ ] CODEOWNERS approval (if required)
