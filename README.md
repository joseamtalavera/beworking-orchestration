
# BeWorking Orchestration

This repository is the documentation and deployment hub for the BeWorking stack. Code lives in sibling folders (backend, landing, dashboards), while this root hosts docs, runbooks, and ECS task definitions.

## Start Here
- Documentation index: `docs/README.md`
- Ops runbook (ECS + S3/CloudFront): `docs/deployment/ops-runbook.md`
- Backend entrypoint: `../beworking-backend-java/src/main/java/com/beworking/JavaApplication.java`
- Landing entrypoint: `../beworking-landing-ov/pages/index.js`

## Local Dev (Stack)
See `docker-compose.yml` for the docker-compose dev setup (backend, frontend, dashboard, Postgres).

For codebase-specific READMEs:
- Backend: `../beworking-backend-java/README.md`
- Landing: `../beworking-landing-ov/README.md`

## Security Notes (Auth changes)
- Backend login now issues short-lived access (15m) and refresh (7d) JWTs via httpOnly, SameSite=Lax cookies (`beworking_access`, `beworking_refresh`).
- Refresh endpoint: `POST /api/auth/refresh` rotates both cookies; permitted in security config.
- Token type/tenantId added to JWT claims; unconfirmed users blocked from login.
- Auth filter accepts Bearer header or access cookie, enforces access token type, and returns 401 on invalid/expired tokens.
- Frontend login uses `credentials: 'include'`; dashboards call `/api/auth/me` with auto-refresh on 401 (no token in URL/storage).
- Cookie `secure` flag is configurable via `app.security.cookie-secure` (default true; set false only for local HTTP dev).
