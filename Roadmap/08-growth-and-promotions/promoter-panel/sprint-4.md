---
epic: promoter-panel
sprint: 4
title: "Cobra, el recibo, Entrégala and the panel's look"
risk: high
phase: Shipped
stories_total: 3
stories:
  - id: S4.1
    title: "«El recibo del negocio»"
    as_a: "a merchant who just paid a promoter"
    i_want: "a receipt on WhatsApp right away, with a page that shows whether my plan is on"
    so_that: "I have proof of payment and a way to reach Miyagi Sánchez if something's wrong"
    risk: high
    status: done
  - id: S4.2
    title: "The panel shell: stepper, «Cobra», «Entrégala»"
    as_a: "a promoter"
    i_want: "to always know where I am and what comes next"
    so_that: "opening a shop feels like four clear steps"
    risk: low
    status: done
  - id: S4.3
    title: "/admin/promoter on the site's components"
    as_a: "Daniel"
    i_want: "the promoter admin to look like the rest of the site"
    so_that: "its buttons read as buttons"
    risk: low
    status: done
---
# El panel del promotor: open a shop in one visit, manual-first, in four steps — Sprint 4: Cobra, el recibo, Entrégala and the panel's look

**Status:** ✅ merged — Storefront [#483](https://github.com/danybgoode/MiyagiSanchez-Storefront/pull/483), squash `952f2d9` · deployed 2026-11-06

## Stories

### Story 4.1 — «El recibo del negocio»
**As** a merchant who just paid a promoter, **I want** a receipt on WhatsApp right away, with a page that shows whether my plan is on, **so that** I have proof of payment and a way to reach Miyagi Sánchez if something's wrong.
**Acceptance:** In Cobra, «Sí, ya me pagó» shows «Mandarle su recibo», which opens WhatsApp to the owner's number with the written message and a link. The email goes out at the same moment when there is one. `/recibo/{token}` shows amount, option, promoter and date, and the status: Activo (card paid), Pendiente (transfer not yet approved), Listo (Gratis setup). It turns Activo when the transfer is approved. A tampered token gets 404. The page is noindex.
**Risk:** high

### Story 4.2 — The panel shell: stepper, «Cobra», «Entrégala»
**As** a promoter, **I want** to always know where I am and what comes next, **so that** opening a shop feels like four clear steps.
**Acceptance:** One stepper. «Cobra» keeps #476's split and transfer-first order on the new components. «Entrégala» shows «Ver su tienda», «Mandar por WhatsApp», «Copiar enlace» and the consent line. Every button is a `.btn`, every input has a label.
**Risk:** low

### Story 4.3 — /admin/promoter on the site's components
**As** Daniel, **I want** the promoter admin to look like the rest of the site, **so that** its buttons read as buttons.
**Acceptance:** Every button in /admin/promoter is a `.btn` variant; no raw Tailwind buttons remain there.
**Risk:** low

## Build contract
Cite the epic README's locked decisions (D1–D12). Escalate per WAYS-OF-WORKING → *Escalate, don't guess*.

## Sprint QA
- **api spec:** e2e/promoter-receipt.spec.ts (token sign/verify/tamper, status per attribution/transfer state, the WhatsApp message built from the locale, the email sent at the same call)
- **api spec:** e2e/promoter-panel-shell.spec.ts (no raw-Tailwind buttons in the panel or /admin/promoter)
- **browser smoke owed:** yes, to Daniel: a card close and a transfer close with a test promoter, checking the receipt page turns Activo
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red under a mutation

## Sprint 4 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. In https://miyagisanchez.com/promotor/cerrar, finish a test shop and pick «Plan Gratis · tienda lista»; tap «Sí, ya me pagó», then «Mandarle su recibo»
   → WhatsApp opens with the receipt message and a link
2. Open the link
   → «Recibo de {negocio}» with the amount, the option, the promoter and a status
3. (money path, owed to Daniel) Pay our share by transfer, then approve it in https://miyagisanchez.com/admin/promoter
   → the receipt page turns «Activo»
4. Go to https://miyagisanchez.com/admin/promoter
   → its buttons look like the rest of the site

If any step fails, note the step number + what you saw — that's the bug report.
