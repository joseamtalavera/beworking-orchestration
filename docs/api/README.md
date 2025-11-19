# API Documentation

Complete API reference for the BeWorking backend services.

## Overview

The BeWorking API is a RESTful API built with Spring Boot. All endpoints require authentication via JWT tokens unless otherwise specified.

## Base URL

- **Development**: `http://localhost:8080`
- **Production**: `https://api.beworking.com` (TBD)

## Authentication

Most endpoints require a JWT token in the `Authorization` header:

```
Authorization: Bearer <your-jwt-token>
```

See [Authentication Documentation](authentication.md) for details.

## API Endpoints

### Authentication
- [Authentication Endpoints](authentication.md) - Login, registration, token management

### Bookings
- [Booking Endpoints](bookings.md) - Create, list, update bookings
- [Blocking Endpoints](bookings.md#blocking) - Manage time blocks

### Contacts
- [Contact Endpoints](contacts.md) - Contact profile management

### Invoices
- [Invoice Endpoints](invoices.md) - Invoice creation and management

### Leads
- [Lead Endpoints](leads.md) - Lead capture and management

### Mailroom
- [Mailroom Endpoints](mailroom.md) - Document management

### Public APIs
- [Public Lookup APIs](bookings.md#public-apis) - Public room catalog and availability

## Interactive API Documentation

For interactive API exploration, use Swagger UI:

- **Development**: `http://localhost:8080/swagger-ui.html`
- **OpenAPI Spec**: `http://localhost:8080/v3/api-docs`

## Response Format

### Success Response
```json
{
  "data": { ... },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "timestamp": "2025-11-07T20:00:00Z"
}
```

## Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

## Rate Limiting

API requests are rate-limited to prevent abuse:
- **Authenticated**: 100 requests per minute
- **Unauthenticated**: 10 requests per minute

## Pagination

List endpoints support pagination:
- `page` - Page number (0-indexed)
- `size` - Items per page (default: 25)
- `sort` - Sort field and direction (e.g., `name,asc`)

## Versioning

Current API version: **v1**

Version is specified in the URL path: `/api/v1/...`

## Support

For API support, contact: [support@beworking.com](mailto:support@beworking.com)


