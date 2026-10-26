# Observability Strategy: Monitoring the Pipeline

This document defines the observability principles and planned telemetry signals for monitoring the health, performance, and correctness of `tracelyt-telemetry-pipeline`.

---

## 1. Distinction: Service Health vs. Processing Correctness

A telemetry pipeline can have an HTTP status of `200 OK` on health endpoints while simultaneously suffering severe processing degradation:
- **Service Liveness/Health**: Answers whether the JVM process is alive and responsive.
- **Processing Correctness**: Answers whether records are being deserialized, transformed, and committed downstream within acceptable latency thresholds without data drops.

Monitoring systems must evaluate both dimensions.

---

## 2. Planned Pipeline Metrics

When processing pipelines are implemented, the following metric dimensions will be published via Micrometer and OpenTelemetry:

| Metric Name | Type | Description |
| :--- | :--- | :--- |
| `tracelyt.pipeline.records.received_total` | Counter | Total telemetry records received at the pipeline boundary. |
| `tracelyt.pipeline.records.processed_total` | Counter | Total records successfully transformed and ready for dispatch. |
| `tracelyt.pipeline.records.dropped_total` | Counter | Records dropped due to tenant drop rules or backpressure. |
| `tracelyt.pipeline.records.malformed_total` | Counter | Records rejected due to parser or format errors. |
| `tracelyt.pipeline.batch.duration_seconds` | Histogram | End-to-end processing latency per batch (p50, p95, p99). |
| `tracelyt.pipeline.buffer.queue_depth` | Gauge | Current count of records buffered in in-memory micro-batch queues. |
| `tracelyt.pipeline.sink.flush_duration_seconds`| Histogram | Time taken to write columnar batches to downstream storage. |
| `tracelyt.pipeline.sink.errors_total` | Counter | Downstream write failures and retry events. |

---

## 3. High-Cardinality and Privacy Safeguards

1. **No High-Cardinality Metric Dimensions**: Metric labels must never include user IDs, IP addresses, trace IDs, or unbounded tenant IDs. Dimensions are strictly bounded to `signal_type` (trace, metric, log), `status` (success, failure), and `error_code`.
2. **Safe Logging**: Log messages must never output raw telemetry payloads, span attributes, or customer data. Logs are restricted to operational events: batch flushes, connection resets, and circuit-breaker state transitions.
