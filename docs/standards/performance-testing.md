# Performance Testing and Benchmarking Guidelines

This document establishes the benchmarking methodology, test workload profiles, and measurement criteria for `tracelyt-telemetry-pipeline`.

---

## 1. Benchmarking Philosophy

1. **Empirical Measurement Over Theoretical Assumptions**: Theoretical claims (e.g., "handles millions of events per second") are meaningless without defined hardware specs, payload sizes, and acceptable error bounds.
2. **Realistic Payload Distributions**: Benchmarking must simulate realistic telemetry distributions:
   - Heterogeneous span counts (small single spans mixed with complex deep trace trees).
   - High-cardinality attribute payloads.
   - Varied log message lengths.
3. **Sustained Load Testing**: Short burst tests fail to reveal memory leaks or JVM garbage collection degradation. Benchmarks must run under sustained load for a minimum of 30 minutes to evaluate GC steady-state behavior.

---

## 2. Key Metrics Recorded

During benchmark evaluations, the test framework must capture:

- **Ingress & Egress Rates**: Records per second and megabytes per second.
- **Latency Percentiles**: End-to-end processing latency at p50, p95, p99, and p99.9.
- **Garbage Collection Pauses**: Frequency, duration, and percentage of CPU time consumed by GC cycles.
- **Consumer Lag & Queue Depth**: Rate of buffer growth under load.
- **Drop / Rejection Counts**: Data loss or backpressure rejection events.

---

## 3. Profiling Requirements for Language Gate Review

As outlined in [Technology Strategy](../architecture/technology-strategy.md), proposing a non-JVM native accelerator (Go, C++, Rust) requires submitting a reproducible benchmark report containing:
- Flamegraphs showing CPU time dominated by specific isolated algorithms (e.g., regex matching or compression).
- Comparative allocation profiling demonstrating that JVM heap pressure cannot be relieved via off-heap or pooling optimizations.
- Measured side-by-side performance data running under identical container CPU and memory constraints.
