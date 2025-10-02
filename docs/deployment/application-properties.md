# Spring Boot Profiles & Configuration
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

This guide documents how configuration is split between common, development, and production profiles so you can recreate the setup quickly without breaking local workflows.

---

## 1. Shared Configuration (`src/main/resources/application.properties`)
These properties apply to every environment.

```properties
# Hibernate dialect and schema
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.default_schema=beworking

# Application metadata
spring.application.name=java

# HubSpot base URL (constant across envs)
hubspot.api.baseUrl=https://api.hubapi.com
```

Keep this file minimal—only add values that never change between environments.

---

## 2. Local Development (`application-dev.properties`)
Used when running locally or inside the existing Docker-based dev environment.

```properties
# Local PostgreSQL (Docker)
spring.datasource.url=jdbc:postgresql://host.docker.internal:5432/lhm_inmo_app
spring.datasource.username=${DB_USERNAME:devuser}
spring.datasource.password=${DB_PASSWORD:devpass}
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# JWT secret (fallback value acceptable for local)
jwt.secret=${JWT_SECRET:YOUR_SUPER_SECRET_KEY}

# HubSpot token (dummy acceptable if not exercising integration)
beworking.api.token=${HUBSPOT_API_TOKEN:dummy-dev-token}
```

Notes:
- Leverage `${VAR:default}` syntax so teammates can override via environment variables without editing the file.
- `ddl-auto=update` keeps the local schema evolving; do not use this in production.

---

## 3. Production (`application-prod.properties`)
Activated on ECS Fargate. Every secret is injected via environment variables or AWS Secrets Manager.

```properties
# Amazon RDS PostgreSQL
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

spring.jpa.hibernate.ddl-auto=validate

# JWT secret (supplied by Secrets Manager / Parameter Store)
jwt.secret=${JWT_SECRET}

# HubSpot API token (secure)
beworking.api.token=${HUBSPOT_API_TOKEN}
```

Guidelines:
- No default values—missing secrets should fail fast.
- Use `validate` so Flyway/Liquibase control schema changes.

---

## 4. Activating Profiles

### Local Development
Run with the dev profile explicitly:
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
# or export SPRING_PROFILES_ACTIVE=dev before launching
```
You can add `spring.profiles.active=dev` to a personal `application-local.properties` (not committed) for convenience.

### Production (ECS)
Set the environment variable in the ECS task definition:
```
SPRING_PROFILES_ACTIVE=prod
```
This is managed in the task definition JSON or via console when updating the service.

---

## 5. Secrets Management (Production)
1. Store values (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET`, `HUBSPOT_API_TOKEN`) in AWS Systems Manager Parameter Store or Secrets Manager.
2. Reference them in the ECS task definition under the **secrets** section so the container receives them as environment variables.
3. Rotate secrets periodically and update the task definition to pick up new values.

---

## 6. Summary Table
| Profile | File | Datasource | JWT & HubSpot Token | Schema Strategy |
| --- | --- | --- | --- | --- |
| Common | `application.properties` | Shared Hibernate settings | — | — |
| Development | `application-dev.properties` | Local Postgres (Docker) | Fallback defaults for convenience | `update` |
| Production | `application-prod.properties` | RDS via env vars | Provided by Secrets Manager | `validate` |

Keep this runbook updated whenever you add new profiles or environment-specific properties.
