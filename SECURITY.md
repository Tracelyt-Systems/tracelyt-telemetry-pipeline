# Security Policy

## Security Expectations for Telemetry Pipeline

The Tracelyt Telemetry Pipeline is intended to process high-volume operational metrics, distributed traces, and application logs. Because telemetry streams may inadvertently carry sensitive attributes, and pipeline services operate at high throughput, the pipeline must be engineered with strict security boundaries.

### Key Principles

1. **No Sensitive Data or Live Credentials**: Tracked files must never contain actual credentials, tokens, API keys, private certificates, internal hostnames, or production customer telemetry. All examples and tests must use synthetic placeholders.
2. **Deterministic & Isolated Validation**: Pipeline configuration must avoid unauthenticated remote lookups during continuous integration.
3. **Defense Against Malformed Payloads**: Future processing engines must strictly validate input batch sizes, payload limits, and memory allocation to guard against parser exhaustion.

## Reporting a Security Vulnerability

We request that security researchers and contributors report suspected vulnerabilities in a coordinated and responsible manner.

### Preferred Reporting Method

1. **GitHub Private Vulnerability Reporting**:
   - Check if [GitHub Private Vulnerability Reporting](https://github.com/Tracelyt-Systems/tracelyt-telemetry-pipeline/security/advisories) is enabled on this repository.
   - If enabled, click **Report a vulnerability** to submit an advisory directly to repository maintainers.
   - *Note for Maintainers*: Repository maintainers must verify and enable this feature under repository **Settings > Code security and analysis > Private vulnerability reporting**.

2. **Direct Maintainer Contact via GitHub**:
   - If Private Vulnerability Reporting is not active, reach out to the project maintainers listed in [.github/CODEOWNERS](.github/CODEOWNERS) via their verified GitHub profiles.
   - Do **not** disclose potential security issues, exploit demonstrations, or affected telemetry payloads in publicly accessible GitHub issues, pull request comments, or public discussions.

### Information to Include in Reports

To help us triage and resolve the issue efficiently, please include:
- A clear description of the vulnerability (e.g., denial-of-service in deserializer, memory leak under unbounded batching, dependency vulnerability).
- The affected file path and commit SHA or release version.
- Step-by-step reproduction instructions or a minimal test case triggering the issue.
- Impact assessment on the telemetry processing pipeline.

### Vulnerability Handling Process

1. **Acknowledgment**: Maintainers will review the submission and acknowledge receipt.
2. **Assessment**: The impact on the pipeline and dependent Tracelyt services will be evaluated.
3. **Remediation**: A coordinated fix will be prepared in a private advisory workspace.
4. **Disclosure**: A public advisory and release will be published in accordance with coordinated disclosure practices.
