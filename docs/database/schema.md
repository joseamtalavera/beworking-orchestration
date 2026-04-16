# Database Schema Documentation

## Overview

BeWorking uses PostgreSQL with schema-based multi-tenancy. All tables are in the `beworking` schema.

## Database Information

- **Database**: PostgreSQL 13
- **Schema**: `beworking`
- **Migrations**: Flyway V1–V38 (located in `beworking-backend-java/src/main/resources/db/migration/`)
- **Extensions**: `unaccent` (V16)

## Entity Relationship Diagram

```
┌─────────────┐
│    users     │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────────┐      ┌──────────────┐
│ contact_profiles │      │   bookings   │
└──────┬──────────┘      └──────┬───────┘
       │                        │
       │ N:1                    │ N:1
       │                        │
┌──────▼──────────┐      ┌──────▼───────┐
│    cuentas       │      │   bloqueos   │
└─────────────────┘      └──────────────┘
                                │
                                │ N:1
                                │
                         ┌──────▼──────┐
                         │  productos   │
                         └──────┬──────┘
                                │ N:1
                         ┌──────▼──────┐
                         │   centros    │
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
| avatar | TEXT | User avatar (V2) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### contact_profiles
Stores contact information for tenants and customers.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Contact name |
| email | VARCHAR(255) | Contact email |
| phone | VARCHAR(50) | Contact phone |
| tenant_type | VARCHAR(100) | Type of tenant |
| cuenta_id | BIGINT | FK → cuentas |
| avatar | TEXT | Contact avatar (V3) |
| vat_valid | BOOLEAN | VAT number valid (V17) |
| vat_validated_at | TIMESTAMP | VAT validation date (V17) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### cuentas
Stores account/company information (V13).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| codigo | VARCHAR | Account code |
| nombre | VARCHAR | Account name |
| descripcion | TEXT | Description |
| activo | BOOLEAN | Active status |
| prefijo_factura | VARCHAR | Invoice prefix |
| numero_secuencial | INT | Next invoice sequence number |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### bookings (reservas)
Stores booking reservations.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| start_time | TIMESTAMP | Booking start time |
| end_time | TIMESTAMP | Booking end time |
| status | VARCHAR(50) | Booking status |
| tenant_id | BIGINT | FK → contact_profiles |
| producto_id | BIGINT | FK → productos |
| created_by | BIGINT | FK → users |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### bloqueos
Stores time blocks for availability management.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| start_time | TIMESTAMP | Block start time |
| end_time | TIMESTAMP | Block end time |
| tipo | VARCHAR(50) | Block type |
| estado | VARCHAR(50) | Status (e.g. Invoiced) |
| producto_id | BIGINT | FK → productos |
| tenant_id | BIGINT | FK → contact_profiles |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### productos
Stores products/services (rooms, desks, etc.).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Product name |
| centro_id | BIGINT | FK → centros |
| capacity | INTEGER | Capacity |
| active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

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

## Billing & Invoicing

### facturas (invoices)
Stores invoice information.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| holdedinvoicenum | VARCHAR | Invoice number |
| tenant_id | BIGINT | FK → contact_profiles |
| id_cuenta | BIGINT | FK → cuentas (V13) |
| amount | DECIMAL(10,2) | Invoice amount |
| status | VARCHAR(50) | Invoice status |
| stripeinvoiceid | VARCHAR | Stripe invoice ID (V12) |
| issue_date | DATE | Issue date |
| due_date | DATE | Due date |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### subscriptions
Stores subscription/recurring billing info (V14).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| contact_id | BIGINT | FK → contact_profiles |
| producto_id | BIGINT | FK → productos (V30) |
| stripe_subscription_id | VARCHAR | Stripe sub ID (nullable) |
| stripe_customer_id | VARCHAR | Stripe customer ID |
| monthly_amount | DECIMAL | Monthly charge |
| currency | VARCHAR | Currency code |
| cuenta | VARCHAR | Account code |
| description | TEXT | Description |
| vat_percent | DECIMAL | VAT percentage |
| vat_number | VARCHAR | VAT number (V15) |
| billing_method | VARCHAR | stripe or bank_transfer (V18) |
| billing_interval | VARCHAR | month or year (V34) |
| last_invoiced_month | VARCHAR | Last invoiced period (V18) |
| start_date | DATE | Subscription start |
| end_date | DATE | Subscription end |
| active | BOOLEAN | Active status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### plans
Pricing plans displayed to users (V24).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| plan_key | VARCHAR | Unique key (basic, pro, max) |
| name | VARCHAR | Display name |
| price | DECIMAL | Price |
| currency | VARCHAR | Currency code |
| features | JSONB | Feature list |
| popular | BOOLEAN | Highlighted plan |
| active | BOOLEAN | Active status |
| sort_order | INT | Display order |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### reconciliation_results
Stores billing reconciliation run results (V21).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| run_date | DATE | Reconciliation date |
| account | VARCHAR | Account code |
| db_active | INT | Active subs in DB |
| stripe_active | INT | Active subs in Stripe |
| stripe_past_due | INT | Past-due subs in Stripe |
| past_due_amount | DECIMAL | Total past-due amount |
| missing_invoice_count | INT | Missing invoices count |
| missing_invoices | TEXT | Missing invoice details |
| past_due_subs | TEXT | Past-due sub details |
| db_only_subs | TEXT | Subs in DB only (V37) |
| stripe_only_subs | TEXT | Subs in Stripe only (V37) |
| db_stripe | INT | Stripe billing count (V38) |
| db_bank_transfer | INT | Bank transfer count (V38) |
| created_at | TIMESTAMP | Creation timestamp |

## Room Catalog (V8–V9)

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
| price_unit | VARCHAR | Price unit (V9) |
| centro_code | VARCHAR | Center code (V9) |
| instant_booking | BOOLEAN | Instant booking enabled (V9) |
| tags | TEXT | Tags (V9) |
| hero_image | VARCHAR | Hero image URL (V9) |
| active | BOOLEAN | Active status |
| creation_date | TIMESTAMP | Creation date (V9) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### room_images
Stores images for rooms.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| room_id | BIGINT | FK → rooms |
| url | VARCHAR(500) | Image URL |
| alt_text | VARCHAR(255) | Alt text |
| display_order | INTEGER | Display order |
| created_at | TIMESTAMP | Creation timestamp |

### room_amenities
Stores amenities for rooms.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| room_id | BIGINT | FK → rooms |
| name | VARCHAR(255) | Amenity name |
| icon | VARCHAR(100) | Icon identifier |
| created_at | TIMESTAMP | Creation timestamp |

## Mailroom & Communication

### mailroom_documents
Stores mailroom document records (V2_1, V5, V10).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| contact_email | VARCHAR | Recipient email (V5) |
| document_type | VARCHAR | Type: letter, package (V10) |
| pickup_code | VARCHAR | Unique pickup code (V10) |
| picked_up_at | TIMESTAMP | Pickup timestamp (V10) |
| status | VARCHAR | Current status |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

## AI & Support (V22–V23)

### ai_usage
Tracks AI query usage per tenant (V22).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| tenant_id | BIGINT | Tenant reference |
| queries_used | INT | Queries consumed |
| period_start | DATE | Period start |
| period_end | DATE | Period end |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

### chat_messages
Stores chat conversation messages (V23).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| tenant_id | BIGINT | Tenant reference |
| user_email | VARCHAR | User email |
| role | VARCHAR | Message role (user, assistant) |
| content | TEXT | Message content |
| created_at | TIMESTAMP | Creation timestamp |

### support_tickets
Stores support ticket requests (V23).

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| tenant_id | BIGINT | Tenant reference |
| user_email | VARCHAR | Reporter email |
| subject | VARCHAR | Ticket subject |
| message | TEXT | Ticket message |
| status | VARCHAR | Status (open, closed, etc.) |
| priority | VARCHAR | Priority level |
| admin_notes | TEXT | Internal notes |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

## CRM

### leads
Stores lead information from forms.

| Column | Type | Description |
|--------|------|-------------|
| id | BIGSERIAL | Primary key |
| name | VARCHAR(255) | Lead name |
| email | VARCHAR(255) | Lead email |
| phone | VARCHAR(50) | Lead phone |
| message | TEXT | Lead message |
| hubspot_id | VARCHAR(255) | HubSpot contact ID (V1) |
| hubspot_sync_status | VARCHAR(32) | PENDING, SYNCED, FAILED (V1) |
| hubspot_synced_at | TIMESTAMP | Last sync time (V1) |
| hubspot_error | TEXT | Last error (V1) |
| hubspot_sync_attempts | INT | Attempt count (V1) |
| last_hubspot_attempt_at | TIMESTAMP | Last attempt time (V1) |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Last update timestamp |

## Relationships

### Foreign Key Constraints
- `contact_profiles.cuenta_id` → `cuentas.id`
- `bookings.tenant_id` → `contact_profiles.id`
- `bookings.producto_id` → `productos.id`
- `bookings.created_by` → `users.id`
- `bloqueos.producto_id` → `productos.id`
- `bloqueos.tenant_id` → `contact_profiles.id`
- `productos.centro_id` → `centros.id`
- `facturas.tenant_id` → `contact_profiles.id`
- `facturas.id_cuenta` → `cuentas.id`
- `subscriptions.contact_id` → `contact_profiles.id`
- `subscriptions.producto_id` → `productos.id`
- `room_images.room_id` → `rooms.id`
- `room_amenities.room_id` → `rooms.id`

## Multi-Tenancy

All queries should be scoped to the tenant context. The `beworking` schema provides logical separation, and application code enforces tenant isolation through:
- JWT claims containing tenant information
- Service layer filtering by tenant
- Repository methods that include tenant context

## Backup and Recovery

- Regular automated backups (RDS snapshots in production)
- Point-in-time recovery available
- Migration rollback procedures documented
