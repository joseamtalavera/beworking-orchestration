# Authentication & Security Playbook
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this guide whenever you need to review or reimplement the Beworking authentication stack. Each section captures concrete steps, code snippets, and file references across the Spring Boot backend and React/Next.js frontend.

---

## 1. Password Security

### Current Implementation
- Password hashing handled via Spring's `PasswordEncoder` (BCrypt) in `RegisterService.java`.
- Frontend components (`SigninCard.js`, `ResetPassword.js`) validate inputs with `validateInputs()` but the backend remains authoritative.

### How to Reapply
1. Define a `PasswordEncoder` bean (usually in `SecurityConfig`):
   ```java
   @Bean
   public PasswordEncoder passwordEncoder() {
       return new BCryptPasswordEncoder();
   }
   ```
2. Hash raw passwords before persistence:
   ```java
   // RegisterService.java
   public void register(RegisterRequest request) {
       String hashed = passwordEncoder.encode(request.getPassword());
       User user = new User();
       user.setEmail(request.getEmail());
       user.setPassword(hashed);
       userRepository.save(user);
   }
   ```
3. Align backend validation rules (see Section 6) with frontend UX hints so users receive consistent messaging.

---

## 2. JWT Security

### Current Implementation
- `JWT_SECRET` provided via environment variables (`docker-compose.yml` for local dev, secret manager in production).
- `application.properties` loads the secret with `jwt.secret=${JWT_SECRET}`.
- `JwtUtil.java` injects the secret using `@Value`, signs tokens with HS256, and verifies signatures on all requests.

### How to Reapply
1. Generate a strong secret: `openssl rand -base64 48`.
2. Inject it via environment variables. Example compose snippet:
   ```yaml
   services:
     beworking-backend:
       environment:
         JWT_SECRET: ${JWT_SECRET:-change-me}
   ```
3. Reference it in `application.properties`:
   ```properties
   # application.properties
   # Injected from env; do not hardcode secrets here
   jwt.secret=${JWT_SECRET}
   ```
4. Use the secret in `JwtUtil.java`:
   ```java
   @Component
   public class JwtUtil {
       @Value("${jwt.secret}")
       private String secret;

       private static final SignatureAlgorithm ALG = SignatureAlgorithm.HS256;

       public Key signingKey() {
           return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
       }

       public String generateToken(String username, Map<String, Object> claims) {
           return Jwts.builder()
               .setSubject(username)
               .setClaims(claims)
               .setIssuedAt(new Date())
               .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
               .signWith(signingKey(), ALG)
               .compact();
       }

       public Jws<Claims> parseToken(String token) {
           return Jwts.parserBuilder()
               .setSigningKey(signingKey())
               .build()
               .parseClaimsJws(token);
       }
   }
   ```
5. Ensure the JWT filter verifies signatures using the same key for every request.

---

## 3. Session Management & Token Expiration

### Current Implementation
- Stateless authentication—no server-side sessions.
- `JwtUtil.java` sets a 1-hour lifetime and the JWT library rejects expired tokens automatically.

### How to Reapply
1. Configure the expiration constant:
   ```java
   private static final long EXPIRATION_TIME = 1000 * 60 * 60; // 1 hour
   ```
2. Apply the expiration when generating tokens (see code above).
3. Handle expiration in the filter:
   ```java
   try {
       Jws<Claims> claims = jwtUtil.parseToken(token);
       // proceed with authentication
   } catch (ExpiredJwtException ex) {
       response.sendError(HttpStatus.UNAUTHORIZED.value(), "Token expired");
       return;
   }
   ```
4. Consider refresh tokens if product requirements demand longer sessions.

---

## 4. CORS Configuration

### Current Implementation
- `SecurityConfig` restricts origins to known frontend hosts and only whitelists required methods/headers.

### How to Reapply
1. Declare a `CorsConfigurationSource` bean:
   ```java
   @Bean
   public CorsConfigurationSource corsConfigurationSource() {
       CorsConfiguration config = new CorsConfiguration();
       config.setAllowedOrigins(List.of("http://localhost:3000"));
       config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
       config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
       UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
       source.registerCorsConfiguration("/**", config);
       return source;
   }
   ```
2. Activate it inside the security filter chain:
   ```java
   http.cors(cors -> cors.configurationSource(corsConfigurationSource()));
   ```
3. Update origin lists when adding QA/staging/production domains.

---

## 5. CSRF Protection

### Current Implementation
- CSRF disabled for stateless APIs using Authorization headers.

### How to Reapply
1. Disable CSRF for JWT-only flows:
   ```java
   http.csrf(csrf -> csrf.disable());
   ```
2. If you move to cookie-based auth, enable CSRF and configure a token repository:
   ```java
   http.csrf(csrf -> csrf
       .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse()));
   ```
