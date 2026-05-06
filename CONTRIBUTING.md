# Contributing to Just Ads

Thank you for your interest in contributing to **Just Ads**! We welcome all contributions - bug fixes, new features, documentation improvements, and more.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Features](#suggesting-features)
  - [Submitting a Pull Request](#submitting-a-pull-request)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Commit Message Convention](#commit-message-convention)
- [License](#license)

---

## Code of Conduct

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md). By participating you agree to abide by its terms. Please report unacceptable behaviour to the maintainers.

---

## Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/just-unknown-dev/just-ads
   cd just_ads
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the tests** to make sure everything is green before you start:
   ```bash
   flutter test
   ```

---

## How to Contribute

### Reporting Bugs

Before opening an issue please:
- Search [existing issues](../../issues) to avoid duplicates.
- Confirm the bug is reproducible on the latest version.

When opening a bug report, include:
- A clear, descriptive title.
- Steps to reproduce the problem.
- Expected vs. actual behaviour.
- Flutter/Dart SDK versions (`flutter --version`).
- A minimal code sample or link to a reproduction repo if possible.

### Suggesting Features

- Open a [GitHub Discussion](../../discussions) or issue labelled **`enhancement`**.
- Describe the problem your feature solves and how you'd like it to behave.
- Check that the feature aligns with this package's scope: Flutter mobile ad integrations (Banner, Interstitial, Rewarded, and App Open) and consent handling.

### Submitting a Pull Request

1. Create a topic branch from `main`:
   ```bash
   git checkout -b feat/my-new-feature
   ```
2. Make your changes, following the [Coding Guidelines](#coding-guidelines).
3. Add or update tests for any changed behaviour.
4. Ensure all tests pass:
   ```bash
   flutter test
   flutter analyze
   ```
5. Commit with a [conventional commit message](#commit-message-convention).
6. Push to your fork and open a Pull Request against `main`.
7. Fill in the PR template — describe what changed and why.
8. Address any review feedback promptly.

> **Small PRs are easier to review.** If your change is large, consider opening an issue first to discuss the approach.

---

## Development Setup

| Tool | Minimum version | Recommended version |
|------|-----------------| --------------------|
| Flutter | 3.19.0 | 3.41.1 |
| Dart SDK | 3.11.0 | 3.11.0 |

This repository is a **Flutter package**.

```bash
# Install dependencies (from packages/just_ads)
flutter pub get

# Run unit tests (from packages/just_ads)
flutter test

# Lint
flutter analyze
```

---

## Coding Guidelines

- Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- All public APIs must have **doc comments** (`///`).
- Prefer `const` constructors wherever possible.
- Do not introduce new dependencies without prior discussion in an issue.
- Keep ad formats and consent logic decoupled so changes in one area do not break another.
- Match the existing file and folder structure under `lib/`.

---

## Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short summary>
```

| Type | When to use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |
| `chore` | Build process, tooling, dependencies |

**Examples:**
```
feat(rewarded): add optional server-side verification options
fix(consent): prevent ad requests before consent state resolves
docs(contributing): add development setup section
```

---

## License

By contributing to just_ads you agree that your contributions will be licensed under the [BSD-3-Clause License](LICENSE).
