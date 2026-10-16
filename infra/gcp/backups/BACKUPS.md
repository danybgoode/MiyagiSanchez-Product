# DB backups — runbook

## Backup-of-record (since the Oracle VM cutover, 2026-10-16)
> GCP project `miyagisanchez-prod` was **deleted** on 2026-10-16. Every Cloud Run job, scheduler and secret
> described below is gone. The only live backup is the VM's `infra/oci/backup.sh`.

Medusa left Cloud SQL for the Oracle VM `panfleto-prod`
([`miyagi-to-oracle-vm`](../../../Roadmap/09-platform-infra/miyagi-to-oracle-vm/README.md)). Cloud SQL
`medusa-pg` was **deleted** on 2026-10-16, and its native backups and PITR went with it.

| Database | Backup-of-record | Mechanism |
|---|---|---|
| **Commerce** (Medusa, Postgres on the VM) | **R2 escrow dump + OCI bucket** | `infra/oci/backup.sh` (systemd `miyagi-backup.timer`, 04:45 UTC) dumps as `backup_ro` to `r2:miyagi-db-escrow/medusa/YYYY/MM/DD/` **and** OCI bucket `miyagi-backups`, reading each upload back. `miyagi-restore-drill.timer` (Sun 05:30 UTC) restores the newest dump and compares counts. See [`infra/oci/`](../../oci/) |
| **Supabase** (non-commerce: conversations, offers, supply) | **R2 escrow dump + OCI bucket** | the same `infra/oci/backup.sh` run on the VM, which dumps with `SUPABASE_BACKUP_DSN` (from `backup.env`) to `supabase/YYYY/MM/DD/`, the prefix the GCP job used, so the series is continuous. The GCP `db-backup` Cloud Run Job below did this until the VM's first verified Supabase dump (2026-10-16), then was **deleted**; the pipeline sections below are history |

The last Cloud SQL state is `r2:miyagi-db-escrow/medusa/2026/10/16/medusa-2026-10-16T135957Z.dump.gz`,
the post-freeze final dump. GCP Medusa took no buyer write after it. The *Restore the commerce DB (Cloud SQL
native)* and *Cloud SQL backup-failure check* sections below are **retired** and kept as history; their
instance, job and scheduler no longer exist.

## R2 escrow dump pipeline (Supabase) — RETIRED: moved to the VM (`infra/oci/backup.sh`)
Daily `pg_dump` to a **Cloudflare R2** bucket, as off-platform, vendor-neutral, immutable escrow. Built in
[Backend Production Readiness, Sprint 2](../../../Roadmap/09-platform-infra/backend-production-readiness/sprint-2.md).
The cross-store RPO/RTO + restore procedures live in the central
[`tasks/backup-and-restore-runbook.md`](../../../tasks/backup-and-restore-runbook.md); this file is the
pipeline's own operate doc.

## Why this shape (the runner decision)
Evaluated **GitHub Action** vs. **Cloud Run Job + Cloud Scheduler**; chose the latter because it keeps the
architectural surface smaller:
- **Credentials** stay in **GCP Secret Manager** (the platform's existing store, per-secret least-privilege
  SA bindings, Cloud Audit Logs) — *not* a second store (GitHub Secrets), and the Supabase/R2 keys aren't
  GCP-issued so OIDC/WIF couldn't remove them from GitHub anyway.
- **Image** is purpose-built and **PG17-pinned** (`postgres:17-alpine`), solving the version-mismatch that
  bites any host with an older `pg_dump`; it lives in Artifact Registry and is CVE-scannable (S4).
- **Observability** is one rail: failures land in Cloud Logging and ping the same Telegram channel
  (`MiyagiDevopsTele` / `TELEGRAM_CICD_CHAT_ID`) the rest of the backend uses. GitHub cron is also
  best-effort (can be delayed/skipped) and the backend code is a separate repo from these `infra/` scripts.

Immutability + anti-lock-in come from the **destination and format** (R2 with a **bucket lock** (WORM
retention — R2 has no object versioning) + lifecycle + a bucket-scoped token, and a plain `pg_dump`
custom-format dump restorable by any PG17 client) — independent of the runner.

## Topology
| | |
|---|---|
| Runner | Cloud Run **Job** `db-backup` (region `us-east4`, SA `medusa-backup`, max-retries 1, 900s, 512Mi, VPC connector `medusa-conn`, egress `private-ranges-only` — Cloud SQL is private-IP only) |
| Schedule | Cloud Scheduler `db-backup-daily`, cron `0 9 * * *` UTC (≈ 03:00 CDMX) → `:run` the job |
| Image | `us-east4-docker.pkg.dev/<project>/medusa-ops/db-backup:<tag>` (`postgres:17-alpine` + rclone) |
| Targets | `supabase,medusa` (env `BACKUP_TARGETS`; `neon` retired 2026-10-15 — an unknown target fails the run) |
| Destination | `r2:<bucket>/<target>/YYYY/MM/DD/<target>-<ts>.dump.gz` |
| Alerts | non-zero exit → Cloud Run Job failure (S4 alert) + best-effort Telegram |

