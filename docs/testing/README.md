# Testing Playbook
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Follow this playbook to reapply or audit the testing strategy for the Beworking platform. Each section lists the exact scenarios, assertions, and tooling we rely on today so you can reproduce coverage from scratch.

---

## 1. Unit Tests (JUnit 5 + Mockito)

### 1.1 Services & Business Logic

**RegisterService**
- ✅ Happy path: new user saved with roles, disabled flag, confirmation token generated.
- ✅ Duplicate email → `DataIntegrityViolationException`.
- ✅ Invalid payload (null fields, bad email) → validation exception thrown.

**LoginService**
- ✅ Valid credentials → returns JWT/DPoP response object.
- ✅ Wrong password → `BadCredentialsException`.
- ✅ Unknown user → `UsernameNotFoundException`.
- ✅ Disabled/locked account → `AccountStatusException`.

**EmailService**
- ✅ Mock `JavaMailSender` → assert recipient, subject, template variables.
- ✅ SMTP failure → custom exception thrown and handled.

**TokenProvider / JwtUtil**
- ✅ `createToken()` produces expected header, claims, expiration.
- ✅ `validateToken()` accepts valid tokens and rejects expired or tampered tokens.

**BcryptHashGenerator** (if implemented)
- ✅ `hash()` + `matches()` succeed for valid pair, fail for mismatched passwords.

**RateLimitingFilter**
- ✅ Under limit → delegates to filter chain.
- ✅ Over limit → returns HTTP 429 with expected body.

### 1.2 Utilities & Helpers

**GlobalExceptionHandler**
- ✅ When `MethodArgumentNotValidException` thrown, response has correct status and JSON payload.

**Custom Converters/Validators**
- ✅ 100% edge-case coverage on remaining helpers.

**Quality Gate**
- Maintain ≥ 90% line/branch coverage across service, utility, and filter packages.

---

## 2. Repository Tests (Spring Data + H2/Testcontainers)

**Custom Query Methods**
- Validate `findByEmail()`, `existsByUsername()` and similar queries return expected data.

**Schema & Migrations**
- Run Flyway/Liquibase migrations against H2 or PostgreSQL Testcontainer and assert tables/columns exist.

> Tip: Prefer `@DataJpaTest` with embedded DB for speed; switch to Testcontainers PostgreSQL for full parity.

---

## 3. Integration Tests (Spring Context + MockMvc/Testcontainers)

Annotate integration suites with:
```java
@SpringBootTest
@AutoConfigureMockMvc
@Testcontainers
```
and spin up PostgreSQL (plus Redis/Kafka if required).

### 3.1 Authentication Flows
- **POST `/api/auth/register`**
  - Valid payload → 200 created, user row persisted, email sent (verify side effects).
  - Duplicate email → 400 with JSON error body.
- **GET `/api/auth/confirm?token=…`**
  - Valid token → 200 and user enabled.
  - Invalid/expired token → 400.
- **POST `/api/auth/login`**
  - Valid credentials → 200 with JWT/DPoP in response header/body.
  - Wrong credentials → 401.
- **POST `/api/auth/forgot-password`**
  - Known email → 200, reset token stored, email dispatched.
  - Unknown email → 404 or 200 (match chosen behaviour).
- **POST `/api/auth/reset-password`**
  - Valid token + strong password → 200, password updated.
  - Invalid token or weak password → 400.

### 3.2 Security Filters & Headers
- Protected endpoint without token → 401.
- With expired/tampered token → 401.
- Response includes `X-XSS-Protection: 1; mode=block`.
- CORS allows only trusted origins.

---

## 4. Contract Tests (Optional, Recommended)

- Generate OpenAPI spec via `springdoc-openapi` (`/v3/api-docs`).
- In CI, ensure frontend types stay in sync:
  ```bash
  npx openapi-typescript http://localhost:8080/v3/api-docs --output frontend/types/api.d.ts
  git diff --exit-code frontend/types/api.d.ts
  ```
- Fail the pipeline if the diff is non-empty.

---

## 5. End-to-End (E2E) Tests (Cypress/Playwright)

Run against a full Docker Compose stack or ephemeral environment.

| Flow | Happy Path | Failure Case |
| --- | --- | --- |
| Register → Confirm → Login | Sign up, follow email, log in, access `/dashboard` (200) | Confirm with invalid token (400) |
| Forgot password → Reset → Login | Request reset, follow link, set new password, login succeeds (200) | Use expired token (400) |
| Protected routes | Call protected API with valid token → 200 | Without/invalid token → 401 |
| Rate limiting | Burst below limit → 200; exceed limit → 429 | — |

---

## 6. Non-Functional & Security Scans
- **Load Testing:** Gatling scenario covering concurrent registrations/logins; maintain p95 latency < 200 ms.
- **OWASP ZAP:** Automated scan against staging; ensure no high/critical findings.
- **Static Analysis:** SonarQube quality gate—no new bugs or vulnerabilities allowed.

---

## 7. CI/CD Quality Gates

**PR Checks**
- Run lint (Checkstyle, SpotBugs), compile, and unit tests only.
- Enforce ≥ 90% coverage (fail pipeline otherwise).

**Merge Pipeline**
- Execute integration tests with Testcontainers.
- Run contract test diff (Section 4).

**Release Pipeline**
- Build and tag Docker images.
- Execute E2E suite and security scans in a preview environment before promotion.

---

## Maintenance Checklist
1. Track coverage trends; fail builds when service/util packages drop below 90%.
2. Refresh Gatling/ZAP baselines quarterly or when major features ship.
3. Keep OpenAPI spec and generated frontend types aligned.
4. Document newly added test suites in this playbook.

Keep this README updated as test coverage evolves so future engineers can regenerate the test harness from these steps.
