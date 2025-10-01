# Frontend Installation
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Steps for running the `beworking-frontend` React application locally.

## 1. Clone & Install Dependencies
```bash
cd ~/Coding/Coding_Projects/20-Multi_tenant/beworking_tenant
git clone git@github.com:<org>/beworking-frontend.git   # skip if already cloned
cd beworking-frontend
```
Install packages with your preferred package manager:
```bash
npm install
# or
pnpm install
```
Ensure Node.js 20.x is active (`node -v`). If you use `nvm`, run `nvm use 20` in this directory.

## 2. Configure Environment
Create `.env.local` based on team defaults or the template provided:
```bash
cp .env.example .env.local   # adjust filename as needed
```
Populate the variables referenced in the [general setup](general-setup.md#34-frontend-beworking-frontend), especially:
```
REACT_APP_API_BASE_URL=http://localhost:8080
REACT_APP_FEATURE_FLAGS={"mailbox": true}
```
Restart the dev server whenever `.env.local` changes.

## 3. Run the Development Server
Start the React app in watch mode:
```bash
npm start
# or
pnpm start
```
By default the app serves on `http://localhost:3000`. The CLI will auto-open a browser tab; otherwise, navigate manually.

## 4. Verify Connectivity
- Confirm the login or registration page loads without console errors.
- Attempt a registration or login flow; ensure API requests hit `http://localhost:8080`. Use the browser dev tools Network panel to verify HTTP 200 responses from the backend.

## 5. Testing & Linting
Run unit tests and lint checks to validate the setup:
```bash
npm test
npm run lint
```
(Replace with `pnpm` equivalents if applicable.)

## 6. Common Issues
- **CORS errors:** confirm the backend has local CORS support enabled and `REACT_APP_API_BASE_URL` matches the running backend URL.
- **Port conflicts:** change the port via `PORT=3001 npm start` or update `.env.local`.
- **Dependency errors:** delete `node_modules` and `package-lock.json`/`pnpm-lock.yaml`, then reinstall.

Document component-specific commands (storybook, Cypress, etc.) as they become available.
