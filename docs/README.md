# BeWorking Orchestration Docs

This folder is the documentation hub for the BeWorking stack (backend, landing site, and supporting services).

## Quick Links
- Ops runbook (ECS + S3/CloudFront): `deployment/ops-runbook.md`
- Architecture overview: `architecture/overview.md`
- API docs: `api/README.md`
- Database schema: `database/schema.md`
- Setup guides: `installation/README.md`
- Security checklist: `security/README.md`
- Testing guides: `testing/README.md`

## Process Docs
- Registration: `processes/registration/README.md`
- Login: `processes/login/README.md`
- Mailbox: `processes/mailbox/README.md`
- Lead intake: `processes/leads/README.md`
- HubSpot sync: `processes/hubspot-integration/README.md`

## Diagrams
- Keep Draw.io sources in `diagrams/draw.<process>.txt`.
- Export `.png`/`.svg` snapshots next to the source and reference them from process docs.

## Updating Docs
1. Update the relevant markdown in-place.
2. Add diagram source + export if the workflow changes.
3. Keep docs and code changes in the same PR when possible.
