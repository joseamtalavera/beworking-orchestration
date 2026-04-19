# BeWorking Staging — QA Access

Everything you need to test the BeWorking platform on staging.

Staging is a full, isolated copy of the production platform (same AWS infra, separate database + Stripe + email sandbox). Nothing you do here affects real customers, real invoices, or real money.

---

## URLs

| Area | URL |
|------|-----|
| Public booking site | https://staging.be-working.com |
| Dashboard (admin + user + accountant) | https://app-staging.be-working.com |
| Backend API base | https://app-staging.be-working.com/api |
| Swagger API docs | https://app-staging.be-working.com/swagger-ui/index.html |
| OpenAPI JSON spec | https://app-staging.be-working.com/v3/api-docs |
| Stripe service | https://stripe-staging.be-working.com |
| Stripe health | https://stripe-staging.be-working.com/api/health |
| Backend health | https://app-staging.be-working.com/api/health |

---

## Test accounts

All accounts share the same password: **`Staging2026!`**

| Login | Role | Use for |
|-------|------|---------|
| `info@codewright.co` | ADMIN | Full admin app — contacts, invoices, bookings, reconciliation, settings |
| `qa-user@codewright.co` | USER | User app with realistic data (active subscription, bookings, invoices) |
| `qa-newuser@codewright.co` | USER | Empty-state user — no bookings, no subs. For signup flow and empty UI |
| `qa-accountant@codewright.co` | ACCOUNTANT | Read-only invoice view scoped to PT (Spanish entity) |

**Log in as any other user:** every user in staging shares `Staging2026!`. Look up a user ID in the admin app (Contacts → click a contact) and log in as `staging+<id>@codewright.co`.

---

## Signup flow

You can sign up with any email (use your own real address to receive the confirmation email). Emails come from **`onboarding@resend.dev`** — that's Resend's sandbox sender. Real and deliverable, just not from a @be-working.com address yet.

Once signed up, you can log into your new account and verify onboarding UX.

---

## Stripe — you need to set up test-mode keys

The Stripe integration on staging is **waiting for your test-mode keys**. Placeholders are in AWS Secrets Manager; nothing Stripe-dependent will work until you replace them.

1. Go to your Stripe dashboard → enable **Test mode** (toggle top-right)
2. **Developers → API keys** → copy:
   - Publishable key (`pk_test_...`)
   - Secret key (`sk_test_...`)
3. **Developers → Webhooks → Add endpoint**:
   - Endpoint URL: `https://stripe-staging.be-working.com/api/webhook/stripe`
   - Events to send: `customer.subscription.*`, `invoice.*`, `checkout.*`, `payment_intent.*`
   - After creating, reveal the **Signing secret** (`whsec_...`)
4. Send the 3 values (publishable, secret, webhook signing secret) to Lead engineer to populate:
   - `staging/beworking/stripe-publishable-key`
   - `staging/beworking/stripe-secret-key`
   - `staging/beworking/stripe-webhook-secret`

For **Globaltechno (GT)** Stripe, repeat with `/api/webhook/stripe-gt` endpoint; values go into `staging/gt/stripe-*` secrets.

**Test card numbers:** https://docs.stripe.com/testing

---

## Data in staging

- **~1,900 users**, **1,970 contact profiles**, **400 subscriptions**, **13,000 invoices**
- All user emails anonymized: `staging+<id>@codewright.co`, `contact+<id>@codewright.co`, etc.
- All phone numbers, addresses, credit-card data **stripped**
- All Stripe IDs invalidated (`staging_invalid_*` prefix) — zero risk of hitting real customer subs in Stripe
- All Holded (invoicing) IDs wiped
- Business data retained: company names, tenant types, invoice numbers & amounts, room catalog, pricing

---

## CI/CD — how your reported fixes reach staging

```
Lead engineer makes a change → branch: staging
                          │
                          ▼
    GitHub Actions builds :staging image + deploys ECS
                          │
                          ▼  (6–10 min)
    staging.be-working.com + app-staging.be-working.com + stripe-staging.be-working.com updated
                          │
                          ▼  QA verifies
                          │
        Lead engineer merges staging → main
                          │
                          ▼
    GitHub Actions builds :main image + deploys prod ECS
```

Direct pushes to `main` (hotfixes) automatically replay to `staging` within seconds via `sync-staging` workflow, so staging is never behind prod.

---

## Known limitations

| Limitation | Impact | Plan |
|---|---|---|
| Stripe placeholders until you provide test keys | Payment flows 500 | You send keys, Lead engineer pastes them |
| Emails send from `onboarding@resend.dev` | From-address looks like Resend | Optional: verify `staging.be-working.com` domain in Resend later |
| Same RDS as prod (different database) | Heavy load on staging could nudge prod perf | Keep load reasonable; separate RDS if needed |

---

## Reporting bugs

Please include:
1. URL you were on
2. Steps to reproduce
3. Screenshot / HAR / network trace
4. Which account you were logged in as
5. Browser + OS

Send via (pick whichever channel you prefer):
- Dedicated Slack channel (to be created)
- GitHub Issues in the relevant repo
- Email: info@globaltechno.io

---

## Contact

- **Product owner:** Lead engineer — `info@globaltechno.io`
- **Platform:** AWS eu-north-1 · ECS Fargate · RDS PostgreSQL 16 · ALB
- **Business entities:** Beworking Partners (PT — Spain) · Globaltechno (GT)
