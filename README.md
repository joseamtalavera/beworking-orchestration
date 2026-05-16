# BeWorking

Multi-tenant workspace management platform for coworking spaces. Handles bookings, invoicing, contacts, mailroom, and payments.

## Architecture

```text
                         ┌──────────────┐
                         │    Nginx     │ :80
                         │ reverse proxy│
                         └──────┬───────┘
          ┌──────────┬─────────┼──────────────┐
          │          │         │              │
   /api/* │    /*    │  /dashboard/*    /payments/*
          │          │         │              │
   ┌──────▼───┐ ┌────▼────┐ ┌──▼────────┐ ┌───▼──────┐
   │ Backend  │ │ Booking │ │ Dashboard │ │  Stripe  │
   │ Java     │ │ Next.js │ │ Vite+React│ │  Service │
   │ :8080    │ │ :4173   │ │ :5173     │ │  :8081   │
   └────┬─────┘ └─────────┘ └───────────┘ └──────────┘
        │
   ┌────▼─────┐
   │PostgreSQL│
   │  :5432   │
   └──────────┘
```

`beworking-frontend` is archived (ECS service deleted); the booking app is now the primary site served at `/`.

## Services

| Service | Tech | Port | Repository |
| ------- | ---- | ---- | ---------- |
| Backend | Spring Boot 3.4, Java 17 | 8080 | `../beworking-backend-java` |
| Booking (primary site) | Next.js 15, Zustand | 4173 | `../beworking-booking` |
| Dashboard | Vite, React 19, MUI 7 | 5173 | `../beworking-dashboard` |
| Stripe Service | FastAPI, Python 3.11 | 8081 | `../beworking-stripe-service` |
| Database | PostgreSQL 13 | 5432 | `../db` |

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 20+ (for running services standalone)
- Java 17 (for backend standalone)
- Python 3.11 (for stripe service standalone)

### 1. Clone repositories

All repos should be siblings under the same parent directory:

```text
beworking_tenant/
├── beworking-orchestration/   (this repo)
├── beworking-backend-java/
├── beworking-dashboard/
├── beworking-booking/
├── beworking-stripe-service/
├── db/
└── packages/
```

### 2. Configure environment

Generate a JWT secret and set required variables:

```bash
# Generate JWT secret
openssl rand -base64 48

# Set in your shell (or create .env in this directory)
export JWT_SECRET=<generated-secret>
export MAIL_USERNAME=your_email@gmail.com
export MAIL_PASSWORD=your_app_password
export TURNSTILE_SECRET=your_turnstile_secret
```

Each service also has a `.env.example` — see individual repos for service-specific variables.

### 3. Start the stack

```bash
docker-compose up
```

### 4. Verify

| Service | URL |
| ------- | --- |
| Booking (primary site) | http://localhost:4173 |
| Dashboard | http://localhost:5173 |
| Backend API | http://localhost:8080/api/health |
| Swagger UI | http://localhost:8080/swagger-ui.html |
| Stripe Service | http://localhost:8081/api/health |

## Documentation

See [docs/](docs/) for detailed documentation:

- [SDLC Framework](docs/sdlc/README.md) — standard lifecycle model for BeWorking & future projects
- [Database Schema](docs/database/schema.md)
- [Deployment & Operations](docs/deployment/ops-runbook.md)
- [QA Staging Handoff](docs/deployment/qa-staging-handoff.md)
- [Business Processes](docs/processes/) (registration, login, leads, HubSpot, mailbox)

## Deployment

Production runs on AWS ECS Fargate (eu-north-1) with RDS PostgreSQL and ECR.

Production domains:

- `be-working.com` — booking app (primary site)
- `app.be-working.com` — dashboard + API
- `stripe.be-working.com` — stripe-service

CI/CD via GitHub Actions — push to `main` triggers build, push, and deploy for each service. Workflow: push to `staging` first, verify, then ff-merge to `main` for release.

See [Ops Runbook](docs/deployment/ops-runbook.md) for details.

## Auth

JWT-based authentication with httpOnly cookies:

- Access token: 15 minutes (`beworking_access`)
- Refresh token: 7 days (`beworking_refresh`)
- Refresh endpoint: `POST /api/auth/refresh`
- Cookie `secure` flag configurable via `APP_SECURITY_COOKIE_SECURE`
