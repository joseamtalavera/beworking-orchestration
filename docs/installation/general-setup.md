# General Setup

- **Owner:** _TBD_
- **Last updated:** 2025-10-01

This guide captures the foundational preparation required before installing any Beworking services. Complete these steps first so the backend, frontend, database, and dashboard instructions run smoothly.

## 1. Prerequisites

Before running any setup scripts, make sure the machine and operator meet the following requirements. Walk through the list in order—later steps depend on the earlier ones.

### 1.1 Workstation Baseline

- **Operating system:** macOS Ventura 13+ or Windows 11 Pro. Linux (Ubuntu 22.04 LTS) is supported but some commands differ; adapt paths as needed.
- **Hardware:** minimum 16 GB RAM and 30 GB free disk space. Docker pulls, multiple repos, and local databases consume several gigabytes.
- **Administrator rights:** required to install system packages, Docker Desktop, and to modify the hosts file if you map custom domains.
- **Corporate VPN:** connect before cloning if Git or package registries are reachable only through the VPN.

### 1.2 Accounts & Access

- **GitHub/GitLab access:** ensure your user has read/write permissions to `beworking-orchestration`, `beworking-backend-java`, `beworking-frontend`, and `beworking-dashboard`.
- **Cloud/third-party services:** request credentials for HubSpot sandbox, transactional email provider, and any tenant-specific APIs. Store secrets in your password manager; do not hard-code them.
- **Package registries:** confirm you can pull from the internal npm registry (if applicable) and Maven repositories. Export any required auth tokens (e.g., `NPM_TOKEN`, `MAVEN_SETTINGS_PATH`).

### 1.3 Core Tooling

Install the following tools with the indicated versions or newer. Verify installations by running the commands in the right column.

| Tool | Version | Install Notes | Verify |
| --- | --- | --- | --- |
| Git | 2.40+ | Use Homebrew (`brew install git`) or winget (`winget install Git.Git`). | `git --version` |
| Node.js | 20.x LTS | Install via nvm (`nvm install 20 && nvm use 20`) or download from nodejs.org. | `node -v` |
| npm or pnpm | npm 10+ or pnpm 8+ | npm ships with Node; install pnpm via `corepack enable` then `corepack prepare pnpm@latest --activate`. | `npm -v` / `pnpm -v` |
| Java JDK | 21 (Temurin recommended) | macOS: `brew install --cask temurin`; Windows: download MSI from Adoptium. | `java -version` |
| Maven Wrapper | Bundled | No global install needed; ensure `./mvnw` runs. | `./mvnw -v` |
| Docker Desktop | 4.30+ | Required for databases and orchestration stack. Enable Kubernetes if you plan to test k8s manifests. | `docker --version` |
| Docker Compose | v2 (ships with Docker Desktop) | CLI plugin; confirm after Docker install. | `docker compose version` |
| Make (optional) | 4.3+ | Useful if repo provides Make targets. | `make -v` |

### 1.4 IDE & Productivity Helpers (Recommended)

