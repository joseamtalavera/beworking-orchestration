# BeWorking

Multi-tenant workspace management platform for coworking spaces. Handles bookings, invoicing, contacts, mailroom, and payments.

## Architecture

```text
                         ┌──────────────┐
                         │    Nginx     │ :80
                         │ reverse proxy│
                         └──────┬───────┘
                ┌───────────────┼───────────────────┐
                │               │                   │
        /api/*  │    /*         │   /dashboard/*    │  /booking/*
                │               │                   │
        ┌───────▼──┐   ┌───────▼──┐   ┌───────────▼┐   ┌──────────┐
        │ Backend  │   │ Frontend │   │  Dashboard  │   │ Booking  │
        │ Java     │   │ Next.js  │   │  Vite+React │   │ Next.js  │
        │ :8080    │   │ :3000    │   │  :5173      │   │ :4173    │
        └────┬─────┘   └──────────┘   └──────┬──────┘   └────┬─────┘
             │                                │               │
             │                         /payments/*            │
             │                                │               │
        ┌────▼─────┐                  ┌───────▼──┐            │
        │PostgreSQL│                  │  Stripe  │◄───────────┘
        │  :5432   │                  │  Service │
        └──────────┘                  │  :8081   │
                                      └──────────┘
```

## Services

| Service | Tech | Port | Repository |
| ------- | ---- | ---- | ---------- |
| Backend | Spring Boot 3.4, Java 17 | 8080 | `../beworking-backend-java` |
| Frontend | Next.js 15, React 19 | 3000 | `../beworking-frontend` |
| Dashboard | Vite, React 19, MUI 7 | 5173 | `../beworking-dashboard` |
| Booking | Next.js 15, Zustand | 4173 | `../beworking-booking` |
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
├── beworking-frontend/
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
| Frontend | http://localhost:3020 |
| Dashboard | http://localhost:5173 |
| Booking | http://localhost:4173 |
| Backend API | http://localhost:8080/api/health |
| Swagger UI | http://localhost:8080/swagger-ui.html |
| Stripe Service | http://localhost:8081/api/health |

## Documentation

See [docs/](docs/) for detailed documentation:

- [Database Schema](docs/database/schema.md)
- [Deployment & Operations](docs/deployment/ops-runbook.md)
- [Business Processes](docs/processes/) (registration, login, leads, HubSpot, mailbox)

## Deployment

Production runs on AWS ECS Fargate (eu-north-1) with RDS PostgreSQL and ECR.

CI/CD via GitHub Actions — push to `main` triggers build, push, and deploy for each service.

See [Ops Runbook](docs/deployment/ops-runbook.md) for details.

## Auth

JWT-based authentication with httpOnly cookies:

- Access token: 15 minutes (`beworking_access`)
- Refresh token: 7 days (`beworking_refresh`)
- Refresh endpoint: `POST /api/auth/refresh`
- Cookie `secure` flag configurable via `APP_SECURITY_COOKIE_SECURE`
