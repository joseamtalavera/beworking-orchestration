# Mailbox Process
- **Owner:** Jose AM Talavera
- **Last updated:** 2026-04-16

## Purpose
Describe how tenant users browse and interact with mailbox threads, how the frontend components coordinate with backend services, and how messages persist and fan out to downstream channels.

## Frontend Components
The mailbox UI lives in the dashboard app (Vite + React):
- **MailboxAdmin** (`beworking-dashboard/src/components/tabs/admin/MailboxAdmin.jsx`) – admin view for managing all mailroom documents.
- **MailboxUser** (`beworking-dashboard/src/components/tabs/user/MailboxUser.jsx`) – tenant user view for their own documents.

State is managed via local React hooks (`useState`) — document lists, filters, loading states, and snackbar notifications. No Redux or global store is used for mailbox.

## Request Flow
1. User hits `/mailbox`; `MailboxPage` requests thread summaries (list component).
2. Selecting a thread triggers `MailboxThread` to fetch full history and mark messages read.
3. Sending a reply posts to `POST /api/mailbox/messages`; the UI optimistically appends the outbound message.
4. WebSocket notifications increment unread counters across other sessions via `NotificationBadge`.

## Backend Components
- **MailboxController** – exposes REST endpoints for listing threads, fetching individual conversations, sending replies, and marking read state.
- **MailboxService** – orchestrates business rules (tenant scoping, permissions, push notifications, audit logging).
- **MailboxThreadRepository / MailboxMessageRepository** – Spring Data JPA repositories for persistence.
- **NotificationService** – wraps async messaging (publishes events to WebSocket gateway and optional email relay).
- **WebSocketGateway** – STOMP/SockJS endpoint broadcasting message and unread updates to subscribed clients.

## Persistence & Integrations
- **PostgreSQL tables**: `mailbox_thread` stores thread metadata; `mailbox_message` holds individual messages plus sender/attachments.
- **External relay** (optional): NotificationService can hand off emails to an SMTP relay for external participants.

## Diagram
- Source: `../../diagrams/draw.mailbox.txt`
- Export: `../../diagrams/mailbox.drawio.png`

![Mailbox flow](../../diagrams/mailbox.drawio.png)

## Sequence Details
1. `MailboxList` → `MailboxController.listThreads()` → `MailboxService.fetchThreads()` → `MailboxThreadRepository` → `mailbox_thread`.
2. `MailboxThread` → `MailboxController.threadDetail(id)` → `MailboxService.fetchThread(id)` → repositories → return DTO for UI.
3. `MailboxComposer` → `MailboxController.createMessage()` → `MailboxService.createMessage()` which:
   - Persists via `MailboxMessageRepository`.
   - Updates thread metadata (last message, unread counts).
   - Emits `MailboxMessageCreatedEvent` consumed by `NotificationService`.
4. `NotificationService` pushes payload to `WebSocketGateway`; connected clients update their state. Optional: send email relay to off-platform recipients.

## Error Handling
- Controller validates tenant access; unauthorized users receive 403.
- Service layer wraps repository exceptions into domain-specific errors (e.g., thread archived, attachment too large).
- WebSocket disconnects trigger re-authentication on the frontend badge component.

## Follow-ups
- [x] Update frontend component references to match dashboard implementation.
- [ ] Expand NotificationService documentation with retry/backoff strategy.
- [ ] Add integration tests covering mailbox API endpoints.
