# Stripe Integration (in progress)

End-to-end flow: booking frontend uses Stripe Elements to collect payment; backend must create a PaymentIntent and return the `clientSecret`. Below are the steps for future developers to set up and verify the integration.

## Step-by-step (current state)
1) Frontend deps installed (beworking-booking `package.json`): `@stripe/stripe-js`, `@stripe/react-stripe-js`.
2) Backend dep added (beworking-backend-java `pom.xml`):
   ```xml
   <dependency>
     <groupId>com.stripe</groupId>
     <artifactId>stripe-java</artifactId>
     <version>24.20.0</version>
   </dependency>
   ```
3) Config placeholders:
   - Backend: add `stripe.secret=${STRIPE_SECRET_KEY:}` to `application.properties` (or profile files) or set env `STRIPE_SECRET_KEY`.
   - Frontend: set `VITE_STRIPE_PUBLISHABLE_KEY` in `.env`/compose.
4) Backend endpoint implemented: `POST /api/public/payment-intents` (`PublicPaymentController`).
   - Request body (`PaymentIntentRequest`): `amount` (cents, Long), `currency`, `productName`, optional `centerCode`, `contactName`, `contactEmail`.
   - Logic: validate amount/currency, set `Stripe.apiKey` from `stripe.secret`, create `PaymentIntent` with metadata, return `{ clientSecret }`.
   - Errors: 400 for bad input, 500 if key missing, 502 on Stripe errors.
5) Restart backend after setting `stripe.secret` so the key loads.
6) Frontend payment UI wiring is pending re-enable: on payment step call the endpoint, wrap with `<Elements clientSecret=... stripe=loadStripe(VITE_STRIPE_PUBLISHABLE_KEY)>`, render `<PaymentElement />`, and call `stripe.confirmPayment(...)`.
7) Orchestration setup (Docker Compose):
   - In `beworking-orchestration`, set `STRIPE_SECRET_KEY=sk_test_...` in a local `.env` (create it if missing; kept out of git).
   - `docker-compose.yml` already passes `STRIPE_SECRET_KEY` to the backend service.
   - Rebuild/restart backend: `docker-compose up -d --build beworking-backend`.

## Deployment / Config
- Backend: `STRIPE_SECRET_KEY`
- Frontend: `VITE_STRIPE_PUBLISHABLE_KEY`
- Restart backend and booking frontend after setting keys.

## Quick Test Plan (once backend endpoint exists)
1) Set both keys, restart services.
2) Go through booking flow to payment step; PaymentElement should render.
3) Use Stripe test card `4242 4242 4242 4242` to pay.
4) Verify PaymentIntent status in Stripe dashboard; update booking status accordingly (to be implemented server-side).

## Status / TODO
- Backend endpoint: implemented (`/api/public/payment-intents`).
- Frontend wiring: PaymentElement + confirmPayment needs to be re-enabled.
- Booking status update on successful payment: **to be implemented**.
