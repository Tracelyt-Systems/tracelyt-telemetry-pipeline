# Code Style and Static Analysis

This document defines the coding standards, formatting rules, and static analysis enforcement for `tracelyt-telemetry-pipeline`.

---

## 1. Automated Style Enforcement: Checkstyle

All Java code in this repository is statically audited by Checkstyle 10.21.4 (via `maven-checkstyle-plugin` 3.6.0). The configuration is stored in `.checkstyle.xml` at the root of the repository.

### Key Rules Enforced:
1. **No Wildcard Imports**: Star imports (`import java.util.*;`) are prohibited. All imports must be explicitly declared.
2. **Naming Conventions**:
   - Classes and Interfaces: `UpperCamelCase` (e.g., `TelemetryBatchProcessor`).
   - Methods and Variables: `lowerCamelCase` (e.g., `processBatch`).
   - Constants: `UPPER_SNAKE_CASE` (e.g., `DEFAULT_BATCH_SIZE`).
   - Packages: Strictly lowercase dot-separated (`io.tracelyt.pipeline`).
3. **Line Length**: Maximum 120 characters per line (excluding package declarations, import lines, and URLs).
4. **Javadoc**: Mandatory Javadoc comments on all public classes, interfaces, and public methods.
5. **Brace Placement**: Standard K&R style left braces on the same line; braces are mandatory on all `if`, `else`, `for`, and `while` blocks.

---

## 2. Running Checkstyle Locally

To audit your code against style rules prior to opening a pull request:

```bash
./mvnw checkstyle:check
```

- Any violation causes the build to fail with a descriptive line number and explanation.
- Violations must be fixed before pull requests can be merged.
