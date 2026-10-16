---
status: shipped  # AUTHORITATIVE epic status (SSOT) — scaffolded | in-progress | shipped | archived. Set shipped at epic close.
phase: Shipped       # the executive ladder — Shaping | Locking architecture | Building | Verifying | In review | Shipped.
                     # WRITTEN at each cadence event, never inferred. Shipped = merged AND deployed.
slug: miyagi-to-oracle-vm
title: "Miyagi on the Oracle VM — move the always-on stack off GCP"
area: 09-platform-infra
risk: high
type: chore
sprints_total: 3
stories_total: 18   # the sum of every sprint's stories_total — keep it in step when a story is added
intent_match: 80   # copied from the seed by scaffold-epic (intent-match); the reader at the lock may update it
quote_low_usd: 20    # ≈ API $ — copied from the seed's `quote:` by scaffold-epic (finops); null = not quoted, never 0
quote_high_usd: 120
quote_basis: "M, n=0, wide"
hypothesis: null   # the result record — copied from the seed by scaffold-epic; null = no target (never an error)
target_metric: null   # which number: a North Star input key (grounded) or free text (not grounded)
target_from: null   # from what, a number
target_to: null       # to what, a number
read_date: null       # YYYY-MM-DD; null = 30 days after shipping, derived by the extract and never written back
verdict: null        # proven | disproven | unclear — stamped by `node scripts/epic-read.mjs --epic <slug> --write`
verdict_actual: null
verdict_evidence: null   # https:// link · north-star:<input>@YYYY-MM-DD · ab:<experiment> (unclear: the reason)
verdict_at: null
persona: null   # for whom, doing which job — copied from the seed (grounded-bets D1)
grounded: null   # true = traced to a North Star input · false = funded anyway (reason below) · null = Bug/Chore or never asked
grounded_reason: null   # only with grounded: false
flag_key: null   # the epic's flag, decided at refine Stage 6b and copied from the seed; null = no flag. The epic page shows its state
target_segment: null   # the bet's measurement (one-bet-wired D1), copied from the seed: TARS target segment
adopted_event: null
retained_event: null
retention_days: null
satisfied_event: null
build_order: 4       # integer position in the ONE global build sequence — the SSOT once the epic
                     # exists (the seed's value is only a fallback). Fill it in at the betting
                     # table; plain integers, no "#2a" suffixes. See 00-ideas/README.md → Ordering.
actual_usd: 25.19
actual_mtok: 72.1
actual_models: "claude-opus-5-5 ≈$25.19"
actual_basis: "this machine · 2026-10-16 · 1 session · prices 2026-10-02"
---

# Epic: Miyagi on the Oracle VM — move the always-on stack off GCP

> **Area:** 09-platform-infra · **Risk:** high · **Class:** Chore · **Scope seed:** [`00-ideas/seeds/miyagi-to-oracle-vm.md`](../../00-ideas/seeds/miyagi-to-oracle-vm.md)
<!-- Class (above) is the Stage-2 classification: Feature, Spike, Bug, or Chore — see SKILL.md's
     Stage 2 table; sourced from scaffold-epic.mjs's --type flag (a fixed 4-value enum, not free
     text — a longer description belongs in the Why section below, not here; this comment never names
     that heading literally, so an edit anchored on it cannot land inside the comment).
     Optional: if this epic was ALSO tagged with an archetype at refining (see spike-role-archetypes.md),
     append " · **Archetype:** <Prototyper|Builder|Sweeper|Grower|Maintainer>" after Class. Omit entirely
     for the Builder default — untagged is fine.
     Scope-seed link: always points at seeds/ — lifecycle lives in the seed's `status:` frontmatter, not
     in a folder path (see 00-ideas/README.md). If this epic was scaffolded from a doc that has no seeds/
     entry, link that doc instead and migrate it to seeds/ when convenient — don't fabricate a seeds/ file
     that doesn't exist. -->

## Why
Miyagi is pre-launch with one user, but it pays for an always-on GCP footprint sized for a live
marketplace. Daniel already has an Oracle Always Free ARM VM (`panfleto-prod`, Querétaro) sitting at load
0.00 with 9.7 GB of free RAM. This epic moves Miyagi's always-on stack onto it, keeps the scale-to-zero
services on Cloud Run's free tier, and gives the Medusa database the offsite backup it is missing today —
so the platform keeps running at the same speed for roughly zero fixed infra cost. The measurements, the
decisions and the research behind every number are in the [seed](../../00-ideas/seeds/miyagi-to-oracle-vm.md).

## Platform-first note
No data-model change: a host relocation, as `postgres-neon-to-cloudsql` was. Medusa stays the system of
record for commerce; Supabase stays where it is (the open `spike-supabase-colocation` is re-framed by this
move and should be re-asked after S2). The VM pattern is not new either — panfleto proved it on this box.

