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
    status: done
  - id: S3.2
    title: "Artifact Registry trimmed"
    as_a: "the platform"
    i_want: "the `frontend` and `medusa` repos deleted and a keep-last-3 cleanup policy on what remains"
    so_that: "~92 GB of old images stop billing"
    risk: high
    status: done
  - id: S3.3
    title: "The free-tier services still answer"
    as_a: "the product owner"
    i_want: "`print-pdf`, `pmo-smalldocs` and both Telegram notifiers working from Cloud Run's free tier"
    so_that: "nothing that stayed on GCP broke"
    risk: high
    status: done
  - id: S3.4
    title: "The GCP reminder list handed to Daniel"
    as_a: "Daniel"
    i_want: "a dated list of GCP projects still billing \u2014 `gen-lang-client-0305197114`, `loyal-coyote-484117-k9`, `project-32471a48-ac44-413f-b51` \u2014 with what each bills"
    so_that: "nothing unused bills on the next cycle"
    risk: high
    status: done
  - id: S3.5
    title: "The docs say what is true"
    as_a: "the next agent"
    i_want: "`BACKUPS.md`, the deploy-topology memory, both apps' `AGENTS.md` deploy sections and `../fluxonline/deploy/README.md` (the VM now hosts a third tenant) updated"
    so_that: "no one deploys to a rail that no longer exists"
    risk: high
    status: done
---
# Miyagi on the Oracle VM — Sprint 3: The GCP teardown

**Status:** ✅ GCP torn down 2026-10-16 ~19:10Z; docs updated

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

## Evidence (2026-10-16)

### S3.1 — Deleted, not disabled
Daniel ran the printed script at about 19:00Z, built from the live inventory and run before the S2.6 smoke. The
inventory changed one planned step:

- **`db-backup` was NOT deleted.** It was the **only Supabase backup**, since it dumped `supabase,medusa`. It now runs
  `BACKUP_TARGETS=supabase`, without the Medusa DSN or the VPC connector. A verifying run passed (`db-backup-6h6jl`),
  and `db-backup-daily` was resumed.
- **No final Cloud SQL export.** GCP Medusa's request log after the 13:59:57Z final dump shows one non-GET:
  `POST /store/carts/scan-incomplete` at 14:00:11, the abandoned-cart scan, not a buyer write. Cloud SQL therefore
  held exactly the R2 dump `medusa/2026/10/16/medusa-2026-10-16T135957Z.dump.gz`.

Everything else in the plan was deleted:

- Cloud Run `miyagi-web`, `medusa-web` and `medusa-web-staging`;
- the whole ALB (forwarding rule, HTTPS proxy, URL map, 2 backend services, 2 NEGs, 2 certs, the Armor policy and
  `miyagi-web-lb-ip`);
- Cloud SQL `medusa-pg`, including `medusa_staging`;
- Memorystore `medusa-redis` and the `medusa-conn` connector;
- the 5 `frontend-*` schedulers, `cloudsql-backup-check-daily`, and the job `cloudsql-backup-check`;
- the 3 Cloud Build triggers and the secret `NEON_BACKUP_DSN`.

Production answered 200 throughout (apex, `www`, `api /health`; `mschz.org` 301).

### S3.2 — Artifact Registry
`frontend` (76.6 GB) and `medusa` (16.6 GB) are deleted. `cloud-run-source-deploy`, `gcf-artifacts`, `medusa-ops` and
`print` now carry `keep-last-3` plus `delete-older` (older than 1 day).

### S3.3 — What stayed on GCP
Cloud Run now runs only `cicd-telegram-build-notifier`, `cicd-telegram-build-notifier-frontend`, `pmo-smalldocs` (200)
and `print-pdf`. None of them uses the deleted connector or services.

- `print-pdf` answers 404 at `/`, which is its normal state: the 30-day request log holds only that probe, so nothing
  calls it.
- **The two notifiers report Cloud Build events, and no trigger is left**, so they will never fire again. Delete them
  in a later cleanup, or leave them, since they cost nothing at zero requests.

### S3.4 — The GCP projects list (checked 2026-10-16, each under its own account)

| Project | Account (gcloud config) | State |
|---|---|---|
| `miyagisanchez-prod` | lolis8755 (`lolis-profile`) | ACTIVE, billing on. Holds only the services above plus `db-backup` (Supabase) |
| `project-32471a48-ac44-413f-b51` | lolis8755 (`lolis-profile`) | **ACTIVE, billing on: owed to Daniel to delete** |
| `gen-lang-client-0305197114` | leroytramafat (`bonsai-profile`) | **ACTIVE, billing on: owed to Daniel to delete** |
| `loyal-coyote-484117-k9` | danielvp1987 (`n8ngcp`) | **ACTIVE, billing on: owed to Daniel to delete** |

A project's absence from one account's `projects list` says nothing about a project that belongs to another
account. A first draft of this table read that absence as "deleted".

Nothing on this list was deleted by an agent.

### S3.5 — The docs
- `infra/gcp/backups/BACKUPS.md`: the backup-of-record is now the VM's dump to R2 and the OCI bucket. The Cloud SQL
  sections are marked RETIRED.
- `infra/gcp/README.md`: a RETIRED banner lists each deploy and provision script that must not be run again, and why
  its static guard still passes.
- **`provision-db-backup.sh` was a live trap, not just a stale doc.** Its default was `supabase,medusa` plus the deleted
  `medusa-conn`, and the provisioner default is the live config. It is now Supabase-only, pinned by a spec that was
  seen failing against the old script.
- Both apps' `AGENTS.md` describe the VM rail: web #433, api #206. panfleto's `deploy/README.md` names the three
  tenants and the no-catch-all rule (justread #31).
- **The deploy rail is now manual.** A merge builds `:main` on the arm64 runner, then
  `ssh ubuntu@159.54.158.4 /opt/miyagi/infra/oci/update.sh` deploys it. Making this automatic needs a VM deploy key
  stored as a GitHub secret, which is a credential decision for Daniel.

