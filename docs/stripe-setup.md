# Stripe Integration (in progress)

End-to-end flow: booking frontend uses Stripe Elements to collect payment; backend must create a PaymentIntent and return the `clientSecret`. Below are the steps for future developers to set up and verify the integration.

## Frontend (beworking-booking)
- Dependencies (already in package.json): `@stripe/stripe-js`, `@stripe/react-stripe-js`.
- Env: set `VITE_STRIPE_PUBLISHABLE_KEY` (e.g., in `.env` or docker compose).
- Flow (BookingFlowPage):
  1) On the payment step, call `POST /api/public/payment-intents` with `{ amount (cents), currency, productName, centerCode, contact? }`.
  2) Receive `{ clientSecret }`, wrap the step in `<Elements clientSecret=... stripe=loadStripe(VITE_STRIPE_PUBLISHABLE_KEY)>`, render `<PaymentElement />`.
  3) “Pay now” calls `stripe.confirmPayment(...)`.
- Pricing: Tarifa is read-only and comes from the selected producto `priceFrom`; Centro/Product are filtered from public lookups.

## Backend (beworking-backend-java)
- Add Stripe SDK to `pom.xml`:
  ```xml
  <dependency>
    <groupId>com.stripe</groupId>
    <artifactId>stripe-java</artifactId>
    <version>24.10.0</version>
  </dependency>
  ```
- Env: set `STRIPE_SECRET_KEY`.
- Endpoint to implement: `POST /api/public/payment-intents`
  - Input: `{ amount: long (cents), currency: string, productName: string, centerCode?: string, contact?: { name, email } }`
  - Logic: `Stripe.apiKey = STRIPE_SECRET_KEY`; create `PaymentIntent` with amount/currency; add metadata (productName, centerCode, contact); return `{ clientSecret }`.
  - Return: `201` or `200` with `{ clientSecret }`.

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
- Frontend wiring: PaymentElement + confirmPayment in place.
- Backend endpoint: **to be implemented** (`/api/public/payment-intents`).
- Booking status update on successful payment: **to be implemented**.