## Secret map (Secret Manager, populated by Daniel)
| Secret | Value |
|---|---|
| `SUPABASE_BACKUP_DSN` | a **read-only** role DSN on the Supabase DB (`postgresql://backup_ro:…@db.<ref>.supabase.co:5432/postgres`) |
| `DATABASE_URL` (reused, bound as `MEDUSA_BACKUP_DSN`) | the Medusa app's own DSN — bound, not copied, so a rotation can't strand the backup on an old password. Read-write, accepted because Cloud SQL is retired by [`miyagi-to-oracle-vm`](../../../Roadmap/09-platform-infra/miyagi-to-oracle-vm/README.md) S3 |
| `R2_BACKUP_ACCESS_KEY_ID` / `R2_BACKUP_SECRET_ACCESS_KEY` | an R2 API token scoped to **only the escrow bucket**, permission **Object Read & Write** (R2 has no write-only level; the read half powers the job's upload verification — escrow immutability comes from the bucket **lock rule** (WORM): even this credential cannot delete/overwrite objects younger than the retention age) |
| `R2_BACKUP_ENDPOINT` | `https://<accountid>.r2.cloudflarestorage.com` |
| `TELEGRAM_BOT_TOKEN` / `TELEGRAM_CICD_CHAT_ID` | reused (already exist) for failure alerts |

`R2_BACKUP_BUCKET`, `BACKUP_TARGETS`, `RETENTION_DAYS` are plain job env (not secret).

## Stand it up (owed to Daniel — needs R2 + Supabase access I don't hold)
```bash
# 0. (Cloudflare) Create bucket `miyagi-db-escrow`; add a LOCK rule (WORM retention, e.g. 30d
#    — R2 has NO object versioning; the lock is the immutability guarantee) + a LIFECYCLE
#    rule (expire after the lock window, e.g. 35d). Create an API token scoped to ONLY this
#    bucket with permission "Object Read & Write" (R2's least object-level grant).
#    Done 2026-06-12 via wrangler: lock worm-30d + lifecycle expire-after-35d + token.
# 1. (Supabase) Create a read-only role (Medusa reuses the app's DATABASE_URL — no new role):
#       CREATE ROLE backup_ro LOGIN PASSWORD '…';
#       GRANT pg_read_all_data TO backup_ro;     -- PG14+; else GRANT SELECT on schemas
#    Build the Supabase DSN.
# 2. Provision (creates SA + secret shells + image + Job + Scheduler; idempotent):
gcloud config configurations activate lolis-profile
export R2_BACKUP_BUCKET='miyagi-db-escrow'
export R2_ACCESS_KEY_ID='…' R2_SECRET_ACCESS_KEY='…' R2_ENDPOINT='https://<acct>.r2.cloudflarestorage.com'
export SUPABASE_DSN='postgresql://backup_ro:…@db.<ref>.supabase.co:5432/postgres'
bash infra/gcp/backups/provision-db-backup.sh
# 3. First run on-demand + confirm objects land in R2:
gcloud run jobs execute db-backup --region=us-east4 --wait
gcloud run jobs executions list --job=db-backup --region=us-east4 --limit=1   # expect Succeeded
#    Then confirm r2:miyagi-db-escrow/{supabase,medusa}/<today>/… exist (Cloudflare dashboard).
```

## Restore from an escrow dump
The dump is `--format=custom`, so use `pg_restore` (NOT psql). **Restore into a staging/scratch DB first** —
never straight over prod.
```bash
# Pull the object from R2 (any S3 client / rclone), then:
gunzip -c supabase-<ts>.dump.gz > restore.dump
# Full restore into an empty target DB:
pg_restore --no-owner --no-privileges --clean --if-exists --dbname="$TARGET_DSN" restore.dump
# Selective (single table) restore:
pg_restore --no-owner --data-only --table=marketplace_offers --dbname="$TARGET_DSN" restore.dump
```
Use a **PG17** `pg_restore` (matches the dump). RTO is a few minutes for the non-commerce volume.

## Restore the commerce DB (Cloud SQL native) — RETIRED 2026-10-16, `medusa-pg` deleted
Cloud SQL restore/PITR is console- or `gcloud`-driven — no R2 dump involved for commerce:
```bash
# List automated backups:
gcloud sql backups list --instance=medusa-pg --project=miyagisanchez-prod
# Restore a backup into a SCRATCH instance (never straight over prod), then repoint if needed:
gcloud sql backups restore <BACKUP_ID> --restore-instance=medusa-pg-scratch --backup-instance=medusa-pg
# Point-in-time restore (within the 7-day PITR window) → a clone at a timestamp:
gcloud sql instances clone medusa-pg medusa-pg-pitr \
  --point-in-time='2026-06-22T03:00:00Z'
```
The in-VPC dump/restore mechanics (connector-attached `postgres:17-alpine` Cloud Run Job — a laptop can't
reach the private IP) are recorded in `postgres-neon-to-cloudsql/sprint-2.md`.

## Cloud SQL backup-failure check (Telegram alert) — RETIRED 2026-10-16, job + scheduler deleted
Cloud SQL's native automated backups are the commerce backup-of-record, but they have **no alert of their
own** — a silently-failing nightly backup would be an invisible blind spot. This job closes it (DevOps
reliability cleanup, Sprint 2): once a day it lists `medusa-pg`'s backups and pings the ops Telegram chat
**only when** the latest automated backup is missing or not `SUCCESSFUL` within ~26h. **Failure-only — no
success heartbeat** (declined by Daniel).

| | |
|---|---|
| Runner | Cloud Run **Job** `cloudsql-backup-check` (region `us-east4`, SA `medusa-backup-check`, max-retries 1, 120s, 512Mi) |
| Schedule | Cloud Scheduler `cloudsql-backup-check-daily`, cron `0 12 * * *` UTC (a few h after the 09:00 backup window) → `:run` the job |
| Image | `…/medusa-ops/cloudsql-backup-check:<tag>` (`google-cloud-cli:slim` — gcloud + python3 + bash + curl) |
| Check | `gcloud sql backups list --instance=medusa-pg --project=miyagisanchez-prod --format=json` → the pure freshness predicate |
| Health rule | HEALTHY iff a **SUCCESSFUL AUTOMATED** backup exists within `MAX_AGE_HOURS` (default 26). A failed `gcloud` listing also alerts (a blind listing is itself a blind spot). |
| Alerts | best-effort Telegram via the reused `TELEGRAM_BOT_TOKEN` / `TELEGRAM_CICD_CHAT_ID` secrets — same idiom as `db-backup.sh` |

Files: [`cloudsql-check/check-cloudsql-backup.sh`](cloudsql-check/check-cloudsql-backup.sh) (gcloud fetch +
alert relay) · [`cloudsql-check/backup-freshness.py`](cloudsql-check/backup-freshness.py) (the **pure**,
unit-tested freshness predicate — `infra/gcp/test/cloudsql-backup-check.test.js`) ·
[`cloudsql-check/Dockerfile`](cloudsql-check/Dockerfile) ·
[`provision-cloudsql-backup-check.sh`](provision-cloudsql-backup-check.sh) (idempotent).

**Stand it up (owed to Daniel — live GCP writes):**
```bash
gcloud config configurations activate lolis-profile
bash infra/gcp/backups/provision-cloudsql-backup-check.sh
# Smoke — real instance → silent (Succeeded); bogus instance → a Telegram failure alert:
gcloud run jobs execute cloudsql-backup-check --region=us-east4 --wait                       # expect Succeeded, no alert
gcloud run jobs update  cloudsql-backup-check --region=us-east4 --update-env-vars=INSTANCE=does-not-exist
gcloud run jobs execute cloudsql-backup-check --region=us-east4 --wait                       # expect a Telegram alert
gcloud run jobs update  cloudsql-backup-check --region=us-east4 --update-env-vars=INSTANCE=medusa-pg
```

## Neon target retirement — done TWICE (2026-06-24, again 2026-10-15)
`neon` was retired live on **2026-06-24** (`devops-reliability-cleanup` sprint 2: `BACKUP_TARGETS=supabase`).
It came back on **2026-07-19**, when `gcp-account-migration` rebuilt this job in `miyagisanchez-prod` with
`provision-db-backup.sh` — whose default was still `supabase,neon` (the live job's previous image is tagged
`20260719-111533`). From then until 2026-10-15 the job dumped the abandoned Neon copy every night and **never
the live Cloud SQL commerce DB**. **The provisioner's default IS the live config**: a retirement applied only to
the running job is undone by the next re-provision (the same family as LEARNINGS' "disabled is not durable").
[`miyagi-to-oracle-vm`](../../../Roadmap/09-platform-infra/miyagi-to-oracle-vm/README.md) S1.1 fixed it at the
source: the default is now `supabase,medusa` (pinned by `infra/gcp/test/db-backup.test.mjs`), the `neon` branch
is deleted from `db-backup.sh` so a stale target fails the run, and `NEON_BACKUP_DSN` is no longer bound (the
secret itself is deleted with the rest of the GCP footprint in that epic's S3).

## Status
Pipeline **LIVE since 2026-06-12** — Cloud Run Job `db-backup` + Cloud Scheduler `db-backup-daily`
(`0 9 * * *` UTC) provisioned, R2 bucket/token + the read-only DSNs in Secret Manager, first run confirmed.
**Backup-of-record today:** commerce → Cloud SQL native automated backups + PITR (confirmed
`SUCCESSFUL`, e.g. backup `1782097256693` 2026-06-22T03:00Z); Supabase → this R2 escrow pipeline (`supabase`
target); commerce is **also** dumped to R2 nightly (`medusa` target, since 2026-10-15).

**Cloud SQL backup-failure check** (DevOps reliability cleanup, Sprint 2): code-complete (job image +
idempotent provision script + pure unit-tested predicate). **Owed to Daniel:** run
`provision-cloudsql-backup-check.sh` + the bogus-instance forced-failure smoke (live GCP writes).
