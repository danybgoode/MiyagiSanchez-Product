# Paid campaign #1 — Meta (Facebook + Instagram), Mexico, Nov–Dec 2026

The first paid seller-acquisition test: **500 MXN a week for four weeks**. Ads open a WhatsApp chat with Daniel, and
we judge them by **shops published**, not by clicks. Copy follows Positioning v2 (2026-11-13): «Tu propia tienda en
línea, armada contigo, sin comisión por venta». Never «gratis» alone in Mexico.

Prices quoted here were read from the live `/mx/precios` on 2026-11-17: 3 months of Plan Negocio free with no card,
then Plan Tienda from $19 a month ($228 a year in one payment, or $29 a month), VAT included. If that page changes,
this copy changes with it.

## Status (2026-11-17)

| Piece | State |
| --- | --- |
| Business portfolio «Miyagi Sánchez» (1798467634739290) | Created |
| Pixel «Miyagi Sánchez web» (29512612288367811) | Created; site code in storefront PR #507 |
| Facebook Page «Miyagi Sánchez» | **Blocked**: Meta refuses to create it ("follow Page policies"), for Claude and for Daniel |
| Instagram ↔ Facebook link | Owed: done from the Instagram app (Accounts Center → Add accounts) |
| WhatsApp Business ↔ Page | Owed, after the Page exists |
| Payment method on ad account 1301539588484869 | Owed: Daniel adds it (a card, or OXXO prepaid as a hard weekly cap) |
| Ad account moved into the portfolio | Owed, after the Page exists |

## The setup in Ads Manager

- **Objective:** Engagement → conversion location **WhatsApp** → performance goal **maximise conversations**.
- **Budget:** one campaign, one ad set, **70 MXN a day** (~490 a week). Four ads in the one ad set.
- **Audience:** Mexico City + Estado de México, ages 22–55, Advantage+ audience on, no interest lists. The creative
  does the targeting.
- **Placements:** Advantage+ (Reels and Stories will take most of it; the videos are 9:16).
- **Welcome message:** the greeting and four quick replies below.
- **URL parameters** (for the landing variant later):
  `utm_source=meta&utm_medium=paid_social&utm_campaign=mx_sellers_w1&utm_content={{ad.name}}`.
- **Week 3 rule:** pause the two ads with the highest cost per conversation that led to no shop kept. Put the budget
  on the winning niche.

| Measure | Target | Where it is read |
| --- | --- | --- |
| Cost per WhatsApp conversation | ≤ 25 MXN | Ads Manager |
| Shops kept (`CompleteRegistration`) | ≥ 2 a week | Events Manager + WhatsApp labels |
| Cost per shop published (`ShopPublished`) | ≤ 250 MXN | Events Manager + WhatsApp labels |

These targets are a first guess, set before any data. Re-set them after week 2.

## The four ads

Each one is a 9:16 vertical video, 20–30 seconds, filmed on a phone. Daniel's face plus the screen. Captions on, since
most people watch muted. The first three seconds carry the whole ad.

### A1 — «Pedidos por WhatsApp» (niche A: people who sell through DMs)

- **Hook (0–3 s), on camera:** «¿Sigues tomando pedidos por WhatsApp y pidiendo captura de la transferencia?»
- **Demo (3–20 s), screen recording:** on miyagisanchez.com, type «Vendo velas de soya en Puebla» or take a photo of
  a product, and the shop builds itself.
- **Voice:** «Describe tu negocio o tómale foto, y en minutos tienes tu propia tienda en línea. Tus clientes eligen y
  pagan solos. Tú a lo tuyo.»
- **Close:** «3 meses gratis, sin tarjeta. Escríbeme y la armamos juntos.»
- **Primary text:** Tu propia tienda en línea, armada contigo, sin comisión por venta. Describe tu negocio o tómale
  foto y en minutos está lista. 3 meses gratis, sin tarjeta.
- **Headline:** Tu tienda en línea, en minutos

### A2 — «El link de tu bio» (niche A, founder on camera)

- **Hook:** «Si vendes por Instagram, tu link de la bio debería vender por ti.»
- **Body:** «Te armo tu tienda contigo, aquí por WhatsApp: tu catálogo con precios, pagos con tarjeta, transferencia
  o efectivo, y un link para tu bio. Sin comisión por venta: lo que vendes es tuyo.»
- **Close:** «Los primeros 3 meses no pagas nada, y no te pido tarjeta. Mándame un mensaje.»
- **Primary text:** Deja de contestar «¿precio?» en cada DM. Tu catálogo, tus pagos y tu link en un solo lugar, sin
  comisión por venta. 3 meses gratis, sin tarjeta.
- **Headline:** Tu negocio, en orden

### B1 — «Tu taller de diciembre» (niche B: classes, workshops, events)

