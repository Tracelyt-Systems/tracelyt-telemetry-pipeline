# Contribution Workflow and Pull Request Guidelines

This document details the step-by-step workflow for contributing code, architectural proposals, and documentation updates to `tracelyt-telemetry-pipeline`.

---

## 1. Development Lifecycle

```text
1. Issue / RFC ---> 2. Branching ---> 3. Code & Test ---> 4. Pre-PR Audit ---> 5. Review & Merge
```

### Step 1: Open an Issue or RFC
Before writing code for major capabilities, open an issue using the [Feature Request Template](../../.github/ISSUE_TEMPLATE/feature_request.yml) to discuss architectural alignment.

### Step 2: Create a Feature Branch
Create a descriptive branch from `main`:
- `feature/add-<component>-stage`
- `fix/docs-<topic>-update`
- `chore/update-<dependency>`

### Step 3: Implement and Test
Follow the guidelines in [Code Style](code-style.md) and [Testing Strategy](testing.md).

### Step 4: Pre-PR Local Audit
Run the full verification suite locally:
```bash
# Verify build, tests, and Checkstyle rules
./mvnw clean test checkstyle:check
```

### Step 5: Submit Pull Request
1. Open a pull request against `main`.
2. Complete all checklist items in [PULL_REQUEST_TEMPLATE.md](../../.github/PULL_REQUEST_TEMPLATE.md).
3. Ensure GitHub Actions CI passes cleanly.
4. Maintainers listed in [.github/CODEOWNERS](../../.github/CODEOWNERS) will review and approve before merging.
