# Mailbox Process
- **Owner:** _TBD_
- **Last updated:** 2025-10-01

## Purpose
Explain how tenant users access, consume, and manage in-app messages or notifications within the mailbox module.

## High-Level Flow
1. Fetch mailbox threads/messages for the authenticated user.
2. Present mailbox UI (list view, detail view, unread counters).
3. Handle user actions (mark read/unread, archive, respond, trigger workflows).
4. Sync changes back to backend services and notify other participants.

Extend the flow with any automation (e.g. email forwarding, push notifications, SLA reminders).

## Systems & Services
- Frontend: mailbox components, real-time updates, state synchronisation.
- Backend: mailbox APIs, notification queue/workers, persistence.
- Integrations: external email gateway, chat service, CRM updates.

Link to concrete files once mapped (e.g. `beworking-backend-java/.../MailboxController`).

## Diagram
- Source: `../../diagrams/draw.mailbox.txt`
- Export (PNG/SVG): `../../diagrams/mailbox.drawio.png`

Embed export when ready:

![Mailbox flow](../../diagrams/mailbox.drawio.png)

## Key Decisions & Notes
- Document retention policies, tenant segregation, permission checks.
- Capture open questions around scalability, notifications, or analytics.

## Follow-ups
- [ ] Verify real-time update path (websocket/polling).
- [ ] Document failure handling and retries.
