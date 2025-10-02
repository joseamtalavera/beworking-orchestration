# RDS Connectivity Checklist (ECS → PostgreSQL)
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this checklist whenever you need to confirm the backend ECS tasks can reach the RDS PostgreSQL instance. It captures the key network, credential, and configuration checks.

---

## 1. Network Connectivity
- **VPC:** Ensure ECS service and RDS instance live in the same VPC (or peered VPCs).
- **Subnets:** ECS tasks must run in subnets with network routes to the RDS subnets—prefer private subnets for both.
- **Security groups:**
  - RDS SG allows inbound TCP 5432 from the ECS task security group.
  - ECS SG allows outbound traffic to the RDS SG on port 5432.
- **Public IPs:** If tasks run in public subnets with `assignPublicIp=ENABLED`, verify RDS still accepts connections (recommended: keep both ECS and RDS private with NAT access).

## 2. Database Credentials & JDBC URL
- In the ECS task definition, confirm:
  - `spring.datasource.url=jdbc:postgresql://database-2.c50syq0iyqal.eu-north-1.rds.amazonaws.com:5432/beworking`
  - `spring.datasource.username=postgres`
  - `spring.datasource.password` fetches from Secrets Manager/Parameter Store (or env var).
- Test manually from your machine to the RDS endpoint:
  ```bash
  psql -h database-2.c50syq0iyqal.eu-north-1.rds.amazonaws.com -d beworking -U postgres -p 5432
  ```

## 3. Spring Boot Production Profile
- `application-prod.properties` should contain:
  ```properties
  spring.datasource.url=${DB_URL}
  spring.datasource.username=${DB_USERNAME}
  spring.datasource.password=${DB_PASSWORD}
  spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
  spring.jpa.hibernate.ddl-auto=validate
  ```
- Keep `SPRING_PROFILES_ACTIVE=prod` set in ECS so these values apply.

## 4. IAM Permissions (Secrets Manager / SSM)
- If credentials are stored in Secrets Manager or Parameter Store, ensure `ecsTaskExecutionRole` includes `secretsmanager:GetSecretValue` or equivalent scoped policy (see `ecs-secrets-ddbb-integration.md`).

## 5. RDS Instance Health
- Verify the RDS instance status is **Available** in the AWS console.
- Check `Enhanced monitoring` or `Performance Insights` for connection errors.

## 6. Log Inspection
- Review CloudWatch logs for the backend service:
  - Successful connection shows `HikariPool-1 - Added connection...`.
  - Failures appear as `org.postgresql.util.PSQLException: FATAL` indicating network or credential issues.

---

## Quick AWS CLI Helpers
Check that the RDS SG allows inbound from the ECS SG:
```bash
aws ec2 describe-security-groups \
  --group-ids <RDS_SG_ID> \
  --query 'SecurityGroups[0].IpPermissions'
```
The output should list the ECS security group under `UserIdGroupPairs` with port 5432.

Keep this checklist handy when provisioning new environments or troubleshooting connectivity issues.
