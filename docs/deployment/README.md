# Deployment Docs

This folder collects deployment runbooks for the BeWorking stack. Use the ops runbook for day-to-day releases and the detailed guides for one-time setup or deep dives.

## Start Here
- Ops runbook (ECS + S3/CloudFront): `ops-runbook.md`
- Backend deployment on ECS: `backend-aws.md`
- Backend rebuild workflow: `backend-rebuild.md`
- RDS connectivity checklist: `rds-connectivity-checklist.md`

## Frontend (Landing) Deployment
The landing site is a static Next.js export deployed to S3 + CloudFront. The detailed setup lives here:
- `../beworking-landing-ov/docs/S3-deployment.md`

## Secrets & Config
- Application profiles: `application-properties.md`
- ECS secrets integration: `ecs-secrets-ddbb-integration.md`
- AWS Secrets Manager: `aws-secrets-manager.md`