3. Mark cookies as `HttpOnly`, `Secure`, and set `SameSite` appropriately.

---

## 6. Input Validation & Sanitisation

### Current Implementation
- DTOs annotated with `@NotBlank`, `@Email`, `@Size`.
- Controllers use `@Valid @RequestBody` so Spring automatically returns `400 Bad Request` on invalid payloads.

### How to Reapply
1. Ensure dependencies exist:
   ```xml
   <dependency>
       <groupId>jakarta.validation</groupId>
       <artifactId>jakarta.validation-api</artifactId>
   </dependency>
   <dependency>
       <groupId>org.hibernate.validator</groupId>
       <artifactId>hibernate-validator</artifactId>
   </dependency>
   ```
2. Annotate DTOs:
   ```java
   public class LoginRequest {
       @NotBlank(message = "Email is required")
       @Email(message = "Invalid email format")
       private String email;

       @NotBlank(message = "Password is required")
       private String password;
   }
   ```
3. Enforce validation in controllers:
   ```java
   @PostMapping("/login")
   public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
       // business logic
   }
   ```
4. Optionally add a global exception handler to customise error payloads.

---

## 7. Error Handling & Messaging

### Current Implementation
- Authentication endpoints return generic failure responses to avoid leaking account state.

### How to Reapply
1. Standardise error messages via `@ControllerAdvice`:
   ```java
   @RestControllerAdvice
   public class GlobalExceptionHandler {
       @ExceptionHandler(BadCredentialsException.class)
       public ResponseEntity<ApiError> handleBadCredentials() {
           return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
               .body(new ApiError("Invalid credentials", Instant.now()));
       }
   }
   ```
2. Log detailed errors server-side only (no sensitive data in responses).

---

## 8. Account Enumeration Protections

### Current Implementation
- Forgot-password and register endpoints respond with the same message regardless of email presence.

### How to Reapply
1. Structure password reset handlers like:
   ```java
   @PostMapping("/forgot-password")
   public ResponseEntity<MessageResponse> forgotPassword(@RequestBody ForgotPasswordRequest request) {
       registerService.sendPasswordResetEmail(request.getEmail());
       return ResponseEntity.ok(new MessageResponse("If an account exists, you will receive an email"));
   }
   ```
2. Ensure the service silently returns if the user is not found, while logging internally.

---

## 9. Rate Limiting & Brute Force Protection

### Current Implementation
- Bucket4j filter limits requests per IP on `/api/auth/*` endpoints and returns HTTP 429 when exceeded.

### How to Reapply
1. Add dependency:
   ```xml
   <dependency>
       <groupId>com.github.vladimir-bukhtoyarov.bucket4j</groupId>
       <artifactId>bucket4j-core</artifactId>
       <version>8.8.0</version>
   </dependency>
   ```
2. Implement the filter:
   ```java
   @Component
   public class RateLimitingFilter implements Filter {
       private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

       private Bucket resolveBucket(String ip) {
           return buckets.computeIfAbsent(ip, key -> Bucket4j.builder()
               .addLimit(Bandwidth.classic(5, Refill.greedy(5, Duration.ofMinutes(1))))
               .build());
       }

       @Override
       public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
           throws IOException, ServletException {
           HttpServletRequest httpRequest = (HttpServletRequest) request;
           String ip = httpRequest.getRemoteAddr();
           Bucket bucket = resolveBucket(ip);
           if (bucket.tryConsume(1)) {
               chain.doFilter(request, response);
           } else {
               ((HttpServletResponse) response).sendError(HttpStatus.TOO_MANY_REQUESTS.value(), "Too many requests");
           }
       }
   }
   ```
3. Register it:
   ```java
   @Bean
   public FilterRegistrationBean<RateLimitingFilter> rateLimiter(RateLimitingFilter filter) {
       FilterRegistrationBean<RateLimitingFilter> registration = new FilterRegistrationBean<>(filter);
       registration.setUrlPatterns(List.of("/api/auth/*"));
       registration.setOrder(Ordered.HIGHEST_PRECEDENCE);
       return registration;
   }
   ```

---

## 10. Email Confirmation & Password Reset

### Current Implementation
- Registration generates confirmation tokens with expiry and sends email.
- Forgot-password flow generates reset tokens, sends email, resets password on valid token, then clears token/expiry.

### How to Reapply
1. Extend `User` entity:
   ```java
   private String confirmationToken;
   private Instant confirmationExpiresAt;
   private String resetToken;
   private Instant resetTokenExpiresAt;
   ```
