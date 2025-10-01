# Database Installation
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this guide to provision the local tenant database used by the backend and dashboard services.

## 1. Choose a Provisioning Method
You can run Postgres in Docker, use a local Postgres installation, or connect to a shared development instance. Docker is recommended for isolation.

### 1.1 Docker Compose (preferred)
1. In `beworking-orchestration`, define a `postgres` service inside `docker-compose.yml`:
   ```yaml
   postgres:
     image: postgres:15
     restart: unless-stopped
     environment:
       POSTGRES_DB: beworking_dev
       POSTGRES_USER: beworking_local
       POSTGRES_PASSWORD: beworking_local_password
     ports:
       - "5432:5432"
     volumes:
       - pgdata:/var/lib/postgresql/data
   ```
2. Start the service:
   ```bash
   docker compose up -d postgres
   ```
3. Verify health:
   ```bash
   docker compose logs -f postgres
   ```

### 1.2 Standalone Docker Container
If you prefer a one-off container:
```bash
docker run --name beworking-postgres \
  -e POSTGRES_DB=beworking_dev \
  -e POSTGRES_USER=beworking_local \
  -e POSTGRES_PASSWORD=beworking_local_password \
  -p 5432:5432 -d postgres:15
```
Use `docker stop beworking-postgres` and `docker rm beworking-postgres` when you need to recycle it.

### 1.3 Native Installation
Install Postgres 15 via Homebrew (`brew install postgresql@15`) or your OS package manager. Create the database and user manually:
```bash
createuser beworking_local --createdb --pwprompt
createdb beworking_dev -O beworking_local
```
Remember to update `pg_hba.conf` if remote access is needed.

## 2. Apply Migrations
Run Flyway migrations from the backend project:
```bash
cd ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant/beworking-backend-java
./mvnw -pl service -am flyway:migrate
```
Confirm the `flyway_schema_history` table exists and shows the latest version.

## 3. Seed Data (Optional)
If the project provides seeders, run them now so smoke tests have reference data:
```bash
./mvnw -pl service -am exec:java -Dexec.mainClass=com.beworking.seed.SeedRunner
```
Alternatively, restore a snapshot SQL dump via `psql < dump.sql`.

## 4. Connection Verification
Use `psql` or a GUI client (TablePlus, DBeaver) to confirm connectivity:
```bash
psql postgresql://beworking_local:beworking_local_password@localhost:5432/beworking_dev -c "SELECT COUNT(*) FROM information_schema.tables;"
```

## 5. Maintenance
- **Backups:** periodically dump data if you rely on seeded content (`pg_dump beworking_dev > backup.sql`).
- **Reset environment:** drop and recreate the DB when migrations diverge (`dropdb beworking_dev && createdb beworking_dev`).
- **Storage cleanup:** remove unused Docker volumes with `docker volume rm` or `docker system prune -a --volumes` after confirming nothing critical is stored there.

Document environment-specific overrides (alternative ports, managed cloud DBs) at the bottom of this file so the team stays aligned.
