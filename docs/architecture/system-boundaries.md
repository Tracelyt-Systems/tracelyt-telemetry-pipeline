# System Boundaries and Component Responsibilities

This document defines the strict functional boundaries separating `tracelyt-telemetry-pipeline` from other repositories across the Tracelyt platform.

---

## 1. Component Responsibility Matrix

| Component Repository | Primary Architectural Role | What Belongs Here | What Explicitly Does NOT Belong Here |
| :--- | :--- | :--- | :--- |
| **`tracelyt-ingestion`** | Edge Protocol Gateway | OTLP network listeners (gRPC/HTTP), TLS termination, API key verification, early client rate limiting, initial payload size rejection. | Complex trace enrichment, span aggregation, long-term buffering, database persistence. |
| **`tracelyt-telemetry-pipeline`** *(This Repository)* | Data Plane Transformation & Routing | In-flight telemetry validation, attribute normalization, privacy redaction, drop filtering, micro-batch aggregation, storage routing. | Edge OTLP network termination, user account management, REST query APIs, long-term storage indexing. |
| **`tracelyt-control-plane`** | Central Platform Administration | Tenant lifecycle management, RBAC, API key issuance, pipeline processing policy distribution, platform billing. | Telemetry payload processing, high-volume log parsing, raw span ingestion. |
| **`tracelyt-query-engine`** | Read Path & Data Access | PromQL/SQL execution, time-series downsampling, query caching, trace waterfall visualization APIs. | Ingestion stream parsing, data plane write batching, pipeline redaction. |
| **`tracelyt-alerting`** | Incident & Rule Engine | Threshold evaluations, anomaly detection algorithms, alert state transitions, notification trigger evaluation. | Bulk telemetry storage, edge network termination. |
| **`tracelyt-notifications`** | Alert Dispatch Integration | Webhook delivery, Slack/PagerDuty integrations, retry policies, delivery templates. | Telemetry stream processing or trace querying. |
| **`tracelyt-specs`** | Shared Contract Authority | Shared OpenAPI specifications, JSON schemas, Protobuf definitions, compatibility guidelines. | Executable services, runtime databases, application code. |

---

## 2. Preventing Functional Overlap

In distributed observability systems, boundary erosion frequently creates maintenance bottlenecks. We apply the following rules to prevent overlap:

### 2.1 Ingestion vs. Pipeline Boundary
- `tracelyt-ingestion` answers: *"Is the network request authenticated and well-formed according to protocol specs?"* If yes, it acknowledges or forwards immediately.
- `tracelyt-telemetry-pipeline` answers: *"How should this telemetry be transformed, redacted, and routed downstream?"*
- **Rule**: If an operation requires parsing individual span attributes or inspecting log message regexes, it belongs in the pipeline, never in the edge gateway.

### 2.2 Pipeline vs. Storage Boundary
- The pipeline organizes telemetry into batches and delivers them to the database write interface.
- **Rule**: The pipeline does not manage physical partition drops, table compaction (e.g., ClickHouse `OPTIMIZE`), or historical data rollups. Persistence and retention are owned by storage configurations and migration tooling.

### 2.3 Pipeline vs. Control Plane Boundary
- The pipeline consumes read-only tenant policy updates (e.g., "Tenant X has log redaction rule Y enabled").
- **Rule**: The pipeline never mutates tenant configuration, resets credentials, or serves control-plane REST endpoints.
