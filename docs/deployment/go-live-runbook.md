# Go-Live Runbook (Beworking)
- **Target date:** January 29, 2026 (update when scheduling)
- **Scope:** Backend (ECS), Booking app, Dashboard, Landing, Stripe payments

## Current State Findings (must fix before go-live)
- No DB migration exists yet for `reservation_payments` or new payment/status fields on `reservas` (latest migration is `V9__augment_room_catalog_fields.sql`).
- Backend only creates PaymentIntents (`/api/public/payment-intents`) and does not persist intent IDs or implement `/stripe/webhook` with signature verification/idempotency.
- ECS task definition (`beworking-orchestration/task-def.json`) currently **missing** `STRIPE_SECRET_KEY` and `WEBHOOK_SECRET` entries under `secrets`.
- Booking frontend has **no Stripe payment step** or call to `payment-intents`; Dashboard uses mocked Stripe customer data.
- No payment/webhook tests exist; test gate not satisfied.

## 0) Owners & Freeze
- Assign on-call / incident channel.
- Code freeze except go-live fixes; tag release in each repo.

## 1) Secrets & Config (must be green before anything ships)
- AWS Secrets Manager / SSM:
  - `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`
  - `JWT_SECRET`
  - `HUBSPOT_API_TOKEN`
  - `STRIPE_SECRET_KEY` (backend)
  - `WEBHOOK_SECRET` (Stripe webhook)
  - `TURNSTILE_SECRET`
- ECS task def updates (`beworking-orchestration/task-def.json`):
  - **Add** `STRIPE_SECRET_KEY` and `WEBHOOK_SECRET` under `secrets` (missing today).
  - Keep `APP_CORS_ALLOWED_ORIGINS` aligned with prod/stage domains.
- Frontend envs:
  - Booking app: `VITE_API_BASE_URL`, `VITE_STRIPE_PUBLISHABLE_KEY` (not wired yet).
  - Dashboard: API base, auth settings; hide Stripe UI until backend ready.
  - Landing: existing CloudFront/S3 settings.

## 2) Database Migrations
- **Create new migration** to add booking/payment schema:
  - `reservation_payments` table + new fields on `reservas` (status/payment fields, intent IDs, amounts, currency, timestamps).
- Run Flyway/Liquibase (backend) against staging → prod after validation.
- Backup: ensure latest RDS snapshot before prod migration; record snapshot ID.

## 3) Backend Release (ECS)
- Implement payment backend before release:
  - Persist PaymentIntent IDs to DB; store status/amount/currency per reservation.
  - Add `/stripe/webhook` with signature verification + idempotency; update booking/payment status on events.
- Build & test:
  - Add unit/integration tests for PaymentIntent creation, webhook handling, booking conflicts; run `./mvnw clean test`.
- Package & image:
  - `./mvnw clean package -DskipTests`
  - `docker build -t beworking-core:main .`
  - Tag/push to ECR `905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main`.
- Register new task def revision (`aws ecs register-task-definition --cli-input-json file://task-def.json`).
- Update service with new revision and `--force-new-deployment`.
- Verify health: `aws ecs describe-services ...` and `curl https://oficinavirtual.be-working.com/api/health`.

## 4) Stripe Integration Completion
- Backend:
  - Bind env `STRIPE_SECRET_KEY` to `stripe.secret` (present) and add `WEBHOOK_SECRET` usage.
  - Implement `/stripe/webhook` with signature verification + idempotency (missing today).
  - Persist PaymentIntent IDs to `reservation_payments`; update booking/payment status on webhook.
- Frontend booking (Vite app):
  - Add payment step calling `POST /api/public/payment-intents` to get `clientSecret`.
  - Wrap UI with `<Elements clientSecret=... stripe={loadStripe(PUBLISHABLE_KEY)}>` and run `stripe.confirmPayment`.
  - Show success/fail states; block navigation until Stripe result.
- Dashboard: replace mocked Stripe data with real API calls or hide payment UI until backend ready.

## 5) Frontend Releases
- Booking app: add Stripe flow + env wiring, then `npm run build`; deploy to S3/CloudFront (or target hosting). Invalidate cache.
- Dashboard: wire/hide payment UI as above; `npm run build`; deploy to hosting target.
- Landing: `npm run build` (Next export) in `beworking-landing-ov`; `aws s3 sync ./out s3://<bucket> --delete`; invalidate CloudFront.

## 6) Testing Gates (must pass before prod)
- Backend: unit + integration (auth, bookings, payments, webhook). Add coverage for PaymentIntent creation and webhook idempotency.
- Booking app: E2E (Stripe test mode) — book → pay (4242) → webhook updates status → dashboard shows confirmed/paid.
- Dashboard: verify billing view shows real data or UI hidden if not ready.
- Regression: auth/login, leads, mailbox flows untouched by payment changes.
- Security: JWT/CORS, no secrets in logs; webhook signature required.

## 7) Observability & Alerts
- CloudWatch alarms: ECS task CPU/Mem, 5xx rate, webhook errors, payment failure rate.
- Log retention set; dashboards for booking/payment funnel.
- Uptime check on `/api/health` and main site.

## 8) Cutover / Prod Deploy Steps
1. Confirm secrets and migrations applied.
2. Deploy backend task revision.
3. Deploy booking app + invalidate CDN.
4. Deploy dashboard (or hide payment UI if backend not fully ready).
5. Smoke tests (prod URLs):
   - `/api/health` returns 200.
   - Create PaymentIntent (small amount) with Stripe test key on staging; in prod use live key and low-value test if allowed.
   - Webhook delivers and booking status changes.
   - Login/admin dashboards load and list bookings.

## 9) Rollback Plan
- Backend: `aws ecs update-service --task-definition beworking-backend-task:<PREV_REV>`.
- Frontends: revert to previous S3 object version / previous build artifact; re-invalidate CDN.
- DB: restore from latest snapshot if migration caused incident (RPO per backup). Document steps before change.

## 10) Post-Go-Live
- Monitor 24–48h; track payment success/failure ratios and error logs.
- Schedule secret rotation (JWT/DB/Stripe) and document cadence.
- Close freeze after stability window; tag final release notes.
