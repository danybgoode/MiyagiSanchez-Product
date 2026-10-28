---
title: "Spike — CFDI autopilot for RESICO micro-merchants (multi-RFC PAC)"
slug: spike-cfdi-autopilot
status: ready
area: "02"
type: spike
appetite: S
underwritten_by: null
risk: high
epic: null
build_order: null
updated: 2026-10-27
intent_ask: verbatim
hypothesis: null
persona: "A Mexican micro-merchant on RESICO who must issue CFDI for every sale and has no accountant or invoicing software"
grounded: false
grounded_reason: "No strategy yet; run as the CFDI spike of the T1 review"
flag_key: null
intent_match: null
---

# Spike — CFDI autopilot for micro-merchants

> **Class:** Spike: an investigation that ends in a written decision, with no code and no slicing until the
> decision is approved. Run on 2026-10-27 at Daniel's request ("lets actually run the CFDI spike itself, no need for
> all the ceremony"). Sources are at the bottom. Web facts were checked on 2026-10-27; most come from accounting firms'
> and PAC vendors' write-ups, not the DOF, so every legal point below is an **input for the fiscal advisor**, not a
> conclusion.

## The ask, as given

> CFDI might be huge for that merchant sector with the recently approved ley de economia digital all small and
> micromerchants must find a seamless, almost autopilot way towards compliance. they are usually on the simplest
> regime, like resico for example. Do you see any cler path for integration? this is ok as well to put in the backlog,
> or well i mean in terms of prioritization lets evaluate

> lets actually run the CFDI spike itself, no need for all the ceremony

## Decision (summary)

1. **GO: build a CFDI autopilot as one epic after BYO Envía**, through a **multi-RFC PAC**. Each merchant becomes an
   issuing organization at the PAC, and Miyagi never holds their CSD.
2. **PAC: Facturapi first, Facturama as the named fallback.**
   - Facturapi's API plan covers multiple RFCs under one licence ($299 MXN/month + $0.60 per stamp). It has
     per-organization keys, global invoices and self-invoicing primitives.
   - Facturama is cheaper per folio ($1,650 MXN/year + $0.40–0.50 per folio), with a JSON multi-issuer API.
3. **The v1 autopilot does four things:**
   - a **fiscal profile once**;
   - **buyer self-invoicing** for any paid order in the month;
   - an **automatic monthly global invoice** for everything not invoiced;
   - a **monthly income summary** the merchant can hand to whoever files.

   **Filing returns is out of scope.**
4. **Blocking before the build: one fiscal-advisor session** (questions below), mainly whether Miyagi itself counts as
   a "digital intermediation platform" with reporting duties. The build doesn't start until that answer is written
   here.
5. **Five merchant conversations** run in parallel with the advisor (script below). They decide whether self-invoicing
   or the global invoice is the hook, and what merchants will pay.

## What changed since the review

- **The Ley de Economía Digital passed the Senate on 2026-10-20** (72–37 by most counts), unchanged from the Diputados
  version. The review said it was still pending in the Senate; that's now out of date.
  - It recognizes QR, NFC, cards and transfers as payment methods.
  - It obliges public bodies to accept them.
  - It lets Hacienda (SHCP) decide in which activities electronic payment can be required. Press reports a timetable
    from 2027; sectors and dates are still to be defined.
  - Its DOF publication date wasn't confirmed.
- **It still creates no invoicing duty.** CFDI pressure on micro-merchants comes from existing rules: CFDI 4.0 for all
  income, RESICO's rules and the platform regime. The law matters to us through **in-person-sales** (QR at the
  counter), which is already queued.

## The regime picture (inputs for the advisor)

- **RESICO for individuals** (art. 113-E LISR): 1%–2.5% ISR on income actually collected, no deductions, up to
  $3.5 M MXN a year. Every sale needs a CFDI; sales to the general public go into a **factura global** to RFC
  `XAXX010101000` (receiver regime 616, use S01). The global-information node gives the periodicity, months and year.
  - One vendor says RESICO can cancel a global invoice only in the month it was issued. Unconfirmed.
- **Digital platforms** (arts. 113-A–113-D LISR, 18-B, 18-J, 18-K LIVA): intermediation platforms retain ISR and 50% of
  the IVA (100% without an RFC) from individuals selling through them, and report to SAT.
  - Firms disagree on the 2026 ISR rate for goods (1% vs 2.5%).
  - **One firm says 18-J fr. III requires reporting the operations to SAT even when the platform doesn't collect the
    payment.**
  - Sources also disagree on whether an individual whose platform income is retained can stay on RESICO; one cites RMF
    2026 rule 3.13.3. Selling through one's **own site** with no retaining intermediary is generally described as
    RESICO-compatible.
