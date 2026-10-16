---
epic: miyagi-to-oracle-vm
sprint: 1
title: "The rail, built dark"
risk: high
phase: Building
stories_total: 7
stories:
  - id: S1.1
    title: "The live Medusa DB gets an offsite copy \u2014 today"
    as_a: "the platform owner"
    i_want: "the nightly `db-backup` job to dump the live Cloud SQL Medusa DB to R2 (`BACKUP_TARGETS=supabase,medusa`, `neon` retired)"
    so_that: "the one dataset has a copy outside GCP before anything moves"
    risk: high
    status: done
  - id: S1.2
    title: "arm64 images built in CI, pulled by sha"
    as_a: "the platform"
    i_want: "GitHub Actions to build `linux/arm64` images of both apps into private GHCR, tagged by sha, with the exact build args `cloudbuild.yaml` passes"
    so_that: "the 2 shared cores never compile Next.js and a rollback is a restart"
    risk: high
    status: planned
  - id: S1.3
    title: "The compose stack on the VM"
    as_a: "the platform"
    i_want: "`infra/oci/` (compose + `update.sh`) running medusa, web, postgres 17 and redis on `/data/miyagi` with mem/cpu limits, joined to panfleto's Caddy through an external `edge` network"
    so_that: "Miyagi runs on the free box without touching panfleto"
    risk: high
    status: planned
  - id: S1.4
    title: "TLS at the VM, Full (Strict)"
    as_a: "the platform"
    i_want: "Caddy to serve Miyagi hosts with the Cloudflare Origin CA cert (wildcard + apex) and `oci.miyagisanchez.com` proxied through Cloudflare"
    so_that: "the VM is reachable exactly the way prod will be, with no HTTP-01 dance"
    risk: high
    status: planned
  - id: S1.5
    title: "A restored copy of prod, proven on ARM"
    as_a: "the product owner"
    i_want: "a restored copy of the prod Medusa DB booting on the VM, with images, Redis and orders proven"
    so_that: "the cutover moves a stack already seen working"
    risk: high
    status: planned
  - id: S1.6
    title: "Crons, backups and a restore drill as VM timers"
    as_a: "the platform"
    i_want: "systemd timers for the 5 `/api/cron/*` jobs, the nightly Medusa dump to R2 **and** the OCI bucket, and a weekly restore drill"
    so_that: "nothing depends on Cloud Scheduler or Cloud SQL backups anymore"
    risk: high
    status: planned
  - id: S1.7
    title: "Latency measured, VM vs Cloud Run"
    as_a: "the product owner"
    i_want: "p95 page latency for `/`, one PDP and one shop page on `oci.` vs prod, recorded in this sprint doc"
    so_that: "we know the 2-core box keeps the site as fast before we flip"
    risk: high
    status: planned
---
# Miyagi on the Oracle VM — Sprint 1: The rail, built dark

