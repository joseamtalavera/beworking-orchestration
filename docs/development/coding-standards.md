# Coding Standards and Documentation Guidelines

## Overview

This document outlines coding standards and documentation requirements for the BeWorking codebase to ensure consistency, maintainability, and comprehensive documentation.

## Code Documentation Standards

### Java (Backend)

#### JavaDoc Requirements
All public classes, methods, and fields must have JavaDoc comments:

```java
/**
 * Service for managing bookings and reservations.
 * 
 * <p>This service handles the business logic for creating, updating,
 * and querying bookings. It ensures tenant isolation and validates
 * booking conflicts.
 * 
 * @author Your Name
 * @since 1.0
 */
@Service
public class BookingService {
    
    /**
     * Creates a new booking reservation.
     * 
     * <p>Validates the booking request, checks for conflicts,
     * and creates a reservation in the database.
     * 
     * @param request The booking creation request
     * @param userId The ID of the user creating the booking
     * @return The created booking response
     * @throws BookingConflictException if the requested time slot is already booked
     * @throws IllegalArgumentException if the request is invalid
     */
    public BookingResponse createBooking(CreateReservaRequest request, Long userId) {
        // Implementation
    }
}
```

#### Required JavaDoc Tags
- `@param` - For all method parameters
- `@return` - For methods that return values
- `@throws` - For all exceptions that can be thrown
- `@since` - Version when the method was added
- `@author` - Author name (optional but recommended)

#### Controller Documentation
All REST controllers should include:
- `@Tag` annotation for API grouping
- `@Operation` for endpoint descriptions
- `@ApiResponse` for response documentation

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

### JavaScript/TypeScript (Frontend)

#### JSDoc Requirements
All exported functions, classes, and components should have JSDoc:

```javascript
/**
 * Fetches bookings from the API with optional filters.
 * 
 * @param {Object} params - Query parameters
 * @param {string} [params.from] - Start date (ISO format)
 * @param {string} [params.to] - End date (ISO format)
 * @param {number} [params.centerId] - Filter by center ID
 * @returns {Promise<BookingResponse[]>} Array of booking responses
 * @throws {Error} If the API request fails
 * 
 * @example
 * const bookings = await fetchBookings({ from: '2025-01-01', to: '2025-01-31' });
 */
export async function fetchBookings(params = {}) {
    // Implementation
}
```

#### React Component Documentation
```javascript
/**
 * Booking list component that displays a paginated list of bookings.
 * 
 * @param {Object} props - Component props
 * @param {Booking[]} props.bookings - Array of bookings to display
 * @param {Function} props.onBookingSelect - Callback when a booking is selected
 * @param {boolean} [props.loading=false] - Loading state
 * 
 * @example
 * <BookingList 
 *   bookings={bookings} 
 *   onBookingSelect={handleSelect}
 *   loading={isLoading}
 * />
 */
export function BookingList({ bookings, onBookingSelect, loading = false }) {
    // Implementation
}
```

## Code Style

### Java
- Follow Google Java Style Guide
- Use 4 spaces for indentation
- Maximum line length: 120 characters
- Use meaningful variable and method names
- Prefer composition over inheritance

### JavaScript/TypeScript
- Use ESLint configuration
- Use 2 spaces for indentation
- Maximum line length: 100 characters
- Use meaningful variable and function names
- Prefer const over let, avoid var

## File Organization

### Backend Structure
```
com.beworking/
├── auth/              # Authentication module
├── bookings/          # Booking module
├── contacts/          # Contact module
├── invoices/          # Invoice module
├── leads/             # Lead module
├── mailroom/          # Mailroom module
└── config/            # Configuration classes
```

### Frontend Structure
```
src/
├── api/               # API client functions
├── components/        # Reusable components
├── pages/             # Page components
├── hooks/             # Custom React hooks
├── store/             # State management
└── utils/             # Utility functions
```

## Naming Conventions

### Java
- **Classes**: PascalCase (`BookingService`)
- **Methods**: camelCase (`createBooking`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_BOOKING_DURATION`)
- **Packages**: lowercase (`com.beworking.bookings`)

### JavaScript/TypeScript
- **Components**: PascalCase (`BookingList`)
- **Functions**: camelCase (`fetchBookings`)
- **Constants**: UPPER_SNAKE_CASE (`API_BASE_URL`)
- **Files**: camelCase for utilities, PascalCase for components

## Testing Documentation

### Unit Tests
- Test file naming: `*Test.java` or `*.test.js`
- Test method naming: `should_ExpectedBehavior_When_StateUnderTest`
- Include comments explaining test scenarios

### Integration Tests
- Document test setup and teardown
- Explain test data requirements
- Document expected behavior

## Documentation Maintenance

### When to Update Documentation
1. **Adding new features**: Document immediately
2. **Changing APIs**: Update API documentation
3. **Refactoring**: Update affected documentation
4. **Bug fixes**: Update if behavior changes

### Documentation Review
- Review documentation during code review
- Ensure examples are up-to-date
- Verify links and references

## Tools and Automation

### JavaDoc Generation
```bash
mvn javadoc:javadoc
```

### API Documentation
- SpringDoc OpenAPI automatically generates Swagger UI
- Access at: `http://localhost:8080/swagger-ui.html`

### Code Quality
- Use IDE plugins for JavaDoc/JSDoc validation
- Configure pre-commit hooks to check documentation
- Include documentation in CI/CD pipeline

## Examples

See the following files for reference:
- `BookingService.java` - Service layer documentation
- `BookingController.java` - Controller documentation
- `fetchBookings.js` - API client documentation
- `BookingList.jsx` - Component documentation


