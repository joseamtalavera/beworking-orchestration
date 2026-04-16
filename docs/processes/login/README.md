# Login Process

- **Owner:** Jose AM Talavera
- **Last updated:** 2026-04-16

## Purpose

Describe how users authenticate, maintain active sessions, and handle multi-account selection in the BeWorking platform.

## High-Level Flow

1. User submits credentials (email, password) + Turnstile CAPTCHA token.
2. Backend verifies Turnstile, authenticates credentials.
3. If user has multiple accounts, a selection token is issued for account picking.
4. Once resolved, JWT access + refresh tokens are set as httpOnly cookies.
5. User is redirected to the dashboard.

## Endpoints

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| POST | `/api/auth/login` | Public | Primary login |
| POST | `/api/auth/select-account` | Public | Pick account (multi-tenant) |
| POST | `/api/auth/switch-account` | Authenticated | Switch between linked accounts |
| POST | `/api/auth/refresh` | Cookie | Refresh access token |
| GET | `/api/auth/my-accounts` | Authenticated | List linked accounts |
| GET | `/api/auth/me` | Authenticated | Current user profile |

## Detailed Flow

### Single-Account Login

1. **Client** sends `POST /api/auth/login` with `{ email, password, turnstileToken }`.
2. **AuthController** delegates to `TurnstileService.verify()` which calls Cloudflare's `siteverify` endpoint.
3. On CAPTCHA pass, `AuthService` authenticates via Spring Security's `AuthenticationManager`.
4. If the user has one (or zero) linked accounts, tokens are issued immediately.
5. Response: `{ message, token, role }` + `beworking_access` and `beworking_refresh` cookies.

### Multi-Account Login

1. Steps 1–3 are the same as above.
2. If the user has multiple contact profiles, no session token is issued yet.
3. Response: `{ message, accountSelectionRequired: true, selectionToken, accounts: [...] }`.
4. Client displays account picker showing `companyName`, `billingTaxId`, `tenantType` for each.
5. User picks an account → `POST /api/auth/select-account` with `{ selectionToken, contactProfileId }`.
6. Backend validates the selection token (5-min expiry), issues full access/refresh tokens scoped to the chosen tenant.

### Token Refresh

1. Client calls `POST /api/auth/refresh` — no body needed, refresh token is in the cookie.
2. Backend validates the `beworking_refresh` cookie, extracts email, issues a new access token.
3. New `beworking_access` cookie is set in the response.

## Token Configuration

| Token | Lifetime | Cookie Name | Cookie Path |
|-------|----------|-------------|-------------|
| Access | 1 hour | `beworking_access` | `/` |
| Refresh | 7 days | `beworking_refresh` | `/api/auth/refresh` |
| Account selection | 5 minutes | — (response body) | — |

All cookies: `httpOnly`, `Secure` (prod), `SameSite=Lax`. Domain configured via `app.security.cookie-domain`.

JWT claims: `email` (subject), `role`, `tenantId`, `tokenType`. Algorithm: HS256.

## Security Filter Chain

1. **RateLimitingFilter** — applies rate limits.
2. **JwtAuthenticationFilter** — extracts JWT from `Authorization: Bearer` header or `beworking_access` cookie; validates `tokenType=access`; populates Spring Security context with email, role, tenantId.
3. **Public routes** (no auth required): `/api/health`, `/api/auth/*`, `/api/leads`, `/api/webhooks/*`, `/api/public/**`.
4. **Role-based routes**: `/dashboard/admin/**` requires ADMIN; `/dashboard/user/**` requires USER.
5. All other routes require authentication.

## Turnstile (CAPTCHA) Integration

- Required on `/api/auth/login` and `/api/auth/register`.
- Backend verifies via `TurnstileService` → `POST https://challenges.cloudflare.com/turnstile/v0/siteverify`.
- Secret from `turnstile.secret` env var. If the secret is not configured (local dev), verification is skipped.

## Systems & Services

- **Backend**: `AuthController.java`, `AuthService.java`, `JwtUtil.java`, `JwtAuthenticationFilter.java`, `SecurityConfig.java`, `TurnstileService.java`.
- **Frontend**: booking app handles the login UI (public-facing via nginx catch-all).
- **Dashboard**: authenticated app at `/dashboard/*`.

## Error Handling

- Invalid credentials → 401.
- Turnstile failure → 403 with Cloudflare error codes.
- Expired selection token → 401, user must re-login.
- Rate limiting → 429.

## Diagram

- Source: `../../diagrams/draw.login.txt`
- Export: `../../diagrams/login.drawio.png`

![Login flow](../../diagrams/login.drawio.png)
