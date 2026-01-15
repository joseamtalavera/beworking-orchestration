# Backend Deployment – AWS ECS (Fargate)
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

This runbook documents the exact steps we use to deploy the Spring Boot backend to AWS using ECR + ECS Fargate behind an Application Load Balancer. Follow it sequentially when rebuilding or updating the environment.

---

## 1. Containerisation & Push to Amazon ECR

### 1.1 Navigate to Backend Project
```bash
cd beworking-backend-java
```
Ensure `pom.xml` and `Dockerfile` are present in this directory.

### 1.2 Create ECR Repository (once per account/region)
```bash
aws ecr create-repository \
  --repository-name beworking-core \
  --image-scanning-configuration scanOnPush=true \
  --region eu-north-1
```
Adjust repository name/region if needed. The example uses Stockholm (`eu-north-1`).

### 1.3 Authenticate Docker Against ECR
```bash
aws ecr get-login-password --region eu-north-1 \
| docker login --username AWS --password-stdin 905418223611.dkr.ecr.eu-north-1.amazonaws.com
```
Expected output: `Login Succeeded`.

### 1.4 Build the Docker Image
```bash
./mvnw clean package -DskipTests
docker build -t beworking-core:main .
```
The Dockerfile packages the Spring Boot app into a runnable JAR inside an Alpine JRE image.

### 1.5 Tag & Push to ECR
```bash
docker tag beworking-core:main 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main
docker push 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main
```

### 1.6 Verify the Image
```bash
aws ecr describe-images \
  --repository-name beworking-core \
  --region eu-north-1 \
  --query 'imageDetails[].imageTags[]'
```
Expected response includes `"main"`.

---

## 2. ECS Cluster & Roles

### 2.1 Service-Linked Role (only if missing)
```bash
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
```

### 2.2 Create ECS Cluster
- Name: `beworking-cluster`
- Launch type: Fargate
- Monitoring: optional (enable later if required)

### 2.3 Task Execution Role
Create the IAM role:
```bash
aws iam create-role \
  --role-name ecsTaskExecutionRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": { "Service": "ecs-tasks.amazonaws.com" },
        "Action": "sts:AssumeRole"
      }
    ]
  }'
```
Attach the AWS managed policy:
```bash
aws iam attach-role-policy \
  --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

---

## 3. Task Definition

Create a Fargate task family `beworking-backend-task` with:
- CPU / Memory: 0.5 vCPU and 1–3 GB RAM
- Execution role: `ecsTaskExecutionRole`
- Container definition:
  - Name: `beworking-backend`
  - Image: `905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main`
  - Port mapping: `8080/tcp`
  - Logging: CloudWatch Logs enabled

Example JSON snippet:
```json
{
  "family": "beworking-backend-task",
  "networkMode": "awsvpc",
  "executionRoleArn": "arn:aws:iam::905418223611:role/ecsTaskExecutionRole",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "beworking-backend",
      "image": "905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main",
      "portMappings": [ { "containerPort": 8080, "protocol": "tcp" } ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/beworking-backend-task",
          "awslogs-region": "eu-north-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```
Register via console or `aws ecs register-task-definition`.

---

## 4. ECS Service & Networking

### 4.1 Service Configuration
- Service name: `beworking-backend-task-service-v2xrc5id`
- Cluster: `beworking-cluster`
- Task definition: `beworking-backend-task:1`
- Desired tasks: 1 (scale later as needed)
- Launch type: Fargate

### 4.2 Networking Layout
- VPC: default or dedicated VPC
- Subnets: Fargate tasks in **private** subnets for production (initial setup used public subnets for testing)
- Security groups:
  - **ALB SG** allows inbound 80/443 from the internet.
  - **ECS SG** allows inbound 8080 from ALB SG only.
  - **ECS SG** allows outbound 5432 to RDS SG.
- Public IP assignment: disable when tasks live in private subnets behind an ALB.

### 4.3 Load Balancer
- Application Load Balancer (public subnets)
- Listener: HTTP 80 (or HTTPS 443 once ACM cert issued)
- Target group: Fargate tasks on port 8080
- Health check path: `/api/health`

### 4.4 Route53
- Create record: `<TODO-api-domain>` → ALB DNS name (alias record).

> Initial deployment exposed the task via public IP (`13.51.249.97:8080`) for validation. Transition to ALB once DNS and certificates are ready.

---

## 5. Data Layer & Secrets

### 5.1 Database
- Amazon RDS PostgreSQL in private subnets (same VPC).
- Security group allows ingress from ECS task SG on port 5432.
- Migrations executed via application startup or CI job.

### 5.2 Secrets & Configuration
- Store environment variables and secrets in AWS Systems Manager Parameter Store or Secrets Manager.
- Inject values through the ECS task definition (secrets section) rather than baking into the container image.

---

## 6. CORS & Application Hardening
- Spring Boot CORS configuration allows `https://www.be-working.com` (and other trusted origins as needed).
- reCAPTCHA validation on lead forms (backend verifies tokens server-side).
- Bucket4j rate limiting protects authentication endpoints.
- Add Content-Security-Policy headers on the landing/marketing site (front end).

---

## 7. CI/CD Pipelines (GitHub Actions)

### 7.1 Backend Workflow
1. On push to main:
   - Build JAR and Docker image.
   - Push image to ECR (`beworking-core:main`).
   - Run `aws ecs update-service --cluster beworking-cluster --service beworking-backend-task-service-v2xrc5id --force-new-deployment`.

### 7.2 Frontend Workflow (for reference)
1. On push:
   - Build/export static site.
   - Sync to S3 bucket.
   - Invalidate CloudFront distribution for cache refresh.

---

## 8. Observability & Logging
- **CloudWatch Logs** capture container stdout/stderr (`/ecs/beworking-backend-task`).
- **CloudWatch Metrics & Alarms:** monitor CPU utilisation, memory, 5xx responses, and target health.
- Optional: enable CloudFront access logs (if frontend uses CloudFront) and store in S3.
- Consider integrating AWS X-Ray or custom metrics for deeper tracing.

---

## 9. Post-Deployment Validation
1. Confirm ECS task has status `RUNNING` in `beworking-cluster`.
2. Hit `/api/health` via ALB DNS or public IP to confirm 200 status.
3. Exercise `/api/auth/login` with valid credentials (requires DB connectivity/seeding).
4. Inspect CloudWatch logs for warnings/errors.

Known initial results (testing phase):
- Task reachable via `http://13.51.249.97:8080`.
- Root path `/` returns 404 (expected). `/api/auth/login` GET fails (endpoint expects POST). POST returned “Unexpected error” pending database setup/log review.

---

## Checklist Before Production Cutover
- [ ] RDS instance provisioned, migrations applied, and credentials stored in Secrets Manager.
- [ ] ECS service wired to ALB with HTTPS (ACM certificate + Route53 alias).
- [ ] Security groups lock down traffic paths (ALB → ECS, ECS → RDS only).
- [ ] CI pipeline pushing tagged images and updating ECS service on release.
- [ ] CloudWatch alarms configured (CPU, 5xx, health check failures).
- [ ] Runbook updated with any environment-specific overrides.

Keep this document current whenever infrastructure, CI/CD, or application hardening steps change.
