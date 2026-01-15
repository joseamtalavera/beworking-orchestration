
# BeWorking Orchestration

This repository is the documentation and deployment hub for the BeWorking stack. Code lives in sibling folders (backend, landing, dashboards), while this root hosts docs, runbooks, and ECS task definitions.

## Start Here
- Documentation index: `docs/README.md`
- Ops runbook (ECS + S3/CloudFront): `docs/deployment/ops-runbook.md`
- Backend entrypoint: `../beworking-backend-java/src/main/java/com/beworking/JavaApplication.java`
- Landing entrypoint: `../beworking-landing-ov/pages/index.js`

## Local Dev (Stack)
See `docker-compose.yml` for the docker-compose dev setup (backend, frontend, dashboard, Postgres).

For codebase-specific READMEs:
- Backend: `../beworking-backend-java/README.md`
- Landing: `../beworking-landing-ov/README.md`
