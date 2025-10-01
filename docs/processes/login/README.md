# Login Process
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

## Purpose
Describe how users authenticate, maintain active sessions, and recover access to the Beworking tenant account.

## High-Level Flow
1. User submits credentials (email/password or SSO token).
2. Backend verifies identity, applies MFA or tenant checks.
3. Session/token issued and persisted on client.
4. User redirected to the appropriate dashboard or mailbox.

Adjust the steps with any custom logic such as device trust, captcha, or forced password updates.

## Systems & Services

- Frontend: login form component(s), state management, error handling.
- Backend: authentication controller, security filters, token issuer.
- External services: identity provider, MFA service, analytics.

Document concrete classes/modules as you trace them (e.g. `beworking-backend-java/src/.../AuthController.java`).

## Diagram
- Source: `../../diagrams/draw.login.txt`
- Export (PNG/SVG): `../../diagrams/login.drawio.png`

Embed export once generated:

![Login flow](../../diagrams/login.drawio.png)

## Edge Cases & Notes
- Detail lockout strategy, retry limits, and error surfaces.
- Capture tenant-aware behaviours (custom domains, brand overrides, feature flags).

## Follow-ups
- [ ] Confirm session length and refresh flow.
- [ ] Link to auth-related integration tests.
