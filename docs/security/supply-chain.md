# Software Supply Chain Security

This document outlines the controls implemented to ensure the integrity, provenance, and security of third-party dependencies and build artifacts in `tracelyt-telemetry-pipeline`.

---

## 1. Supply Chain Defense Principles

1. **Dependency Minimization**:
   - Every additional library expands the project attack surface. Dependencies must be justified and approved before inclusion in `pom.xml`.
2. **Strict Version Pinning**:
   - Dependencies not managed directly by the Spring Boot parent POM must have explicit, pinned version properties in `pom.xml`.
3. **Immutable Action Pinning in CI**:
   - Third-party GitHub Actions must be pinned to full 40-character commit SHAs (e.g., `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2`) to prevent tag-mutation attacks.
4. **Reproducible Container Builds**:
   - The project Dockerfile uses official Eclipse Temurin base images with multi-stage separation. Build tools, Maven caches, and source code are excluded from the final execution layer.
5. **No Blind Remote Script Execution**:
   - Continuous integration scripts must never pipe untrusted remote URLs directly to shells (`curl | bash`).

---

## 2. Dependency Vulnerability Triage

When Common Vulnerabilities and Exposures (CVEs) are detected in project dependencies:
1. **Assessment**: Maintainers evaluate whether the vulnerable code path is reachable within the telemetry pipeline runtime.
2. **Remediation**: If vulnerable, the dependency version property is updated immediately in `pom.xml`.
3. **Release**: A patch release or updated container build is issued in accordance with coordinated disclosure practices.
