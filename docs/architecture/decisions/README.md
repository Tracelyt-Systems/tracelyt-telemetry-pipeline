# Architecture Decision Records (ADRs)

This directory records significant architectural decisions regarding runtimes, streaming topologies, storage interfaces, and data models for `tracelyt-telemetry-pipeline`.

---

## 1. ADR Format

We use a lightweight, consistent ADR format:

- **Title**: Sequential number and short title (e.g., `0001-adopt-java-21-spring-boot.md`).
- **Status**: `Proposed`, `Accepted`, `Deprecated`, or `Superseded`.
- **Date**: ISO-8601 date (YYYY-MM-DD).
- **Context**: The engineering challenge or architectural constraint.
- **Decision**: The selected technology or approach.
- **Alternatives Considered**: Other options evaluated and why they were rejected.
- **Consequences**: Positive benefits and operational trade-offs.

---

## 2. ADR Index

| ADR | Title | Status | Date | Summary |
| :--- | :--- | :--- | :--- | :--- |
| **0001** | Adopt Java 21 LTS and Spring Boot 3.4.3 Foundation | **Accepted** | 2026-10-26 | Establish Java 21 LTS with Spring Boot as the initial foundation framework for pipeline orchestration. |
| *(Pending)* | Intermediate Streaming Broker Selection (Kafka vs. NATS) | **Proposed** | — | Evaluate distributed streaming broker for ingestion-to-pipeline buffering. |
| *(Pending)* | Columnar Storage Sink Protocol and Batching Thresholds | **Proposed** | — | Design pluggable batch sink interface for ClickHouse and cold storage. |

---

## 3. Submitting an ADR

1. Create a branch and add a draft file `docs/architecture/decisions/NNNN-<short-name>.md`.
2. Mark status as `Proposed`.
3. Open a pull request for maintainer review. Once approved and merged, update status to `Accepted`.
