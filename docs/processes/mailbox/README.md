# Mailbox Process
- **Owner:** _TBD_
- **Last updated:** 2025-10-02

## Purpose
Describe how tenant users browse and interact with mailbox threads, how the frontend components coordinate with backend services, and how messages persist and fan out to downstream channels.

## Frontend Components
1. **MailboxPage (/mailbox)** – layout shell that wires Redux/React Query providers, loads initial metadata, and mounts child components.
2. **MailboxList** – fetches paginated threads via `GET /api/mailbox/threads`, renders unread counts, and surfaces selection events.
3. **MailboxThread** – loads the active conversation with `GET /api/mailbox/threads/<built-in function id>`, handles scrolling, and marks messages as read.
4. **MailboxComposer** – validates input, applies tenant templates, and posts new replies through `POST /api/mailbox/messages`.
5. **NotificationBadge** – subscribes to WebSocket/STOMP updates to refresh counts in real time.

All components share a mailbox store slice so state (selected thread, message cache, composer draft) stays consistent between views.

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
- [ ] Generate and commit `docs/diagrams/mailbox.drawio.png` after updating the draw.io diagram.
- [ ] Expand NotificationService documentation with retry/backoff strategy.
- [ ] Add integration tests covering WebSocket unread updates.
