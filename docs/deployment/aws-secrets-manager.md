# AWS Secrets Manager Setup
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this walkthrough to provision the secrets required by the Beworking backend in AWS Secrets Manager. It mirrors the current production configuration.

---

> **Note:** Store actual secret values in `docs/private/` (git-ignored) and reference them when following this guide. The placeholders below (`<DB_USERNAME>`, etc.) should never be committed.

## 1. Open Secrets Manager
1. Sign in to the [AWS Management Console](https://console.aws.amazon.com/console/home).
2. In the top search bar, type **Secrets Manager** and select it.
3. Click **Store a new secret** in the upper right corner.

---

## 2. Database Credentials Secret
1. Secret type: choose **Other type of secret** (key/value pairs).
2. Add the credentials used by the backend:
   - `username` → `<DB_USERNAME>`
   - `password` → `<DB_PASSWORD>`
3. Click **Next**.
4. Secret name: `beworking-db-credentials`.
5. Leave the remaining options with their defaults (automatic rotation disabled for now).
6. Click **Next** → **Next** → **Store**.

---

## 3. JWT Secret
1. Click **Store a new secret** again.
2. Secret type: **Other type of secret**.
3. Add key/value pair:
   - `JWT_SECRET` → `<JWT_SECRET>`
4. Secret name: `beworking-jwt-secret`.
5. Save the secret (defaults are fine).

---

## 4. HubSpot Token
1. Store a new secret once more.
2. Secret type: **Other type of secret**.
3. Key/value pair:
   - `HUBSPOT_API_TOKEN` → `<HUBSPOT_API_TOKEN>`
4. Secret name: `beworking-hubspot-token`.
5. Save the secret.

---

## 5. Verification
You should now see three secrets listed in Secrets Manager:
- `beworking-db-credentials`
- `beworking-jwt-secret`
- `beworking-hubspot-token`

Record the ARNs for each secret—these will be referenced in the ECS task definition so the container receives the values as environment variables.

---

## 6. Next Steps
1. In the ECS task definition, add each secret under the **secrets** section:
   - `DB_USERNAME` and `DB_PASSWORD` read from `beworking-db-credentials`.
   - `JWT_SECRET` read from `beworking-jwt-secret`.
   - `HUBSPOT_API_TOKEN` read from `beworking-hubspot-token`.
2. Grant the task execution role (`ecsTaskExecutionRole`) permission to retrieve these secrets (attach `SecretsManagerReadWrite` or a scoped-down policy).
3. Rotate secrets on a schedule and update the ECS service to pick up new versions.

Keep this document updated if secrets are renamed, rotated differently, or additional services are added.
