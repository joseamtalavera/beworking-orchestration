# Dashboard Installation
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Instructions for running the `beworking-dashboard` application (Next.js/Vite-based) in a local environment.

## 1. Clone & Install Dependencies
```bash
cd ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant
git clone git@github.com:<org>/beworking-dashboard.git   # skip if already cloned
cd beworking-dashboard
```
Install dependencies with the team-standard package manager:
```bash
npm install
# or
pnpm install
```

## 2. Configure Environment
Create `.env.local` (or the framework-specific equivalent) using the variables from the [general setup](general-setup.md#35-dashboard-beworking-dashboard):
```
VITE_API_BASE_URL=http://localhost:8080
DASHBOARD_AUTH_CLIENT_ID=<client-id-from-ops>
ANALYTICS_WRITE_KEY=<segment-or-amplitude-key>
```
For Next.js, prefix public variables with `NEXT_PUBLIC_`.

## 3. Run the Development Server
Start the dev server:
```bash
npm run dev
# or
pnpm dev
```
- Vite defaults to `http://localhost:5173`
- Next.js defaults to `http://localhost:3000`

Confirm the console shows “ready” without build errors.

## 4. Backend Connectivity
Update any API clients to use the backend base URL defined above. Test key dashboards or analytics pages to ensure data loads without 401/403 errors. If authentication fails, verify the OAuth/Keycloak configuration matches the backend.

## 5. Testing & Quality Checks
```bash
npm test          # unit tests
npm run lint      # linting
npm run typecheck # if TypeScript is enabled
```
Adjust commands to match the repository scripts.

## 6. Troubleshooting
- **Env variables not applied:** restart the dev server after editing `.env.local`.
- **SSR errors:** check server console output for missing secrets or network failures during data fetching.
- **Authentication issues:** ensure the dashboard client id/secret pair aligns with the identity provider configuration in the backend.

Capture additional dashboard-specific steps (storybook, e2e suites, analytics checks) as the project matures.
