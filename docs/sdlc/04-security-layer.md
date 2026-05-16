# Security Layer

- **Owner:** Jose AM Talavera
- **Last updated:** 2026-05-16

> Protects the **SYSTEM**. Runs in parallel with Testing & QA and Data & AI.

## Purpose

Ensure the built system enforces the trust boundaries and threat model defined
in Architecture, and that risk is identified, contained, and tracked.

## Components

### IAM
- Authentication model (tokens, sessions, expiry/refresh).
- Authorization: role gates **and** object-level ownership checks.
- Per-endpoint auth matrix verified against the architecture spec.
- **Artifact:** authz matrix, verified per role.

### Encryption
- In transit (TLS) and at rest; secret storage (managed vault, never in repo).
- Key rotation policy.
- **Artifact:** encryption + secrets policy.

### Cybersecurity
- SAST, SCA, secret scanning (incl. git history), container/image scan.
- Cloud posture review; endpoint × role authz scan.
- Penetration test scope + rules of engagement (non-destructive, staging,
  authorized — never prod).
- **Artifact:** consolidated assessment report, pentest RoE.

### Privacy
- PII inventory and classification; data minimization.
- Retention and deletion; GDPR/subject-rights handling.
- **Artifact:** PII map, retention policy.

### Risk Mgmt
- Findings logged with severity, owner, containment vs remediation.
- Remediation phased (containment first), each phase its own commit + verify.
- **Artifact:** risk register / tracked issue with severities and order.

## Inputs
- Engineering surface (endpoints, services, integrations) + Architecture threat model.

## Outputs
- Hardened endpoints, verified authz, tracked + closed findings, audit trail.

## Definition of Done
- [ ] Authz matrix verified for no-auth / user / admin roles.
- [ ] No secrets in repo or history; managed secret store in use.
- [ ] SAST/SCA/secret/image/cloud scans run, findings triaged by severity.
- [ ] Object-level (IDOR) ownership checks present on all object-scoped routes.
- [ ] Internal-only services not reachable from the public edge.
- [ ] Findings tracked with owner + remediation order; criticals contained.
