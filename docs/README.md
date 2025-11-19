# Beworking Orchestration Documentation

This folder centralises product and technical documentation that spans the frontend, backend, and orchestration services. Use it as the jump-off point for understanding key end-to-end flows and the diagrams that support them.

## 📚 Documentation Overview

For a complete guide to our documentation strategy, see [Comprehensive Documentation Plan](COMPREHENSIVE_DOCUMENTATION_PLAN.md).

## Structure
- `api/` – Complete API documentation with OpenAPI/Swagger specifications
- `architecture/` – System architecture, components, and design patterns
- `components/` – Detailed documentation for each module and component
- `database/` – Database schema, migrations, and entity relationships
- `development/` – Development guides, coding standards, and workflows
- `processes/` – narrative documentation for each business or technical process.
- `diagrams/` – source files (`.drawio`) and lightweight exports (`.png`/`.svg`) referenced from the process docs.
- `installation/` – end-to-end setup guides for local, QA, or production environments.
- `security/` – authentication hardening checklists and security best practices.
- `seo/` – search engine optimisation playbooks and frontend guidance.
- `testing/` – unit, integration, contract, and E2E testing playbooks.
- `deployment/` – infrastructure runbooks and CI/CD workflows.
- `troubleshooting/` – Common issues, error codes, and solutions

## Process Index
| Process | Summary | Notes |
| --- | --- | --- |
| Registration | User onboarding from submission through verification. | [Docs](processes/registration/README.md) |
| Login | Authentication path, including MFA and session lifecycle. | [Docs](processes/login/README.md) |
| Mailbox | In-app messaging/mailbox handling flow. | [Docs](processes/mailbox/README.md) |
| Lead Intake | Capture inbound leads and trigger follow-up listeners. | [Docs](processes/leads/README.md) |
| HubSpot Integration | Sync leads to HubSpot with retries and monitoring. | [Docs](processes/hubspot-integration/README.md) |

## Adding Or Updating Content
1. Create or update the relevant `processes/<process>/README.md` file with the narrative and decisions.
2. Place the Draw.io source as `docs/diagrams/draw.<process>.txt` so it keeps the original XML format and name.
3. Export a snapshot (`.png` or `.svg`) alongside the source and reference it from the process README.
4. Commit both the documentation and diagrams together so the history stays aligned.

See [Working with Draw.io](WORKING_WITH_DRAWIO.md) for CLI tips and automation options.

## Installation Guides
| Environment | Notes |
| --- | --- |
| Local Dev | [Setup](installation/README.md) |

## Security Guides
| Topic | Notes |
| --- | --- |
| Authentication Hardening | [Checklist](security/README.md) |

## SEO Guides
| Topic | Notes |
| --- | --- |
| Frontend SEO | [Playbook](seo/README.md) |

## Testing Guides
| Topic | Notes |
| --- | --- |
| Backend & End-to-End Testing | [Playbook](testing/README.md) |
| Frontend Jest Setup | [Guide](testing/frontend-jest.md) |

## API Documentation
| Topic | Notes |
| --- | --- |
| API Overview | [Complete API Reference](api/README.md) |
| Authentication APIs | [Auth Endpoints](api/authentication.md) |
| Booking APIs | [Booking Endpoints](api/bookings.md) |
| Interactive Swagger UI | Available at `http://localhost:8080/swagger-ui.html` when backend is running |

## Architecture Documentation
| Topic | Notes |
| --- | --- |
| System Overview | [Architecture Overview](architecture/overview.md) |
| Components | [Component Architecture](architecture/components.md) |
| Data Flow | [Data Flow Diagrams](architecture/data-flow.md) |

## Database Documentation
| Topic | Notes |
| --- | --- |
| Database Schema | [Complete Schema Reference](database/schema.md) |
| Migrations | [Migration History](database/migrations/) |

## Development Guides
| Topic | Notes |
| --- | --- |
| Coding Standards | [Code Style and Documentation Guidelines](development/coding-standards.md) |
| Setup Guide | [Development Setup](installation/README.md) |

## Deployment Guides
| Topic | Notes |
| --- | --- |
| Backend on AWS ECS | [Runbook](deployment/backend-aws.md) |
| Application Profiles | [Runbook](deployment/application-properties.md) |
| AWS Secrets Manager | [Setup](deployment/aws-secrets-manager.md) |
| ECS Secrets (DDBB, JWT, HubSpot) | [Process](deployment/ecs-secrets-ddbb-integration.md) |
| Backend Rebuild Workflow | [Guide](deployment/backend-rebuild.md) |
| RDS Connectivity Checklist | [Guide](deployment/rds-connectivity-checklist.md) |
| Frontend Docker Workflow | [Guide](deployment/frontend-docker.md) |
| Backend Docker Workflow | [Guide](deployment/backend-docker.md) |
