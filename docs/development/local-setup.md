# Local Developer Setup

This guide walks through configuring your local development workstation for building, testing, and contributing to `tracelyt-telemetry-pipeline`.

---

## 1. Prerequisites

To build and run the pipeline foundation locally, you need:

| Requirement | Recommended Version | Purpose |
| :--- | :--- | :--- |
| **Java JDK** | 21 LTS (Eclipse Temurin recommended) | Primary development and compilation runtime |
| **Git** | 2.30 or newer | Source code management |
| **Maven** | Handled via `./mvnw` | Build automation (Maven Wrapper included) |
| **Docker** *(Optional)* | 24+ | Local container image builds |

---

## 2. Cloning the Repository

```bash
git clone https://github.com/Tracelyt-Systems/tracelyt-telemetry-pipeline.git
cd tracelyt-telemetry-pipeline
```

---

## 3. Environment Configuration

Copy the sample environment file to create your local `.env`:

```bash
cp .env.example .env
```

*Note*: `.env` is ignored by Git to prevent accidental credential leakage.

---

## 4. Building the Project

Use the provided Maven Wrapper to compile and verify the project:

### Linux / macOS
```bash
# Verify compilation and run tests
./mvnw clean test

# Run Checkstyle static code analysis
./mvnw checkstyle:check

# Package the executable JAR
./mvnw clean package
```

### Windows (PowerShell / Command Prompt)
```powershell
# Set JAVA_HOME if not configured globally
$env:JAVA_HOME = "C:\Path\To\jdk-21"

# Run tests and static checks
.\mvnw.cmd clean test checkstyle:check
```

---

## 5. Running the Application Locally

Run the Spring Boot application locally:

```bash
./mvnw spring-boot:run
```

By default, the application starts on port `8082`. Verify application health via the Actuator endpoint:
```bash
curl http://localhost:8082/actuator/health
```