- **Why this matters for Miyagi:** we never collect the merchant's money. Charges go directly into their own Stripe,
  Mercado Pago or CLABE; we take no commission, and only sell optional extras such as the subdomain and the custom
  domain. If that means we're **not** a retaining intermediary, our merchants look like "selling through their own
  site" and stay on RESICO cleanly. That would be a strong, honest pitch, but **only the advisor can say it**. If we
  *are* covered, we'd owe SAT registration and monthly reports even without collecting, which is a separate compliance
  epic.

## Questions for the fiscal advisor (the one thing Daniel books)

1. With no payment collection, no commission on sales, and paid optional services (subdomain, domain, print ad,
   migration), is Miyagi a *servicio digital de intermediación entre terceros* (18-B fr. II LIVA / 113-A LISR)? What
   registration, reporting (18-J fr. III) and retention duties apply, if any?
2. Can a RESICO individual who sells through Miyagi (payments into their own accounts) stay on RESICO?
3. Can Miyagi issue CFDI **in the merchant's name** through a PAC, with the merchant's CSD loaded at the PAC under the
   merchant's authorization? What must the merchant authorize in our terms (a mandate), and what liability stays with us?
4. For RESICO individuals, which global-invoice periodicities are allowed (monthly?), and until when can a buyer
   request their own CFDI for a sale already in a global invoice?
5. IVA on typical products: basic food at 0%, prepared food at 16%, crafts, clothing. Can a category → tax default
   with a merchant override be safe enough? Are our listed prices legally IVA-inclusive?
6. Refunds and returns: cancellation vs a credit note (egreso) for RESICO, within the month and after.
7. Our own extras (subdomain, domain, print ad): what CFDI does Miyagi owe merchants for them today? This is a
   separate gap from the autopilot.

## PAC options

| | Multi-RFC | Price (MXN) | Self-invoicing | Global invoice | Fit |
|---|---|---|---|---|---|
| **Facturapi** | ✅ API plan is multi-RFC "sin costo adicional por RFC"; Organizations API with per-org live/test keys; CSD upload/delete endpoints | $299/month + $0.60 per stamp (IVA incl.); 14-day trial | Self-invoice settings, domain and a `self-invoice completed` webhook; E-Receipts → invoice | ✅ `global` object (periodicity, months, year) | **Best**: a clean organization model, global invoice and self-invoice primitives, test keys for the smoke |
| **Facturama** | ✅ "API Multiemisor"; CSD uploaded per issuer | $1,650/year + $0.40–0.50 per folio | Build our own | ✅ (via CFDI JSON) | **Fallback**: cheaper per folio, JSON-only multi-issuer (no pre-signed XML) |

Cost check:
- A shop with 100 online sales a month, where 10 buyers ask for their own CFDI, needs 10 invoices plus 1 global
  invoice: 11 stamps ≈ **$6.60 a month** on Facturapi.
- The licence ($299) is a platform cost, shared by every shop.
- T1 includes 25 invoices free, then charges. A comparable free allowance is affordable, and the volume price matters
  more than the plan.

## Shape of the build (for the epic, not decided in detail here)

- **Fiscal profile** in Medusa on the seller (commerce-adjacent, AGENTS rule 1):
  - RFC, legal name, regime (626 RESICO suggested), fiscal postal code;
  - the PAC organization id;
  - status.
- **CSD custody: never ours.** The merchant uploads the `.cer`, the `.key` and the password through our backend
  straight to the PAC. We store neither the files nor the password, only the PAC's "certificate valid until" date.
  Expiry triggers a nudge.
  - This is the one place a credential transits us. The security lens covers it, and the BYO Envía rules apply:
    never logged, never echoed.
- **Line items:** SAT `ClaveProdServ` and `ClaveUnidad` per product, defaulted from our catalog category with a
  merchant override; IVA treatment by category default plus override; prices as IVA-inclusive amounts broken down at
  stamping (advisor questions 5 and 1 decide the defaults).
- **Self-invoicing:**
  - The order page and receipt carry «¿Necesitas factura?».
  - The buyer enters RFC, name, regime, CP and use in a page on our domain.
  - The CFDI is stamped in the merchant's name and emailed.
  - The window closes at month end, or per the advisor's answer to question 4.
