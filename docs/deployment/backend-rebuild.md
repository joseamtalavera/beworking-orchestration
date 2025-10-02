# Backend Rebuild & Deployment Workflow
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this guide when you need to refresh local Docker containers or rebuild/publish the backend image for AWS ECS. It captures the safe commands and when to run them so you avoid unnecessary rebuilds.

---

## 1. Local Development (docker-compose)

### 1.1 When **not** to rebuild
- **Do _not_ run `./mvnw clean package -DskipTests`** for:
  - Editing `application.properties` or other config files (mounted volume reloads automatically).
  - Java code tweaks (Spring Boot DevTools hot-reloads).
  - Most dependency updates (restart container instead).

### 1.2 Clean rebuild workflow
Run this sequence only when you change `docker-compose.yml`, Dockerfiles, or need a fresh image.

1. Stop containers
   ```bash
   docker-compose down
   ```
2. Remove project images (optional but keeps things tidy)
   ```bash
   docker rmi $(docker images "beworking-orchestration*" -q) -f
   ```
3. Prune dangling layers & volumes
   ```bash
   docker system prune -f
   docker volume prune -f
   ```
4. Rebuild & start everything
   ```bash
   docker-compose up --build
   ```
5. Verify containers
   ```bash
   docker ps
   ```

After this, you are running freshly rebuilt containers based on the latest Dockerfiles.

---

## 2. Production Build & Deployment (AWS ECS)

### 2.1 Build & push image to ECR
From `beworking-backend-java`:
```bash
./mvnw clean package -DskipTests
aws ecr get-login-password --region eu-north-1 \
| docker login --username AWS --password-stdin 905418223611.dkr.ecr.eu-north-1.amazonaws.com

docker build -t beworking-core:main .
docker tag beworking-core:main 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main
docker push 905418223611.dkr.ecr.eu-north-1.amazonaws.com/beworking-core:main
```

### 2.2 Register new task definition revision
Ensure `task-def.json` references the latest image and secrets, then register:
```bash
aws ecs register-task-definition \
  --cli-input-json file://task-def.json \
  --region eu-north-1
```
The response returns the new revision (e.g., `beworking-backend-task:8`).

### 2.3 Update ECS service
```bash
aws ecs update-service \
  --cluster beworking-cluster \
  --service beworking-backend-task-service-v2xrc5id \
  --task-definition beworking-backend-task:<latest_revision> \
  --force-new-deployment \
  --region eu-north-1
```
This stops the old task and starts a new one with the latest image and secrets.

### 2.4 Verify
1. **Check deployment status** (AWS Console → ECS service events).
2. **Confirm running tasks use the new revision**:
   ```bash
   aws ecs list-task-definitions --family-prefix beworking-backend-task --sort DESC | head -1
   aws ecs list-tasks --cluster beworking-cluster --service-name beworking-backend-task-service-v2xrc5id
   aws ecs describe-tasks --cluster beworking-cluster --tasks <TASK_ARN>
   ```
   Review `taskDefinitionArn` and `containers[].image`.
3. **Fetch logs**:
   ```bash
   aws logs get-log-events \
     --log-group-name /ecs/beworking-backend-task \
     --log-stream-name ecs/beworking-backend/<stream-id> \
     --region eu-north-1 \
     --limit 50
   ```
4. Hit the ALB `/actuator/health` endpoint to confirm service health.

> Optional helper: to print just the image URI of the first running task use `jq`:
> ```bash
> aws ecs describe-tasks \
>   --cluster beworking-cluster \
>   --tasks $(aws ecs list-tasks --cluster beworking-cluster --service-name beworking-backend-task-service-v2xrc5id --query 'taskArns[0]' --output text) \
>   | jq -r '.tasks[0].containers[0].image'
> ```

---

## 3. Quick Reference
| Environment | Key Command(s) |
| --- | --- |
| Local (no rebuild) | DevTools reloads; skip `./mvnw clean package -DskipTests` |
| Local (full rebuild) | `docker-compose down` → prune → `docker-compose up --build` |
| Prod build | `./mvnw clean package -DskipTests` + Docker build/tag/push |
| Prod deploy | `aws ecs register-task-definition …` → `aws ecs update-service …` |

Keep this playbook updated whenever the Docker or ECS workflow changes.
