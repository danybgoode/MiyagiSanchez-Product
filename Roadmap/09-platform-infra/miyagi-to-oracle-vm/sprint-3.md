---
epic: miyagi-to-oracle-vm
sprint: 3
title: "The GCP teardown"
risk: high
phase: Shaping
stories_total: 5
stories:
  - id: S3.1
    title: "Delete the GCP heavy parts"
    as_a: "the product owner"
    i_want: "the always-on GCP resources deleted (not disabled) right after S2.6 passes"
    so_that: "the bill drops on the next cycle"
    risk: high
    status: planned
  - id: S3.2
    title: "Artifact Registry trimmed"
    as_a: "the platform"
    i_want: "the `frontend` and `medusa` repos deleted and a keep-last-3 cleanup policy on what remains"
    so_that: "~92 GB of old images stop billing"
    risk: high
    status: planned
  - id: S3.3
    title: "The free-tier services still answer"
    as_a: "the product owner"
    i_want: "`print-pdf`, `pmo-smalldocs` and both Telegram notifiers working from Cloud Run's free tier"
    so_that: "nothing that stayed on GCP broke"
    risk: high
    status: planned
  - id: S3.4
    title: "The GCP reminder list handed to Daniel"
    as_a: "Daniel"
    i_want: "a dated list of GCP projects still billing \u2014 `gen-lang-client-0305197114`, `loyal-coyote-484117-k9`, `project-32471a48-ac44-413f-b51` \u2014 with what each bills"
    so_that: "nothing unused bills on the next cycle"
    risk: high
    status: planned
  - id: S3.5
    title: "The docs say what is true"
    as_a: "the next agent"
    i_want: "`BACKUPS.md`, the deploy-topology memory, both apps' `AGENTS.md` deploy sections and `../fluxonline/deploy/README.md` (the VM now hosts a third tenant) updated"
    so_that: "no one deploys to a rail that no longer exists"
    risk: high
    status: planned
---
# Miyagi on the Oracle VM — Sprint 3: The GCP teardown

**Status:** ⬜ not started

## Stories

### Story 3.1 — Delete the GCP heavy parts
**As** the product owner, **I want** the always-on GCP resources deleted (not disabled) right after S2.6 passes, **so that** the bill drops on the next cycle.
**Acceptance:** A final Cloud SQL export to R2 first; then delete Cloud SQL `medusa-pg`, Redis `medusa-redis`, the ALB + `miyagi-web-lb-ip` + Cloud Armor policy, the `medusa-conn` connector, `medusa-web`, `miyagi-web`, `medusa-web-staging` + its DB, the 3 Cloud Build triggers (deleted, never disabled), the 5 `frontend-*` schedulers, the `db-backup` + `cloudsql-backup-check` jobs + their schedulers. **Daniel confirms the printed list before the first delete.**
**Risk:** high

### Story 3.2 — Artifact Registry trimmed
**As** the platform, **I want** the `frontend` and `medusa` repos deleted and a keep-last-3 cleanup policy on what remains, **so that** ~92 GB of old images stop billing.
**Acceptance:** `gcloud artifacts repositories list` shows only the repos the free-tier services use, each with a cleanup policy.
**Risk:** high

### Story 3.3 — The free-tier services still answer
**As** the product owner, **I want** `print-pdf`, `pmo-smalldocs` and both Telegram notifiers working from Cloud Run's free tier, **so that** nothing that stayed on GCP broke.
**Acceptance:** A print PDF renders from admin; a deploy notification reaches Telegram; the project's billing forecast is inside the free tier, or the residue is named.
**Risk:** high

### Story 3.4 — The GCP reminder list handed to Daniel
**As** Daniel, **I want** a dated list of GCP projects still billing — `gen-lang-client-0305197114`, `loyal-coyote-484117-k9`, `project-32471a48-ac44-413f-b51` — with what each bills, **so that** nothing unused bills on the next cycle.
**Acceptance:** The list is posted in the PR body and the retro; nothing on it is deleted by an agent.
**Risk:** high

### Story 3.5 — The docs say what is true
**As** the next agent, **I want** `BACKUPS.md`, the deploy-topology memory, both apps' `AGENTS.md` deploy sections and `../fluxonline/deploy/README.md` (the VM now hosts a third tenant) updated, **so that** no one deploys to a rail that no longer exists.
**Acceptance:** Every doc names the VM rail; the GCP rail is described as retired; `deploy-invariants` and any guard pinned to Cloud Run are updated or retired with a reason.
**Risk:** high

## Sprint QA
- **api spec(s):** none new; guards that pinned Cloud Run (`deploy-invariants`) are updated or retired with a reason.
- **browser smoke owed:** yes, to Daniel — the print-PDF step below (admin auth).
- **deterministic gate:** CI green on every repo touched; `node scripts/build-order.mjs --check`.

## Sprint 3 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open https://miyagisanchez.com
   → still renders (nothing on GCP that mattered was deleted).
2. **(admin auth — owed to Daniel)** In admin, open a print edition and generate its PDF.
   → the PDF downloads (`print-pdf` on Cloud Run's free tier still answers).
3. Open the GCP console billing page for `miyagisanchez-prod`
   → the forecast for next month is ~$0, or the residue is named in this doc.
4. Read the GCP reminder list in this sprint's PR
   → it names the three projects to delete and what each bills.

If any step fails, note the step number + what you saw — that's the bug report.
