# Testing Strategy and Test Guidelines

This document establishes the testing principles, test execution commands, and guidelines for `tracelyt-telemetry-pipeline`.

---

## 1. Testing Philosophy

Because telemetry pipelines process high volumes of in-flight records, test suites must adhere to the following standards:
- **Fast and Deterministic**: Unit tests must not depend on external network connections, live cloud accounts, or running database clusters.
- **Memory Safety**: Tests are configured with in-process execution (`<forkCount>0</forkCount>`) to prevent memory exhaustion in constrained CI environments.
- **Mocking Boundaries**: Use mocks and in-memory test doubles for external broker and storage sink interfaces.

---

## 2. Test Execution Commands

Run the complete test suite:

```bash
# Run all unit tests
./mvnw test

# Run a specific test class
./mvnw test -Dtest=TracelytTelemetryPipelineApplicationTests
```

---

## 3. Test Layers

### 3.1 Context Bootstrap Smoke Tests
- Located in `src/test/java/io/tracelyt/pipeline/TracelytTelemetryPipelineApplicationTests.java`.
- Verifies that the Spring Boot `ApplicationContext` initializes without missing bean dependencies or circular references.

### 3.2 Planned Unit Tests (Future Implementation)
When processing stages are developed, test suites will cover:
- **Sanitization & Redaction Tests**: Verifying that regex patterns correctly strip credentials and PII without mangling valid telemetry strings.
- **Attribute Normalization Tests**: Ensuring incoming raw attributes map accurately to standard OpenTelemetry semantic convention keys.
- **Batching Threshold Tests**: Verifying that micro-batches trigger flushes accurately based on record count, byte volume, and elapsed time thresholds.
- **Error & DLQ Tests**: Ensuring malformed payloads are isolated without crashing worker threads.