**Status:** 🏗️ in progress — S1.1 live 2026-10-15 (PR #206)

## Stories

### Story 1.1 — The live Medusa DB gets an offsite copy — today ✅ `6759011` (PR #206) · live execution `db-backup-88v4l`
**As** the platform owner, **I want** the nightly `db-backup` job to dump the live Cloud SQL Medusa DB to R2 (`BACKUP_TARGETS=supabase,medusa`, `neon` retired), **so that** the one dataset has a copy outside GCP before anything moves.
**Acceptance:** `db-backup.sh` gains a `medusa` target (same `pg_dump -Fc | gzip → rclone → verify` path); the GCP job reaches the private IP (`medusa-conn` connector) with a DSN from Secret Manager; one run lands a verified `medusa/YYYY/MM/DD/…dump.gz` in `miyagi-db-escrow`; `BACKUPS.md` says so. **Ships first, on its own, ahead of the rest of the epic.**
**Risk:** high

### Story 1.2 — arm64 images built in CI, pulled by sha
**As** the platform, **I want** GitHub Actions to build `linux/arm64` images of both apps into private GHCR, tagged by sha, with the exact build args `cloudbuild.yaml` passes, **so that** the 2 shared cores never compile Next.js and a rollback is a restart.
**Acceptance:** Both app repos push `ghcr.io/danybgoode/<app>:<sha>` on merge to `main`; the build args are **derived** from each `cloudbuild.yaml` and a spec asserts parity; Cloud Build keeps deploying GCP untouched until S2.
**Risk:** high

### Story 1.3 — The compose stack on the VM
**As** the platform, **I want** `infra/oci/` (compose + `update.sh`) running medusa, web, postgres 17 and redis on `/data/miyagi` with mem/cpu limits, joined to panfleto's Caddy through an external `edge` network, **so that** Miyagi runs on the free box without touching panfleto.
**Acceptance:** Limits: web 1.5G, medusa 1.25G, postgres 1.5G, redis 128M, plus `cpus:` caps; `docker ps` before/after shows panfleto + aomx never restarted; panfleto's `Caddyfile` changes by exactly one `import` line; secrets live in a root-only `deploy/oci/.env` written by a script that reads Secret Manager as the operator (never `.env.local`).
**Risk:** high

### Story 1.4 — TLS at the VM, Full (Strict)
**As** the platform, **I want** Caddy to serve Miyagi hosts with the Cloudflare Origin CA cert (wildcard + apex) and `oci.miyagisanchez.com` proxied through Cloudflare, **so that** the VM is reachable exactly the way prod will be, with no HTTP-01 dance.
**Acceptance:** `https://oci.miyagisanchez.com` returns 200 through Cloudflare Full (Strict); `openssl s_client -connect 159.54.158.4:443 -servername oci.miyagisanchez.com` shows the Origin CA cert.
**Risk:** high

### Story 1.5 — A restored copy of prod, proven on ARM
**As** the product owner, **I want** a restored copy of the prod Medusa DB booting on the VM, with images, Redis and orders proven, **so that** the cutover moves a stack already seen working.
**Acceptance:** `/health` 200; product count equals GCP's; a real `/api/img` request returns an image (ARM `sharp`/libvips proven — a green build is not evidence); a test order reaches a subscriber (Redis event bus proven).
**Risk:** high

### Story 1.6 — Crons, backups and a restore drill as VM timers
**As** the platform, **I want** systemd timers for the 5 `/api/cron/*` jobs, the nightly Medusa dump to R2 **and** the OCI bucket, and a weekly restore drill, **so that** nothing depends on Cloud Scheduler or Cloud SQL backups anymore.
**Acceptance:** Timers exist but the 5 cron timers stay **disabled** until S2 (no double-run with Cloud Scheduler); the backup lands in both buckets (OCI via instance principal, no keys on host); the drill restores the newest dump into a throwaway container and posts row counts to Telegram; a failure alerts Telegram; the backup connects as a dedicated **read-only** role (`pg_read_all_data`), never the app's role (PR #206 review: the GCP job reuses `DATABASE_URL` only until Cloud SQL is deleted).
**Risk:** high

### Story 1.7 — Latency measured, VM vs Cloud Run
**As** the product owner, **I want** p95 page latency for `/`, one PDP and one shop page on `oci.` vs prod, recorded in this sprint doc, **so that** we know the 2-core box keeps the site as fast before we flip.
**Acceptance:** A table of measured p95s (cold + warm) in this doc; any page >25% slower is named with its cause before S2 starts.
**Risk:** high

## Decisions made while building (2026-10-15)
- **D9 · `infra/oci/`, not `deploy/oci/`.** The root repo's CI only watches `infra/**`; the stack's
  invariants (`infra/oci/test/oci-stack.test.mjs`) run in the same `guards` step as `infra/gcp/test`.
- **D10 · The dark copy runs Medusa in `server` mode** (HTTP only — jobs do not run and no event is
  processed). ⚠️ Corrected by the PR #209 review: server mode still ENQUEUES events into Redis, so the cutover
  must flush Redis before switching to `shared` (sprint-2 S2.3).
  It runs on a restored copy of prod with production credentials, and its jobs reach the real world
  (Mercado Libre reconciliation, the sweepstakes draw). So S1.5 proves Redis by Medusa booting on its
  Redis event bus, workflow engine and locking; **"an order reaches a subscriber" moves to S2.6**, after
  the cutover sets `MEDUSA_WORKER_MODE=shared`.
- **D11 · Images are public on GHCR** — both app repos are public, so the VM pulls anonymously (no
  registry credential on the host, panfleto's pattern) and the arm64 runners are free.
- **D12 · Tenants plug into panfleto's Caddy through `/opt/edge/sites` + the `edge` network**
  (danybgoode/justread#30), never by editing its Caddyfile, which panfleto's `update.sh` resets to
  `origin/main` on every deploy — the way aomx's hand-added route was lost.
- **D13 · Credentials move in ONE operator-run step, `infra/oci/bootstrap.sh`.** It reads Secret Manager as
  Daniel and streams each value into a 0600 file on the VM (owned by the deploy user, which the `docker` group already makes root-equivalent); Origin CA keys are generated on the VM.
  The agent never handles a secret (the auto-mode classifier refuses it, correctly).

- **D14 · Miyagi's Caddy file names every host; no catch-all.** The first draft's `https://` catch-all (for
  Cloudflare-for-SaaS tenant domains) took over the SHARED Caddy's TLS: panfleto.win, app.panfleto.win and
  aomx's host were served `CN=miyagisanchez.com` — found by the fresh reviewer, reproduced and then proven
  fixed with `openssl s_client` per host on the VM. Cost today: none — the S2.1 census saw zero tenant-domain
  requests. When the first tenant domain moves, it gets its own named block.

## Sprint QA
- **api spec(s):** a pure spec on the build-args derivation (S1.2: parity with `cloudbuild.yaml`), a spec on `db-backup.sh`'s target dispatch (S1.1: `medusa` dumps, unknown target fails loud), each observed red once by mutation.
- **browser smoke owed:** yes, to Daniel — the walkthrough below against `oci.miyagisanchez.com` (restored copy, not live data).
- **deterministic gate:** each repo's CI green; `node --test "scripts/**/*.test.mjs"` in this repo.

## Sprint 1 — Smoke walkthrough (do these in order)
Env: the Oracle VM, dark · https://oci.miyagisanchez.com

1. Open https://oci.miyagisanchez.com
   → the Miyagi home page renders, with product images.
2. Open any product page on https://oci.miyagisanchez.com
   → the product photo loads (proves ARM `sharp`).
3. In the R2 bucket `miyagi-db-escrow`, open `medusa/` for today's date
   → one `medusa-<timestamp>.dump.gz` from last night's run.
4. In Telegram (`MiyagiDevopsTele`), look for the weekly restore-drill message
   → row counts for the restored copy, no error.
5. Open https://app.panfleto.win
   → panfleto still works (the VM's other tenant was not disturbed).

If any step fails, note the step number + what you saw — that's the bug report.
