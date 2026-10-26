# Telemetry Privacy and Sensitive Data Governance

This document establishes the guidelines for handling sensitive attributes, privacy boundaries, and customer data in `tracelyt-telemetry-pipeline`.

---

## 1. The Observability Data Privacy Challenge

Observability signals frequently capture raw operational strings from application stacks. Without deliberate redaction filters, sensitive fields—such as HTTP cookies, Authorization headers, Bearer tokens, passwords, and personal identifiers (PII)—can be inadvertently written to long-term storage.

---

## 2. Privacy Guardrails for Telemetry Processing

1. **Header Sanitization**:
   - Ingress and pipeline workers must automatically redact known sensitive HTTP headers:
     `Authorization`, `Cookie`, `Set-Cookie`, `X-Api-Key`, `Proxy-Authorization`.
   - Values must be substituted with standard masks: `[REDACTED]`.
2. **Regex-Based Attribute Masking**:
   - The pipeline will support configurable tenant redaction rules for scanning span attributes and structured log bodies for sensitive patterns (e.g., credit card numbers, email addresses, Social Security Numbers).
3. **Data Minimization Principle**:
   - Only attributes strictly necessary for application diagnostics should be preserved. Unused bulky payloads or raw request bodies should be dropped at the pipeline stage.
4. **No Raw Telemetry in Operational Logs**:
   - Pipeline error handlers must never log the raw contents of failed telemetry records. Logs must report only failure metadata: `tenant_id`, `record_count`, `error_type`, and `timestamp`.
5. **Synthetic Test Data**:
   - All unit and integration test fixtures must strictly use synthetic dummy data (e.g., `user@example.com`, `00000000-0000-0000-0000-000000000000`). Using production customer telemetry in tests or issues is prohibited.