## Locked decisions (2026-10-15, Daniel)
- **D1 · Backups:** nightly `pg_dump` of Medusa to **R2** (offsite, WORM — the existing `miyagi-db-escrow`)
  **and** the OCI bucket (fast restore), plus a weekly restore drill. No PITR, no Supabase mirror.
- **D2 · Staging:** retired, not moved.
- **D3 · Cutover:** a short maintenance window behind Medusa's kill switch, not live replication.
- **D4 · Teardown timing:** GCP's heavy parts are deleted **right after S2.6's money-path smoke passes** —
  no waiting period. Daniel still confirms the printed delete list (S3.1).
- **D5 · S1.1 ships first, alone** — the live Medusa DB has no offsite copy today.
- **D6 · Panfleto and aomx stay** on the VM; Miyagi joins through one `import` line in panfleto's Caddy.
- **D7 · The tenancy is Pay-As-You-Go but stays inside Always Free** — no paid OCI resource is created.
- **D8 · GCP projects outside `miyagisanchez-prod` are Daniel's to delete** (S3.4 hands him the list).

## What already exists (reuse, don't rebuild)
- `../fluxonline/deploy/` — compose (Caddy-only ports, state on `/data`), `update.sh` (pull by sha),
  `backup.sh` + systemd timer (instance-principal upload, no keys on host), `allow-my-ip.sh`.
- `infra/gcp/backups/db-backup.sh` + `BACKUPS.md` — the R2 escrow rail; S1.1 adds a target.
- `apps/miyagisanchez/cloudbuild.yaml`, `apps/backend/cloudbuild.yaml` — the build args and deploy shape to mirror.
- `infra/gcp/cloudflare-origin-cert.mjs`, `cloudflare-cutover-flip.mjs` (`--domain`, `--extra-hosts`),
  `cloudflare-saas-fallback-provision.mjs`, `cloudflare-cache-provision.mjs`.
- The 5 `/api/cron/*` routes the `frontend-*` schedulers call today.
- `print-pdf` / `pmo-smalldocs`: public + shared secret (`lib/print-pdf-client.ts`) — they stay on Cloud Run.
- The money-path CI gate, `scripts/live-smoke.mjs`, the nightly browser smoke.

## Scope — stories
| Sprint | Story | Risk |
|---|---|---|
| 1 | 1.1 The live Medusa DB gets an offsite copy — today | high |
| 1 | 1.2 arm64 images built in CI, pulled by sha | high |
| 1 | 1.3 The compose stack on the VM | high |
| 1 | 1.4 TLS at the VM, Full (Strict) | high |
| 1 | 1.5 A restored copy of prod, proven on ARM | high |
| 1 | 1.6 Crons, backups and a restore drill as VM timers | high |
| 1 | 1.7 Latency measured, VM vs Cloud Run | high |
| 2 | 2.1 The Host census is the flip list | high |
| 2 | 2.2 A timed rehearsal | high |
| 2 | 2.3 Freeze, final dump, restore | high |
| 2 | 2.4 Certs proven before DNS moves | high |
| 2 | 2.5 The origin flip | high |
| 2 | 2.6 Money-path smoke on the VM | high |
| 3 | 3.1 Delete the GCP heavy parts | high |
| 3 | 3.2 Artifact Registry trimmed | high |
| 3 | 3.3 The free-tier services still answer | high |
| 3 | 3.4 The GCP reminder list handed to Daniel | high |
| 3 | 3.5 The docs say what is true | high |

## Deploy order
S1.1 first and alone (GCP job + root-repo script). Then S1.2 in both app repos (additive CI, Cloud Build
keeps deploying GCP). S1.3–S1.7 on the VM, dark. S2 is operations, in the order of its stories; the
rollback until S2.6 passes is flipping Cloudflare back to the GCP ALB. S3 only after S2.6.

## Definition of Done (epic)
- [ ] All sprints merged to `main` + smoke-tested (gaps stated — `node scripts/owed-ledger.mjs` counts what is still owed)
- [ ] Each `sprint-N.md` has its smoke walkthrough (real URLs)
- [ ] This README marked ✅; every sprint status ticked with commit refs
- [ ] `RETROSPECTIVE.md` written
- [ ] Product poster (`Roadmap/README.md`) updated
- [ ] Team memory + `MEMORY.md` index updated
- [ ] Durable learnings promoted to `Roadmap/LEARNINGS.md` (dedupe — sharpen, don't append)
- [ ] **Kill-switch (only if one was planned at refining — Stage 6b):** the flag slice shipped, the flag
      exists **in Golden Frijoles, in every env**, with the stated polarity, **and its switch is set there** —
      `frijoles flags get <key>` must print `on vN` or `off vN` in its PRODUCTION row (a bare `off` with no version
      means nothing is served there, so the app runs on its own built-in default). A newly synced flag goes live as written in its file; a sync never switches an existing one. *Verify-only — not a new gate; whether a high-risk epic needs one
      is decided at refining, not here.*
- [ ] Feature branch deleted; **this README's frontmatter `status: shipped`** (the SSOT — the board & Notion derive from it; run `node scripts/build-order.mjs`)
