# Frontend Testing Setup (Jest + Testing Library)
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this guide to configure Jest and Testing Library in `beworking-frontend`. Follow the steps in order to ensure the unit test suite runs consistently across machines and CI.

---

## 1. Install Dependencies
From the `beworking-frontend` directory:
```bash
npm install --save-dev jest @testing-library/react @testing-library/jest-dom jest-environment-jsdom
```
This pulls in Jest, the React Testing Library helpers, the DOM matchers, and the required JSDOM environment package (Jest no longer bundles it by default).

---

## 2. Update `package.json`
Add a `test` script so tests can run via `npm test`:
```json
"scripts": {
  "dev": "next dev",
  "build": "next build",
  "start": "next start",
  "lint": "next lint",
  "test": "jest"
}
```
Keep existing scripts in place; only append the `test` entry.

---

## 3. Babel Configuration
Create `.babelrc` (or `babel.config.js`) in the project root:
```json
{
  "presets": ["next/babel"]
}
```
This ensures Jest understands Next.js/JSX transpilation.

---

## 4. Jest Configuration
Create `jest.config.js` in the project root:
```js
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
};
```
Optional: point to a setup file for custom matchers or mocks (see next step).

Create `jest.setup.js` alongside the config to register Testing Library matchers:
```js
import '@testing-library/jest-dom/extend-expect';
```

---

## 5. Running Tests
Execute the suite with:
```bash
npm test
```
Jest picks up files under `__tests__/` or any `*.test.(js|jsx|ts|tsx)` by default. Use watch mode (`npm test -- --watch`) during development if desired.

---

## 6. CI Integration (Optional)
Add `npm ci` followed by `npm test` to your CI pipeline before builds or deployments to maintain regression coverage.

Keep this document updated as the frontend testing stack evolves (e.g., adding Cypress, Playwright, or custom Jest transformers).
