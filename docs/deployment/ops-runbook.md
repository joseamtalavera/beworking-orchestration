# Ops Runbook (ECS + S3/CloudFront)

This runbook documents the manual deployment flow for the backend (ECS/Fargate) and the landing site (S3 + CloudFront). Use it when deploying without CI/CD.

## Prerequisites
- AWS CLI v2 configured for `eu-north-1`
- Docker installed and running
- Node.js + npm for the landing build

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

## Landing: S3 + CloudFront

### 1) Build the static export
From `beworking-landing-ov`:
```bash
npm ci
npm run build
```
The export output is `out/`.

### 2) Sync to S3
```bash
AWS_REGION=eu-north-1
BUCKET=<TODO-beworking-landing-bucket>
aws s3 sync ./out s3://$BUCKET/ --delete
```

### 3) Invalidate CloudFront cache
```bash
DISTRIBUTION_ID=<TODO-cloudfront-distribution-id>
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
```

### 4) Verify
```bash
curl -I https://oficinavirtual.be-working.com
```

## One-Time Setup References
- Backend ECS setup: `backend-aws.md`
- Landing S3/CloudFront setup: `../beworking-landing-ov/docs/S3-deployment.md`

## TODO / Assumptions
- TODO: confirm S3 bucket name for landing static assets.
- TODO: confirm CloudFront distribution ID.
