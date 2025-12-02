#!/bin/bash

set -euo pipefail

REPO="joseamtalavera/beworking-orchestration"

ensure_labels() {
	while IFS='|' read -r name color; do
		[[ -z "$name" ]] && continue
		if ! gh label view "$name" --repo "$REPO" >/dev/null 2>&1; then
			if gh label create "$name" --color "$color" --repo "$REPO" >/dev/null 2>&1; then
				echo "Created missing label '$name'"
			else
				echo "Warning: could not create label '$name'" >&2
			fi
		fi
	done <<'EOF'
epic|ff5733
core|0052cc
auth|1d76db
backend|0e8a16
multi-tenant|5319e7
licensing|b60205
users|5319e7
dashboard|1d76db
settings|fbca04
infrastructure|6f42c1
gateway|0052cc
crm|f9d0c4
metadata|5319e7
finance|d73a4a
invoices|0e8a16
expenses|5319e7
banking|0052cc
crypto|5319e7
integration|6f42c1
booking|006b75
spaces|5319e7
ui|fbca04
marketplace|5319e7
productivity|0052cc
files|1d76db
ticketing|d93f0b
security|b60205
community|6f42c1
posts|0e8a16
events|0366d6
courses|fbca04
chat|5319e7
automation|0052cc
engine|0e8a16
integrations|0366d6
webhooks|5319e7
ai|5319e7
documents|0366d6
signature|d93f0b
templates|f9d0c4
kb|6f42c1
partners|0e8a16
EOF
}

create_issue() {
	local title="$1"
	local body="$2"
	shift 2
	local url
	url=$(gh issue create --repo "$REPO" --title "$title" --body "$body" "$@" | tail -n 1)
	echo "Created issue: $url"
}

create_epic() {
	local title="$1"
	local body="$2"
	shift 2
	local url
	url=$(gh issue create --repo "$REPO" --title "$title" --body "$body" "$@" | tail -n 1)
	echo "Created issue: $url" >&2
	echo "$url" | awk -F'/' '{print $NF}'
}

ensure_labels

echo "Creating EPIC 1: Core Platform"
EPIC1_BODY=$(cat <<'EOF'
This epic includes all foundational services of the BeWorking platform: authentication, multi-tenant management, user directory, module licensing, overview, settings, and the internal API gateway foundation.
EOF
)
EPIC1=$(create_epic "EPIC: Core Platform (Authentication, Tenants, Licensing, Settings)" "$EPIC1_BODY" --label epic --label core)
echo "Created EPIC 1 as #$EPIC1"

AUTH_BODY=$(cat <<EOF
Parent Epic: #$EPIC1

Description:
Implement full authentication (login, refresh tokens, JWT, Spring Security).

Scope:
- Login endpoint
- JWT access + refresh
- Token validation filter
- User registration
- Password hashing
- Spring Security configuration

Acceptance Criteria:
- Secure login with JWT
- Refresh flow functional
- Role-based access working
- Multi-tenant aware
EOF
)
create_issue "Authentication & JWT Implementation" "$AUTH_BODY" --label core --label auth --label backend

TENANT_BODY=$(cat <<EOF
Parent Epic: #$EPIC1

Description:
Implement tenant registry, tenant CRUD, user ↔ tenant mapping, and tenant metadata storage.

Scope:
- Tenant CRUD
- User↔tenant assignments
- Tenant activation
- Tenant metadata

Acceptance Criteria:
- Tenants can be created, updated, disabled
- API enforces tenant isolation
EOF
)
create_issue "Tenant Management Service" "$TENANT_BODY" --label core --label multi-tenant

LICENSE_BODY=$(cat <<EOF
Parent Epic: #$EPIC1

Description:
Implement tenant_modules table, activation/deactivation, and feature flags enforcement.

Scope:
- Module activation API
- Feature flags
- License checks

Acceptance Criteria:
- Tenant can enable/disable modules
- Core enforces licensing automatically
EOF
)
create_issue "Module Licensing Engine" "$LICENSE_BODY" --label core --label licensing

