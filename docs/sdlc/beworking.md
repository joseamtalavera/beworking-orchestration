# BeWorking — SDLC

- **Owner:** Jose AM Talavera
- **Last updated:** 2026-05-16
- **Status:** live · iterating

> This is [TEMPLATE.md](TEMPLATE.md) instantiated for the BeWorking platform —
> a worked example of the framework. Reference model: [README.md](README.md).

---

## 1. Business Layer — the WHY
_Ref: [01-business-layer.md](01-business-layer.md)_

- **Vision:** A multi-tenant SaaS to run coworking spaces — bookings, virtual
  offices, billing, mailroom — sold globally (city-agnostic positioning).
- **Product strategy:** Booking app is the primary site; dashboard is the
  admin/user back office; Stripe-backed monetization (subscriptions + one-off).
- **Requirements (FR):** room/desk booking, virtual-office signup, invoicing,
  subscriptions, contact funnel (Potencial / Activo / Inactivo), mailroom.
- **Requirements (NFR):** tenant isolation, GDPR, Spanish tax/VAT correctness,
  high availability on AWS, recoverable billing.
- **Out of scope:** `beworking-frontend` (archived).
- **Stakeholders / decision owners:** Jose AM Talavera (product + eng owner);
  team inbox `info@be-working.com`.
- **Governance / compliance:** GDPR; Spanish VAT lock-in; cron emails BCC the
  team inbox; chronological invoice numbering.
- **Project management:** single backlog — `beworking_orchestration_issues`
  (GitHub project 13). Daily task ⇄ issues mirror is mandatory.

## 2. Architecture Layer — the STRUCTURE
_Ref: [02-architecture-layer.md](02-architecture-layer.md)_

- **System design:** 6 services via docker-compose + nginx, on AWS ECS Fargate
  (eu-north-1). Nginx (:80) routes `/api/*`→backend, `/`→booking,
  `/dashboard/*`→dashboard, `/payments/*`→stripe-service.
- **Microservices / monolith:** service-oriented — backend-java (Spring Boot),
  dashboard (Vite/React), booking (Next.js), stripe-service (FastAPI), db
  (Postgres). Domain-driven packages inside the Java backend.
- **Domain model:** `auth`, `bookings`, `contacts`, `invoices`, `leads`,
  `mailroom`, `rooms`, `cuentas`, `subscriptions`, `payments`, `integrations`.
- **API design:** REST; Swagger at `/swagger-ui.html`. Public read vs
  admin/auth surfaces. **Known gap:** per-endpoint authz incomplete (workstream).
- **Integration strategy:** Stripe (subscriptions, webhooks, identity sync),
  HubSpot, Cloudflare Turnstile, Akiles (door/access).
- **Scalability decisions:** ECS Fargate horizontal; RDS PostgreSQL shared
  instance (prod `beworking`, staging `beworking_staging`).
- **Security design:** JWT (15 min access + 7 d refresh) in httpOnly cookies;
  Spring Security; row-level tenant isolation via `tenant_id` from JWT claims.
- **Data architecture:** PostgreSQL schema `beworking`; Flyway versioned,
  forward-only migrations; billing-identity snapshot frozen at issue time;
  VAT lock-in (`com.beworking.tax` single source of truth).
