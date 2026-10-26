# Failure Model and Degradation Modes

This document analyzes the primary failure categories that a high-volume telemetry pipeline faces, defining the critical engineering questions each implementation component must resolve.

> [!WARNING]
> **No Magic Recovery Promises**: Distributed systems fail in complex ways. Automatic recovery, zero data loss, or infinite buffering cannot be guaranteed. The design objective is **graceful degradation, explicit failure containment, and actionable operator observability**.

---

## 1. Failure Categories & Engineering Questions

### 1.1 Downstream Storage Unavailable
- **Failure Scenario**: The primary time-series database (e.g., ClickHouse) experiences network isolation, node failure, or disk saturation.
- **Critical Questions for Implementation**:
  - How long can the pipeline buffer records in memory or local disk before memory exhaustion occurs?
  - Does the pipeline reject new incoming batches from ingestion, or spill over to secondary object storage (S3/GCS)?
  - How are backpressure signals communicated upstream to prevent cascading out-of-memory crashes?

### 1.2 Intermediate Queue / Broker Unavailable
- **Failure Scenario**: The message broker (Kafka or NATS) becomes unreachable due to network partition or quorum loss.
- **Critical Questions for Implementation**:
  - Should the pipeline enter an immediate pause state and cease downstream flushes to maintain offset alignment?
  - How does the pipeline signal unreadiness to orchestrators (Kubernetes liveness/readiness probes)?

### 1.3 Consumer Lag & Processing Saturation
- **Failure Scenario**: Incoming telemetry rate exceeds pipeline processing and enrichment capacity, causing growing consumer lag.
- **Critical Questions for Implementation**:
  - What sampling or drop algorithms (e.g., dropping debug logs first, preserving error traces) will engage automatically?
  - Can workers be horizontally autoscaled dynamically based on consumer group lag metrics?

### 1.4 Malformed or Malicious Input
- **Failure Scenario**: An upstream client emits corrupt Protobuf byte sequences, non-UTF-8 strings, or deeply nested JSON payloads.
- **Critical Questions for Implementation**:
  - Is parsing strictly bound by timeouts and recursion limits to prevent parser denial-of-service?
  - Are malformed records routed to a diagnostic dead-letter queue (DLQ) without halting the processing of adjacent valid records in the batch?

### 1.5 Oversized Payloads & Mega-Traces
- **Failure Scenario**: A batch contains a single trace with 100,000 spans or a giant log entry exceeding 10 MB.
- **Critical Questions for Implementation**:
  - What hard maximum payload limits are enforced before deserialization?
  - How does the pipeline safely truncate oversized attributes while preserving core diagnostic metadata?

### 1.6 Tenant-Specific Overload (Noisy Neighbor)
- **Failure Scenario**: A single tenant experiences an instrumentation loop or deployment bug, flooding the pipeline with 100x their quota.
- **Critical Questions for Implementation**:
  - How is tenant isolation enforced in processing thread pools?
  - Are tenant-level rate limiters evaluated early to prevent one tenant from starving shared CPU or storage write bandwidth?

### 1.7 Duplicate Delivery & Idempotency
- **Failure Scenario**: Network blips or broker consumer rebalances trigger duplicate deliveries of the same telemetry batch.
- **Critical Questions for Implementation**:
  - What deduplication keys (e.g., batch UUID + span ID) will downstream storage support?
  - Does the database insertion engine support idempotent replacing/collapsing merge trees?

### 1.8 Graceful Shutdown & Abrupt Termination
- **Failure Scenario**: SIGTERM emitted by container orchestrator during pod scale-down or node draining.
- **Critical Questions for Implementation**:
  - Does the pipeline stop accepting new batches immediately while flushing in-flight micro-batches to storage within the termination grace period (e.g., 30 seconds)?
  - How are uncommitted stream offsets saved to prevent duplicate reprocessing on restart?
