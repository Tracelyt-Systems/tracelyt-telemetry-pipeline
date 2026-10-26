# Deployment Readiness and Runtime Operations

This document defines the operational requirements for deploying `tracelyt-telemetry-pipeline` in containerized production environments.

---

## 1. Container Runtime Guidelines

1. **Non-Root Execution**: Container images run exclusively as non-root user `tracelyt:tracelyt` (UID/GID 10001) with unprivileged capabilities.
2. **Minimal Attack Surface**: The runtime image uses `eclipse-temurin:21-jre-jammy` without build compilers, package managers, or debugging shells in production layers.
3. **Exec-Form Entrypoint**: The container uses standard exec-form entrypoint `["java", ...]` to ensure OS signals (SIGTERM, SIGINT) propagate directly to the JVM for graceful termination.

---

## 2. Health & Readiness Probes

The pipeline exposes Spring Boot Actuator health endpoints:

- **Liveness Probe**: `GET /actuator/health/liveness`
  - Validates that the JVM is responsive. If this fails, the container orchestrator restarts the pod.
- **Readiness Probe**: `GET /actuator/health/readiness`
  - Validates that internal queue buffers are not saturated and downstream sinks are accessible. If this fails, the orchestrator ceases routing traffic to the instance without restarting it.

---

## 3. Resource Allocation and JVM Tuning

When deploying on Kubernetes or Docker:
- **Memory Requests & Limits**: Set memory requests equal to limits to avoid OOM-killer evictions during heap expansion.
- **JVM Memory Flags**: Use container-aware flags:
  `-XX:+UseG1GC -XX:MaxRAMPercentage=75.0`
- **CPU Throttling**: Provide adequate CPU requests to prevent GC pauses triggered by CFS CPU bandwidth throttling.

---

## 4. Graceful Shutdown Lifecycle

1. Container orchestrator sends `SIGTERM`.
2. The pipeline stops pulling new records from the ingestion stream buffer.
3. Active worker threads are given a configured grace window (e.g., 30 seconds) to flush in-flight micro-batches to downstream storage.
4. Active database connections and network sockets are closed cleanly before process termination.