- VS Code or IntelliJ IDEA Ultimate for Java/Spring development; install ESLint/Prettier extensions for JavaScript work.
- draw.io desktop app if you prefer editing diagrams offline; otherwise bookmark [app.diagrams.net](https://app.diagrams.net/).
- HTTP client (Insomnia, Postman, or VS Code REST Client) for inspecting API endpoints.

### 1.5 Environment Preparation

- **SSH keys:** add your public key to the Git provider to avoid HTTPS credential prompts.
- **Proxy settings:** export `HTTP_PROXY`/`HTTPS_PROXY` if your corporate network requires them; configure Docker to use the proxy as well.
- **Hosts file entries:** reserve space to map custom tenant domains (e.g., `beworking.local`) once the services are running.
- **Security tooling:** ensure any endpoint protection software allows Docker virtualization and local web servers.

### 1.6 Verification Checklist

Run the following commands; all should succeed before moving on:

```bash
git --version
node -v
npm -v   # or pnpm -v
java -version
./mvnw -v            # run inside beworking-backend-java once cloned
docker --version
docker compose version
```

Document any deviations (e.g., different OS) so future troubleshooting can account for them.

## 2. Repository Layout

The Beworking stack lives across four repositories that expect to sit next to each other on disk. Clone them under a common parent directory so relative paths in scripts and documentation remain valid.

```
~/Coding/
└── Coding_Projects/
    └── 20-Multi_tenant/
        └── beworking_tenant/
            ├── beworking-orchestration/   # central docs, docker-compose, infra helpers
            ├── beworking-backend-java/    # Spring Boot services
            ├── beworking-frontend/        # React client app
            └── beworking-dashboard/       # Admin/analytics dashboard
```

### 2.1 Cloning Strategy

1. Create the parent directory if it does not already exist:

   ```bash
   mkdir -p ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant
   cd ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant
   ```

2. Clone each repository using SSH (preferred) or HTTPS:

   ```bash
   git clone git@github.com:<org>/beworking-orchestration.git
   git clone git@github.com:<org>/beworking-backend-java.git
   git clone git@github.com:<org>/beworking-frontend.git
   git clone git@github.com:<org>/beworking-dashboard.git
   ```

3. Verify the folder structure matches the tree above before moving on.

> Hint: if you need to work with forks, keep the same directory names locally so scripts and relative imports continue to work.

### 2.2 Cross-Repo Dependencies

- **Orchestration repo** hosts shared documentation, docker-compose definitions, and environment scripts consumed by the other projects.
- **Backend Java** exposes REST APIs, consumes messaging queues, and publishes events. Environment variables and database schemas defined here are referenced by the frontend and dashboard.
- **Frontend** expects the backend to run on `http://localhost:8080` by default; adjust `.env.local` if you change ports.
- **Dashboard** may rely on the same backend endpoints or dedicated analytics services; confirm the base URL and credentials during configuration.

Keep repos updated together—pull changes across all four before starting work so contracts stay aligned.

### 2.3 Submodules & Shared Assets

Currently no Git submodules are defined. If you add shared libraries later, place them under `beworking-orchestration` and document the linking strategy here.

### 2.4 Branching & Worktrees (Optional)

If you regularly work on features spanning multiple repos, consider creating matching branch names in each repository and using `git worktree` to manage parallel checkouts. Document team conventions (branch naming, PR links) in this section if they differ from the default.

## 3. Environment Configuration

All services rely on environment variables for database access, third-party integrations, and tenant-specific behaviour. Configure them before starting any applications.

### 3.1 Central Dotenv Files

The orchestration repo includes sample env files under `beworking-orchestration/env/` (create the folder if it does not exist). Copy the templates to local overrides:

```bash
cd beworking-orchestration
mkdir -p env
cp env/.env.sample env/.env.local   # if template exists; otherwise create from table below
```

Use `.env.local` for developer-specific values. Do not commit personal env files.

### 3.2 Shared Variables

| Variable | Description | Consumed By | Example |
| --- | --- | --- | --- |
| `TENANT_DOMAIN` | Base domain used for local routing and emails. | Backend, Frontend, Dashboard | `beworking.local` |
| `ENVIRONMENT` | Environment label for logging/metrics. | All services | `local` |
| `LOG_LEVEL` | Default log level. | Backend | `INFO` |

### 3.3 Backend Java (`beworking-backend-java`)

Create `beworking-backend-java/.env.local` or export variables through your IDE run configuration. The Spring Boot app reads from `application-local.yaml` and environment variables.

| Variable | Purpose | Notes |
| --- | --- | --- |
| `SPRING_PROFILES_ACTIVE` | Activates the `local` profile. | Set to `local`. |
| `DATABASE_URL` | JDBC connection string for the tenant database. | e.g. `jdbc:postgresql://localhost:5432/beworking_dev`. |
| `DATABASE_USERNAME` / `DATABASE_PASSWORD` | Credentials for the local database user. | Create a dedicated `beworking_local` user. |
| `JWT_SECRET` | Symmetric key for signing tokens. | Use a strong random string; never commit. |
| `EMAIL_PROVIDER_API_KEY` | Key for transactional email service. | Request from ops; store in secrets manager. |
| `HUBSPOT_TOKEN` | HubSpot sandbox access token. | Needed for lead sync listeners. |
| `REDIS_URL` (if applicable) | Cache/message broker endpoint. | Optional; depends on feature flags. |

Add any feature flags or integration URLs discovered during development. Keep the table updated as new services appear.

### 3.4 Frontend (`beworking-frontend`)

The React app reads environment variables prefixed with `REACT_APP_` from `.env.local`.

| Variable | Description | Example |
| --- | --- | --- |
| `REACT_APP_API_BASE_URL` | Points to the backend REST API. | `http://localhost:8080` |
| `REACT_APP_HUBSPOT_PORTAL_ID` | Optional HubSpot portal identifier if embedding widgets. | `999999` |
| `REACT_APP_FEATURE_FLAGS` | JSON string enabling optional UI features. | `{ "mailbox": true }` |

After editing `.env.local`, restart the dev server so variables take effect.

### 3.5 Dashboard (`beworking-dashboard`)

Configure environment variables in `.env.local`. Adjust names to match the framework (Next.js, Vite, etc.).

| Variable | Description |
| --- | --- |
| `VITE_API_BASE_URL` or `NEXT_PUBLIC_API_URL` | Backend endpoint used by the dashboard. |
| `DASHBOARD_AUTH_CLIENT_ID` | OAuth/Keycloak client id if the dashboard uses SSO. |
| `ANALYTICS_WRITE_KEY` | Segment/Amplitude key if analytics dashboards push events. |

### 3.6 Secrets Management

- Store sensitive values (tokens, passwords) in a secrets manager (1Password, Vault) and share them through secure channels only.
- For production environments, integrate with the organisation-approved secrets manager (e.g., AWS Secrets Manager, HashiCorp Vault) and grant least-privilege access through IAM roles or service accounts. Document the lookup paths so operations can audit them.
- Do not commit `.env.local` or secrets to Git. Ensure `.gitignore` covers these files.
- For CI/CD pipelines, coordinate with DevOps to inject secrets via environment variables or secret stores.

### 3.7 Environment Sync Checklist

1. Create or update `.env.local` files in each repository.
2. Run `git status` to verify no secret files are staged.
3. Share any new variable requirements with the team via the orchestration docs to keep everyone aligned.

Document deviations (e.g., alternative database host) at the bottom of this section so others can reproduce your setup.
