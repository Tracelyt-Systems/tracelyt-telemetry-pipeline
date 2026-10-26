# Secure Development Lifecycle (SDLC)

This document outlines the secure development practices enforced across the lifecycle of `tracelyt-telemetry-pipeline`.

---

## 1. Core Secure Coding Principles

1. **Defensive Parsing**:
   - Treat all telemetry input streams as potentially malicious.
   - Enforce bounded collection sizes, bounded string lengths, and recursion depth limits during deserialization.
2. **Safe Error Handling**:
   - Never expose internal JVM stack traces, internal database hostnames, or unmasked payload attributes in error responses or logs.
3. **Secret Hygiene**:
   - Tracked files must never contain secrets, private certificates, or production API keys.
   - Use `.gitignore` and `.dockerignore` to prevent local configuration or environment files from being committed.
4. **No Native Serialization**:
   - Standard Java native object serialization (`java.io.Serializable` with `ObjectInputStream`) is strictly prohibited due to well-known deserialization gadget vulnerabilities.

---

## 2. Review and Verification Controls

1. **Automated Static Code Analysis**:
   - Checkstyle audits every build locally and in CI to enforce naming, clean imports, and structural safety.
2. **Least-Privilege CI Environment**:
   - GitHub Actions workflows operate with `permissions: contents: read`.
   - CI runners do not have write access to repository code, packages, or production environments.
3. **Mandatory Peer Review**:
   - All code changes require pull request approval from designated maintainers in [.github/CODEOWNERS](../../.github/CODEOWNERS).