USER_DIR_BODY=$(cat <<EOF
Parent Epic: #$EPIC1

Description:
Global user identity service, shared by all modules.

Scope:
- User CRUD
- Roles & permissions
- Avatar upload

Acceptance Criteria:
- Users can be created and updated
- Global role-based access
EOF
)
create_issue "User Directory Service" "$USER_DIR_BODY" --label core --label users

OVERVIEW_BODY=$(cat <<EOF
Parent Epic: #$EPIC1

Description:
Provide overview dashboard metrics and aggregated data from services.
EOF
)
create_issue "Overview Dashboard API" "$OVERVIEW_BODY" --label core --label dashboard

SETTINGS_BODY=$(cat <<EOF
Parent Epic: #$EPIC1

Description:
Implement user settings and tenant-level workspace settings.
EOF
)
create_issue "Settings API" "$SETTINGS_BODY" --label core --label settings

REGISTRY_BODY=$(cat <<EOF
Parent Epic: #$EPIC1

Description:
Implement service discovery table + health checks.
EOF
)
create_issue "Internal Service Registry" "$REGISTRY_BODY" --label core --label infrastructure

GATEWAY_BODY=$(cat <<EOF
Parent Epic: #$EPIC1

Description:
Define NGINX routes mapping each microservice: /auth, /crm, /finance, /booking, etc.
EOF
)
create_issue "API Gateway Routing (NGINX)" "$GATEWAY_BODY" --label core --label gateway

echo "Creating EPIC 2: CRM Module"
EPIC2_BODY=$(cat <<'EOF'
CRM module responsible for contacts, notes, tags, and custom CRM fields. Sellable independently.
EOF
)
EPIC2=$(create_epic "EPIC: CRM Module (Contacts + Notes + Fields)" "$EPIC2_BODY" --label epic --label crm)
echo "Created EPIC 2 as #$EPIC2"

CONTACTS_BODY=$(cat <<EOF
Parent Epic: #$EPIC2

Description:
Implement contacts microservice with CRUD, tags, custom fields.
EOF
)
create_issue "Contacts Service Implementation" "$CONTACTS_BODY" --label crm --label backend

NOTES_BODY=$(cat <<EOF
Parent Epic: #$EPIC2

Description:
Add notes to contacts with timestamps + authorship.
EOF
)
create_issue "CRM Notes" "$NOTES_BODY" --label crm

CUSTOM_FIELDS_BODY=$(cat <<EOF
Parent Epic: #$EPIC2

Description:
Implement dynamic custom CRM fields.
EOF
)
create_issue "CRM Custom Fields" "$CUSTOM_FIELDS_BODY" --label crm --label metadata

echo "Creating EPIC 3: Finance Module"
EPIC3_BODY=$(cat <<'EOF'
Financial module including invoicing, expenses, bank accounts, crypto wallet, and Holded integration.
EOF
)
EPIC3=$(create_epic "EPIC: Finance Module (Invoices + Expenses + Banks + Crypto)" "$EPIC3_BODY" --label epic --label finance)
echo "Created EPIC 3 as #$EPIC3"

INVOICING_BODY=$(cat <<EOF
Parent Epic: #$EPIC3

Description:
Implement invoice CRUD, numbering, PDF generator, email sending.
EOF
)
create_issue "Invoicing Service" "$INVOICING_BODY" --label finance --label invoices

EXPENSES_BODY=$(cat <<EOF
Parent Epic: #$EPIC3

Description:
Expense tracking with categories and receipt uploads.
EOF
)
create_issue "Expenses Service" "$EXPENSES_BODY" --label finance --label expenses

BANKS_BODY=$(cat <<EOF
Parent Epic: #$EPIC3

Description:
Store bank accounts and balances.
EOF
)
create_issue "Banks Service" "$BANKS_BODY" --label finance --label banking

CRYPTO_BODY=$(cat <<EOF
Parent Epic: #$EPIC3

Description:
Basic wallet ledger + Stripe Crypto integration.
EOF
)
create_issue "Crypto Wallet Service" "$CRYPTO_BODY" --label finance --label crypto

