<div align="center">
  <img width="1200" alt="Stampfy" src="public/image_1.jpg" />
</div>

<div align="center">

# Stampfy

**Plataforma de fidelidade digital (white-label) para comércios locais.**

Cartões de carimbo digitais, missões, pontos, recompensas, site institucional e comunicação com o cliente — em uma única instalação, com os dados isolados por comércio.

[Documentação](docs/README.md) · [Guia de instalação](docs/instalacao.md) · [White-label](docs/white-label.md) · [English](README.en.md)

[![Licença: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-blue.svg)](https://www.typescriptlang.org/)
[![React](https://img.shields.io/badge/React-18-61dafb.svg)](https://react.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres-3ECF8E.svg)](https://supabase.com/)
[![Vercel](https://img.shields.io/badge/Deploy-Vercel-000000.svg)](https://vercel.com/)

</div>

---

## O que é

O Stampfy é um sistema completo de fidelidade que você instala na sua infraestrutura e oferece aos comércios que atende. Substitui o cartão de papel por um cartão digital com QR Code, e acrescenta o que normalmente exigiria várias ferramentas separadas: missões, pontos e níveis, catálogo de recompensas com cupons, site institucional próprio do comércio e comunicação por WhatsApp.

Cada comércio é um **tenant** isolado. Os clientes do seu cliente final acessam o cartão por link, sem precisar instalar aplicativo.

## Capturas de tela

| Painel do comércio | Cartão do cliente |
|---|---|
| ![Analytics](public/demo_1.png) | ![Cartão digital](public/demo_2.png) |

| Campanhas | Recompensas |
|---|---|
| ![Campanhas](public/demo_3.png) | ![Catálogo de recompensas](public/demo_4.png) |

| Missões | Site institucional |
|---|---|
| ![Missões](public/demo_5.png) | ![Site do comércio](public/demo_6.png) |

Mais telas em [`public/`](public/) e na [galeria de templates](data/templates.tsx).

---

## Funcionalidades

### Núcleo de fidelidade
- **Cartões de carimbo digitais** com QR Code, leitura por câmera e página pública do cliente
- **Campanhas** com recompensa e quantidade-alvo configuráveis
- **Emissão e revogação de cartões** preservando o histórico
- **Registro de visitas** por equipe, com trilha de auditoria (`stamp_add`, `stamp_remove`, `redeem`, `issued`)
- **Entrada pública em campanha** — o cliente participa por link, sem cadastro obrigatório

### Missões e desafios
- Missões do tipo **frequência** (N visitas em um período) e **meta de campanha**
- Progresso derivado de transações válidas no servidor — nunca de valores enviados pelo navegador
- Conclusão e concessão de recompensa **idempotentes e atômicas**, protegidas contra chamadas repetidas e concorrentes
- Período e fuso horário configuráveis por comércio
- Operação documentada em [`docs/missoes.md`](docs/missoes.md)

### Pontos, níveis e emblemas
- **Ledger imutável** de pontos com chave de idempotência
- Níveis configuráveis por faixa de pontos, com benefícios descritivos
- Emblemas por marcos verificáveis (primeira visita, missão concluída)
- Ajustes manuais auditados, exclusivos do proprietário
- Política: pontos não expiram; remover carimbo reverte os pontos correspondentes até o saldo disponível

### Catálogo de recompensas e cupons
- Recompensas globais ou vinculadas a campanha
- Custo em pontos, período de oferta, validade, **estoque** e limite por cliente
- **Códigos únicos** com validação de uso único pela equipe
- Cancelamento com devolução de pontos; expiração automática
- Trilha de auditoria: emissão, expiração, resgate e cancelamento

### Site institucional por comércio
- Editor assistido com uploads, catálogo de produtos/serviços e SEO básico
- Histórico de publicação e páginas públicas renderizadas no servidor
- **Domínio próprio** por comércio, conectado via API da Vercel, com verificação DNS
- Subdomínio automático (`<slug>.<seu-domínio>`) enquanto o domínio próprio não é configurado
- Formulário de captura de leads
- Detalhes em [`docs/sites.md`](docs/sites.md) e [`docs/business-site-domains.md`](docs/business-site-domains.md)

### Comunicação e reengajamento
- **WhatsApp via Zernio** — conexão OAuth, templates aprovados pela Meta e envio em eventos de fidelidade
- Outbox idempotente, com revalidação de consentimento antes de cada envio
- **Lembretes automáticos** com gatilhos configuráveis, horário silencioso no fuso do comércio e supressão após atividade
- Envio por **um único canal elegível** entre push e WhatsApp, com fallback configurável
- Detalhes em [`docs/zernio_whatsapp_instagram_meta.md`](docs/zernio_whatsapp_instagram_meta.md) e [`docs/customer-engagement-reminders.md`](docs/customer-engagement-reminders.md)

### PWA e Web Push
- Instalável como aplicativo, com fallback offline
- Notificações push **opcionais**, com permissão só solicitada após clique explícito
- Inscrição vinculada ao cartão do próprio cliente
- Detalhes em [`docs/web-push.md`](docs/web-push.md)

### Portal do cliente
- Conta única que agrega cartões e histórico de **vários comércios**
- Vínculo por e-mail verificado ou por link do cartão
- Preferências de comunicação revisáveis e revogáveis por comércio
- RLS e RPCs impedem leitura cruzada entre clientes e tenants

### Plataforma multi-tenant
- Isolamento de dados por `owner_id`
- Console de plataforma em `/platform`, restrito a usuários registrados em `platform_admins`
- Gestão de tenants: listar, suspender e restaurar acesso
- Papéis separados: proprietário do comércio, equipe e administrador da plataforma

### Interface
- Bilíngue: **português (Brasil)**, **inglês** e **espanhol**
- Moeda e fuso horário configuráveis por comércio
- Interface responsiva

---

## Para quem é

**1. Comércio que quer usar**
Instale, crie sua empresa em `/signup`, monte campanhas e compartilhe o link. Guia: [`docs/instalacao.md`](docs/instalacao.md).

**2. Prestador que quer revender ou implementar**
Instale **uma** vez, atenda vários comércios como tenants e entregue cada cliente com a **marca dele**. Guia: [`docs/white-label.md`](docs/white-label.md) e [`docs/venda-e-implementacao.md`](docs/venda-e-implementacao.md).

**3. Desenvolvedor que quer contribuir**
Issues e PRs são bem-vindos. Comece por [`CONTRIBUTING.md`](CONTRIBUTING.md) e [`docs/arquitetura.md`](docs/arquitetura.md).

---

## Instalação rápida

Pré-requisitos: **Node.js 20+** e um projeto **Supabase**.

```bash
git clone https://github.com/douglaswbc/stampfy.git
cd stampfy
npm install
cp .env.example .env.local     # Windows PowerShell: Copy-Item .env.example .env.local
```

Edite `.env.local` com suas credenciais:

```dotenv
VITE_APP_URL=http://localhost:3000
VITE_APP_NAME=Stampfy
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_ANON_KEY=sua-chave-anon
```

No **SQL Editor** do Supabase, execute nesta ordem:

```text
1. supabase/migration.sql   -> instalação nova (obrigatório)
2. supabase/seed.sql        -> opcional: contas de demonstração, somente dev
```

Depois:

```bash
npm run dev
```

Abra `http://localhost:3000`.

Para também exercitar as funções serverless (`api/*.ts`) localmente, use `npm run dev:vercel` em vez de `npm run dev`.

> O passo a passo completo, incluindo os patches de migração, está em [`docs/instalacao.md`](docs/instalacao.md).

## Scripts

| Comando | O que faz |
|---|---|
| `npm run dev` | Servidor de desenvolvimento (Vite) |
| `npm run dev:vercel` | Desenvolvimento com as funções `api/*.ts` |
| `npm run build` | Gera sitemap, compila e faz prerender da landing |
| `npm run preview` | Pré-visualiza o build de produção |
| `npm run generate:sitemap` | Regenera `public/sitemap.xml` e `public/robots.txt` |

Verificação: `npx tsc --noEmit` e `npm run build`. **Não há suíte de testes automatizados** — veja [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Stack

React 18 · TypeScript · Vite 6 · Tailwind CSS 4 · React Router 7 · Radix UI · Supabase (Auth, Postgres, Storage, RPC) · Vercel Functions e Cron · Lottie

## Variáveis de ambiente

| Variável | Obrigatória | Descrição |
|---|---|---|
| `VITE_APP_URL` | sim | URL canônica, sem barra final |
| `VITE_SUPABASE_URL` | sim | URL do projeto Supabase |
| `VITE_SUPABASE_ANON_KEY` | sim | Chave anônima do Supabase |
| `VITE_APP_NAME` | não | Nome exibido (padrão `Stampfy`) |
| `VITE_APP_DESCRIPTION` | não | Descrição em SEO / Open Graph |
| `VITE_SOCIAL_IMAGE` | não | Imagem de compartilhamento |
| `VITE_SUPPORT_EMAIL` | não | E-mail de suporte exibido no app |
| `VITE_SALES_EMAIL` | não | E-mail comercial |
| `VITE_NUMBER_COMERCIAL` | não | Telefone/WhatsApp, apenas dígitos |
| `SUPABASE_URL` | para `api/*` | Idem, sem prefixo `VITE_` |
| `SUPABASE_ANON_KEY` | para `api/*` | Idem, sem prefixo `VITE_` |
| `SUPABASE_SERVICE_ROLE_KEY` | para `api/*` | **Server-only.** Nunca prefixar com `VITE_` |
| `APP_ORIGIN` | para `api/*` | Origem pública canônica |
| `VERCEL_ACCESS_TOKEN` | para domínios | Token com permissão de gerenciar domínios |
| `VERCEL_PROJECT_ID` | para domínios | ID do projeto Vercel |
| `VERCEL_TEAM_ID` | opcional | Quando o projeto pertence a um time |
| `ZERNIO_ENCRYPTION_KEY` | para WhatsApp | Segredo de criptografia, ≥32 caracteres |
| `COMMUNICATIONS_CRON_SECRET` | para workers | Autoriza os workers, ≥16 caracteres |
| `CRON_SECRET` | para cron | Header `Authorization` dos cron jobs |
| `VITE_WEB_PUSH_PUBLIC_KEY` | para push | Chave pública VAPID |
| `WEB_PUSH_PRIVATE_KEY` | para push | **Server-only** |
| `WEB_PUSH_SUBJECT` | para push | URI `mailto:` ou `https:` |
| `PUSH_CRON_SECRET` | para push | Autoriza `/api/customer-push-worker` |
| `VITE_ENABLE_DEMO_WORKSPACE` | não | Workspace demo (**só em dev**) |
| `VITE_DEMO_EMAIL` | não | E-mail da conta demo |

Variáveis marcadas como server-only **nunca** devem receber o prefixo `VITE_`, ou seriam incluídas no bundle do navegador.

## Deploy

A aplicação é uma SPA Vite com funções serverless. [`vercel.json`](vercel.json) já contém crons, headers de segurança e rewrites — incluindo o roteamento por subdomínio para os sites dos comércios.

1. Implemente o repositório na Vercel (ou em qualquer plataforma que sirva SPAs com funções).
2. Cadastre as variáveis de ambiente, separando as `VITE_` das server-only.
3. Rode `supabase/migration.sql` no projeto Supabase.
4. Para domínios próprios, adicione o **curinga** do hostname da aplicação (ex.: `*.exemplo.com.br`) no projeto Vercel.

Detalhes em [`docs/instalacao.md`](docs/instalacao.md#deploy).

## Documentação

| Documento | Conteúdo |
|---|---|
| [`docs/instalacao.md`](docs/instalacao.md) | Setup completo, patches SQL e deploy |
| [`docs/white-label.md`](docs/white-label.md) | **Como rebrendar e revender** |
| [`docs/venda-e-implementacao.md`](docs/venda-e-implementacao.md) | Guia comercial: precificação, escopo, perguntas frequentes |
| [`docs/arquitetura.md`](docs/arquitetura.md) | Estrutura do código, rotas e fluxo de dados |
| [`docs/missoes.md`](docs/missoes.md) | Operação de missões e desafios |
| [`docs/sites.md`](docs/sites.md) | Módulo de site institucional |
| [`docs/business-site-domains.md`](docs/business-site-domains.md) | Domínio próprio por comércio |
| [`docs/web-push.md`](docs/web-push.md) | PWA e notificações push |
| [`docs/customer-engagement-reminders.md`](docs/customer-engagement-reminders.md) | Lembretes e reengajamento |
| [`docs/zernio_whatsapp_instagram_meta.md`](docs/zernio_whatsapp_instagram_meta.md) | Integração Zernio / WhatsApp |
| [`docs/saas-foundation.md`](docs/saas-foundation.md) | Modelo multi-tenant e roadmap da plataforma |

## Estado do projeto

Módulos **prontos para uso**: cartões e campanhas, missões, pontos e níveis, catálogo de recompensas, site institucional, domínios próprios, portal do cliente, lembretes e WhatsApp.

Em **validação de produção** pelo mantenedor: patches de portal do cliente, push e lembretes ainda precisam ser aplicados no Supabase de destino — ver [`docs/instalacao.md`](docs/instalacao.md).

**Não implementado**: cobrança recorrente, marketplace entre comércios e cadastro multi-unidade.

## Contribuindo

Leia [`CONTRIBUTING.md`](CONTRIBUTING.md). Issues de segurança: [`SECURITY.md`](SECURITY.md). Código de conduta: [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## Licença

**MIT** — use, modifique, revenda e ofereça como serviço. Ver [`LICENSE`](LICENSE).

O MIT concede direitos de copyright, **não** de marca registrada. Se for revender, renomeie a instalação para a marca do seu cliente — veja [`docs/white-label.md`](docs/white-label.md).

## Créditos

Este projeto é um fork aprimorado de **[Stampee](https://github.com/danlim26/stampee)**, de **Danilo Lim**, sob licença MIT. A atribuição completa e o detalhamento do que este fork adiciona estão em [`NOTICE`](NOTICE).

Agradecemos a Danilo Lim pelo trabalho original, que forneceu a base deste projeto.