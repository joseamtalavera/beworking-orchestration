# Frontend Docker Workflow (Next.js)
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this recipe to containerise the Next.js frontend, rebuild the image, and verify it locally. The steps below match the configuration we tested.

---

## 1. Dockerfile
Place the following `Dockerfile` at the root of `beworking-frontend`.

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --omit=dev

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/src ./src
COPY --from=builder /app/pages ./pages
COPY --from=builder /app/next.config.mjs ./next.config.mjs
COPY --from=builder /app/jsconfig.json ./jsconfig.json
COPY --from=builder /app/README.md ./README.md

EXPOSE 3000
CMD ["npm", "start"]
```

> Add a `.dockerignore` file to keep build context small (e.g. ignore `.next`, `node_modules`, `coverage`).

---

## 2. Build the Image
Run from the `beworking-frontend` directory:
```bash
docker build -t beworking-frontend:latest .
```

---

## 3. Run the Container
Start the container and map port 3000:
```bash
docker run --rm -p 3000:3000 --name beworking-frontend beworking-frontend:latest
```
If environment variables are required (e.g. `NEXT_PUBLIC_API_URL`), add `-e` flags or mount an `.env.production` file.

---

## 4. Verify
- Open `http://localhost:3000` in a browser to confirm the UI loads.
- Tail logs in the terminal; the app should report `ready - started server on http://0.0.0.0:3000`.

Stop the container with `Ctrl+C` or `docker stop beworking-frontend`.

Keep this workflow handy whenever you need a clean rebuild of the frontend container image.
