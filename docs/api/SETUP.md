# API Documentation Setup

## Overview

The BeWorking API documentation is automatically generated using SpringDoc OpenAPI (Swagger). This provides interactive API documentation that stays in sync with the code.

## Accessing the Documentation

### Development Environment

1. Start the backend application:
   ```bash
   cd beworking-backend-java
   mvn spring-boot:run
   ```

2. Open your browser and navigate to:
   - **Swagger UI**: `http://localhost:8080/swagger-ui.html`
   - **OpenAPI JSON**: `http://localhost:8080/v3/api-docs`
   - **OpenAPI YAML**: `http://localhost:8080/v3/api-docs.yaml`

### Production Environment

- **Swagger UI**: `https://api.beworking.com/swagger-ui.html`
- **OpenAPI JSON**: `https://api.beworking.com/v3/api-docs`

## Configuration

The OpenAPI configuration is in:
- `beworking-backend-java/src/main/java/com/beworking/config/OpenApiConfig.java`

## Adding API Documentation

### Controller Documentation

Add annotations to your controllers:

```java
@Tag(name = "Bookings", description = "Booking management endpoints")
@RestController
@RequestMapping("/api/bookings")
public class BookingController {
    
    @Operation(
        summary = "List bookings",
        description = "Retrieves a paginated list of bookings with optional filters"
    )
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Successfully retrieved bookings"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Forbidden")
    })
    @GetMapping
    public ResponseEntity<List<BookingResponse>> listBookings(...) {
        // Implementation
    }
}
```

### Request/Response Documentation

Document your DTOs:

```java
@Schema(description = "Request to create a new booking")
public class CreateReservaRequest {
    
    @Schema(description = "Start time of the booking", example = "2025-11-07T10:00:00Z", required = true)
    private LocalDateTime startTime;
    
    @Schema(description = "End time of the booking", example = "2025-11-07T12:00:00Z", required = true)
    private LocalDateTime endTime;
    
    // ... other fields
}
```

## Required Dependencies

The following dependency is already added to `pom.xml`:

```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.6.0</version>
</dependency>
```

## Customization

### Change API Path

Edit `application.properties`:

```properties
springdoc.api-docs.path=/api-docs
springdoc.swagger-ui.path=/swagger-ui.html
```

### Disable in Production

Add to `application-prod.properties`:

```properties
springdoc.api-docs.enabled=false
springdoc.swagger-ui.enabled=false
```

## Exporting Documentation

### Export OpenAPI Spec

```bash
curl http://localhost:8080/v3/api-docs.yaml > docs/api/openapi.yaml
```

### Generate Static Documentation

Use tools like:
- [Redoc](https://github.com/Redocly/redoc) - Generate beautiful static docs
- [Swagger Codegen](https://swagger.io/tools/swagger-codegen/) - Generate client libraries

## Best Practices

1. **Document all endpoints** - Every public endpoint should have `@Operation`
2. **Use meaningful descriptions** - Help developers understand the purpose
3. **Document all parameters** - Use `@Parameter` for complex parameters
4. **Include examples** - Use `@Schema(example = "...")` for request/response examples
5. **Document errors** - Use `@ApiResponse` for all possible error responses
6. **Group related endpoints** - Use `@Tag` to organize endpoints

## Troubleshooting

### Swagger UI not loading
- Check that the backend is running
- Verify the port (default: 8080)
- Check browser console for errors

### Missing endpoints
- Ensure controllers are in the correct package
- Check that `@RestController` annotation is present
- Verify Spring component scanning

### Authentication not working in Swagger UI
- Click "Authorize" button in Swagger UI
- Enter: `Bearer <your-jwt-token>`
- Token format: `Bearer <token>` (include "Bearer " prefix)


