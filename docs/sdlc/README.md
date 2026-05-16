# SDLC Framework

- **Owner:** Jose AM Talavera
- **Last updated:** 2026-05-16

## Purpose

This is the **standard software development lifecycle model** for BeWorking and
every future project. It defines the layers a system passes through — from the
business *why* down to the users who generate value — and the order in which
those layers are decided, built, and validated.

Use it two ways:

1. **As a method** — when starting any new project, copy [`TEMPLATE.md`](TEMPLATE.md)
   and fill the eight layers top-down. That is the line we follow.
2. **As a reference** — each layer has its own doc (links below) with the
   questions to answer, artifacts to produce, and a definition of done.

[`beworking.md`](beworking.md) is this framework instantiated for the current
BeWorking platform — a worked example of the template filled in.

## The Layered Model

```
┌────────────────────────────────────────────────────────────┐
│                    BUSINESS LAYER                         │
│------------------------------------------------------------│
│ • Vision                                                   │
│ • Product Strategy                                         │
│ • Requirements Engineering                                 │
│ • Stakeholders                                              │
│ • Governance / Compliance                                  │
│ • Project Management                                       │
└────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                  ARCHITECTURE LAYER                       │
│------------------------------------------------------------│
│ • System Design                                            │
│ • Microservices / Monolith                                 │
│ • Domain Modeling                                          │
│ • API Design                                                │
│ • Integration Strategy                                     │
│ • Scalability Decisions                                    │
│ • Security Design                                          │
│ • Data Architecture                                        │
│ • AI / Agent Architecture                                  │
└────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                 ENGINEERING LAYER                         │
│------------------------------------------------------------│
│ • Frontend Development                                     │
│ • Backend Development                                      │
│ • Database Engineering                                     │
│ • AI Engineering                                           │
│ • DevOps Engineering                                       │
│ • Automation                                               │
│ • Integrations                                             │
└────────────────────────────────────────────────────────────┘
             │                    │                    │
             ▼                    ▼                    ▼

┌──────────────────┐   ┌────────────────────┐   ┌──────────────────┐
│ SECURITY LAYER   │   │ TESTING & QA LAYER │   │ DATA & AI LAYER  │
│------------------│   │--------------------│   │------------------│
│ IAM              │   │ Unit Testing       │   │ Databases        │
│ Encryption       │   │ Integration Tests  │   │ Analytics        │
│ Cybersecurity    │   │ E2E Testing        │   │ AI Agents        │
│ Privacy          │   │ Performance Tests  │   │ Machine Learning │
│ Risk Mgmt        │   │ Security Testing   │   │ Automation       │
└──────────────────┘   │ QA Automation      │   │ Knowledge Layer  │
                       └────────────────────┘   └──────────────────┘
             │                    │                    │
             └────────────────────┴────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│             INFRASTRUCTURE & OPERATIONS                   │
│------------------------------------------------------------│
│ • Cloud Infrastructure                                     │
│ • Docker / Kubernetes                                      │
│ • Networking                                               │
│ • CI/CD                                                    │
│ • Monitoring / Logging                                     │
│ • Scalability                                              │
│ • Reliability / Backups                                    │
│ • Observability                                            │
└────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                  HUMAN INTERACTION                        │
│------------------------------------------------------------│
│ • UI                                                       │
│ • UX                                                       │
│ • Accessibility                                            │
│ • Customer Experience                                      │
│ • Mobile / Web Interaction                                 │
└────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────┐
│                         USERS                              │
└────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

| Layer | Defines | Doc |
|-------|---------|-----|
| Business | the **WHY** | [01-business-layer.md](01-business-layer.md) |
| Architecture | the **STRUCTURE** | [02-architecture-layer.md](02-architecture-layer.md) |
| Engineering | builds the **SYSTEM** | [03-engineering-layer.md](03-engineering-layer.md) |
| Security | protects the **SYSTEM** | [04-security-layer.md](04-security-layer.md) |
| Testing & QA | validates the **SYSTEM** | [05-testing-qa-layer.md](05-testing-qa-layer.md) |
| Data & AI | gives **INTELLIGENCE** | [06-data-ai-layer.md](06-data-ai-layer.md) |
| Infrastructure | runs the **SYSTEM** | [07-infrastructure-ops-layer.md](07-infrastructure-ops-layer.md) |
| Human Interaction | connects the **HUMAN** | [08-human-interaction-layer.md](08-human-interaction-layer.md) |
| Users | generate **VALUE** | — |

## The Lifecycle Loop

The model is not a one-shot waterfall. It is a loop: users generate feedback,
feedback becomes new requirements, and the cycle repeats.

```
VISION
  ↓
REQUIREMENTS
  ↓
ARCHITECTURE
  ↓
ENGINEERING
  ↓
AI + DATA + SECURITY
  ↓
INFRASTRUCTURE
  ↓
USERS
  ↓
FEEDBACK
  ↓
NEW REQUIREMENTS
  ↓
(loop)
```

## How to Use for a New Project

1. Copy [`TEMPLATE.md`](TEMPLATE.md) to `docs/sdlc/<project>.md`.
2. Fill the layers **top-down** — you cannot decide Architecture before Business
   is clear, nor Engineering before Architecture.
3. Treat each layer's *Definition of Done* as a gate before moving down.
4. After release, capture feedback and re-enter at REQUIREMENTS — keep the doc
   alive, bump *Last updated*.

## Index

- [TEMPLATE.md](TEMPLATE.md) — blank per-project skeleton
- [beworking.md](beworking.md) — framework instantiated for BeWorking
- Layer docs: [Business](01-business-layer.md) ·
  [Architecture](02-architecture-layer.md) ·
  [Engineering](03-engineering-layer.md) ·
  [Security](04-security-layer.md) ·
  [Testing & QA](05-testing-qa-layer.md) ·
  [Data & AI](06-data-ai-layer.md) ·
  [Infrastructure & Ops](07-infrastructure-ops-layer.md) ·
  [Human Interaction](08-human-interaction-layer.md)
