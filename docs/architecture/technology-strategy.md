# Technology Strategy and Language Evaluation

This document details the architectural evaluation of programming languages, streaming runtimes, and storage interfaces for the Tracelyt Telemetry Pipeline.

---

## 1. Evaluation of Language Candidates

### 1.1 Java 21 LTS + Spring Boot (Selected Foundation)
- **Role**: Core application orchestration, configuration binding, metric lifecycle, and baseline data-processing pipelines.
- **Strengths**:
  - Direct ecosystem synergy with `tracelyt-control-plane` and `tracelyt-ingestion`.
  - Java 21 features: Virtual Threads (Project Loom) provide high-concurrency I/O with sequential programming models.
  - Mature ecosystem for structured dependency injection, health checking, and metric publishing (Micrometer).
  - Robust testing tooling (JUnit 5, Testcontainers, Mockito) and comprehensive static analysis (Checkstyle, SpotBugs).
- **Trade-offs**:
  - Memory Footprint: Higher baseline memory consumption compared to compiled native binaries.
  - Garbage Collection: High object allocation rates under intense telemetry spikes can cause GC latency pauses if not tuned carefully (e.g., with ZGC or Shenandoah).
- **Conclusion**: **Approved as the initial foundation.**

### 1.2 Go
- **Candidate Scope**: Potential future specialized worker agents or network proxy components.
- **Evaluation**:
  - Provides lightweight goroutines, fast startup times, and compact static binaries.
  - However, adopting Go introduces a secondary build system, duplicate dependency auditing, disparate code-style standards, and divided maintainer attention.
- **Conclusion**: **Deferred.** Polyglot complexity is not justified during pre-1.0 foundation.

### 1.3 C++ / Rust
- **Candidate Scope**: Future isolated native acceleration libraries for CPU-intensive cryptographic hashing, regex payload redaction, or SIMD compression.
- **Evaluation**:
  - Offers zero-cost abstractions, deterministic memory management without GC pauses, and extreme throughput.
  - However, introduces FFI (Foreign Function Interface) overhead, complex cross-platform compilation matrices, and increased cognitive load for open-source contributors.
- **Conclusion**: **Deferred.** Native components will be considered only after empirical profiling proves Java 21 GC or CPU bottlenecks cannot be resolved via JVM tuning.

### 1.4 Python
- **Candidate Scope**: Offline machine-learning experimentation or ad-hoc data science scripts.
- **Evaluation**:
  - Unsuitable for in-line, high-throughput telemetry stream processing due to interpreter concurrency constraints (GIL) and runtime overhead.
- **Conclusion**: **Strictly Prohibited** in the core data plane execution path.

---

## 2. Event Streaming Evaluation: Apache Kafka

Apache Kafka is an industry-standard distributed streaming log. We evaluate its prospective role as a decoupled buffer between ingestion and the pipeline:

### Key Considerations
1. **Durability & Replay**: Append-only disk logging allows the pipeline to replay historical telemetry if downstream storage undergoes maintenance or failure.
2. **Partitioning & Ordering**: Kafka partition keys can enforce per-tenant or per-service ordering for distributed trace spans.
3. **Operational Overhead**: Running a production Kafka cluster requires ZooKeeper/KRaft quorum management, partition rebalancing monitoring, disk I/O provisioning, and consumer lag tracking.
4. **Delivery Semantics**: Kafka provides at-least-once delivery; consumers must be designed to be idempotent to handle duplicated records during consumer rebalancing.

**Current Verdict**: Evaluated as a primary architectural candidate for multi-node deployments, but **intentionally not packaged or mandated during this setup phase**.

---

## 3. Upstream OpenTelemetry Integration

The pipeline aligns directly with CNCF OpenTelemetry standards:
- **Semantic Conventions**: Attributes (e.g., `http.response.status_code`, `service.name`, `host.id`) will conform strictly to official OpenTelemetry semantic conventions.
- **Internal Instrumentation**: When operational monitoring is introduced, the pipeline itself will emit metrics and traces using the OpenTelemetry Java SDK.
- **No Proprietary Envelopes**: The pipeline will not wrap OpenTelemetry data in custom Tracelyt envelopes that break ecosystem interoperability.

---

## 4. Separation from Downstream Storage

Storage technologies (e.g., ClickHouse for columnar traces and logs, Prometheus/VictoriaMetrics for time-series metrics, MinIO/S3 for cold storage) represent distinct architectural tiers:
- Storage choices will be finalized in coordination with `tracelyt-query-engine` requirements.
- The pipeline remains decoupled via pluggable batch sink interfaces, ensuring processing logic does not depend directly on database internal storage engines.

---

## 5. Technology Decision Summary

| Component | Status | Approved Foundation |
| :--- | :--- | :--- |
| **Primary Language** | Approved | **Java 21 LTS** |
| **Framework** | Approved | **Spring Boot 3.4.3** |
| **Build Tool** | Approved | **Maven 3.9+ with Maven Wrapper (`mvnw`)** |
| **Static Analysis** | Approved | **Checkstyle 10.21.4 (Plugin: 3.6.0)** |
| **Testing** | Approved | **JUnit 5 (Jupiter)** |
| **Container Base** | Approved | **Eclipse Temurin 21-jre-jammy (Non-root)** |
| **Streaming Brokers** | Deferred | Awaiting multi-service integration requirements |
| **Native Accelerators** | Deferred | Requires reproducible profiling evidence |
| **Storage Sinks** | Deferred | Pluggable interface design pending query engine alignment |

### Policy for Introducing Secondary Languages
A secondary language (Go, Rust, C++) may be introduced **only when**:
1. A reproducible workload benchmark demonstrates a clear JVM performance limitation.
2. Alternative Java optimizations (ZGC tuning, off-heap buffers, vector API) are evaluated and found insufficient.
3. The proposed secondary component has a strictly bounded interface.
4. Repository maintainers review and approve the operational and maintenance costs.
