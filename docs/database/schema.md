# Database Schema Documentation

## Overview

BeWorking uses PostgreSQL with schema-based multi-tenancy. All tables are in the `beworking` schema.

## Database Information

- **Database**: PostgreSQL 14+
- **Schema**: `beworking`
- **Migrations**: Flyway (located in `src/main/resources/db/migration/`)

## Entity Relationship Diagram

```
┌─────────────┐
│    users    │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────────┐      ┌──────────────┐
│ contact_profiles│      │   bookings   │
└──────┬──────────┘      └──────┬───────┘
       │                        │
       │ N:1                    │ N:1
       │                        │
┌──────▼──────────┐      ┌──────▼───────┐
│    cuentas      │      │   bloqueos   │
└─────────────────┘      └──────────────┘
                                │
                                │ N:1
                                │
                         ┌──────▼──────┐
                         │  productos  │
                         └─────────────┘
```

## Core Tables

### users
Stores user accounts for authentication.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| email | VARCHAR(255) | Unique email address |
| password | VARCHAR(255) | BCrypt hashed password |
| role | VARCHAR(50) | User role (ADMIN, USER) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Unique index on `email`

### contact_profiles
Stores contact information for tenants and customers.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Contact name |
| email | VARCHAR(255) | Contact email |
| phone | VARCHAR(50) | Contact phone |
| tenant_type | VARCHAR(100) | Type of tenant |
| cuenta_id | BIGINT | Foreign key to cuentas |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `cuenta_id`
- Index on `email`

### cuentas
Stores account/company information.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Account name |
| active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `active`

### bookings (reservas)
Stores booking reservations.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| start_time | TIMESTAMP | Booking start time |
| end_time | TIMESTAMP | Booking end time |
| status | VARCHAR(50) | Booking status |
| tenant_id | BIGINT | Foreign key to contact_profiles |
| producto_id | BIGINT | Foreign key to productos |
| created_by | BIGINT | Foreign key to users |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `tenant_id`
- Index on `producto_id`
- Index on `start_time`, `end_time` (for availability queries)

### bloqueos
Stores time blocks for availability management.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| start_time | TIMESTAMP | Block start time |
| end_time | TIMESTAMP | Block end time |
| tipo | VARCHAR(50) | Block type |
| producto_id | BIGINT | Foreign key to productos |
| tenant_id | BIGINT | Foreign key to contact_profiles |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `producto_id`
- Index on `start_time`, `end_time`

### productos
Stores products/services (rooms, desks, etc.).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Product name |
| centro_id | BIGINT | Foreign key to centros |
| capacity | INTEGER | Capacity |
| active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `centro_id`
- Index on `active`

### centros
Stores center/location information.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Center name |
| address | VARCHAR(500) | Center address |
| active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `active`

### invoices (facturas)
Stores invoice information.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| invoice_number | VARCHAR(100) | Invoice number |
| tenant_id | BIGINT | Foreign key to contact_profiles |
| amount | DECIMAL(10,2) | Invoice amount |
| status | VARCHAR(50) | Invoice status |
| issue_date | DATE | Issue date |
| due_date | DATE | Due date |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `tenant_id`
- Index on `invoice_number`
- Index on `status`

### leads
Stores lead information from forms.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Lead name |
| email | VARCHAR(255) | Lead email |
| phone | VARCHAR(50) | Lead phone |
| message | TEXT | Lead message |
| hubspot_sync_status | VARCHAR(50) | HubSpot sync status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Index on `email`
- Index on `hubspot_sync_status`

## Room Catalog Tables (V8 Migration)

### rooms
Stores room information for the catalog.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Room name |
| slug | VARCHAR(255) | URL-friendly identifier |
| description | TEXT | Room description |
| capacity | INTEGER | Room capacity |
| price_hourly | DECIMAL(10,2) | Hourly price |
| price_daily | DECIMAL(10,2) | Daily price |
| price_monthly | DECIMAL(10,2) | Monthly price |
| active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

**Indexes:**
- Primary key on `id`
- Unique index on `slug`
- Index on `active`

### room_images
Stores images for rooms.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| room_id | BIGINT | Foreign key to rooms |
| url | VARCHAR(500) | Image URL |
| alt_text | VARCHAR(255) | Alt text |
| display_order | INTEGER | Display order |
| created_at | TIMESTAMP | Creation timestamp |

**Indexes:**
- Primary key on `id`
- Index on `room_id`

### room_amenities
Stores amenities for rooms.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| room_id | BIGINT | Foreign key to rooms |
| name | VARCHAR(255) | Amenity name |
| icon | VARCHAR(100) | Icon identifier |
| created_at | TIMESTAMP | Creation timestamp |

**Indexes:**
- Primary key on `id`
- Index on `room_id`

## Relationships

### Foreign Key Constraints
- `contact_profiles.cuenta_id` → `cuentas.id`
- `bookings.tenant_id` → `contact_profiles.id`
- `bookings.producto_id` → `productos.id`
- `bookings.created_by` → `users.id`
- `bloqueos.producto_id` → `productos.id`
- `bloqueos.tenant_id` → `contact_profiles.id`
- `productos.centro_id` → `centros.id`
- `invoices.tenant_id` → `contact_profiles.id`
- `room_images.room_id` → `rooms.id`
- `room_amenities.room_id` → `rooms.id`

## Multi-Tenancy

All queries should be scoped to the tenant context. The `beworking` schema provides logical separation, and application code enforces tenant isolation through:
- JWT claims containing tenant information
- Service layer filtering by tenant
- Repository methods that include tenant context

## Migrations

Database changes are managed through Flyway migrations:
- Location: `src/main/resources/db/migration/`
- Naming: `V{version}__{description}.sql`
- Example: `V8__create_room_catalog_tables.sql`

See [Migration Documentation](migrations/) for detailed migration history.

## Performance Considerations

### Indexes
- All foreign keys are indexed
- Frequently queried columns have indexes
- Composite indexes for common query patterns

### Query Optimization
- Use EXPLAIN ANALYZE for slow queries
- Monitor query performance
- Consider materialized views for complex reports

## Backup and Recovery

- Regular automated backups (RDS snapshots in production)
- Point-in-time recovery available
- Migration rollback procedures documented


