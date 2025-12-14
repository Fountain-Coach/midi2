# Contributing to midi2

Thank you for your interest in contributing to the **midi2** project! This document provides guidelines for contributing to the Swift and JavaScript/TypeScript MIDI 2.0 reference implementations.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Branch Naming](#branch-naming)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Requirements](#testing-requirements)
- [Code Style](#code-style)
- [Documentation](#documentation)
- [Review Process](#review-process)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment. We expect:
- Professional and courteous communication
- Constructive feedback in reviews
- Focus on technical merit
- Respect for different skill levels and backgrounds

Issues violating these principles should be reported to the maintainers.

## Getting Started

### Prerequisites

**For Swift development:**
- macOS 13+ or Ubuntu 22.04+
- Swift 6.1 or later
- Xcode 15+ (macOS only, for IDE support)

**For JavaScript/TypeScript development:**
- Node.js 20.x or later
- npm 9.x or later

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/midi2.git
   cd midi2
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/Fountain-Coach/midi2.git
   ```

### Local Setup

**Swift setup:**
```bash
# Install dependencies and build
swift package resolve
swift build

# Run tests
swift test

# Run specific test
swift test --filter MIDI2Tests
```

**JavaScript/TypeScript setup:**
```bash
cd midi2.js

# Install dependencies
npm install

# Type check
npm run check

# Run tests
npm test

# Build
npm run build
```

## Development Workflow

1. **Sync with upstream:**
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Create feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes:**
   - Write code
   - Add tests
   - Update documentation

4. **Test locally:**
   ```bash
   # Swift
   swift test
   
   # JavaScript
   cd midi2.js && npm test
   ```

5. **Commit changes** (see [Commit Message Guidelines](#commit-message-guidelines))

6. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Open Pull Request** on GitHub

## Branch Naming

Use descriptive branch names with prefixes:

- `feature/` - New features or enhancements
  - Example: `feature/sysex8-chunking`
- `fix/` - Bug fixes
  - Example: `fix/timestamp-overflow`
- `docs/` - Documentation updates
  - Example: `docs/update-readme`
- `refactor/` - Code refactoring without behavior changes
  - Example: `refactor/ump-decoder`
- `test/` - Test additions or improvements
  - Example: `test/midici-coverage`
- `chore/` - Maintenance tasks (dependencies, CI, etc.)
  - Example: `chore/update-swift-tools`

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, CI, build)
- `perf`: Performance improvements
- `ci`: CI/CD changes

### Scope (optional)
Component or package affected:
- `swift`: Swift package changes
- `js`: JavaScript/TypeScript changes
- `ci`: CI/CD changes
- `docs`: Documentation
- `examples`: Example applications
- `compliance`: Compliance testing

### Examples
```
feat(js): Add SysEx8 fragmentation support

Implements SysEx8 message fragmentation and reassembly according
to MIDI 2.0 spec section 7.4.

Closes #123

---

fix(swift): Correct timestamp overflow in JR receiver

The jitter-reduction receiver was not handling timestamp wrap
correctly for messages spanning the 64-bit boundary.

Fixes #456

---

docs: Update README with midi2.js installation instructions

---

chore(deps): Bump vitest to 3.2.4

Updates vitest to resolve security advisory GHSA-xxxx-yyyy-zzzz.
```

### Commit Message Rules
- Use imperative mood ("Add feature" not "Added feature")
- Capitalize first letter of subject
- No period at the end of subject
- Limit subject line to 72 characters
- Separate subject from body with blank line
- Wrap body at 72 characters
- Reference issues/PRs in footer (e.g., "Closes #123", "Fixes #456")

## Pull Request Process

### Before Opening a PR

1. **Ensure CI passes locally:**
   ```bash
   # Swift
   swift build -Xswiftc -warnings-as-errors
   swift test
   
   # JavaScript
   cd midi2.js
   npm run check
   npm test
   npm run build
   ```

2. **Run coverage checks:**
   ```bash
   # Swift
   swift test --enable-code-coverage
   
   # JavaScript
   npm run coverage
   ```
   Ensure coverage is ≥80% for changed code.

3. **Update documentation:**
   - Add/update docstrings for new public APIs
   - Update README if behavior changes
   - Add examples if introducing new features

4. **Update CHANGELOG.md:**
   Add your changes to the "Unreleased" section:
   ```markdown
   ## [Unreleased]
   ### Added
   - New SysEx8 fragmentation API
   
   ### Fixed
   - Timestamp overflow in JR receiver
   ```

### PR Template

When creating a PR, include:

**Description:**
- What problem does this solve?
- What approach did you take?

**Related Issues:**
- Closes #123
- Related to #456

**Testing:**
- What tests did you add?
- How did you verify the changes?

**Checklist:**
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] CI passes locally
- [ ] Coverage ≥80%

### PR Title Format
Use conventional commit format:
```
feat(js): Add SysEx8 fragmentation support
fix(swift): Correct timestamp overflow in JR receiver
docs: Update README with installation instructions
```

## Testing Requirements

### Swift Tests
- **Location:** `Tests/MIDI2Tests/`, `Tests/Fuzz/`
- **Framework:** Swift Testing (XCTest-based)
- **Coverage target:** ≥80% for all production code

**Writing tests:**
```swift
import XCTest
@testable import MIDI2

final class UMPEncoderTests: XCTestCase {
    func testNoteOnEncoding() throws {
        let noteOn = MIDI2.noteOn(channel: 0, note: 60, velocity: 100)
        XCTAssertEqual(noteOn.messageType, .midi2ChannelVoice)
        XCTAssertEqual(noteOn.group, 0)
    }
}
```

**Run tests:**
```bash
swift test                        # All tests
swift test --filter MIDI2Tests    # Specific test target
swift test --enable-code-coverage # With coverage
```

### JavaScript/TypeScript Tests
- **Location:** `midi2.js/src/*.test.ts`
- **Framework:** Vitest
- **Coverage target:** ≥80% for all production code

**Writing tests:**
```typescript
import { describe, it, expect } from 'vitest';
import { encodeNoteOn } from './ump';

describe('UMP Encoder', () => {
  it('encodes note-on message', () => {
    const msg = encodeNoteOn({ channel: 0, note: 60, velocity: 100 });
    expect(msg.messageType).toBe(0x4);
  });
});
```

**Run tests:**
```bash
cd midi2.js
npm test           # All tests
npm run coverage   # With coverage report
```

### Test Coverage Requirements
- New features must include tests
- Bug fixes must include regression tests
- Coverage must not decrease below 80%
- Aim for edge cases: boundary values, error conditions, null/undefined

## Code Style

### Swift Code Style
- **Formatting:** Follow Swift API Design Guidelines
- **Linting:** Warnings as errors enabled in CI (`-warnings-as-errors`)
- **Naming:**
  - Types: `PascalCase`
  - Functions/variables: `camelCase`
  - Constants: `camelCase`
- **Documentation:** Use Swift doc comments (`///`) for public APIs
- **Concurrency:** Use Swift 6 concurrency features (async/await, actors)

**Example:**
```swift
/// Encodes a MIDI 2.0 Note On message.
///
/// - Parameters:
///   - channel: MIDI channel (0-15)
///   - note: Note number (0-127)
///   - velocity: Velocity (0.0-1.0)
/// - Returns: Universal MIDI Packet
public func noteOn(channel: UInt8, note: UInt8, velocity: Float) -> UMP {
    // Implementation
}
```

### JavaScript/TypeScript Code Style
- **Formatting:** Prettier-compatible (2 spaces, single quotes)
- **Linting:** TypeScript strict mode enabled
- **Naming:**
  - Types/Interfaces: `PascalCase`
  - Functions/variables: `camelCase`
  - Constants: `UPPER_SNAKE_CASE` or `camelCase`
- **Documentation:** Use JSDoc/TSDoc for public APIs
- **Type safety:** Prefer explicit types, avoid `any`

**Example:**
```typescript
/**
 * Encodes a MIDI 2.0 Note On message.
 *
 * @param channel - MIDI channel (0-15)
 * @param note - Note number (0-127)
 * @param velocity - Velocity (0-65535)
 * @returns Universal MIDI Packet
 */
export function encodeNoteOn(
  channel: number,
  note: number,
  velocity: number
): UMPMessage {
  // Implementation
}
```

## Documentation

### Code Documentation
- All public APIs must have doc comments
- Include parameter descriptions, return values, and examples
- Document error conditions and edge cases

### README Updates
Update README.md when:
- Adding new features visible to users
- Changing installation or usage instructions
- Adding new examples or packages

### Changelog Updates
**Always update CHANGELOG.md** in the "Unreleased" section:
- `Added`: New features
- `Changed`: Changes to existing functionality
- `Deprecated`: Features marked for removal
- `Removed`: Removed features
- `Fixed`: Bug fixes
- `Security`: Security fixes

## Review Process

### Code Review Guidelines

**For authors:**
- Keep PRs focused and reasonably sized (<500 lines preferred)
- Respond to feedback promptly
- Mark conversations as resolved when addressed
- Request re-review after making changes

**For reviewers:**
- Review within 72 hours when assigned
- Check for:
  - Correctness and logic errors
  - Test coverage
  - Code style and readability
  - Performance implications
  - Security concerns
- Provide constructive feedback
- Approve when satisfied or request changes

### Required Checks (enforced by CI)
- ✅ Swift build passes (`swift build -Xswiftc -warnings-as-errors`)
- ✅ Swift tests pass (`swift test`)
- ✅ JavaScript type check passes (`npm run check`)
- ✅ JavaScript tests pass (`npm test`)
- ✅ Coverage ≥80%
- ✅ DoD compliance checks pass (if applicable)

### Approval Rules
- At least 1 approval from maintainer required
- CODEOWNERS approval required for changes to:
  - Core Swift packages (`Sources/MIDI2/`, `Sources/MIDI2CI/`)
  - Core JavaScript library (`midi2.js/src/`)
  - CI workflows (`.github/workflows/`)
  - Release files (`Package.swift`, `midi2.js/package.json`)

### Merge Strategy
- **Squash and merge** preferred for feature PRs
- **Create merge commit** for release PRs or multi-author PRs
- **Rebase** not recommended (can complicate history)

## Getting Help

- **Questions:** Open a [GitHub Discussion](https://github.com/Fountain-Coach/midi2/discussions)
- **Bugs:** Open a [GitHub Issue](https://github.com/Fountain-Coach/midi2/issues)
- **Security:** See [SECURITY.md](SECURITY.md)
- **Maintenance:** See [AGENTS.md](AGENTS.md)

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes (for significant features)
- CHANGELOG.md (via git commit attribution)

Thank you for contributing to **midi2**! 🎵
