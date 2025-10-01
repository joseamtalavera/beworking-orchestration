# Installation & Setup Index

- **Owner:** _TBD_
- **Last updated:** 2025-10-01

Use this index to navigate environment setup instructions for the Beworking tenant platform. Start with the general guide, then follow the component-specific playbooks.

| Guide | Scope | Link |
| --- | --- | --- |
| General Setup | Prerequisites, repo layout, shared env configuration, secrets handling. | [general-setup.md](general-setup.md) |
| Backend Installation | Spring Boot services, migrations, local/dev Docker flow. | [backend.md](backend.md) |
| Database Installation | Postgres provisioning (Docker/native), migrations, maintenance. | [database.md](database.md) |
| Frontend Installation | React client setup, env vars, dev server & testing. | [frontend.md](frontend.md) |
| Dashboard Installation | Analytics/admin app setup, env vars, and troubleshooting. | [dashboard.md](dashboard.md) |
| Backend Docker Hot Reload | Spring Boot DevTools inside Docker for iterative dev. | [backend-hot-reload.md](backend-hot-reload.md) |

## How to Use This Folder

1. Complete everything in **General Setup** first.
2. Provision the **Database** so dependent services have a data store.
3. Bring up the **Backend**, then the **Frontend** and **Dashboard**.
4. Record any environment-specific differences directly in the relevant guide so teammates can reproduce your setup.

Additional environment playbooks (QA, staging, production bootstrap) can live alongside these files—link them here when available.
