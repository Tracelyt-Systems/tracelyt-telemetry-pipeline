# Telemetry Data Flow and Processing Lifecycle

This document describes the planned lifecycle of telemetry records as they traverse the Tracelyt platform.

> [!CAUTION]
> **No Lossless Guarantees Without Concrete Topologies**: Distributed data streaming involves physical hardware boundaries, network partitions, and buffer saturation. Exactly-once processing, lossless delivery, or strict global ordering must never be claimed without verified infrastructure and idempotency guarantees.

---

## 1. High-Level Telemetry Lifecycle

The intended end-to-end telemetry lifecycle progresses through five stages:

```text
[ 1. Ingress & Handshake ]
          |  (OTLP over gRPC / HTTP terminated at tracelyt-ingestion)
          v
[ 2. In-Flight Validation & Partitioning ]
          |  (Format verification, tenant identity binding, initial quota check)
          v
[ 3. Pipeline Processing Stages ]
          |  (Sanitization -> Redaction -> Enrichment -> Filtering)
          v
[ 4. Micro-Batch Aggregation ]
          |  (Size-bounded and time-bounded columnar buffering)
          v
[ 5. Downstream Dispatch & Storage ]
             (Batch write to ClickHouse / Long-term Object Store / Alerting stream)
```

---

## 2. Detailed Processing Stages

### Stage 1: Ingress Termination
- Telemetry originates from instrumented application services (OpenTelemetry SDKs or infrastructure collectors).
- `tracelyt-ingestion` terminates the network protocol, validates bearer tokens/API keys, verifies basic batch framing, and forwards batches to the pipeline stream.

### Stage 2: In-Flight Validation & Tenant Isolation
- **Boundary Verification**: Checks payload structure against the schema specifications defined in `tracelyt-specs`.
- **Tenant Binding**: Attaches immutable, validated tenant identifiers. All subsequent processing stages operate within strictly isolated tenant context partitions to prevent cross-tenant leakage.

### Stage 3: Data Transformation Pipeline
When processing stages are implemented, each telemetry record passes through a deterministic pipeline:
1. **Sanitization**: Strips invalid UTF-8 characters, normalizes timestamp formatting to UTC, and caps unbounded string fields.
2. **Privacy Redaction**: Evaluates tenant-configured regex rules to mask sensitive tokens, credentials, and personal data (PII) before records reach persistent storage.
3. **Attribute Normalization & Enrichment**: Appends environment tags, cluster identifiers, and standardizes OpenTelemetry semantic conventions.
4. **Filtering & Drop Rules**: Drops operational noise, health check spans, or excluded debug logs according to tenant configuration.

### Stage 4: Micro-Batch Aggregation
- Downstream columnar stores (such as ClickHouse) degrade significantly under single-record inserts.
- The pipeline collects processed records into in-memory micro-batches governed by dual thresholds:
  - **Size threshold**: e.g., flush when buffer reaches 5,000 records or 2 MB.
  - **Time threshold**: e.g., flush when buffer age reaches 1,000 ms.

### Stage 5: Downstream Dispatch & Storage
- Flushes formatted columnar batches to storage sink connectors.
- Emits derived alert signals (e.g., error rate thresholds) directly to `tracelyt-alerting`.

---

## 3. Synchronous vs. Asynchronous Transport Trade-offs

Two architectural models exist for the boundary between ingestion and the pipeline:

| Dimension | Synchronous (Direct HTTP/gRPC) | Asynchronous (Durable Stream Buffer) |
| :--- | :--- | :--- |
| **End-to-End Latency** | Very Low (immediate in-memory forward) | Low-to-Moderate (broker write + read cycle) |
| **Storage Failure Impact** | Immediate backpressure propagated to edge | Edge unaffected; buffer absorbs downtime |
| **Operational Simplicity** | Simple (no broker cluster to manage) | Requires managing Kafka or NATS cluster |
| **Replay Capability** | None (failed records must be redriven by edge) | Replay historical offsets on demand |
| **Memory Pressure** | High under downstream slowdowns | Offloaded to distributed streaming disk storage |

The target production architecture favors an **asynchronous buffer** for enterprise deployments, while maintaining an optional direct in-memory transport for lightweight developer testing.
