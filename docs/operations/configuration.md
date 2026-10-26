# Configuration Strategy and Operational Settings

This document outlines the configuration philosophy, active configuration properties, and future environment management for `tracelyt-telemetry-pipeline`.

---

## 1. Configuration Philosophy

1. **Strict Separation of Config and Secrets**: Application configuration must never bundle hard-coded credentials, private certificates, or production endpoints.
2. **Safe Defaults**: All configuration properties must define safe fallback defaults enabling local startup without external cloud dependencies.
3. **Environment Injection**: Configuration values are externalized via environment variables (following 12-factor application conventions) or Spring Boot property overrides.
4. **No Premature Feature Configs**: Configuration keys for features that do not exist (such as Kafka broker addresses, ClickHouse credentials, or sampling flags) are intentionally omitted from active files.

---

## 2. Active Configuration Properties

The following properties are configured in `src/main/resources/application.yml`:

| Property | Environment Variable | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `server.port` | `SERVER_PORT` | `8082` | HTTP port for diagnostic endpoints and health probes. |
| `logging.level.io.tracelyt.pipeline` | `LOGGING_LEVEL_IO_TRACELYT_PIPELINE` | `INFO` | Logging level for pipeline application classes (`DEBUG`, `INFO`, `WARN`, `ERROR`). |
| `management.endpoints.web.exposure.include` | `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` | `health,info` | Actuator endpoints exposed over the management interface. |

---

## 3. Secret Injection Strategy

When future streaming connectors (e.g., Kafka SASL tokens, database write passwords) are implemented:
- **Kubernetes**: Secrets will be mounted as environment variables from Kubernetes Secret objects or injected via HashiCorp Vault sidecars.
- **Local Testing**: Secrets must be loaded exclusively via `.env` files (which are git-ignored).
- **Log Masking**: Configuration loaders must never log raw property values marked as sensitive.