- **Global invoice:** a month-end job stamps one global CFDI per shop for paid orders not individually invoiced.
  - It needs a real scheduler entry on the VM. Team memory: a reminder cron once shipped with none.
  - It's idempotent per shop and month (validate → claim → apply).
- **Refunds:** cancel or issue a credit note per the advisor's answer to question 6.
- **Monthly summary** in Ganancias: income collected per month, CFDIs issued, the global invoice. It's labelled
  informational («para tu declaración»), never a filed return or tax advice.
- **Agents:** MCP read tools (CFDIs, monthly summary); no tool ever takes a CSD.
- **Risk:** high throughout (fiscal documents in the merchant's name, credentials in transit, money-adjacent). Appetite
  L.

## Merchant conversations (five, 20 minutes each)

1. How do you invoice today, if at all? Who asks you for a factura, and how often?
2. Are you on RESICO? Who files your monthly return: you, an accountant, a family member?
3. Do you have your CSD (sellos)? Have you ever used SAT's free invoicing tool?
4. Would you rather buyers request their own invoice, or have everything invoiced automatically at month end?
5. What do you pay for invoicing or an accountant now? What would you pay for this?

Record answers here; the hook (self-invoicing vs global invoice) and the free allowance come from them.

## Prioritization

- **After envia-byo-connect, before or beside share-kit.** CFDI is the strongest retention feature on the list, and
  it's the one thing T1 bundles that a micro-merchant can't easily get elsewhere for free. But it's blocked on the
  advisor's answer to question 1, and it's an L build.
- **Order:**
  1. The advisor session and the five conversations, now (Daniel).
  2. Write the answers into this file.
  3. Refine the `cfdi-autopilot` epic from them.
  4. Queue it after BYO Envía.
- **If the advisor says we're a reporting platform**, a compliance epic for our own SAT duties comes **first**, because
  it's an obligation rather than a feature.

## Sources (accessed 2026-10-27)

- Senate approval of the Ley de Economía Digital: [Infobae](https://www.infobae.com/mexico/2026/10/20/el-senado-aprueba-la-nueva-ley-que-obliga-al-pago-digital-y-electronico-a-partir-de-2027/),
  [El Financiero](https://www.elfinanciero.com.mx/nacional/2026/10/20/senado-aprueba-ley-de-economia-digital-pago-digital/),
  [La Jornada](https://www.jornada.com.mx/noticia/2026/10/20/politica/entre-protestas-de-oposicion-y-morena-senado-avala-ley-para-ampliar-uso-de-pagos-electronicos),
  [IDC](https://idconline.mx/corporativo/2026/10/21/senado-aprueba-ley-de-economia-digital-hacienda-definira-sectores-estrategicos-para-pagos-electronicos)
- Platform regime and RESICO (firm write-ups, not the DOF):
  [Praxium](https://praxiumconsultores.com/blog/regimen-plataformas-digitales-guia-2026),
  [Carbajal](https://carbajalcontadores.com/2026/10/01/plataformas-digitales-2026-retenciones-iva-isr-ieps-sat/),
  [Trámites Notariales](https://mex.tramitesnotariales.info/resico/resico-plataformas-digitales/),
  [Siempre al día](https://siemprealdia.co/mexico/fiscal/obligaciones-fiscales-de-las-plataformas-digitales/),
  [Facturando](https://www.facturando.mx/blog/2026/09/13/plataformas-digitales-2027-propuesta/)
- Global invoice and CFDI 4.0: [Facturama blog](https://facturama.mx/blog/10-errores-en-el-llenado-del-cfdi-4-0/),
  [Edifact](https://www.edifact.com.mx/masinfo/tratamiento-fiscal-de-facturas-canceladas),
  [Facturador help](https://facturador.helpjuice.com/%C2%BFc%C3%B3mo-generar-una-factura-global)
- PACs: [Facturapi pricing](https://www.facturapi.io/pricing),
  [Facturapi organizations](https://docs.facturapi.io/en/docs/guides/organizations/),
  [Facturapi API reference](https://docs.facturapi.io/en/api/),
  [Facturama API](https://facturama.mx/api-facturacion-electronica),
  [satcfdi Facturama notes](https://satcfdi.readthedocs.io/en/latest/_modules/satcfdi/pacs/facturama.html)

**Daniel sign-off:** ☐ pending. Approve the GO + PAC choice, and book the advisor session.
