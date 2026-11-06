---
epic: promoter-panel
sprint: 2
title: "El negocio"
risk: high
phase: Locking architecture
stories_total: 2
stories:
  - id: S2.1
    title: "«El negocio»: one form for the lead and the shop"
    as_a: "a promoter"
    i_want: "to type a merchant's data once"
    so_that: "saving a lead and opening the shop never ask the same thing twice"
    risk: high
    status: planned
  - id: S2.2
    title: "The panel copy and the choice lists"
    as_a: "a promoter recruited on the street"
    i_want: "every screen in plain words, and choices instead of free text"
    so_that: "I understand what to do without asking anyone"
    risk: low
    status: planned
---
# El panel del promotor: open a shop in one visit, manual-first, in four steps — Sprint 2: El negocio

**Status:** ⬜ not started

## Stories

### Story 2.1 — «El negocio»: one form for the lead and the shop
**As** a promoter, **I want** to type a merchant's data once, **so that** saving a lead and opening the shop never ask the same thing twice.
**Acceptance:** «Guardar para después» saves the lead only. «Abrir su tienda» saves the lead, creates the shop and links them. The name, location and email are typed once. Only the business name and WhatsApp are required. A WhatsApp already used by this promoter offers «Sí, seguir con ese» / «No, es otro».
**Risk:** high

### Story 2.2 — The panel copy and the choice lists
**As** a promoter recruited on the street, **I want** every screen in plain words, and choices instead of free text, **so that** I understand what to do without asking anyone.
**Acceptance:** Every string comes from `promotorPanel` in the locales and matches the seed's copy. Free text only for the business name, the owner's name, product names and notes. «¿Qué vende?», «Categoría principal», «¿Vende hoy en otra plataforma?», «¿Por dónde prefiere que le hablen?» and «¿Qué tan interesado está?» are dropdowns. The postal code fills colonia, municipio and estado. No «cerrar / cierre», no English.
**Risk:** low

## Build contract
Cite the epic README's locked decisions (D1–D12). Escalate per WAYS-OF-WORKING → *Escalate, don't guess*.

## Sprint QA
- **api spec:** e2e/promoter-panel-form.spec.ts (the lists come from the platform's constants; the form's two actions call the right routes in order)
- **api spec:** e2e/seller-acquisition-copy.spec.ts no-cerrar check extended to promotorPanel; dictionary contract
- **browser smoke owed:** yes, to Daniel: open a lead and a shop on his phone
- **deterministic gate:** `tsc --noEmit` + `npm run build` + Playwright `api` green before merge; every new spec seen red under a mutation

## Sprint 2 — Smoke walkthrough (do these in order)
Env: production · https://miyagisanchez.com

1. Go to https://miyagisanchez.com/promotor/cerrar and enter your promoter code
   → «Tu panel de promotor» with the stepper «1 El negocio · 2 Sus productos · 3 Cobra · 4 Entrégala»
2. Fill only «Nombre del negocio» and «WhatsApp del dueño», pick the other fields from the lists, then «Guardar para después»
   → «Guardado. Lo encuentras en Mis negocios cuando vuelvas.»
3. Open the same lead and tap «Abrir su tienda»
   → «Listo, la tienda de {nombre} ya existe…», without typing anything again

If any step fails, note the step number + what you saw — that's the bug report.