HOLDED_BODY=$(cat <<EOF
Parent Epic: #$EPIC3

Description:
Sync invoices + balances with Holded API.
EOF
)
create_issue "Holded Integration" "$HOLDED_BODY" --label finance --label integration

echo "Creating EPIC 4: Spaces & Booking Module"
EPIC4_BODY=$(cat <<'EOF'
Module to handle meeting rooms, workspace floorplans, and reservation engine.
EOF
)
EPIC4=$(create_epic "EPIC: Spaces & Booking Module (Rooms + Floorplan + Reservations)" "$EPIC4_BODY" --label epic --label booking)
echo "Created EPIC 4 as #$EPIC4"

ROOMS_BODY=$(cat <<EOF
Parent Epic: #$EPIC4

Description:
CRUD rooms, availability, rules.
EOF
)
create_issue "Meeting Rooms Service" "$ROOMS_BODY" --label booking --label spaces

ENGINE_BODY=$(cat <<EOF
Parent Epic: #$EPIC4

Description:
Reservation logic, availability checks.
EOF
)
create_issue "Booking Engine" "$ENGINE_BODY" --label booking --label backend

FLOORPLAN_BODY=$(cat <<EOF
Parent Epic: #$EPIC4

Description:
Floorplan upload + desk coordinates + booking UI endpoints.
EOF
)
create_issue "Floorplan Booking" "$FLOORPLAN_BODY" --label booking --label ui --label spaces

CATALOG_BODY=$(cat <<EOF
Parent Epic: #$EPIC4

Description:
Partner spaces marketplace listings.
EOF
)
create_issue "Space Catalog" "$CATALOG_BODY" --label spaces --label marketplace

echo "Creating EPIC 5: Productivity Module"
EPIC5_BODY=$(cat <<'EOF'
Productivity tools for workspace operations.
EOF
)
EPIC5=$(create_epic "EPIC: Productivity Module (Storage + Tickets + Passwords)" "$EPIC5_BODY" --label epic --label productivity)
echo "Created EPIC 5 as #$EPIC5"

STORAGE_BODY=$(cat <<EOF
Parent Epic: #$EPIC5

Description:
File uploads via S3/Drive + folder system.
EOF
)
create_issue "Storage Service" "$STORAGE_BODY" --label productivity --label files

TICKETS_BODY=$(cat <<EOF
Parent Epic: #$EPIC5

Description:
Support ticketing system with assignments and status.
EOF
)
create_issue "Tickets / Tasks Service" "$TICKETS_BODY" --label productivity --label ticketing

PASSWORD_BODY=$(cat <<EOF
Parent Epic: #$EPIC5

Description:
Encrypted vault for shared passwords.
EOF
)
create_issue "Password Manager" "$PASSWORD_BODY" --label productivity --label security

echo "Creating EPIC 6: Community Module"
EPIC6_BODY=$(cat <<'EOF'
Community features for workspace users: social wall, events, courses, channels.
EOF
)
EPIC6=$(create_epic "EPIC: Community Module (Posts + Events + Courses + Channels)" "$EPIC6_BODY" --label epic --label community)
echo "Created EPIC 6 as #$EPIC6"

POSTS_BODY=$(cat <<EOF
Parent Epic: #$EPIC6

Description:
Posts + comments + attachments.
EOF
)
create_issue "Community Posts" "$POSTS_BODY" --label community --label posts

EVENTS_BODY=$(cat <<EOF
Parent Epic: #$EPIC6

Description:
Events with reminders + Google Calendar sync.
EOF
)
create_issue "Events Service" "$EVENTS_BODY" --label community --label events

COURSES_BODY=$(cat <<EOF
Parent Epic: #$EPIC6

Description:
Course builder with lessons + Stripe payments.
EOF
)
create_issue "Courses" "$COURSES_BODY" --label community --label courses

CHANNELS_BODY=$(cat <<EOF
Parent Epic: #$EPIC6

Description:
Topic channels with WebSockets.
EOF
)
create_issue "Channels" "$CHANNELS_BODY" --label community --label chat

