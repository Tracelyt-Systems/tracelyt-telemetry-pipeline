# Capacity Planning and Sizing Principles

This document establishes the sizing principles, workload metrics, and capacity planning guidelines for the Tracelyt Telemetry Pipeline.

> [!NOTE]
> **No Fabricated Benchmarks**: Capacity numbers depend heavily on payload attributes, span counts, regex redaction complexity, and hardware profiles. Baseline service-level objectives (SLOs) must be derived from measured testing rather than theoretical marketing claims.

---

## 1. Core Workload Sizing Dimensions

When sizing pipeline instances for production deployments, operators must evaluate the following four dimensions:

1. **Throughput (Events/sec and Bytes/sec)**:
   - Evaluates sustained input volume across metrics, logs, and spans.
   - Sizing must account for payload size distribution: 10,000 minimal metrics consume significantly less CPU than 10,000 complex spans with 50 attributes each.
2. **Processing Latency (p50, p95, p99)**:
   - The time elapsed from record ingress to downstream storage acknowledgement.
   - Latency spikes often indicate JVM garbage collection pauses or downstream database buffer contention.
3. **Memory & Allocation Rate**:
   - Telemetry transformation creates short-lived objects. High object allocation rates place heavy pressure on the JVM Young Generation.
   - Sizing requires profiling heap usage under peak burst conditions to tune collector flags (G1GC vs. ZGC).
4. **Durability vs. Backpressure Thresholds**:
   - Sizing in-memory queues determines how many seconds of downstream storage downtime the pipeline can absorb before shedding load.

---

## 2. Multi-Tenant Capacity Distribution

In multi-tenant clusters, capacity planning must address the "Noisy Neighbor" problem:
- **Tenant Quotas**: Pipelines must enforce soft and hard throughput limits per tenant.
- **Resource Partitioning**: Processing threads should not allow a single tenant's massive telemetry burst to consume 100% of CPU time, starving other tenants.

---

## 3. Language Decision and Optimization Gates

To prevent premature polyglot complexity, introducing an alternative implementation language (such as Go, C++, or Rust) requires satisfying the following formal gates:
1. **Identified Workload**: A specific processing bottleneck (e.g., regex redaction, decompression) is isolated.
2. **JVM Optimization Exhaustion**: Optimization attempts using Java 21 features (Virtual Threads, off-heap buffers, ZGC tuning, Vector API) are tested and documented.
3. **Reproducible Benchmark**: A peer-reviewed benchmark proves the alternative language delivers a material, measured improvement (e.g., >3x throughput or >50% lower p99 latency).
4. **Maintainer Consensus**: The long-term maintenance and build overhead is approved by project maintainers.
