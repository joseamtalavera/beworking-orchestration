# BeWorking Staging — QA Handoff

Staging environment is a full isolated copy of the BeWorking platform for testing.
It runs on AWS (same infra as prod) but uses a separate database and separate Stripe/email accounts — nothing you do here touches real customers or real money.

---

## URLs

| Area | URL | Notes |
|---|---|---|
| Public booking site | https://staging.be-working.com | what end customers see |
| Dashboard (admin + user) | https://app-staging.be-working.com | login page |
| Stripe service | https://stripe-staging.be-working.com | internal, used by payments flow |
| **Swagger API docs** | https://app-staging.be-working.com/swagger-ui.html | interactive API explorer — useful for API/integration testing |

Backend API lives under `https://app-staging.be-working.com/api/*` (same base URL as the dashboard).

---

## Test accounts

All four accounts share the same password: **`Staging2026!`**

| Login | Role | What it's for |
|---|---|---|
| `info@codewright.co` | ADMIN | Full admin app — contacts, invoices, bookings, reconciliation, settings |
| `qa-user@codewright.co` | USER | Realistic user — has active subscription, bookings, invoices. Use to test the user-side app |
| `qa-newuser@codewright.co` | USER | Empty user — no bookings, no subs. Use to test signup flow / empty states |
| `qa-accountant@codewright.co` | ACCOUNTANT | Read-only invoice view scoped to PT (Spanish entity) |

You can also log in as **any** user in staging — every user has the same password `Staging2026!`. Look up user IDs in the admin app and log in as `staging+<id>@codewright.co`.

---

## Creating new users (signup flow)

Staging signup works. You can sign up with any email — if you use your own real email, the confirmation email will arrive in your inbox (staging sends via Resend sandbox, `onboarding@resend.dev`).

Once signed up, you can log into the new account and verify the onboarding flow.

---

## Stripe — setting up test mode

The Stripe integration on staging is **waiting for your test-mode keys**. Placeholders are in place; nothing Stripe-dependent will work until they're replaced.

1. Create (or use your existing) Stripe account with **Test mode** enabled.
2. From the Stripe dashboard → Developers → API keys, copy:
   - Publishable key (`pk_test_...`)
   - Secret key (`sk_test_...`)
3. Create a webhook endpoint in Stripe:
   - URL: `https://stripe-staging.be-working.com/api/webhook/stripe`
   - Events: `customer.subscription.*`, `invoice.*`, `checkout.*`, `payment_intent.*`
   - Copy the signing secret (`whsec_...`)
4. Send these 3 values to Jose — they go into AWS Secrets Manager:
   - `staging/beworking/stripe-secret-key`
   - `staging/beworking/stripe-publishable-key`
   - `staging/beworking/stripe-webhook-secret`

If you're also testing GT (Globaltechno), repeat for the GT account and populate `staging/gt/stripe-*` secrets.

Use Stripe's test card numbers: https://docs.stripe.com/testing

---

## What data is in staging

- **~1,900 users**, ~1,970 contact profiles, ~400 subscriptions, ~13,000 invoices
- All emails anonymized: `staging+<id>@codewright.co`, `contact+<id>@codewright.co`, etc.
- All phone numbers, addresses, credit card data stripped
- All Stripe IDs invalidated (prefixed `staging_invalid_`) — so no accidental hits on real Stripe data
- Business data kept: company names, invoice amounts, room catalog, tenant types

---

## Known limitations on day 1

| Limitation | Impact | Plan |
|---|---|---|
| Stripe placeholders until you provide keys | Payment flows 500 | You provide keys, see above |
| Emails send from `onboarding@resend.dev` | From-address says Resend, not BeWorking | Will switch to `staging@staging.be-working.com` once domain is verified in Resend |
| Same RDS as prod (different DB) | Heavy queries on staging could affect prod perf | Keep load reasonable; if it's a problem we move staging to its own RDS |

---

## Reporting bugs

1. Include the URL you were on
2. Steps to reproduce
3. Screenshot or HAR if possible
4. The account you were logged in as
5. Browser + OS

Submit via (pick whichever channel we agreed on):
- Shared Slack channel
- GitHub Issues in the relevant repo
- Email to `jose.molina.talavera@gmail.com`

---

## CI/CD: how changes reach staging

```
Dev makes a change
       │
       ▼
 push to branch: staging           → GitHub Actions builds `:staging` image
       │                             and redeploys staging ECS services
       ▼
 QA tests on staging               → takes ~6–10 min from push to live
       │
       │ (QA approves)
       ▼
 push staging → main               → GitHub Actions builds `:main` image
                                     and redeploys prod ECS services
```

If Jose pushes directly to `main` (hotfix), a separate workflow auto-merges `main` → `staging` within seconds, so staging is never behind prod.

---

## Contact

- Product owner: Jose Molina (jose.molina.talavera@gmail.com)
- Platform: AWS eu-north-1, ECS Fargate, RDS Postgres
- Region of operations: Spain (business entity PT) + Globaltechno (GT)
