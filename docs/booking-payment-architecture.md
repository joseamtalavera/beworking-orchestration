## Booking & Payment Architecture – Backend Plan

### 1. Objectives
- Support multi-step reservation workflow with payment gating (user vs admin initiated).
- Track booking lifecycle (`blocked → confirmed → cancelled`) and payment status (`unpaid → pending → paid/failed`).
- Integrate Stripe for card capture, payment links, and recurring monthly charges.
- Provide APIs consumed by dashboards and new public booking app.

### 2. Data Model Enhancements

#### 2.1 `reservas` table (JPA `Reserva`)
- Add `booking_status` (enum/string) – values: `blocked`, `confirmed`, `cancelled`.
- Add `payment_status` – values: `unpaid`, `pending`, `paid`, `failed`, `refunded`.
- Add `created_by` – values: `user`, `admin`, `visitor`.
- Add `payment_deadline` (TIMESTAMP) for auto-cancellation (24h for admin/visitor flows).
- Add `stripe_customer_id`, `stripe_payment_method_id` (optional for repeat billing).
- Add `billing_cycle` (`once`, `monthly`) and `next_billing_date`.
- Add auditing columns if missing (`cancelled_at`, `confirmed_at`, `cancelled_reason`).

#### 2.2 New table: `reservation_payments`
```
reservation_payments (
  id BIGSERIAL PRIMARY KEY,
  reserva_id BIGINT REFERENCES reservas(id),
  stripe_payment_intent_id TEXT,
  stripe_payment_link_id TEXT,
  amount NUMERIC(10,2),
  currency VARCHAR(3) DEFAULT 'EUR',
  billing_period_start DATE,
  billing_period_end DATE,
  status VARCHAR(20),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
)
```
- Track each charge attempt (initial and recurring).
- Store PaymentIntent or PaymentLink IDs for webhook reconciliation.

#### 2.3 Visitor → Contact sync
- When visitor books, auto-create/attach `contact_profile` record using provided billing data if email not already present.

### 3. Service Layer Changes

#### 3.1 Booking Creation (`BookingService.createReserva`)
1. Validate & generate `Reserva` + `Bloqueo` as today but default to:
   - `bookingStatus = BLOCKED`
   - `paymentStatus = UNPAID`
   - `paymentDeadline = now + paymentWindow`
   - `createdBy` from request (`user`/`admin`/`visitor`)
2. Persist reservation & bloqueos inside transaction.
3. Emit domain event or call `PaymentOrchestrator`:
   - **User initiated**: create Stripe `SetupIntent` (if no payment method) and immediate `PaymentIntent` for current period.
   - **Admin/Visitor**: generate `PaymentLink` (expires in 24h) and store ID/deadline.
4. Return response with payment instructions (client secret, payment link URL, deadline).

#### 3.2 Payment Confirmation
- New `PaymentService.handleSuccess(reservaId, stripePaymentIntentId)` invoked by Stripe webhook:
   - Update `payment_status = PAID`, `booking_status = CONFIRMED`, `confirmed_at = now`.
   - Store payment record; set `next_billing_date` for recurring bookings.
- For monthly recurrence, schedule job to create next PaymentIntent/PaymentLink on `next_billing_date`.

#### 3.3 Payment Failure / Timeout
- Webhook `payment_intent.payment_failed` or scheduler for expired payment links triggers:
   - Update `payment_status = FAILED`, `booking_status = CANCELLED`, set `cancelled_reason`.
   - Release associated bloqueos (delete or mark cancelled).

### 4. Scheduled Jobs
- **Payment deadline watcher** (runs every 5–10 min): cancel reservations where `booking_status = BLOCKED` and `payment_deadline < now`.
- **Monthly billing job** (1st of month 00:05): iterate reservations with `billing_cycle = 'monthly' AND booking_status='CONFIRMED'`, generate payments:
  - For stored payment methods → create PaymentIntent & confirm automatically.
  - For admin-created reservations → create new PaymentLink + notify contact via email.
- Use Spring `@Scheduled` or integration with existing job framework.

### 5. API Endpoints (REST)
- `POST /bookings` (existing): extend request/response to handle payment metadata:
  ```json
  {
    "paymentMode": "user" | "admin" | "visitor",
    "billingCycle": "once" | "monthly",
    "paymentMethodId": "...",   // optional
    "contact": { ... },         // visitor data for auto-registration
    "quote": { "amount": 100, "currency": "EUR" }
  }
  ```
- New `POST /bookings/{id}/payment-link` – regenerate link (admin/visitor).
- New `POST /bookings/{id}/confirm` – internal use from webhooks/service (not public).
- New `POST /bookings/{id}/cancel` – manual cancel.
- `GET /bookings/{id}/payments` – history for dashboards.
- Stripe webhook endpoint `/stripe/webhook` (verify signature; map events).

### 6. Stripe Integration Notes
- Use Stripe API client via dependency (Java SDK).
- Store Stripe keys in environment variables (Docker compose update).
- Entities should persist `stripe_customer_id` per contact/user for re-use.
- Implement idempotency using reservation ID as key when creating PaymentIntents.
- For Payment Links, set metadata (`booking_id`, `contact_id`) for webhook correlation.
- Ensure `payment_deadline` aligns with `expires_at` from Payment Link.

### 7. Email/Notification Hooks
- Notify users/visitors on booking creation (with payment instructions), confirmation, cancellation.
- Could use existing email service or add new event emitter.

### 8. Migration Strategy
- Write Flyway/Liquibase scripts to alter `reservas` and create `reservation_payments`.
- Backfill existing records: mark legacy confirmed reservations as `confirmed/paid`.
- Update DTOs (`BookingResponse`, `CreateReservaRequest`, etc.) to expose new fields.

### 9. Next Steps
1. Agree on database schema changes & create migration scripts.
2. Implement Stripe integration service with configuration & DTOs.
3. Update booking controller/service to produce payment instructions.
4. Add scheduled jobs and webhook controller.
5. Update dashboard/frontend clients to handle new response fields and payment flows.

---
This blueprint aligns backend changes with the new public booking application and admin workflows.
