# Ops Runbook (ECS Fargate)

This runbook documents the manual deployment flow for the backend and supporting services on ECS/Fargate. Use it when deploying without CI/CD.

## Prerequisites
- AWS CLI v2 configured for `eu-north-1`
- Docker installed and running
- Access to ECR registry `905418223611.dkr.ecr.eu-north-1.amazonaws.com`

## Services & Images

| Service | ECR Image | Task Definition | CPU / Memory |
|---------|-----------|-----------------|--------------|
| Backend | `beworking-core:main` | `beworking-backend-task` | 512 / 3 GB |
| Dashboard | `beworking-dashboard:main` | `beworking-dashboard-task` | 256 / 512 MB |
| Booking | `beworking-booking:main` | `beworking-booking-task` | 256 / 512 MB |
| Stripe Service | `beworking-stripe-service:main` | `beworking-stripe-service-task` | 256 / 512 MB |

## Backend: ECS (Fargate)

### 1) Build the Spring Boot JAR
From `beworking-backend-java`:
```bash
./mvnw clean package -DskipTests
```

### 2) Build, tag, and push the Docker image
```bash
docker build -t beworking-core:main .
docker tag beworking-core:main 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main

aws ecr get-login-password --region eu-north-1 \
| docker login --username AWS --password-stdin 905418223611.dkr.ecr.eu-north-1.amazonaws.com

docker push 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main
```

### 3) Register a new ECS task definition
From `beworking-orchestration`:
```bash
aws ecs register-task-definition \
  --cli-input-json file://task-def.json \
  --region eu-north-1
```
Note the revision (e.g., `beworking-backend-task:16`).

### 4) Deploy the new revision
```bash
aws ecs update-service \
  --cluster beworking-cluster \
  --service beworking-backend-task-service-v2xrc5id \
  --task-definition beworking-backend-task:<REVISION> \
  --force-new-deployment \
  --region eu-north-1
```

### 5) Verify
```bash
aws ecs describe-services \
  --cluster beworking-cluster \
  --services beworking-backend-task-service-v2xrc5id \
  --region eu-north-1

curl -i https://oficinavirtual.be-working.com/api/health
```

For logs:
```bash
aws logs tail /ecs/beworking-backend-task --region eu-north-1 --since 30m
```

## Production Domains

| Domain | Purpose |
|--------|---------|
| `be-working.com` / `www.be-working.com` | Primary |
| `app.be-working.com` | App entry |
| `oficinavirtual.be-working.com` | Dashboard |
| `stripe.be-working.com` | Stripe payments |
| `be-spaces.com` / `www.be-spaces.com` | Partner/secondary |

## One-Time Setup References
- Backend ECS setup: `backend-aws.md`
