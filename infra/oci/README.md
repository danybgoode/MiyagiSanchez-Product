# Miyagi on the Oracle VM — operate

Production since **2026-10-16** (epic [`miyagi-to-oracle-vm`](../../Roadmap/09-platform-infra/miyagi-to-oracle-vm/README.md)).
GCP is deleted; nothing of Miyagi runs anywhere else.

| | |
|---|---|
| Host | `panfleto-prod`, OCI A1 Always Free (2 OCPU / 12 GB), mx-queretaro-1, `159.54.158.4` |
| Access | `ssh -i ~/.ssh/panfleto_oci ubuntu@159.54.158.4`. When it times out, your IP rotated: run `../fluxonline/deploy/allow-my-ip.sh` |
| Neighbours | panfleto (`/opt/panfleto`, owns Caddy `deploy-caddy-1`) and aomx. Restarting Caddy takes **every** tenant offline |
| Stack | `/opt/miyagi/infra/oci`: `docker-compose.yml` (postgres, redis, medusa, web), capped ≤ 5 GB / ≤ 1.75 CPU |
| Edge | Cloudflare (proxied, Full Strict) → Caddy → `/opt/edge/sites/miyagi.caddy` → the `edge` network. Origin CA certs in `/opt/edge/certs`, valid until 2041 |

## Deploy and roll back
A merge to `main` in either app repo only **builds** `ghcr.io/danybgoode/{miyagisanchez-storefront,miyagisanchez-backend}:main` (arm64,
public). Nothing deploys by itself. Once the image build is green:

```bash
/opt/miyagi/infra/oci/update.sh   # pulls this repo + both :main images by digest, migrates, health-checks, validates Caddy
```

To roll back, add `MEDUSA_IMAGE_PIN=ghcr.io/danybgoode/miyagisanchez-backend:<sha>` (or `WEB_IMAGE_PIN=…`) to
`/opt/miyagi/infra/oci/.env` and re-run `update.sh`. A pin always wins over `:main`; delete the line to roll forward.

## Secrets: two copies, and only two
`.env` (DB passwords), `medusa.env`, `web.env` and `backup.env` hold production's secrets: 0600, owner `ubuntu`. The
**only** other copy is Daniel's password manager (one note per file, plus `CLOUDFLARE_API_TOKEN`,
`CLOUDFLARE_ACCOUNT_ID`, `SERPAPI_KEY`, `GOLDEN_BEANS_FLAG_SYNC_KEY_{BACKEND,FRONTEND}`). The nightly backups do
**not** include these files. To change a value, edit the VM file, run `update.sh`, **and update the password
manager**. `bootstrap.sh` is historical: its source (GCP Secret Manager) is deleted.

## Timers (UTC)
| When | Unit | What |
|---|---|---|
| 04:45 daily | `miyagi-backup` | `backup.sh`: Medusa (as `backup_ro`) and Supabase → R2 `miyagi-db-escrow/{medusa,supabase}/YYYY/MM/DD/` **and** OCI bucket `miyagi-backups`, each read back and size-checked; Telegram on any failure |
| 05:30 Sunday | `miyagi-restore-drill` | restores the newest Medusa dump into a scratch DB and compares counts with live |
| 06:00–10:00 daily | `miyagi-cron-*` | launchpad-campaigns, domain-lapse-sweep, print-pending, order-autoconfirm, merchant-lifecycle-sweep → `/api/cron/<name>` with `CRON_SECRET` |
| 15:00 daily | `miyagi-cron-p2s-nudges` | prompt-to-shop day 1/3/7 nudges → `/api/cron/p2s-nudges` with `CRON_SECRET` (09:00 Mexico City) |

Logs: `sudo journalctl -u miyagi-backup.service -n 50`, `docker compose logs -f medusa`.

## Restore Medusa from a dump
```bash
rclone copyto r2:miyagi-db-escrow/medusa/YYYY/MM/DD/<file>.dump.gz ./m.dump.gz   # or oci os object get
gunzip m.dump.gz
docker compose exec -T postgres pg_restore -U medusa -d <empty-db> --no-owner < m.dump
```

## Known gaps (2026-10-16)
- `PRINT_PDF_URL`/`PRINT_PDF_SECRET` are unset (they were on Cloud Run too), so print-PDF rendering returns a
  clean 503. The `print-pdf` service it called is deleted; its source is in the web repo's `services/print-pdf`.
- `CLOUDFLARE_API_TOKEN`/`CLOUDFLARE_ZONE_ID` and `SERPAPI_KEY` are unset (also never on Cloud Run): seller
  custom-domain setup and the supply-batch routes throw.
- Every first R2 upload returns `501 NotImplemented`; rclone's retry succeeds.
- The restore drill covers Medusa, not Supabase.
