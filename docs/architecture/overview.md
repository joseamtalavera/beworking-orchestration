# BeWorking Architecture Overview

## System Architecture

BeWorking is a multi-tenant workspace management platform with the following components:

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend Layer                        │
├─────────────────┬─────────────────┬──────────────────────────┤
│  Main Frontend  │    Dashboard    │      Booking App         │
│   (Next.js)     │    (Vite/React) │     (Vite/React)         │
└────────┬────────┴────────┬────────┴──────────┬───────────────┘
         │                 │                   │
         └─────────────────┴───────────────────┘
                           │
         ┌─────────────────▼───────────────────┐
         │      Backend API (Spring Boot)       │
         │  ┌────────────────────────────────┐ │
         │  │  Authentication & Authorization │ │
         │  │  JWT, Spring Security           │ │
         │  └────────────────────────────────┘ │
         │  ┌────────────────────────────────┐ │
         │  │  Business Logic Services        │ │
         │  │  - Bookings                    │ │
         │  │  - Contacts                    │ │
         │  │  - Invoices                    │ │
         │  │  - Leads                       │ │
         │  │  - Mailroom                    │ │
         │  └────────────────────────────────┘ │
         └─────────────────┬───────────────────┘
                           │
         ┌─────────────────▼───────────────────┐
         │      Database Layer (PostgreSQL)    │
         │  - Multi-tenant schema (beworking)   │
         │  - Flyway migrations                 │
         └─────────────────┬───────────────────┘
                           │
         ┌─────────────────▼───────────────────┐
         │      External Services              │
         │  - HubSpot (CRM integration)         │
         │  - Stripe (Payments)                │
         │  - Email (SMTP)                      │
         └─────────────────────────────────────┘
```

## Technology Stack

### Backend
- **Framework**: Spring Boot 3.4.5
- **Language**: Java 17
- **Database**: PostgreSQL 14+
- **Migrations**: Flyway
- **Security**: Spring Security + JWT
- **Build**: Maven

### Frontend
- **Main Site**: Next.js
- **Dashboard**: Vite + React + Material UI
- **Booking**: Vite + React + Material UI

### Infrastructure
- **Containerization**: Docker
- **Cloud**: AWS (ECS Fargate, RDS, ECR)
- **Load Balancer**: Application Load Balancer

## Key Architectural Patterns

### 1. Multi-Tenancy
- Schema-based multi-tenancy using PostgreSQL
- Tenant isolation at database level
- Tenant context passed via JWT claims

### 2. RESTful API Design
- Resource-based URLs
- Stateless authentication
- Standard HTTP methods and status codes

### 3. Service Layer Pattern
- Controllers handle HTTP concerns
- Services contain business logic
- Repositories handle data access

### 4. Event-Driven Components
- Spring Events for async processing
- HubSpot sync listeners
- Email notification listeners

## Data Flow

### Authentication Flow
```
User → Frontend → POST /api/auth/login
                → Backend validates credentials
                → Returns JWT token
                → Frontend stores token
                → Subsequent requests include token
```

### Booking Flow
```
User → Frontend → POST /api/bookings
                → Backend validates request
                → Checks availability
                → Creates reservation
                → Returns confirmation
```

### Lead Capture Flow
```
Visitor → Frontend → POST /api/leads
                    → Backend creates lead
                    → Triggers event
                    → HubSpot sync listener
                    → Email notification
```

## Security Architecture

### Authentication
- JWT-based stateless authentication
- Token expiration and refresh
- Role-based access control (ADMIN, USER)

### Authorization
- Endpoint-level security
- Method-level security annotations
- Tenant-scoped data access

### Data Protection
- Password hashing (BCrypt)
- SQL injection prevention (JPA)
- XSS protection (input sanitization)
- CORS configuration

## Scalability Considerations

### Horizontal Scaling
- Stateless backend (JWT)
- Database connection pooling
- Load balancer distribution

### Performance
- Database indexing
- Query optimization
- Caching strategies (future)

### Monitoring
- Health check endpoints
- Logging and error tracking
- Performance metrics

## Deployment Architecture

### Development
- Local PostgreSQL
- Docker containers
- Hot reload enabled

### Production
- AWS ECS Fargate
- RDS PostgreSQL
- ECR for container images
- Application Load Balancer
- Secrets Manager for credentials

## Future Enhancements

- [ ] Redis caching layer
- [ ] WebSocket for real-time updates
- [ ] Microservices migration (if needed)
- [ ] GraphQL API option
- [ ] Event sourcing for audit trail


