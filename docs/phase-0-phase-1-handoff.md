# Phase 0 and Phase 1 Handoff - Infra

## Completed Today
- Baseline decisions locked in root plan.
- Local infra stack file added.
- Database init SQL with pgvector and base tables added.
- Environment tfvars templates added for preview/staging/production.
- Validation and smoke scripts added.

## How to Run
1. Copy env template:
   - cp .env.example .env
2. Validate stack files:
   - ./scripts/validate.sh
3. Start and verify local stack:
   - ./scripts/smoke.sh

## Notes
- This is Phase 0 and Phase 1 only.
- API/worker/MCP/web implementation remains out of scope for this execution slice.
