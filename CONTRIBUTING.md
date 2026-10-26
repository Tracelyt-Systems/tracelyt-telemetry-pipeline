# Contributing to Tracelyt Telemetry Pipeline

Welcome! We are excited that you want to contribute to the Tracelyt open-source observability platform telemetry pipeline.

This repository will eventually define and execute the telemetry transformation, enrichment, redaction, and routing pipelines between ingestion and storage engines.

---

## 1. Governance Principles

Before contributing, please keep the following core tenets in mind:

1. **Architecture Precedes Implementation**: Every new component, streaming connector, or transformation stage must be supported by documented architectural consensus.
2. **Quality Tooling Enforcement**: All code must compile cleanly under Java 21, pass Checkstyle static checks with zero violations, and include automated tests.
3. **No Secrets or Production Telemetry**: Never submit pull requests containing real tokens, passwords, customer data, or internal enterprise network identifiers.
4. **Code of Conduct**: All participants are expected to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 2. Contribution Workflow

When proposing changes:

1. **Open an Issue**:
   - For bugs or documentation issues, file a [Bug Report](.github/ISSUE_TEMPLATE/bug_report.yml).
   - For new capabilities, file a [Feature Request](.github/ISSUE_TEMPLATE/feature_request.yml).
2. **Branching Strategy**:
   - Fork the repository and create a descriptive branch:
     - `feature/add-<component>-foundation`
     - `fix/docs-<topic>-update`
     - `chore/update-dependencies`
3. **Validate Locally**:
   - Follow [Local Setup Guide](docs/development/local-setup.md).
   - Run Maven test suite and Checkstyle validation:
     ```bash
     ./mvnw clean test checkstyle:check
     ```
4. **Submit a Pull Request**:
   - Fill out the [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md).
   - Ensure continuous integration checks pass.
   - Obtain review and approval from code owners listed in [.github/CODEOWNERS](.github/CODEOWNERS).
