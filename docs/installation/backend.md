# Backend Installation

- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Follow these steps to get `beworking-backend-java` running locally with all required services.

## 1. Clone & Verify Tooling

```bash
cd ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant
git clone git@github.com:<org>/beworking-backend-java.git   # skip if already cloned
cd beworking-backend-java
./mvnw --version   # confirm Maven Wrapper is executable
```

If this is the first time running `./mvnw`, it will download Maven 3.9.x and project dependencies; expect a few minutes.

## 2. Configure Environment

1. Copy the sample env file (if present) or create `.env.local` using the variables listed in the [general setup](general-setup.md#3-environment-configuration).

   ```bash
   cp .env.sample .env.local   # adjust if file names differ
   ```

2. On macOS/Linux, you can export key variables before launching:

   ```bash
   export SPRING_PROFILES_ACTIVE=local
   export DATABASE_URL=jdbc:postgresql://localhost:5432/beworking_dev
   export DATABASE_USERNAME=beworking_local
   export DATABASE_PASSWORD=beworking_local_password
   export JWT_SECRET=<replace-with-random>
   export EMAIL_PROVIDER_API_KEY=<provided-by-ops>
   export HUBSPOT_TOKEN=<hubspot-sandbox-token>
   ```

3. On Windows, set the same values through PowerShell or your IDE run configuration (`Run → Edit Configurations…`).

## 3. Database Provisioning

> See also the dedicated [database installation guide](database.md) for shared instructions.

1. Start the local database. If using Docker Compose from `beworking-orchestration`:

   ```bash
   docker compose up -d postgres
   ```

   If no compose service exists, start a standalone container:

   ```bash
   docker run --name beworking-postgres \
     -e POSTGRES_DB=beworking_dev \
     -e POSTGRES_USER=beworking_local \
     -e POSTGRES_PASSWORD=beworking_local_password \
     -p 5432:5432 -d postgres:15
   ```

2. Verify connectivity:

   ```bash
   psql postgresql://beworking_local:beworking_local_password@localhost:5432/beworking_dev -c "SELECT 1;"
   ```

3. Apply database migrations:

   ```bash
   ./mvnw -pl service -am flyway:migrate   # adjust module path if multi-module
   ```

   Check the Flyway table `flyway_schema_history` to confirm migrations succeeded.

## 4. Run the Application

1. Start the backend in development mode:

   ```bash
   ./mvnw spring-boot:run
   ```

   or run from your IDE using the `BeworkingApplication` main class with the `local` profile.

2. Wait for the log message `Started BeworkingApplication` and ensure port `8080` is listening:

   ```bash
   curl http://localhost:8080/actuator/health
   ```

   Expect `"status":"UP"`.

## 5. Seed & Test

1. Seed reference data if the project includes seed scripts:

   ```bash
   ./mvnw -pl service -am exec:java -Dexec.mainClass=com.beworking.seed.SeedRunner
   ```

   (Skip or adjust depending on actual seed tooling.)

2. Execute smoke tests to confirm the basic flows:

   ```bash
   ./mvnw test -Dtest=RegistrationControllerIT
   ```

   Replace with available integration tests.

## 6. Troubleshooting

- **Port already in use:** stop conflicting services (`lsof -i :8080`).
- **Migrations fail:** drop and recreate the database, then rerun Flyway migrations.
- **Missing env vars:** Spring logs the missing property; cross-check `.env.local`.
- **HubSpot/email calls:** mock or disable integrations if sandbox credentials are unavailable; use profile-specific configuration.

Document any project-specific scripts (Gradle tasks, Make targets, npm helpers) here as they evolve.

## 7. Docker Hot-Reload Workflow

See the detailed hot-reload playbook: [backend-hot-reload.md](backend-hot-reload.md).
