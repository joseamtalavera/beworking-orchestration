# BeWorking Full Deployment Runbook (ECS Fargate, eu-north-1)

This runbook covers the full BeWorking deployment on AWS ECS Fargate behind an ALB in **Stockholm (eu-north-1)**.
It follows the established backend flow and extends it to the full app stack.

## Services and ECR repositories

- Backend (Spring Boot): `beworking-core`
- Frontend (Next.js): `beworking-frontend`
- Dashboard (Vite): `beworking-dashboard`
- Booking: `beworking-booking`
- Stripe service: `beworking-stripe`

## 1) ECR repositories (create if missing)

```bash
aws ecr create-repository --repository-name beworking-core --image-scanning-configuration scanOnPush=true --region eu-north-1
aws ecr create-repository --repository-name beworking-frontend --image-scanning-configuration scanOnPush=true --region eu-north-1
aws ecr create-repository --repository-name beworking-dashboard --image-scanning-configuration scanOnPush=true --region eu-north-1
aws ecr create-repository --repository-name beworking-booking --image-scanning-configuration scanOnPush=true --region eu-north-1
aws ecr create-repository --repository-name beworking-stripe --image-scanning-configuration scanOnPush=true --region eu-north-1
```

## 2) Docker login to ECR

```bash
aws ecr get-login-password --region eu-north-1 \
| docker login --username AWS --password-stdin 905418223611.dkr.ecr.eu-north-1.amazonaws.com
```

## 3) Build and push images

### Backend

```bash
cd beworking-backend-java
./mvnw clean package -DskipTests
docker build -t beworking-core:main .
docker tag beworking-core:main 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main
docker push 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main
```

### Frontend

```bash
cd ../beworking-frontend
docker build -t beworking-frontend:main .
docker tag beworking-frontend:main 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-frontend:main
docker push 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-frontend:main
```

### Dashboard

```bash
cd ../beworking-dashboard
docker build -t beworking-dashboard:main -f Dockerfile.dev .
docker tag beworking-dashboard:main 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-dashboard:main
docker push 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-dashboard:main
```

### Booking

```bash
cd ../beworking-booking
docker build -t beworking-booking:main .
docker tag beworking-booking:main 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-booking:main
docker push 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-booking:main
```

### Stripe service

```bash
cd ../beworking-stripe-service
docker build -t beworking-stripe:main .
docker tag beworking-stripe:main 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-stripe:main
docker push 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-stripe:main
```

## 4) Secrets Manager

Store secrets in **AWS Secrets Manager** (examples):

- `beworking/jwt_secret`
- `beworking/db_url`
- `beworking/db_user`
- `beworking/db_pass`
- `beworking/turnstile_secret`
- `beworking/stripe_secret`
- `beworking/mail_user`
- `beworking/mail_pass`

Reference these secrets in each task definition.

## 5) ECS task definitions (new revision per service)

For each service:

- Launch type: **Fargate**
- CPU / Memory: per service needs
- Image: ECR image from step 3
- Port mapping:
  - Backend: 8080
  - Frontend: 3000
  - Dashboard: 5173
  - Booking: verify container port
  - Stripe: verify container port
- Logging: CloudWatch
- Environment variables + Secrets: from Secrets Manager

## 6) ECS services

Create or update one ECS Service per app:

- `beworking-backend-service`
- `beworking-frontend-service`
- `beworking-dashboard-service`
- `beworking-booking-service`
- `beworking-stripe-service`

Update each service with the latest task definition revision.

## 7) Load balancer + DNS

Use ALB with target groups + listener rules for each service:

- `api.be-working.com` -> backend (8080)
- `web.be-working.com` -> frontend (3000)
- `superapp.be-working.com` -> dashboard (5173)
- `booking.be-working.com` -> booking (port?)
- `stripe.be-working.com` -> stripe service (port?)

Set Route53 records for the above domains to ALB.

## 8) Health checks and verification

- Backend: `/actuator/health`
- Dashboard: load main route
- Frontend: load main route
- Booking: load main route
- Stripe: check service endpoint

Check CloudWatch logs for errors after deployment.

## 9) Security & hardening

- ECS tasks in private subnets
- RDS in private subnets
- ALB public
- SG rules:
  - ALB -> ECS app ports
  - ECS -> RDS 5432
- CORS allow `https://www.beworking.com`

## 10) CI/CD (GitHub Actions)

- Backend: build -> push to ECR -> update ECS service
- Frontend, Dashboard, Booking, Stripe: build -> push to ECR -> update ECS service

---

Notes:
- Create DNS records at your domain provider pointing to the ALB DNS name.
- Confirm booking and stripe container ports before creating target groups.