- **Hook:** «¿Vas a dar un taller, una clase o un evento este diciembre?»
- **Demo:** an Evento listing with a limited number of places and card payment, sold out to «Agotado» on screen.
- **Voice:** «Vende tus lugares con tarjeta desde tu propia página. Pones cuántos hay, y cuando se acaban dice
  Agotado solo. Miyagi Sánchez no cobra comisión por boleto.»
- **Close:** «3 meses gratis, sin tarjeta. Escríbeme y dejamos tu evento listo hoy.»
- **Primary text:** Tu propia página para vender tus lugares con tarjeta. Cupo limitado, sin comisión de plataforma
  por boleto. 3 meses gratis, sin tarjeta.
- **Headline:** Vende tus lugares hoy

### B2 — «Las boleteras se quedan con una parte» (niche B, founder on camera)

- **Hook:** «Las boleteras se quedan con una parte de cada boleto. Aquí no.»
- **Body:** «Tu evento en tu propia página, con pago con tarjeta y cupo que se cierra solo. El dinero llega a tu cuenta.»
- **Close:** «Escríbeme y lo armamos juntos.»
- **Primary text:** Vende tus talleres, clases y eventos con tarjeta desde tu propia página. Sin comisión de
  plataforma por boleto. 3 meses gratis, sin tarjeta.
- **Headline:** Tu evento, tus boletos

**Wording rule for B:** «sin comisión de plataforma» or «Miyagi Sánchez no cobra comisión», never «sin comisiones».
The card processor still charges its own fee, and the ad must not suggest otherwise.

## The WhatsApp conversation

The goal of every chat is a shop **kept** the same day. Reply within minutes during the day: a lead loses interest
within the hour.

**Greeting** (the ad's welcome message):

> ¡Hola! Soy Daniel, de Miyagi Sánchez. Te armo tu propia tienda en línea contigo, aquí mismo. Para empezar: ¿qué
> vendes?

**Quick replies:** «Vendo productos» · «Doy talleres, clases o eventos» · «Ofrezco servicios» · «¿Cuánto cuesta?»

**1. Get to know them** (one question at a time):

> ¿Dónde vendes hoy? ¿Instagram, WhatsApp, Marketplace, en persona?

> ¿Más o menos cuántos productos (o fechas) tienes?

**2. Build it during the chat:**

> Va. Mándame el nombre de tu negocio y 3 fotos de lo que vendes, con su precio, y en 10 minutos te enseño cómo se ve
> tu tienda.

or, for someone who wants to do it themselves:

> Aquí la armas tú: describe tu negocio o tómale foto 👉 miyagisanchez.com — y si te atoras, aquí estoy.

**3. Close:**

> ¿Cómo la ves? Si te late, la dejas a tu nombre con un clic y es tuya. Los primeros 3 meses no pagas nada.

**Answers to the questions that will come:**

| They ask | Answer |
| --- | --- |
| ¿Cuánto cuesta? | Los primeros 3 meses no pagas nada y no te pido tarjeta. Después, el Plan Tienda cuesta desde $19 al mes ($228 al año en un pago, o $29 al mes), IVA incluido. Y no cobramos comisión por venta: lo que vendes es tuyo. |
| ¿Y las comisiones de tarjeta? | Miyagi Sánchez no cobra comisión por venta. Si tu cliente paga con tarjeta, el procesador cobra su comisión normal; con transferencia o efectivo no hay costo extra. |
| Ya vendo por Instagram | Perfecto, no lo dejas. Tu tienda te da un link para tu bio donde ven precios, eligen y pagan, sin que contestes cada DM. |
| ¿Es confiable? / ¿A dónde llega el dinero? | El dinero llega a tu cuenta, no a la nuestra. Tú decides cómo cobras: tarjeta, transferencia o efectivo. |
| Lo pienso | Claro. ¿Te la dejo armada para que la veas con calma? No pagas nada estos 3 meses. |

**Next-day follow-up** (inside the 24-hour window, so it's free):

> ¡Hola, {nombre}! Ayer quedamos en armar tu tienda. ¿Te mando cómo se ve para que la revises?

**WhatsApp Business labels**, one per stage, counted every Monday into the table above: Nuevo · Platicando · Tienda
armada · Tienda a su nombre · Publicada · No por ahora.

## Copy bank — lines from this campaign

These are meant for the copy bank in the growth plan doc, which this session could not open. Paste them there.

- «¿Sigues tomando pedidos por WhatsApp y pidiendo captura de la transferencia?» — pain hook for DM sellers.
- «Tu link de la bio debería vender por ti.» — the Instagram angle.
- «Deja de contestar "¿precio?" en cada DM.» — the shortest statement of the pain.
- «Tus clientes eligen y pagan solos. Tú a lo tuyo.» — the promise, applied.
- «Las boleteras se quedan con una parte de cada boleto. Aquí no.» — events hook (keep «sin comisión de plataforma»).
- «Cuando se acaban, dice Agotado solo.» — the seats feature in plain words.
- «El dinero llega a tu cuenta, no a la nuestra.» — the trust line.
