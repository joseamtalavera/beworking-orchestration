#!/bin/bash

gh issue create --title "Space Catalog: Add image upload UI and wire to /api/uploads" --body "Add file input/drag-drop in Photos tab, call POST /api/uploads (multipart), insert returned URL into images array. Keep URL field as fallback. Show upload progress/errors." --repo joseamtalavera/beworking-orchestration

gh issue create --title "Backend: Finalize upload pipeline (dev vs prod)" --body "Dev: local storage under uploads/catalog, served at /uploads/** (already added).\nProd: add S3/GCS impl behind MediaStorageService, config via env (bucket, prefix, ACL, cache-control).\nEnforce MIME/size limits and return usable public URL." --repo joseamtalavera/beworking-orchestration

gh issue create --title "Space Catalog: Persist full room fields and fix data refresh" --body "Ensure payload includes code on edits; confirm DB updates for capacity/price/description/hero image.\nAfter save/delete, reload list from API or update state with returned row to avoid stale IDs." --repo joseamtalavera/beworking-orchestration

gh issue create --title "Data cleanup: Correct sample records" --body "Fix MA1_DESK row (name/description), ensure MA1A1–MA1A5 have the right capacity/price/tags/hero images.\nConsider adding a migration/SQL seed for the six canonical rows." --repo joseamtalavera/beworking-orchestration

gh issue create --title "Booking cards: Limit to published spaces" --body "Confirm only MA1A1–MA1A5 + desk appear on booking site. Either enforce in API (status/published flag) or filter in booking app until ready to expose more." --repo joseamtalavera/beworking-orchestration

gh issue create --title "Catalog API tests" --body "Add integration tests for /api/catalog/spaces and /api/uploads (auth required, validation, happy path with images/amenities)." --repo joseamtalavera/beworking-orchestration