# Backend Docker Hot Reload

- **Owner:** _TBD_
- **Last updated:** 2025-10-01

This guide walks through enabling Spring Boot DevTools hot reload while running `beworking-backend-java` inside Docker. Follow each step in order.

## Step 1 — Ensure DevTools Dependency

Confirm `spring-boot-devtools` is declared in `pom.xml` and is *not* marked optional:
```

<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-devtools</artifactId>
  <scope>runtime</scope>
</dependency>
```

Removing `<optional>true</optional>` guarantees DevTools stays on the container classpath.

## Step 2 — Enable DevTools Settings

1. Verify your compose file launches the backend with `command: ./mvnw spring-boot:run` (or an equivalent entrypoint) so DevTools loads.

2. Create or edit `src/main/resources/application.properties` and enable LiveReload:

   ```properties
   spring.devtools.livereload.enabled=true
   ```
  
   A minimal example for local development:
  
   ```properties
   spring.datasource.url=${SPRING_DATASOURCE_URL}
   spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
   spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}
   spring.datasource.driver-class-name=org.postgresql.Driver
   spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
   spring.jpa.hibernate.ddl-auto=${SPRING_JPA_HIBERNATE_DDL_AUTO}
   spring.jpa.properties.hibernate.default_schema=beworking
   spring.application.name=java
   spring.devtools.livereload.enabled=true
   ```

## Step 3 — Mount the Maven Cache

Add the Maven cache to your compose service so dependencies persist between runs:

```yaml
services:
  beworking-backend:
    volumes:
      - ../beworking-backend-java:/app
      - ~/.m2:/root/.m2   # Windows: %USERPROFILE%/.m2
```

Keep the project source volume to allow DevTools to watch file changes.

## Step 4 — Provide a Dev Dockerfile

Create `beworking-backend-java/Dockerfile.dev`:

```dockerfile
FROM maven:3.9.9-eclipse-temurin-17-alpine
WORKDIR /app
COPY pom.xml mvnw ./
COPY .mvn .mvn/
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B
EXPOSE 8080
CMD ["./mvnw", "-Dspring.devtools.restart.enabled=true", "spring-boot:run"]
```

Point your compose service to this Dockerfile:

```yaml
services:
  beworking-backend:
    build:
      context: ../beworking-backend-java
      dockerfile: Dockerfile.dev
    command: ./mvnw spring-boot:run
    volumes:
      - ../beworking-backend-java:/app
      - ~/.m2:/root/.m2
```

## Step 5 — Rebuild and Start Containers

```bash
docker compose down
docker compose up --build
```

Use `docker-compose` if your tooling requires the hyphenated binary.

## Step 6 — Verify the Running Process

Ensure the container is executing Maven rather than a packaged JAR:

```bash
docker compose exec beworking-backend ps aux
```

Look for an entry starting with `./mvnw`.

## Step 7 — Trigger a Hot Reload

1. Modify a Java source file or resource locally.

2. Compile on the host to emit fresh class files:

   ```bash
   ./mvnw compile
   ```

3. Follow the container logs:

   ```bash
   docker compose logs -f beworking-backend
   ```
  
   You should see messages such as `Restarting due to changed files` or `[restartedMain]`.

## Step 8 — Lifecycle Summary

| Step | What happens |
| --- | --- |
| Edit file locally | Source updates on host filesystem |
| Save file | Docker volume syncs into `/app` inside container |
| Container sees new source | `/app/src/...` reflects the edit |
| DevTools watches change | Detects Java/resource updates |
| Host compiles (`./mvnw compile`) | Outputs new `.class` files in `target/classes` |
| DevTools detects classpath change | Triggers soft restart |
| Spring context restarts | Beans/controllers reinitialise, DB connections refreshed |
| New code served | Subsequent HTTP requests use updated implementation |

Use a full rebuild (`docker compose up --build`) if you change dependencies or Docker configuration.
