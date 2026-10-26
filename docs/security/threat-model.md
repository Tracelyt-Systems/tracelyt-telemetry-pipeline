# Threat Model and Security Analysis

This document details the security threat model for `tracelyt-telemetry-pipeline`, analyzing threat actors, attack vectors, assets, and planned mitigation strategies.

---

## 1. Threat Actors and Trust Boundaries

The pipeline operates across several critical trust boundaries:
- **Untrusted Ingress Boundary**: Telemetry producers (applications, external infrastructure collectors) that may emit malformed, oversized, or malicious telemetry.
- **Internal Platform Boundary**: The network boundary between `tracelyt-ingestion`, `tracelyt-telemetry-pipeline`, and downstream storage.
- **Control Plane Boundary**: Policy and tenant configuration distributed from `tracelyt-control-plane`.
- **Public Open-Source Boundary**: External GitHub contributors submitting pull requests and third-party dependencies downloaded from Maven Central.

---

## 2. Threat Analysis Matrix

| Asset | Threat Scenario | Potential Impact | Required Mitigation | Mitigation Status |
| :--- | :--- | :--- | :--- | :--- |
| **Pipeline Memory & CPU** | Malicious producer sends deeply nested payloads or billion-laughs XML/JSON bombs. | Denial of Service (OOM crash, CPU starvation). | Enforce strict payload size limits and bounded deserialization recursion depths. | **Planned** (Implementation Stage) |
| **Tenant Data Isolation** | A flaw in batch processing allows Tenant A to see or query Tenant B's telemetry. | Data breach, multi-tenant compliance violation. | Cryptographically verify tenant ID at ingestion; enforce strict tenant context partitioning in worker threads. | **Planned** (Implementation Stage) |
| **Customer Privacy** | Telemetry spans capture raw passwords, JWT tokens, or credit cards in attributes. | Compliance violations (GDPR/HIPAA), credential theft. | In-flight regex redaction and automated header masking before storage insertion. | **Planned** (Implementation Stage) |
| **Pipeline Storage Credentials** | Hard-coded database passwords or Kafka SASL tokens leaked in source code or Git history. | Unauthorized access to backend data stores. | Externalized configuration via environment variables/secrets; automated pre-commit secret scanning. | **Active** (Gitignore & Secret Scanning) |
| **Build Pipeline Integrity** | A malicious dependency or compromised GitHub Action injects backdoors into artifacts. | Supply-chain compromise affecting all users. | Pinned action commit SHAs, least-privilege CI permissions, dependency auditing. | **Active** (CI Workflow Hardening) |
| **Diagnostic Endpoints** | Actuator diagnostic endpoints expose heap dumps or sensitive configuration in production. | Information disclosure of internal network topologies. | Restrict Actuator exposure to `health,info`; require authentication for debug endpoints. | **Active** (`application.yml` Baseline) |
| **Deserialization Engine** | Unsafe Java object deserialization leading to Remote Code Execution (RCE). | Complete host/container compromise. | Prohibit native Java object serialization (`ObjectInputStream`); use strict Protobuf/JSON schema parsers only. | **Active** (Architectural Policy) |
| **Stream Ordering & Deduplication** | Replayed or duplicated events trigger double-counting in billing or derived metrics. | Inaccurate platform reporting and alerting false positives. | Idempotent storage write keys and consumer deduplication windows. | **Planned** (Implementation Stage) |
