# Beworking Orchestration Documentation

This folder centralises product and technical documentation that spans the frontend, backend, and orchestration services. Use it as the jump-off point for understanding key end-to-end flows and the diagrams that support them.

## Structure
- `processes/` – narrative documentation for each business or technical process.
- `diagrams/` – source files (`.drawio`) and lightweight exports (`.png`/`.svg`) referenced from the process docs.
- `installation/` – end-to-end setup guides for local, QA, or production environments.
- `security/` – authentication hardening checklists and security best practices.

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
