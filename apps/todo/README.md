# Todo starter

Production-ready starter monorepo for a small Todo app.

This directory exists to provide a realistic, deployable demo application for the infrastructure work in this repository. The app is intentionally small so platform, deployment, and operations concerns can evolve independently from business logic.

## Application Disclaimer

The application in this directory was generated entirely using AI.

I intentionally have not reviewed, refactored, or optimized the application code. The application itself is not the focus of this repository.

Its sole purpose is to provide a realistic demo application for building, deploying, and operating cloud infrastructure.

The focus of this repository is the surrounding infrastructure, including:

- Docker
- Terraform
- AWS architecture
- Networking
- ECS
- CI/CD
- IAM
- Deployment strategies
- Observability
- Scaling
- Security

The application is intentionally kept simple so the infrastructure can evolve independently without spending time implementing business logic.

## Purpose

Use this directory as a small but realistic demo application for:

- local container orchestration
- image builds
- infrastructure provisioning
- deployment workflows
- health and readiness checks
- observability and scaling experiments

## Stack

- Frontend: React, TypeScript, Vite, React Router, TanStack Query
- Backend: Node.js, TypeScript, Fastify, Prisma, Zod
- Database: PostgreSQL
- Shared package: TypeScript types, Zod schemas, constants
- Tooling: npm workspaces, ESLint, Prettier, Docker Compose

## Structure

```text
apps/todo/
  frontend/
    public/
    src/
  backend/
    prisma/
    src/
  shared/
    src/
  docker-compose.yml
```

## Run with Docker Compose

From `apps/todo`:

```bash
docker compose up
```

Compose starts PostgreSQL, runs Prisma migrations as a one-off container, then starts backend and frontend.

Services:

- Frontend: http://localhost:3000
- Backend API: http://localhost:3001
- PostgreSQL: localhost:5432

Health endpoints:

- `GET /health`
- `GET /ready`

`/ready` verifies the backend can reach PostgreSQL before reporting ready.

## Environment variables

### Backend

Defined in `backend/.env.example`.

- `DATABASE_URL` - PostgreSQL connection string for local development and Docker Compose
- `DB_SECRET_ARN` - ECS only, RDS-managed secret ARN read by the backend task role
- `DB_HOST` - ECS only, private RDS endpoint
- `DB_PORT` - ECS only, private RDS port
- `DB_NAME` - ECS only, PostgreSQL database name
- `HOST` - backend bind address
- `PORT` - backend port
- `CORS_ORIGIN` - allowed browser origin list, comma-separated
- `TRUST_PROXY` - trust `X-Forwarded-*` headers from a reverse proxy or ALB
- `SHUTDOWN_TIMEOUT_MS` - max time allowed for graceful shutdown before forced exit

### Frontend

Defined in `frontend/.env.example`.

- `VITE_API_URL` - backend base URL used by the browser

The frontend container reads `VITE_API_URL` at runtime, so the same image can be reused across environments without rebuilding.

## Local development without Docker

Install dependencies:

```bash
npm install
```

### Backend

1. Start PostgreSQL.
2. Copy `backend/.env.example` to `backend/.env` and update values if needed.
3. Run Prisma generation and migrations:

```bash
npm run prisma:generate --workspace @todo/backend
npm run prisma:migrate:deploy --workspace @todo/backend
```

4. Start backend:

```bash
npm run dev --workspace @todo/backend
```

Local development uses `DATABASE_URL` directly.

### Frontend

1. Copy `frontend/.env.example` to `frontend/.env`.
2. Start frontend:

```bash
npm run dev --workspace @todo/frontend
```

## Scripts

```bash
npm run build
npm run lint
npm run format
```

## API

### Health

- `GET /health` -> liveness endpoint, always `200 { "status": "ok" }` while process is alive
- `GET /ready` -> readiness endpoint, `200 { "status": "ok" }` only when the app is accepting traffic and database connectivity is ready

### Todos

- `GET /todos`
- `GET /todos/:id`
- `POST /todos`
- `PUT /todos/:id`
- `DELETE /todos/:id`

## Docker notes

- Backend image: multi-stage Node build, non-root runtime user, stateless container startup, graceful shutdown support
- Frontend image: multi-stage Vite build served by NGINX with runtime config injection
- Compose waits for PostgreSQL health, runs migrations as a separate one-off container, then starts backend and frontend
- On ECS, the backend uses its task role to read the RDS-managed secret from Secrets Manager and constructs the Prisma connection URL in memory
- This lab uses the RDS-managed master credential to keep the scope focused on ECS, private networking, IAM task roles, Secrets Manager, and RDS integration. A production system should use a separate restricted application database role.
- For ECS/production, run Prisma migrations as a separate deploy step before new tasks receive traffic

## ECS Fargate Prisma migration flow

Terraform defines a one-off migration task:

- `aws_ecs_task_definition.backend_migration`
- same backend image repo, execution role, and task role as the API task
- same database inputs: `DB_SECRET_ARN`, `DB_HOST`, `DB_PORT`, `DB_NAME`
- no port mappings
- no ALB
- no ECS service
- command: `node backend/dist/scripts/migrate.js`

The migration runner resolves the RDS secret with `resolveDatabaseUrl()`, injects `DATABASE_URL` only into the Prisma child process, forwards stdout/stderr, and exits with Prisma's exit code.

### Recommended deploy order

1. Build and push the backend image.
2. Apply Terraform with `backend_migration_image_tag=<new>` and `backend_image_tag=<current>`.
3. Run `./scripts/run-ecs-migration.sh`.
4. Verify exit code `0`.
5. Apply Terraform with `backend_migration_image_tag=<new>` and `backend_image_tag=<new>`.
6. Wait for backend service stability.

This two-step tag model prevents the backend service from switching to the new image before the migration succeeds.
