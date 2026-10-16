# GCP provisioning — Medusa backend

> **RETIRED 2026-10-16. Miyagi's production now runs on the Oracle VM: see [`infra/oci/`](../oci/)**
> (epic [`miyagi-to-oracle-vm`](../../Roadmap/09-platform-infra/miyagi-to-oracle-vm/README.md)). These
> resources were deleted: Cloud Run `medusa-web`, `miyagi-web`, `medusa-web-staging`; Cloud SQL `medusa-pg`;
> Memorystore; `medusa-conn`; the ALB; the Cloud Build triggers; and the `frontend-*` schedulers. **Do not
> run** `deploy*.sh`, `provision.sh`, `provision-cloudsql.sh`, `provision-frontend.sh`, `provision-alb-frontend.sh`,
> `provision-scheduler-frontend.sh`, `provision-staging.sh` or `cicd-setup*.sh`: they recreate billing
> infrastructure for a rail that no longer exists. Their static guards (`test/deploy-invariants*.test.js`,
> `alb-invariants`, `scheduler-invariants`) still pass because they only read these files. Delete the guards
> together with the scripts if the scripts are ever removed. What remains live in `miyagisanchez-prod`:
> `db-backup` (Supabase only, `backups/`), `print-pdf`, `pmo-smalldocs` and the two Telegram notifiers.

Reviewable scripts to stand up the Medusa backend on **Cloud Run (us-east4)**, co-located
with Neon (AWS us-east-1). Nothing here runs automatically — read, set the variables, then run.

Target: see [`tasks/gcp-migration.md`](../../tasks/gcp-migration.md).
Recovery / rollback / health-probe / admin-exposure posture: see
[`tasks/backend-recovery-runbook.md`](../../tasks/backend-recovery-runbook.md) (Backend Production
Readiness S3). Admin-exposure decision: **KEEP `/app` + harden** (`DISABLE_MEDUSA_ADMIN` unset);
`deploy.sh`'s `ADMIN_CORS` default includes `api.miyagisanchez.com` (the admin's own origin).

## Billing — resolved

Project **`miyagisanchez-prod`** is created under `lolis8755@gmail.com` and linked to **OPEN**
billing account **`019B4F-8DBBBA-3EE80C`** (gcp-account-migration cutover, 2026-07-19). The scripts
default to these. Run as the `lolis-profile` config (the `lolis8755@gmail.com` identity).

The old `miyagisanchezback-497722`/leroytramafat project was kept as the rollback path through
Sprint 4 and is **DECOMMISSIONED** as of 2026-07-28: all build triggers **deleted** (not merely
disabled — a disabled trigger can be re-enabled by replaying a stale config export, which is exactly
how the old deploy rail came back to life on 2026-07-28), all Cloud Run services `ingress=internal`,
Cloud SQL `STOPPED`. The project itself still exists — **final deletion and billing unlink are
pending Daniel's go** — but it is no longer a usable rollback and nothing should be deployed to it.

## Order

```bash
# 0. Use the right identity
gcloud config configurations activate lolis-profile

# 1. Enable APIs, provision AR + Memorystore + VPC connector + SA + secret shells
#    (project + billing-link steps are idempotent — already done, will be skipped)
bash infra/gcp/provision.sh

# 2. Populate secret VALUES (see prompts the script prints).
#    Rotate JWT_SECRET / COOKIE_SECRET here (do NOT reuse 'supersecret').
#    Set DATABASE_URL to Neon's POOLED endpoint (host contains '-pooler').

# 3. Build the image with Cloud Build and deploy the web service
bash infra/gcp/deploy.sh
```

## After deploy

- Map `api.miyagisanchez.com` → the Cloud Run service (or route via your existing Cloudflare tunnel).
- Repoint Vercel `MEDUSA_STORE_URL`, `STORE/ADMIN/AUTH_CORS`, Stripe `/hooks/payment/...`, MP webhook.
- Re-enable Medusa admin (drop the `NODE_ENV==='production'` disable in `medusa-config.ts`).
- Move `reconcile-checkouts` to a Medusa scheduled job; verify Session A reconciliation; decommission Render.

Initial deploy runs a **single shared-mode** service (`min-instances=1`). Split into
`server` + `worker` (set `MEDUSA_WORKER_MODE`) only when traffic warrants.

## CI/CD (automated deploys)

After the first manual deploy, `apps/backend/cloudbuild.yaml` + a Cloud Build trigger
give you push-to-main auto-deploy (replacing Render's auto-deploy). The deploy step only
swaps the image; Cloud Run preserves env/secrets/connector/SA set by `deploy.sh`.

```bash
# One-time GitHub connection is a console step (OAuth) — see cicd-setup.sh header.
bash infra/gcp/cicd-setup.sh   # grants Cloud Build SA deploy rights; creates the trigger
```

Terminal success/failure notifications are separate project-local resources; they do not migrate
with the trigger or Secret Manager values. Provision both filtered consumers after any project
move, from the backend repo under `lolis-profile`:

```bash
PROJECT_ID=miyagisanchez-prod bash infra/gcp/deploy-cicd-telegram-notifier.sh
PROJECT_ID=miyagisanchez-prod bash infra/gcp/deploy-cicd-telegram-notifier-frontend.sh
```

Both subscribe to the new project's `cloud-builds` topic. A real terminal event (or a controlled
synthetic Pub/Sub event) is the smoke; the functions merely existing is not sufficient evidence.
