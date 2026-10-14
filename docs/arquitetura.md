# Arquitetura

Visão geral de como o Stampfy é organizado, para quem pretende estender ou contribuir.

---

## Visão geral

```
┌─────────────────────────────────────────────────────────────┐
│  Navegador (SPA React)                                       │
│                                                              │
│  App.tsx ── rotas ──► components/                            │
│       │                    │                                 │
│       │                    └──► lib/db/*  (acesso a dados)   │
│       │                              │                      │
│  lib/siteConfig.ts ◄── variáveis de ambiente (branding)      │
└──────────────────────────────┬──────────────────────────────┘
                               │ HTTPS / supabase-js
┌──────────────────────────────▼──────────────────────────────┐
│  Supabase                                                     │
│    Auth        → sessões, senhas                              │
│    Postgres    → schema, RLS, funções RPC                    │
│    Storage     → imagens de campanha e do site               │
│    Edge/CDN    → assets                                       │
└──────────────────────────────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│  Funções serverless (api/*.ts) — Vercel                       │
│    public-site.ts          renderiza sites por subdomínio    │
│    sites-sitemap.ts        sitemap dinâmico dos sites        │
│    business-site-lead.ts   captura de leads                   │
│    business-site-domains.ts conexão de domínios (Vercel API) │
│    zernio.ts               proxy da API Zernio               │
│    zernio-worker.ts        envio de WhatsApp                 │
│    customer-push-worker.ts envio de Web Push                  │
└──────────────────────────────────────────────────────────────┘
```

**Regra central:** o navegador **nunca** decide regra de negócio. Progresso de missão, saldo de pontos, resgate de recompensa e código de cupom são calculados em funções RPC no Postgres, com RLS por tenant. A interface apenas exibe.

---

## Estrutura de diretórios

```
.
├── api/                  Funções serverless (Vercel)
├── components/           Componentes React
│   └── ui/               Primitivas Radix reestilizadas
├── data/                 Conteúdo estático (artigos, templates)
├── docs/                 Documentação
├── lib/
│   ├── db/               Uma função por domínio de dados
│   ├── storage/          Helpers de Storage
│   ├── analytics.ts      Telemetria
│   ├── i18n.ts           Traduções pt-BR / en / es
│   ├── supabase.ts       Cliente Supabase e detecção de config
│   ├── siteConfig.ts     Branding e URL pública
│   ├── timezones.ts      Fuso horário por comércio
│   └── utils.ts          Utilidades
├── public/               Assets estáticos
├── scripts/              Scripts de build e manutenção
├── supabase/
│   ├── migration.sql     Schema canônico
│   ├── seed.sql          Dados de desenvolvimento
│   └── legacy-patches/   Patches aditivos e correções
├── types.ts              Tipos TypeScript compartilhados
├── App.tsx               Rotas da aplicação
└── vercel.json           Crons, headers e rewrites
```

---

## Rotas

Definidas em `App.tsx`.

### Públicas

| Rota | Componente | Acesso |
|---|---|---|
| `/` | `MarketingLandingPage` | Público |
| `/login` | `LoginPage` | Público |
| `/signup` | `SignupPage` | Público |
| `/signup-confirmation` | `SignupConfirmationPage` | Público |
| `/forgot-password` | `ForgotPasswordPage` | Público |
| `/account` | `CustomerAccountPage` | Link seguro por e-mail |
| `/:slug` | `PublicBusinessSitePage` | Público |
| `/:slug/join/:campaignId` | `PublicCampaignSignupPage` | Público |
| `/:slug/:uniqueId` | `LoyaltyCard` | Público |
| `/:slug/staff` | `StaffLoginPage` | Público |
| `/:slug/scan/:uniqueId` | Leitura de QR | Público |

### Autenticadas

| Rota | Componente | Papel |
|---|---|---|
| `/dashboard` | `DashboardPage` | owner/staff |
| `/campaigns` | `CampaignsPage` | owner/staff |
| `/missions` | `MissionsPage` | owner |
| `/rewards` | `RewardsCatalogPage` | owner |
| `/reward-redemptions` | `RewardRedemptionsPage` | owner/staff |
| `/issued-cards` | `IssuedCardsPage` | owner/staff |
| `/customers` | `CustomersPage` | owner/staff |
| `/analytics` | `AnalyticsPage` | owner/staff |
| `/transactions` | `TransactionsPage` | owner/staff |
| `/gallery` | `TemplatesGallery` | owner/staff |
| `/settings` | `SettingsPage` | owner |
| `/site` | `BusinessSiteAdminPage` | owner |
| `/site/preview` | Pré-visualização do site | owner |
| `/platform` | `PlatformAdminPage` | `platform_admin` |
| `/editor/:id` | Editor de cartão | owner/staff |
| `/preview/:templateId` | Preview de template | owner/staff |

`RequireAuth` e `RequireRole` protegem os blocos.

---

## Camada de dados

Cada arquivo em `lib/db/` encapsula um domínio e expõe funções tipadas. Nenhum componente chama `supabase.from(...)` diretamente.

| Arquivo | Responsabilidade |
|---|---|
| `profiles.ts` | Perfis, papéis, preferências da empresa |
| `campaigns.ts` | Campanhas e cartões emitidos |
| `customers.ts` | Cadastro de clientes |
| `issuedCards.ts` | Emissão e revogação |
| `loyaltyPoints.ts` | Ledger de pontos, níveis, emblemas |
| `missions.ts` | Missões e progresso |
| `rewards.ts` | Catálogo, códigos, resgates |
| `businessSites.ts` | Sites institucionais |
| `businessSiteDomains.ts` | Domínios próprios |
| `customerPortal.ts` | Portal do cliente |
| `customerEngagement.ts` | Preferências e lembretes |
| `publicPushNotifications.ts` | Assinaturas de push |
| `publicSignup.ts` | Entrada pública em campanha |
| `dashboard.ts` | Agregações do painel |
| `dataManagement.ts` | Reinício de dados |
| `licenseKeys.ts` | Ativação de licença |

