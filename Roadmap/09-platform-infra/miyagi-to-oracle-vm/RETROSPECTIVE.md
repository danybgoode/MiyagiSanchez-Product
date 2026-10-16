# Miyagi on the Oracle VM — move the always-on stack off GCP — Retrospective

_Closed: 2026-10-16_
_Intent: yes_
_Quote vs actual: $20–120 (M, n=0, wide) → ≈$25 (−79% vs the quote's top)_
_Crew (actual): claude-opus-5-5 ≈$25.19 · reviewers codex + antigravity (cross-family, every S1 PR) and a fresh pr-reviewer on the four S1 PRs · prose Claude — one session end to end. Daniel ran every production-changing command (freeze, flip, teardown, secrets) as a `!` command, because the classifier blocks those for the agent._

## What shipped
Miyagi's always-on stack left GCP for the Oracle Always Free A1 VM `panfleto-prod`. It now runs there beside
panfleto and aomx, behind panfleto's Caddy.

- **S1, the dark rail.** Medusa now backs up to R2 (danybgoode/miyagi-product-management#206); before that, the
  nightly job had been dumping an abandoned Neon copy. Both apps now build arm64 images on GitHub's free ARM runners
  (danybgoode/miyagisanchezcommerce#432, danybgoode/medusa-bonsai-backend#204). The `infra/oci/` stack is Postgres,
  Redis, Medusa and the storefront, capped at ≤ 5 GB and ≤ 1.75 CPU, plus systemd crons, nightly backups to R2 and
  OCI, and a weekly restore drill (danybgoode/miyagi-product-management#209, #210). panfleto's Caddy imports tenant
  site files over a shared `edge` network (danybgoode/justread#30).
- **S2, the cutover (2026-10-16).**
  - 13:58Z freeze, then the final dump and the restore. Row counts were identical to the rehearsal.
  - Redis was flushed before shared mode, and SNI was proven on all 7 host families.
  - 14:06Z DNS flip. `--audit-ip` then found 0 records on the old IP.
  - **Checkout was off for about 10 minutes** (danybgoode/miyagi-product-management#212).
- **S3, GCP deleted.**
  - The always-on stack and ~93 GB of images went the same day. The Supabase backup moved to the VM
    (danybgoode/miyagi-product-management#213), and the unused leftovers were deleted.
  - Daniel then deleted `miyagisanchez-prod` and the 3 spare projects. Miyagi's fixed infrastructure cost is now ~0.

## What went well
- **A census built from logs, not memory.** It produced exactly the flip list. Auditing by **content**
  (`--audit-ip`), not by name, caught `cname.` and `gcp.`, the same records that were missed in July.
- **The rehearsal made the window measurable.** Identical row counts turned "did we lose anything" into a fact.
- **Reading the live inventory before deleting anything.** It caught three plan errors: `db-backup` was the only
  Supabase backup; `bootstrap.sh` still wrote the dark-period prefix; `provision-db-backup.sh` still named the
  deleted VPC connector.
- **Cross-family review was useful.** Codex and agy found the argv secret exposure and the dark-period prefix
  collision. Two of their confident claims were false ("an empty import glob breaks Caddy", "fallback_sni grants a
  valid cert") and were verified away rather than acted on.

## What we learned
- **A Caddy catch-all site on a SHARED Caddy hijacks every tenant's TLS.** `https://` / `:443` became a TLS policy
  with no host matcher, and panfleto.win was served `CN=miyagisanchez.com`. Reproduced with openssl, then fixed by
  naming every host (D14).
- **Medusa forces TLS on any non-localhost `DATABASE_URL`.** A compose service name counts as non-localhost, so
  Medusa crash-looped until `?sslmode=disable`.
- **`server` mode still ENQUEUES events.** The dark copy's Redis held jobs that would have fired at real people on
  the first `shared` boot. Flush before switching (D10).
- **A provisioner's default IS the live config.** This bit three times in one epic (the backup provisioner,
  bootstrap's prefix, bootstrap's Cloud Run env source). After any teardown, re-read every script that could
  recreate what you just deleted.
- **One account's project list is not the inventory.** Two "deleted" projects were alive under other accounts.
  Check each under its own credentials.
- **The load balancer's request logging was OFF.** A census that returns zero is a fact to explain, not "no traffic".

## Gaps / follow-ups
- **OWED to Daniel: the S2.6 live money-path smoke** (a real Stripe checkout, then Clerk sign-out/in on the VM).
  Descoped under the pre-launch rule; never run. GCP is gone, so a failure is fixed forward.
- **The deploy rail is manual.** A merge builds `:main`; the deploy is `ssh … /opt/miyagi/infra/oci/update.sh`.
  Making it automatic needs a VM deploy key in GitHub secrets, which is Daniel's call.
- **Secrets have exactly two homes:** the VM's env files and Daniel's password manager. `bootstrap.sh`'s Secret
  Manager reads are now dead code. An encrypted env backup (age to the existing SSH key) was offered and declined.
- **Pre-existing, not regressions:** `CLOUDFLARE_API_TOKEN`/`CLOUDFLARE_ZONE_ID` and `SERPAPI_KEY` were never on
  Cloud Run either. Seller custom-domain setup and the supply-batch routes throw without them.
- **Each first R2 upload returns `501 NotImplemented`;** rclone's retry succeeds. Worth finding why.
- **The Sunday restore drill only restores Medusa,** not the Supabase dump.
- **Retired GCP scripts stay in `infra/gcp/`** under a RETIRED banner; their static guards still pass. Delete
  scripts and guards together if they are ever removed.
