# Contract Governance and Cross-Service Interoperability

This document defines how `tracelyt-telemetry-pipeline` integrates with the platform-wide contract governance established in [`tracelyt-specs`](https://github.com/Tracelyt-Systems/tracelyt-specs).

---

## 1. Centralized Contract Source of Truth

To prevent schema drift and uncoordinated breaking changes:
- **No Proprietary Independent Schemas**: The telemetry pipeline does not invent private, incompatible copies of telemetry wire schemas or control-plane API contracts.
- **Upstream OpenTelemetry Alignment**: Ingress telemetry formats conform to upstream CNCF OpenTelemetry Protocol (OTLP) definitions without custom proprietary wrappers.
- **Shared Platform Contracts**: Shared cross-service message envelopes, alert definitions, and tenant policy schemas are authored, versioned, and reviewed centrally within `tracelyt-specs`.

---

## 2. Integration & Change Lifecycle

When a new payload format or contract modification is needed:

```text
1. RFC in tracelyt-specs ---> 2. Security & Compatibility Review ---> 3. Merge in Specs ---> 4. Consume in Pipeline
```

1. **RFC Submission**: Propose the change via an RFC issue in the `tracelyt-specs` repository.
2. **Compatibility Analysis**: Assess whether the change is purely additive (safe) or backward-incompatible (requiring a major version transition).
3. **Consumer Verification**: Both producer (`tracelyt-ingestion`) and consumer (`tracelyt-telemetry-pipeline`) maintainers review the change.
4. **Adoption**: Once approved and published in `tracelyt-specs`, the pipeline imports or binds to the updated contract specification.
