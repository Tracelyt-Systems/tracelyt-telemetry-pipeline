# syntax=docker/dockerfile:1.7
# Build Stage
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /workspace

# Copy build descriptor and wrapper
COPY mvnw pom.xml ./
COPY .mvn/ .mvn/

# Resolve dependencies in a separate cached layer
RUN ./mvnw dependency:go-offline -B

# Copy application source code and checkstyle config
COPY src/ src/
COPY .checkstyle.xml ./

# Package runnable application jar without running tests in container build
RUN ./mvnw clean package -DskipTests -B

# Runtime Stage
FROM eclipse-temurin:21-jre-jammy AS runner
WORKDIR /app

# Create dedicated non-root service user and group
RUN groupadd -g 10001 tracelyt && \
    useradd -u 10001 -g tracelyt -s /bin/false -M -d /app tracelyt

# Copy application artifact from builder stage
COPY --from=builder --chown=tracelyt:tracelyt /workspace/target/tracelyt-telemetry-pipeline-0.1.0-SNAPSHOT.jar app.jar

USER tracelyt:tracelyt

EXPOSE 8082

ENTRYPOINT ["java", "-XX:+UseG1GC", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