- **AI / agent architecture:** MariaAI orchestrator + department microservices
  — planned (EPIC issue #49).

## 3. Engineering Layer — builds the SYSTEM
_Ref: [03-engineering-layer.md](03-engineering-layer.md)_

- **Frontend:** dashboard (Vite + React 19, MUI 7, Grid v2); booking
  (Next.js 15, Zustand + React Query). Shared `packages/` (stripe-client, ui).
- **Backend:** Spring Boot 3.4 / Java 17; `@TransactionalEventListener`
  (AFTER_COMMIT) for side effects; JdbcTemplate for raw SQL paths.
- **Database engineering:** Flyway under `db/migration/V<N>__*.sql`, idempotent,
  never edit applied files (last applied V61–V63 range).
- **AI engineering:** pending MariaAI module.
- **DevOps:** GitHub Actions, OIDC AWS auth; auto-deploy on task-def changes.
- **Automation:** recovery + reengagement crons, daily aging job — all cron
  emails BCC/reply-to `info@be-working.com`.
- **Integrations:** Stripe identity sync (name/VAT → Stripe customer), HubSpot,
  Akiles dual auth (prod API key / staging OAuth).

## 4. Security Layer — protects the SYSTEM
_Ref: [04-security-layer.md](04-security-layer.md)_

- **IAM:** JWT + Spring Security; **active workstream** — per-endpoint authz
  matrix being built (issue #200).
- **Encryption / secrets:** TLS at the edge; AWS Secrets Manager in prod; `.env`
  local only; never commit secrets.
- **Cybersecurity:** **ACTIVE** — 5 confirmed prod IDOR/missing-authz findings
  (invoice PDF, stripe-service zero-auth, contact-profiles, admin gate, tenant
  bypass). Plan + severities in orch issue **#200**; S0 assessment then S1
  containment. Customer-reported 2026-05-15.
- **Privacy:** PII in `contact_profiles`/`facturas`; billing identity frozen at
  issue time (no retroactive rewrite).
- **Risk mgmt:** tracked in issue #200, phased S0→S5, containment first, each
  phase its own commit + staging verify.

## 5. Testing & QA Layer — validates the SYSTEM
_Ref: [05-testing-qa-layer.md](05-testing-qa-layer.md)_

- **Unit:** backend JUnit + Spring Boot Test; dashboard Vitest + RTL.
- **Integration:** backend Spring Boot Test against DB/migrations.
- **E2E:** not yet formalized (gap).
- **Performance:** not yet formalized (gap).
- **Security testing:** authz matrix execution planned under #200.
- **QA automation / CI gates:** CI on push to `main`; `qa-staging-handoff.md`
  checklist; staging → verify → ff-merge main.

## 6. Data & AI Layer — gives INTELLIGENCE
_Ref: [06-data-ai-layer.md](06-data-ai-layer.md)_

- **Databases:** RDS PostgreSQL; prod `beworking` vs staging `beworking_staging`
  (always `SELECT current_database()` before raw SQL).
- **Analytics / KPIs:** subscription reconciliation, invoicing reports
  (dashboard Reports tab).
- **AI agents:** MariaAI — planned (#49).
- **Machine learning:** none yet.
- **Automation:** contact-funnel state machine; recovery/reengagement/aging crons.
- **Knowledge layer:** `CLAUDE.md` + project memory as canonical operational
  knowledge; this SDLC folder as method knowledge.

## 7. Infrastructure & Operations Layer — runs the SYSTEM
_Ref: [07-infrastructure-ops-layer.md](07-infrastructure-ops-layer.md)_

- **Cloud infrastructure:** AWS eu-north-1 — ECS Fargate, RDS, ECR,
  Secrets Manager, ALB.
- **Docker / Kubernetes:** docker-compose + nginx; ECS task definitions.
- **Networking:** nginx :80 path routing; domains `be-working.com` (booking),
  `app.be-working.com` (dashboard + API), `stripe.be-working.com`;
  redirect domains via ALB 301. **Edge restriction of stripe-service: open
  (part of #200).**
- **CI/CD:** GitHub Actions OIDC; `auto-deploy-taskdef.yml`,
  `deploy-ecs.yml`, `manual-deploy.yml`; push staging → OK → ff-merge main.
- **Monitoring / logging:** baseline only (improvement area).
- **Scalability:** ECS Fargate.
- **Reliability / backups:** RDS managed backups; restore drill not documented (gap).
- **Observability:** baseline (improvement area).

## 8. Human Interaction Layer — connects the HUMAN
_Ref: [08-human-interaction-layer.md](08-human-interaction-layer.md)_

- **UI:** booking app is design source of truth; dashboard being brought to
  parity (radius/type/motion/eyebrows/pills); Geist for wordmarks.
- **UX:** 3-layer booking flow (catalog → room detail → book); 3-state contact
  funnel.
- **Accessibility:** not yet formalized (gap).
- **Customer experience:** lifecycle emails (recovery 4-email sequence,
  reengagement); team inbox `info@be-working.com`.
- **Mobile / web interaction:** responsive booking + dashboard; device matrix
  not formalized (gap).

---

## Lifecycle Status

| Stage | State | Notes |
|-------|-------|-------|
| Vision | ✅ | Stable; global positioning |
| Requirements | 🔄 | Continuous via single backlog (project 13) |
| Architecture | ✅ | Stable; AI/agent arch pending (#49) |
| Engineering | 🔄 | Active feature + fix flow |
| AI + Data + Security | 🔄 | **Security #200 active**; MariaAI #49 pending |
| Infrastructure | ✅ | Live on ECS; obs/backup-drill gaps noted |
| Users (live) | ✅ | Production traffic |
| Feedback → new requirements | 🔄 | Loop active (customer-reported security finding fed back) |

### Open gaps tracked elsewhere
- Security workstream → orch issue **#200** (in PROGRESS).
- MariaAI / AI layer → EPIC **#49**.
- Dashboard design parity → **#201**; Geist body adoption → **#202**.
- Not yet formalized: E2E + performance tests, accessibility, observability,
  restore drills.
