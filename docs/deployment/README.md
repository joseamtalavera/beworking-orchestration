# Deployment

All services run on AWS ECS Fargate (eu-north-1) with RDS PostgreSQL and ECR.

CI/CD via GitHub Actions — push to `main` triggers build, push, and deploy.

## Runbook

See [ops-runbook.md](ops-runbook.md) for:

- ECS service deployment
- Secrets management (AWS Secrets Manager)
- RDS connectivity
- Troubleshooting
