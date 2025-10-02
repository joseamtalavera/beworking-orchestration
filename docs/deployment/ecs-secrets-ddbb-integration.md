# ECS Secrets Integration (DDBB, JWT, HubSpot)
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

This runbook captures the full process for wiring database credentials, JWT secrets, and HubSpot tokens into the backend ECS service via AWS Secrets Manager.

---

> **Note:** Replace the placeholder values (`<DB_USERNAME>`, `<DB_PASSWORD>`, etc.) with actual secrets stored locally under `docs/private/`. Never commit real credentials.

## 1. Create Secrets in AWS Secrets Manager
Region: `eu-north-1`.

1. **Database credentials**
   - Name: `beworking-db-credentials`
   - Secret value (key/value JSON):
     ```json
     {
       "username": "<DB_USERNAME>",
       "password": "<DB_PASSWORD>"
     }
     ```

2. **JWT secret**
   - Name: `beworking-jwt-secret`
   - Secret value:
     ```text
     <JWT_SECRET>
     ```

3. **HubSpot API token**
   - Name: `beworking-hubspot-token`
   - Secret value:
     ```text
     <HUBSPOT_API_TOKEN>
     ```

Refer to [aws-secrets-manager.md](aws-secrets-manager.md) for console screenshots and detailed creation steps.

---

## 2. Grant ECS Execution Role Access
Role: `ecsTaskExecutionRole`.

Attach an inline policy allowing the task to retrieve the secrets:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": [
        "arn:aws:secretsmanager:eu-north-1:905418223611:secret:beworking-db-credentials*",
        "arn:aws:secretsmanager:eu-north-1:905418223611:secret:beworking-jwt-secret*",
        "arn:aws:secretsmanager:eu-north-1:905418223611:secret:beworking-hubspot-token*"
      ]
    }
  ]
}
```

---

## 3. Update ECS Task Definition
Task definition family: `beworking-backend-task`.

Create a new revision with:
- **Environment variables**
  - `SPRING_PROFILES_ACTIVE=prod`
  - `DB_URL=jdbc:postgresql://database-2.c50syq0iyqal.eu-north-1.rds.amazonaws.com:5432/mydatabase`
- **Secrets mapping**
  - `DB_USERNAME` ← `beworking-db-credentials.username`
  - `DB_PASSWORD` ← `beworking-db-credentials.password`
  - `JWT_SECRET` ← `beworking-jwt-secret`
  - `HUBSPOT_API_TOKEN` ← `beworking-hubspot-token`
- **Logging**
  - CloudWatch group `/ecs/beworking-backend-task`

Register the revision (sample command):
```bash
aws ecs register-task-definition \
  --cli-input-json file://task-def.json
```

---

## 4. Update ECS Service
Update the running service to use the new task definition:
```bash
aws ecs update-service \
  --cluster beworking-cluster \
  --service beworking-backend-task-service-v2xrc5id \
  --task-definition beworking-backend-task:2 \
  --region eu-north-1
```
ECS will stop the old task and launch a replacement with the new secrets & env vars.

---

## 5. Verification Steps
1. Ensure the ECS deployment reaches steady state (service events tab).
2. Fetch recent logs to confirm startup and DB connectivity:
   ```bash
   aws logs get-log-events \
     --log-group-name /ecs/beworking-backend-task \
     --log-stream-name ecs/beworking-backend/<stream-id> \
     --region eu-north-1 \
     --limit 50
   ```
3. Access `/actuator/health` through the ALB/public IP to verify the service responds.

---

## Checklist
- [ ] Secrets exist in Secrets Manager (DB, JWT, HubSpot).
- [ ] `ecsTaskExecutionRole` has `secretsmanager:GetSecretValue` permission on these ARNs.
- [ ] Task definition maps secrets to environment variables.
- [ ] ECS service runs the latest revision and passes health checks.

Keep this document updated if secrets change names, new secrets are added, or the service pipeline evolves.
