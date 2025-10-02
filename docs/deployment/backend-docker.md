# Backend Docker Workflow (Spring Boot)
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this guide when you want a standalone Docker image for `beworking-backend-java` without relying on docker-compose. It mirrors the current development setup and documents the hot-reload recovery steps.

---

## 1. Dockerfile
Create `beworking-backend-java/Dockerfile` with the following contents:

```dockerfile
# syntax=docker/dockerfile:1
FROM maven:3.9.9-eclipse-temurin-17-alpine AS build
WORKDIR /app

# cache dependencies
COPY pom.xml mvnw ./
COPY .mvn .mvn
RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline -B

# build app
COPY src src
RUN ./mvnw clean package -DskipTests -B

FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

> Optional: add a `.dockerignore` to exclude `target/`, `.idea/`, `.git/`, etc. from the build context.

---

## 2. Build the Image
From `beworking-backend-java`:
```bash
./mvnw clean package -DskipTests
docker build -t beworking-backend-java .
```

---

## 3. Run the Container
```bash
docker run -p 8080:8080 --env-file .env --name beworking-backend beworking-backend-java
```
Ensure `.env` contains the required Spring properties (DB URL, user, password, JWT secret, etc.).

---

## 4. Verify the Service
- Visit `http://localhost:8080` or call specific endpoints with curl/Postman.
- Health check example:
  ```bash
  curl http://localhost:8080/actuator/health
  ```
Use `Ctrl+C` or `docker stop beworking-backend` to stop the container.

---

## 5. Hot Reload (DevTools)
With DevTools enabled and source/target volumes mounted (see compose-based workflow):
1. Edit code locally.
2. Run `./mvnw compile` on the host:
   ```bash
   cd ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant/beworking-backend-java
   ./mvnw compile
   ```
3. The mounted `target/classes` updates inside the container and DevTools restarts automatically. No need to run Maven inside the container.

---

## 6. Recover from Compilation Issues
If hot reload stalls:
```bash
cd ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant/beworking-backend-java
./mvnw clean compile

cd ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant/beworking-orchestration
docker compose restart beworking-backend
```
This rebuilds all classes (e.g., `WebConfig`), synchronises them via the mounted volume, and restarts the container with fresh bytecode.

---

## 7. Clean Docker Space
Prune unused images and volumes to reclaim disk:
```bash
docker system prune -a --volumes
docker system prune -a -f --volumes
```
Use with care—this removes all dangling resources.

Keep this document updated if the Dockerfile or runtime process changes.
