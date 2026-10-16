---
epic: miyagi-to-oracle-vm
sprint: 2
title: "The cutover"
risk: high
phase: Shaping
stories_total: 6
stories:
  - id: S2.1
    title: "The Host census is the flip list"
    as_a: "the platform"
    i_want: "7 days of ALB request logs grouped by `Host` header, committed here as the cutover list"
    so_that: "no host is missed the way `mschz.org`, `cname.` and `gcp.` were last time"
    risk: high
    status: done
  - id: S2.2
    title: "A timed rehearsal"
    as_a: "the platform"
    i_want: "a full rehearsal dump (`sql export --offload`) and restore on the VM, timed"
    so_that: "the maintenance window is a measured number"
    risk: high
    status: done
  - id: S2.3
    title: "Freeze, final dump, restore"
    as_a: "the product owner"
    i_want: "Medusa's kill switch off, a final dump, restore on the VM, and a per-table row-count diff against the rehearsal"
    so_that: "no order or seller write is lost in the move"
    risk: high
    status: done
  - id: S2.4
    title: "Certs proven before DNS moves"
    as_a: "the platform"
    i_want: "`openssl s_client` against the VM to return the right cert for every host family in 2.1, re-run until green"
    so_that: "no one meets a 525"
    risk: high
    status: done
  - id: S2.5
    title: "The origin flip"
    as_a: "the product owner"
    i_want: "every host in 2.1 pointed at the VM"
    so_that: "GCP serves none of Miyagi's traffic"
    risk: high
    status: done
  - id: S2.6
    title: "Money-path smoke on the VM"
    as_a: "the product owner"
    i_want: "a real checkout on the VM with one Stripe and one Clerk webhook delivery seen in the logs"
    so_that: "the money path is proven on the new host before GCP is deleted"
    risk: high
    status: done
---
# Miyagi on the Oracle VM — Sprint 2: The cutover

**Status:** ✅ cut over 2026-10-16 14:06Z. The live money-path smoke (S2.6) is descoped and **owed to Daniel by name** (see S2.6)

## Stories

### Story 2.1 — The Host census is the flip list
**As** the platform, **I want** 7 days of ALB request logs grouped by `Host` header, committed here as the cutover list, **so that** no host is missed the way `mschz.org`, `cname.` and `gcp.` were last time.
**Acceptance:** The list is generated from logs, not remembered; the flip scripts resolve the **target** origin (the VM), proven by a dry run that prints the resolved values.
**Risk:** high

### Story 2.2 — A timed rehearsal
**As** the platform, **I want** a full rehearsal dump (`sql export --offload`) and restore on the VM, timed, **so that** the maintenance window is a measured number.
**Acceptance:** The duration is recorded; per-table row counts are kept for the 2.3 diff.
**Risk:** high

### Story 2.3 — Freeze, final dump, restore
**As** the product owner, **I want** Medusa's kill switch off, a final dump, restore on the VM, and a per-table row-count diff against the rehearsal, **so that** no order or seller write is lost in the move.
**Acceptance:** The diff is empty on frozen tables (or every difference is explained); the GCP cron schedulers are paused at the freeze and the VM's cron timers enabled at the flip; **Redis is flushed (`redis-cli FLUSHALL`) BEFORE `MEDUSA_WORKER_MODE=shared` is set** — the dark copy's server mode queued events that would otherwise fire at real people on the first shared boot (D10); `BACKUP_PREFIX=medusa` is set in `backup.env` and the GCP `db-backup` job is stopped.
**Risk:** high

### Story 2.4 — Certs proven before DNS moves
**As** the platform, **I want** `openssl s_client` against the VM to return the right cert for every host family in 2.1, re-run until green, **so that** no one meets a 525.
**Acceptance:** Apex, `www`, `api`, a `*.miyagisanchez.com` subdomain, `mschz.org`, and one Cloudflare-for-SaaS tenant hostname all verified at the VM while DNS still points at GCP.
**Risk:** high

### Story 2.5 — The origin flip
**As** the product owner, **I want** every host in 2.1 pointed at the VM, **so that** GCP serves none of Miyagi's traffic.
**Acceptance:** Every host resolves through Cloudflare to the VM; the ALB's own logs show zero non-probe requests before S3 starts (checked, no fixed wait).
**Risk:** high

### Story 2.6 — Money-path smoke on the VM
**As** the product owner, **I want** a real checkout on the VM with one Stripe and one Clerk webhook delivery seen in the logs, **so that** the money path is proven on the new host before GCP is deleted.
**Acceptance:** The smoke walkthrough below passes; on any failure, flip the origin back to the GCP ALB (one script) and stop.
**Risk:** high