echo "Creating EPIC 7: Automation Module"
EPIC7_BODY=$(cat <<'EOF'
Automation engine for trigger-based workflows and integrations.
EOF
)
EPIC7=$(create_epic "EPIC: Automation Module (Workflows + Integrations + Webhooks)" "$EPIC7_BODY" --label epic --label automation)
echo "Created EPIC 7 as #$EPIC7"

WORKFLOW_BODY=$(cat <<EOF
Parent Epic: #$EPIC7

Description:
Trigger → Action logic with JSON workflow builder.
EOF
)
create_issue "Workflow Engine" "$WORKFLOW_BODY" --label automation --label engine

INTEGRATION_BODY=$(cat <<EOF
Parent Epic: #$EPIC7

Description:
Store external API keys and connections.
EOF
)
create_issue "Integration Registry" "$INTEGRATION_BODY" --label automation --label integrations

WEBHOOKS_BODY=$(cat <<EOF
Parent Epic: #$EPIC7

Description:
Incoming/outgoing webhooks with retry policies.
EOF
)
create_issue "Webhooks Engine" "$WEBHOOKS_BODY" --label automation --label webhooks

AI_TRIGGERS_BODY=$(cat <<EOF
Parent Epic: #$EPIC7

Description:
Execute AI tasks based on events.
EOF
)
create_issue "AI Triggers" "$AI_TRIGGERS_BODY" --label automation --label ai

echo "Creating EPIC 8: Documents & Signature Module"
EPIC8_BODY=$(cat <<'EOF'
Document signing and template library with Google Docs integration.
EOF
)
EPIC8=$(create_epic "EPIC: Documents & Signature Module (Signatures + Templates + PDFs)" "$EPIC8_BODY" --label epic --label documents)
echo "Created EPIC 8 as #$EPIC8"

SIGNATURE_BODY=$(cat <<EOF
Parent Epic: #$EPIC8

Description:
Document upload, signature placement, audit trail.
EOF
)
create_issue "Signature Service" "$SIGNATURE_BODY" --label documents --label signature

TEMPLATE_BODY=$(cat <<EOF
Parent Epic: #$EPIC8

Description:
Reusable templates with placeholders.
EOF
)
create_issue "Template Library" "$TEMPLATE_BODY" --label documents --label templates

echo "Creating EPIC 9: AI Module"
EPIC9_BODY=$(cat <<'EOF'
AI assistant + agents + embeddings-based knowledge base.
EOF
)
EPIC9=$(create_epic "EPIC: AI Module (BeCopilot)" "$EPIC9_BODY" --label epic --label ai)
echo "Created EPIC 9 as #$EPIC9"

AI_ASSISTANT_BODY=$(cat <<EOF
Parent Epic: #$EPIC9

Description:
Chat endpoint + routing engine.
EOF
)
create_issue "AI Assistant API" "$AI_ASSISTANT_BODY" --label ai --label backend

AI_KB_BODY=$(cat <<EOF
Parent Epic: #$EPIC9

Description:
Documents + embeddings + vector search.
EOF
)
create_issue "AI Knowledge Base" "$AI_KB_BODY" --label ai --label kb

echo "Creating EPIC 10: Marketplace Module"
EPIC10_BODY=$(cat <<'EOF'
Service marketplace for coworking partners and digital service providers.
EOF
)
EPIC10=$(create_epic "EPIC: Marketplace Module (Listings + Partners)" "$EPIC10_BODY" --label epic --label marketplace)
echo "Created EPIC 10 as #$EPIC10"

MARKETPLACE_LISTINGS_BODY=$(cat <<EOF
Parent Epic: #$EPIC10

Description:
Catalog of service providers.
EOF
)
create_issue "Marketplace Listings" "$MARKETPLACE_LISTINGS_BODY" --label marketplace

PARTNER_PROFILES_BODY=$(cat <<EOF
Parent Epic: #$EPIC10

Description:
Partner profile + reviews.
EOF
)
create_issue "Partner Profiles" "$PARTNER_PROFILES_BODY" --label marketplace --label partners

echo "All epics and child issues queued for creation."