### Padrão

As funções que alteram dados Broadcasting confiança ao cliente chamam **RPCs** (`supabase.rpc(...)`) em vez de `insert`/`update` diretos. Isso garante:

- Validação de papel e de titularidade no servidor
- Idempotência (chave de idempotência nos argumentos)
- Auditoria (gravado em tabelas de histórico dentro da transação)
- Atomicidade (tudo em uma única transação do Postgres)

---

## Isolamento multi-tenant

Três camadas:

1. **`owner_id`** — toda tabela de negócio referencia o proprietário.
2. **RLS** — políticas verificam `auth.uid()` contra o `owner_id` da linha.
3. **RPCs** — operações compostas revalidam a titularidade dentro da função.

`lib/db/dataManagement.ts` expõe a limpeza de dados; `supabase/legacy-patches/reset_owner_business_data.sql` define o que é preservado (proprietário, equipe e preferências da empresa).

### Papéis

| Papel | Origem | Escopo |
|---|---|---|
| `owner` | Cadastro em `/signup` | Um comércio |
| `staff` | Criado pelo owner em Configurações | Mesmo comércio, permissões limitadas |
| `platform_admin` | Tabela `platform_admins` | Console `/platform` |

---

## Configuração e branding

`lib/siteConfig.ts` centraliza:

| Export | Origem |
|---|---|
| `APP_NAME` | `VITE_APP_NAME` |
| `APP_DESCRIPTION` | `VITE_APP_DESCRIPTION` |
| `APP_ORIGIN` | `VITE_APP_URL` |
| `BUSINESS_SITE_DOMAIN` | Derivado de `VITE_APP_URL` |
| `SUPPORT_EMAIL` | `VITE_SUPPORT_EMAIL` |
| `SALES_EMAIL` | `VITE_SALES_EMAIL` |
| `DEMO_WORKSPACE_ENABLED` | `VITE_ENABLE_DEMO_WORKSPACE` + modo dev |

Componentes **não** leem `import.meta.env` diretamente para branding — use `siteConfig`. Isso mantém o white-label funcionando com uma única mudança de variável.

Para SEO, `scripts/seo-config.mjs` expõe um plugin Vite que substitui tokens `__APP_URL__`, `__APP_NAME__`, `__APP_DESCRIPTION__` e `__SOCIAL_IMAGE__` em `index.html` durante dev e build. O arquivo-fonte não é alterado.

---

## Roteamento por subdomínio

`vercel.json` resolve o host antes do rewrite:

1. Requisições em `www`, `app`, `api`, `admin` ou `*.vercel.app` seguem para a SPA.
2. Hosts desconhecidos vão para `/api/public-site?host=...`, que renderiza o site do comércio.
3. Rotas literais `/empresa/:slug` também resolvem para a mesma função.
4. O restante cai em `index.html` (SPA).

`lib/businessSiteDomain.ts` extrai o slug do subdomínio e classifica hosts de plataforma.

---

## Build

```bash
npm run build
```

Executa três etapas:

1. `generate:sitemap` — reescreve `public/sitemap.xml` e o bloco `Sitemap:` de `public/robots.txt` a partir de `VITE_APP_URL`.
2. `vite build` — compila e injeta os tokens de SEO via plugin.
3. `prerender:landing` — renderiza `MarketingLandingPage` estaticamente em `dist/index.html`, substituindo `<div id="root"></div>`.

> Se você remover a landing de marketing, remova também a etapa 3 do `package.json`. Veja [`white-label.md`](white-label.md#4-landing-page-de-marketing).

---

## Onde mexer para cada tarefa

| Objetivo | Arquivo |
|---|---|
| Adicionar rota | `App.tsx` |
| Adicionar tela do painel | `components/`, proteger em `App.tsx` |
| AdicionarTranslations | `lib/i18n.ts` |
| Adicionar regra de negócio | RPC no Supabase + wrapper em `lib/db/` |
| Adicionar endpoint serverless | `api/` + rota em `vercel.json` se for cron |
| Mudar cores | `index.css`, `tailwind.config.cjs` |
| Mudar textos legais | `components/TermsPage.tsx`, `PrivacyPolicyPage.tsx`, `CookiePolicyPage.tsx` |
| Mudar branding | `lib/siteConfig.ts` + variáveis de ambiente |
| Adicionar coluna no banco | Novo patch em `supabase/legacy-patches/` |

---

## Convenções

- **TypeScript estrito** — `tsconfig.json` usa `strict`. Rode `npx tsc --noEmit` antes de commitar.
- **Sem suíte de testes** — a verificação é `tsc` + `npm run build`.
- **Sem formatter** — siga o estilo do arquivo circundante.
- **Comentários** — explique o *porquê*, não o *o quê*.
- **Migrations aditivas** — nunca apague ou recrie tabela com dados. Use `create ... if not exists` e `drop policy if exists`.

---

## Ver também

- [`instalacao.md`](instalacao.md) — setup e patches
- [`white-label.md`](white-label.md) — rebranding
- [`missoes.md`](missoes.md) — regras de missão
- [`sites.md`](sites.md) — módulo de site institucional
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — como contribuir