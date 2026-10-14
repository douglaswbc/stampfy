<div align="center">
  <img width="1200" alt="Stampfy" src="public/image_1.jpg" />
</div>

<div align="center">

# Stampfy

**White-label digital loyalty platform for local businesses.**

Digital stamp cards, missions, points, rewards, institutional websites and customer messaging — in a single install, with data isolated per business.

[Documentation](docs/README.md) · [Installation](docs/instalacao.md) · [White-labeling](docs/white-label.md) · [Português (Brasil)](README.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-blue.svg)](https://www.typescriptlang.org/)
[![React](https://img.shields.io/badge/React-18-61dafb.svg)](https://react.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres-3ECF8E.svg)](https://supabase.com/)
[![Vercel](https://img.shields.io/badge/Deploy-Vercel-000000.svg)](https://vercel.com/)

</div>

---

> 🇧🇷 **Português é o idioma principal deste projeto.** Veja o [README em PT-BR](README.md), que é mais completo.

## What it is

Stampfy is a complete loyalty system you install on your own infrastructure and offer to the businesses you serve. It replaces the paper card with a QR-code-enabled digital card, and adds what would normally require several separate tools: missions, points and tiers, a rewards catalog with coupon codes, each business's own institutional website, and customer messaging via WhatsApp.

Each business is an isolated **tenant**. Your end customers access their card through a link — no app install required.

## Features

### Loyalty core
- **Digital stamp cards** with QR codes, camera scanning, and a public customer page
- **Campaigns** with configurable rewards and stamp targets
- **Card issuance and revocation** with history preserved
- **Visit logging** by staff, with an audit trail (`stamp_add`, `stamp_remove`, `redeem`, `issued`)
- **Public campaign enrollment** — customers join via link, no account required

### Missions and challenges
- **Frequency** missions (N visits within a period) and **campaign goal** missions
- Progress derived from server-validated transactions — never from client-submitted values
- Completion and reward grants are **idempotent and atomic**, safe against repeated and concurrent calls
- Periods evaluated in the business's configured time zone
- Operations documented in [`docs/missoes.md`](docs/missoes.md)

### Points, tiers and badges
- **Immutable points ledger** with idempotency keys
- Configurable tiers by point range, with descriptive benefits
- Badges for verifiable milestones (first visit, mission completed)
- Owner-only manual adjustments, fully audited
- Policy: points never expire; removing a stamp reverses the corresponding points up to the available balance

### Rewards catalog and coupons
- Global rewards or rewards tied to a campaign
- Point cost, offer period, validity, **stock** and per-customer limits
- **Unique codes** validated once by staff
- Cancellation refunds points; automatic expiration
- Full audit trail: issuance, expiration, redemption and cancellation

### Per-business institutional website
- Assisted editor with uploads, product/service directory and basic SEO
- Publication history and server-rendered public pages
- **Custom domain** per business, connected via the Vercel API with DNS verification
- Automatic subdomain (`<slug>.<your-domain>`) while the custom domain is being set up
- Lead capture form
- Details in [`docs/sites.md`](docs/sites.md) and [`docs/business-site-domains.md`](docs/business-site-domains.md)

### Messaging and reengagement
- **WhatsApp via Zernio** — OAuth connection, Meta-approved templates, triggered by loyalty events
- Idempotent outbox with consent revalidation before every send
- **Automated reminders** with configurable triggers, quiet hours in the business time zone, and suppression after customer activity
- Delivery over a **single eligible channel** between push and WhatsApp, with configurable fallback
- Details in [`docs/zernio_whatsapp_instagram_meta.md`](docs/zernio_whatsapp_instagram_meta.md) and [`docs/customer-engagement-reminders.md`](docs/customer-engagement-reminders.md)

### PWA and Web Push
- Installable as an app, with offline fallback
- **Optional** push notifications, permission requested only after an explicit click
- Subscription bound to the customer's own card
- Details in [`docs/web-push.md`](docs/web-push.md)

### Customer portal
- A single account aggregating cards and history across **multiple businesses**
- Linked via verified email or card link
- Communication preferences reviewable and revocable per business
- RLS and RPCs prevent cross-customer and cross-tenant data access

### Multi-tenant platform
- Data isolation by `owner_id`
- Platform console at `/platform`, restricted to users registered in `platform_admins`
- Tenant management: list, suspend and restore access
- Separate roles: business owner, staff, and platform administrator

### Interface
- Trilingual: **Portuguese (Brazil)**, **English** and **Spanish**
- Per-business currency and time zone
- Fully responsive

## Who it's for

**1. A business that wants to use it**
Install, register your company at `/signup`, build campaigns and share the link. Guide: [`docs/instalacao.md`](docs/instalacao.md).

**2. A provider who wants to resell or implement it**
Install **once**, serve multiple businesses as tenants, and hand each client their **own brand**. Guide: [`docs/white-label.md`](docs/white-label.md) and [`docs/venda-e-implementacao.md`](docs/venda-e-implementacao.md).

**3. A developer who wants to contribute**
Issues and PRs welcome. Start with [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`docs/arquitetura.md`](docs/arquitetura.md).

## Quick start

Prerequisites: **Node.js 20+** and a **Supabase** project.

```bash
git clone https://github.com/douglaswbc/stampfy.git
cd stampfy
npm install
cp .env.example .env.local     # Windows PowerShell: Copy-Item .env.example .env.local
```

Edit `.env.local`:

```dotenv
VITE_APP_URL=http://localhost:3000
VITE_APP_NAME=Stampfy
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

In the Supabase **SQL Editor**, run in this order:

```text
1. supabase/migration.sql   -> fresh install (required)
2. supabase/seed.sql        -> optional: demo accounts, dev only
```

Then:

```bash
npm run dev
```

Open `http://localhost:3000`.

To exercise the serverless functions (`api/*.ts`) locally, run `npm run dev:vercel` instead of `npm run dev`.

## Scripts

| Command | Description |
|---|---|
| `npm run dev` | Development server (Vite) |
| `npm run dev:vercel` | Development with `api/*.ts` functions |
| `npm run build` | Generate sitemap, build, prerender landing |
| `npm run preview` | Preview the production build |
| `npm run generate:sitemap` | Regenerate `public/sitemap.xml` and `public/robots.txt` |

Verification: `npx tsc --noEmit` and `npm run build`. **There is no automated test suite** — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Stack

React 18 · TypeScript · Vite 6 · Tailwind CSS 4 · React Router 7 · Radix UI · Supabase (Auth, Postgres, Storage, RPC) · Vercel Functions and Cron · Lottie

## Environment variables

| Variable | Required | Description |
|---|---|---|
| `VITE_APP_URL` | yes | Canonical URL, no trailing slash |
| `VITE_SUPABASE_URL` | yes | Supabase project URL |
| `VITE_SUPABASE_ANON_KEY` | yes | Supabase anon key |
| `VITE_APP_NAME` | no | Display name (default `Stampfy`) |
| `VITE_APP_DESCRIPTION` | no | SEO / Open Graph description |
| `VITE_SOCIAL_IMAGE` | no | Social share image |
| `VITE_SUPPORT_EMAIL` | no | Support email shown in the app |
| `VITE_SALES_EMAIL` | no | Sales email |
| `VITE_NUMBER_COMERCIAL` | no | Phone/WhatsApp, digits only |
| `SUPABASE_URL` | for `api/*` | Same, without the `VITE_` prefix |
| `SUPABASE_ANON_KEY` | for `api/*` | Same, without the `VITE_` prefix |
| `SUPABASE_SERVICE_ROLE_KEY` | for `api/*` | **Server-only.** Never prefix with `VITE_` |
| `APP_ORIGIN` | for `api/*` | Canonical public origin |
| `VERCEL_ACCESS_TOKEN` | for domains | Token with domain management permission |
| `VERCEL_PROJECT_ID` | for domains | Vercel project ID |
| `VERCEL_TEAM_ID` | optional | When the project belongs to a team |
| `ZERNIO_ENCRYPTION_KEY` | for WhatsApp | Encryption secret, ≥32 chars |
| `COMMUNICATIONS_CRON_SECRET` | for workers | Authorizes workers, ≥16 chars |
| `CRON_SECRET` | for cron | `Authorization` header for cron jobs |
| `VITE_WEB_PUSH_PUBLIC_KEY` | for push | VAPID public key |
| `WEB_PUSH_PRIVATE_KEY` | for push | **Server-only** |
| `WEB_PUSH_SUBJECT` | for push | `mailto:` or `https:` URI |
| `PUSH_CRON_SECRET` | for push | Authorizes `/api/customer-push-worker` |
| `VITE_ENABLE_DEMO_WORKSPACE` | no | Demo workspace (**dev only**) |
| `VITE_DEMO_EMAIL` | no | Demo account email |

Server-only variables **must never** carry the `VITE_` prefix, or they will be bundled into the browser build.

## Deploy

The app is a Vite SPA plus serverless functions. [`vercel.json`](vercel.json) already ships crons, security headers and rewrites — including subdomain routing for business sites.

1. Deploy the repository to Vercel (or any platform that serves SPAs with functions).
2. Set the environment variables, keeping `VITE_` and server-only vars separated.
3. Run `supabase/migration.sql` against your Supabase project.
4. For custom domains, add the **wildcard** for your app hostname (e.g. `*.example.com`) to the Vercel project.

## Documentation

| Document | Contents |
|---|---|
| [`docs/instalacao.md`](docs/instalacao.md) | Full setup, SQL patches and deployment |
| [`docs/white-label.md`](docs/white-label.md) | **How to rebrand and resell** |
| [`docs/venda-e-implementacao.md`](docs/venda-e-implementacao.md) | Commercial guide: pricing, scope, FAQ |
| [`docs/arquitetura.md`](docs/arquitetura.md) | Code structure, routes and data flow |
| [`docs/missoes.md`](docs/missoes.md) | Mission operations |
| [`docs/sites.md`](docs/sites.md) | Institutional website module |
| [`docs/business-site-domains.md`](docs/business-site-domains.md) | Per-business custom domains |
| [`docs/web-push.md`](docs/web-push.md) | PWA and push notifications |
| [`docs/customer-engagement-reminders.md`](docs/customer-engagement-reminders.md) | Reminders and reengagement |
| [`docs/zernio_whatsapp_instagram_meta.md`](docs/zernio_whatsapp_instagram_meta.md) | Zernio / WhatsApp integration |
| [`docs/saas-foundation.md`](docs/saas-foundation.md) | Multi-tenant model and platform roadmap |

## Project status

**Ready to use**: cards and campaigns, missions, points and tiers, rewards catalog, institutional website, custom domains, customer portal, reminders and WhatsApp.

**Under production validation by the maintainer**: the customer portal, push and reminder patches still need to be applied to your Supabase project — see [`docs/instalacao.md`](docs/instalacao.md).

**Not implemented**: recurring billing, cross-business marketplace, multi-branch accounts.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Security issues: [`SECURITY.md`](SECURITY.md). Code of conduct: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## License

**MIT** — use, modify, resell and offer as a service. See [`LICENSE`](LICENSE).

MIT grants copyright rights, **not** trademark rights. If you resell, rename the install to your client's brand — see [`docs/white-label.md`](docs/white-label.md).

## Credits

This project is an enhanced fork of **[Stampee](https://github.com/danlim26/stampee)** by **Danilo Lim**, MIT licensed. Full attribution and a detailed list of what this fork adds are in [`NOTICE`](NOTICE).

We thank Danilo Lim for the original work, which provided the foundation of this project.