2. Generate tokens in `RegisterService`:
   ```java
   String token = UUID.randomUUID().toString();
   user.setConfirmationToken(token);
   user.setConfirmationExpiresAt(Instant.now().plus(24, ChronoUnit.HOURS));
   emailService.sendConfirmationEmail(user.getEmail(), token);
   ```
3. Confirm token in `AuthController`:
   ```java
   @GetMapping("/confirm")
   public ResponseEntity<String> confirm(@RequestParam String token) {
       registerService.confirmEmail(token);
       return ResponseEntity.ok("Account confirmed");
   }
   ```
4. Reset password similarly, ensuring tokens are single-use and cleared on success.

---

## 11. HTTPS Enforcement

### Current Implementation
- TLS terminated at load balancer/reverse proxy; Spring Security sets HSTS headers.

### How to Reapply
1. Configure HTTPS at infrastructure layer (NGINX, AWS ALB, etc.).
2. Keep HSTS enabled:
   ```java
   http.headers(headers -> headers
       .httpStrictTransportSecurity(hsts -> hsts
           .includeSubDomains(true)
           .maxAgeInSeconds(31536000)
       ));
   ```
3. Document certificate renewal and domain procedures.

---

## 12. Logging & Monitoring

### Current Implementation
- Authentication attempts and failures are logged without exposing secrets.
- Logs shipped to monitoring/alerting platform for anomaly detection.

### How to Reapply
1. Log events with structured data:
   ```java
   log.info("login_attempt user={} success={} ip={}", username, success, request.getRemoteAddr());
   ```
2. Mask sensitive information (no passwords or tokens).
3. Forward logs to centralised storage (ELK, CloudWatch) and configure alerts.

---

## 13. Registration Enumeration Controls

### Current Implementation
- Registration returns generic responses regardless of duplicate email state.

### How to Reapply
1. Catch duplicate email exceptions:
   ```java
   try {
       registerService.register(request);
   } catch (UserAlreadyExistsException ex) {
       return ResponseEntity.status(HttpStatus.OK)
           .body(new MessageResponse("If the email is not registered, we will create an account"));
   }
   ```
2. Provide admin-only tooling to inspect actual conflicts when necessary.

---

## 14. Security Headers

### Current Implementation
- `SecurityConfig` adds standard security headers including HSTS, XSS protection, frame options, and content-type options.

### How to Reapply
Add headers in the filter chain:
```java
http.headers(headers -> headers
    .contentTypeOptions(contentType -> contentType.and())
    .xssProtection(xss -> xss.block(true))
    .frameOptions(frame -> frame.sameOrigin())
    .httpStrictTransportSecurity(hsts -> hsts
        .includeSubDomains(true)
        .maxAgeInSeconds(31536000)
    )
);
```
Add Content-Security-Policy via reverse proxy (NGINX) or additional filters if needed.

---

## 15. Dependency Hygiene & Continuous Hardening

### Current Implementation
- Regular dependency updates (Spring Boot, JWT libs, Bucket4j, frontend packages).
- Security reviews ensure only necessary endpoints are public, JWT handling is correct, errors are generic, and scans (Dependabot, OWASP Dependency-Check, OWASP ZAP) run periodically.

### How to Reapply
1. Enable automated dependency scanners.
2. Review `SecurityConfig` to ensure only expected endpoints use `permitAll()`.
3. Test token generation/verification after library upgrades.
4. Run security scans (ZAP/Burp) before releases and fix findings.
5. Maintain HTTPS enforcement and log monitoring.

---

## Quick Reference Table
| Area | Key Files | Action |
| --- | --- | --- |
| Password hashing | `RegisterService.java`, `SecurityConfig.java` | Ensure BCrypt encoder + hashed persistence |
| JWT secret | `docker-compose.yml`, `application.properties`, `JwtUtil.java` | Inject via env/vault, never hardcode |
| Token expiry | `JwtUtil.java`, auth filter | Set expiration constant and handle expiry exceptions |
| Rate limiting | `RateLimitingFilter.java`, `Application.java` | Register Bucket4j filter for `/api/auth/*` |
| Email flows | `AuthController.java`, `RegisterService.java`, `EmailService.java` | Manage tokens, expiry, single use |
| Security headers | `SecurityConfig.java` | Keep header DSL + HSTS enabled |
| Logging | Controllers/services | Log auth events safely |
| HTTPS | Infra configs, `SecurityConfig.java` | Enforce TLS and document cert renewals |

---

## Next Steps & Maintenance
1. Document secret rotation cadence and tooling (AWS Secrets Manager, Vault).
2. Add automated tests for expired token handling, rate limiting, and duplicate registration responses.
3. Schedule recurring security scans and penetration tests.
4. Extend monitoring dashboards with auth metrics (login success/failure, 429 counts).

Update this playbook whenever security controls change so future engineers can reproduce the configuration without guesswork.