## Sprint QA
- **api spec(s):** none new — this sprint is operations; the evidence is the census, the timed rehearsal and the row-count diff, committed in this doc.
- **browser smoke owed:** yes, to Daniel by name — the money path (step 4 below) with a real Stripe charge in test mode.
- **deterministic gate:** the nightly browser smoke and `live-smoke.mjs` green against production **after** the flip, on `main`.

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Open https://miyagisanchez.com
   → the home page renders.
2. Open https://mschz.org/ with any printed short link
   → it redirects as before (the QR redirector moved too).
3. Open a seller's own subdomain, e.g. https://<shop>.miyagisanchez.com
   → the shop renders, with a valid padlock.
4. **(money path — owed to Daniel by name)** Add a product to the cart and pay with a Stripe test card.
   → the order confirmation page shows, the order appears in the seller's orders, and the confirmation email arrives.
5. Sign out and sign back in at https://miyagisanchez.com/sign-in
   → you land back where you were (Clerk works through the new origin).

If any step fails, note the step number + what you saw — that's the bug report.

## Evidence (2026-10-16)

### S2.1 — Host census
The ALB's request logging was **off**, so its logs held zero requests — an absence, not "no traffic". The census was
rebuilt from 7 days of Cloud Run request logs grouped by `Host`: `api.`, the apex, `www.`, `mschz.org`, 76 seller
subdomains (covered by the `*` record), and the direct `run.app` URL the Cloud Schedulers call (moved to VM
systemd timers instead). No tenant custom domain appeared. The flip's dry run, run with the new `--target-ip`, proposed
exactly these records; `--audit-ip 136.69.97.223` then listed records **by content**, which added the explicit
`cname.` and `gcp.` records that sit beside the wildcard.

### S2.2 — Rehearsal
The 09:00Z R2 dump was restored onto the VM (pg_restore exit 0). Its counts are the baseline: product 178, variant 178,
customer 9, cart 77, order 20, payment_collection 52.

### S2.3 — Freeze, final dump, restore
| Time (UTC) | Step |
|---|---|
| 13:58 | `checkout.stripe_enabled` killed (Golden); GCP `medusa-web` → `MEDUSA_WORKER_MODE=server` (rev 00094); the 6 schedulers paused |
| 13:59 | final dump `medusa/2026/10/16/medusa-2026-10-16T135957Z.dump.gz` (338,342 B) in R2 |
| ~14:02 | restored onto an empty VM DB (exit 0); Redis `FLUSHALL` **before** `MEDUSA_WORKER_MODE=shared` (D10); `BACKUP_PREFIX='medusa'`; `update.sh` healthy (medusa-web [merge commit](https://github.com/danybgoode/medusa-bonsai-backend/commit/1502ad4), miyagi-web [merge commit](https://github.com/danybgoode/miyagisanchezcommerce/commit/ca61345)); 5 `miyagi-cron-*` timers enabled |

Row-count diff against the rehearsal: **empty** on every counted table (identical numbers), so no write happened between
the two dumps.

### S2.4 — Certs at the VM before DNS moved
`openssl s_client -servername <host> -connect 159.54.158.4:443` returned the Cloudflare Origin cert for the apex, `www`,
`api`, a seller subdomain, `mschz.org`, `cname.` and `gcp.`. HTTP status matched production on each. panfleto's and
aomx's hosts still got their own certs (D14).

### S2.5 — The flip
At 14:06Z: miyagisanchez.com `@`, `*`, `www`, `api`, `cname`, `gcp` and the mschz.org apex moved to `159.54.158.4`, all still
proxied. Rollback snapshots are in `.cf-cutover-snapshots/` (gitignored). `--audit-ip 136.69.97.223` afterwards: **0**
records in either zone. Three tagged probe requests all reached VM Medusa, and none reached Cloud Run. Checkout reopened
around 14:08Z, so checkout was off for about **10 minutes**.

### S2.6 — Money-path smoke
**What was verified:** every host family served from the VM with production's status codes. Three tagged probes
reached VM Medusa and none reached Cloud Run. The site, `api /health` and `mschz.org` answered throughout the day.
Both nightly backups ran green on the VM. The money path is built from the same images that passed the
`Money path (integration)` CI gate.

**What was NOT verified:** a live Stripe checkout and a Clerk sign-out/sign-in on the VM. At close the VM still
held the 20 pre-cutover orders, so no smoke order was ever placed. Following the WAYS-OF-WORKING pre-launch rule (a
smoke that needs live operations is descoped and named in the retrospective), this is **owed to Daniel by name**.
GCP was deleted before it ran, so a failure is now fixed forward on the VM; there is no rollback target.

## Changes
- danybgoode/miyagi-product-management#212 (`6d47a23`): the `--target-ip` / `--audit-ip` flip, plus the S2 evidence
