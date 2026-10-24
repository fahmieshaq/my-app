# Minimal Spring Boot 21 AWS Blueprint Smoke Test

This is an **independent application** for testing the blueprint. It has no database and does not exercise backup/restore paths. It does expose `/api/hello`, `/actuator/health/readiness`, and `/actuator/prometheus`.

## First local setup (required)

Install JDK 21. To generate the Maven Wrapper without installing Maven globally, run from this directory:

```powershell
docker run --rm -v "${PWD}:/workspace" -w /workspace maven:3.9.11-eclipse-temurin-21 mvn -N wrapper:wrapper
.\scripts\run-maven.ps1
```

The Maven wrapper files must be **committed** with this project, including `.mvn/wrapper/maven-wrapper.properties` and the generated `mvnw` / `mvnw.cmd` scripts. For GitHub Actions Linux runner, mark `mvnw` executable:

```powershell
git add mvnw mvnw.cmd .mvn pom.xml src Dockerfile .dockerignore .gitignore
git update-index --chmod=+x mvnw
git commit -m "Add Spring Boot smoke test application"
```

Before pushing, confirm Maven wrapper generation succeeded. The Dockerfile requires `target/*.jar`, which CI builds in the Maven test job; **the current blueprint Docker job downloads no build artifact and checks out source in a separate job**, so the workflow must be corrected to build the jar or download a jar artifact in the Docker job. Do not deploy until fixed.

Build locally:

```powershell
.\scripts\run-maven.ps1
docker build -t blueprint-smoke-test:local .
docker run --rm -p 8080:8080 blueprint-smoke-test:local
```

In another terminal: `Invoke-RestMethod http://localhost:8080/actuator/health/readiness`.

**Java preflight:** Always run `scripts/run-maven.ps1` instead of invoking `mvnw.cmd` directly on Windows. It selects an installed JDK 21 for Maven and fails before compilation if unavailable. This does not change the machine-wide Java settings. CI must independently configure Java 21 with `actions/setup-java` before invoking Maven.
