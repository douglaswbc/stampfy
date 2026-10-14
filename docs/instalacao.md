# Instalação

Passo a passo completo para colocar o Stampfy em funcionamento.

---

## 1. Pré-requisitos

| Item | Versão | Observação |
|---|---|---|
| Node.js | 20 ou superior | Verifique com `node -v` |
| npm | 10 ou superior | Incluído com Node 20 |
| Conta Supabase | — | [supabase.com](https://supabase.com); o plano gratuito basta para começar |
| Conta Vercel | — | Opcional; apenas para deploy |

---

## 2. Obter o código

```bash
git clone https://github.com/douglaswbc/stampfy.git
cd stampfy
npm install
```

---

## 3. Configurar as variáveis de ambiente

```bash
cp .env.example .env.local
```

No Windows PowerShell:

```powershell
Copy-Item .env.example .env.local
```

Edite `.env.local`. O mínimo obrigatório:

```dotenv
VITE_APP_URL=http://localhost:3000
VITE_APP_NAME=Stampfy
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_ANON_KEY=sua-chave-anon
```

Onde encontrar suas chaves: **Supabase → Project Settings → API**.

Para as funções serverless (`api/*.ts`) localmente, adicione também:

```dotenv
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon
SUPABASE_SERVICE_ROLE_KEY=sua-chave-service-role
APP_ORIGIN=http://localhost:3000
```

> `SUPABASE_SERVICE_ROLE_KEY` **nunca** deve receber o prefixo `VITE_`. Com esse prefixo, a chave seria incluída no bundle do navegador e exposta publicamente.

Todas as variáveis e o que cada uma controla estão na [tabela do README](../README.md#variáveis-de-ambiente) e em [`.env.example`](../.env.example).

---

## 4. Inicializar o banco de dados

Abra **Supabase → SQL Editor** e execute:

### 4.1 Instalação nova (obrigatório)

```text
supabase/migration.sql
```

Esse é o script canônico. Cria todo o schema, políticas RLS, políticas de storage e funções RPC. É **idempotente** — pode ser executado com segurança mais de uma vez.

### 4.2 Contas de demonstração (opcional, somente dev)

```text
supabase/seed.sql
```

> ⚠️ **Cuidado:** o seed cria contas com senhas **conhecidas e públicas**. Use apenas em projeto de teste descartável. Nunca aponte para um projeto com dados reais de clientes. Veja o aviso no topo do arquivo.

| Conta | E-mail | Senha | Slug |
|---|---|---|---|
| Owner (comércio) | `admin@stampfy.local` | `Admin1234` | `demo` |
| Administrador da plataforma | `platform@stampfy.local` | `PlatformAdmin123!` | — |

### 4.3 Administrador da plataforma em produção

Não use o seed. Em vez disso:

1. Crie um usuário em **Supabase → Authentication** com senha única.
2. Coloque o e-mail em `supabase/bootstrap_platform_admin.sql`.
3. Execute aquele arquivo no SQL Editor.

---

## 5. Iniciar o servidor

```bash
npm run dev
```

Acesse `http://localhost:3000`.

Para testar também as rotas serverless em `api/`:

```bash
npm run dev:vercel
```

O comando `npm run dev` (Vite puro) **não** serve as funções em `api/`. O script `dev:vercel` encaminha as configurações server-side de arquivos `.env` ignorados pelo Git, sem encaminhar tokens pessoais de CLI.

---

## 6. Criar a primeira empresa

1. Acesse `/signup` e crie a conta do proprietário.
2. Defina o **slug** — ele define as URLs públicas:

```
https://seu-dominio.com/{slug}                    site institucional
https://seu-dominio.com/{slug}/join/{campaignId}   entrada em campanha
https://seu-dominio.com/{slug}/{uniqueId}          cartão público
https://seu-dominio.com/{slug}/staff               login da equipe
```

3. Em **Configurações**, ajuste nome, cor, moeda, fuso horário e logotipo.

---

## 7. Patches para projetos já existentes

Se você está **atualizando uma instalação anterior**, aplique apenas os patches dos módulos que for usar. Todos são **aditivos** — preservam os dados existentes.

Execute no SQL Editor, **na ordem indicada**:

| Ordem | Patch | O que habilita |
|---|---|---|
| 1 | `legacy-patches/add_saas_platform_foundation.sql` | Registro de admins da plataforma e RPCs de gestão de tenants |
| 2 | `legacy-patches/add_company_locale_preferences.sql` | Idioma e moeda da empresa |
| 3 | `legacy-patches/add_company_time_zone.sql` | Fuso horário da empresa |
| 4 | `legacy-patches/add_campaign_asset_storage.sql` | Storage de arquivos da campanha |
| 5 | `legacy-patches/add_campaign_enable_disable_public_signup.sql` | Liga/desliga inscrição pública |
| 6 | `legacy-patches/preserve_issued_cards_on_campaign_delete.sql` | Preserva cartões emitidos ao excluir campanha |
| 7 | `legacy-patches/add_loyalty_missions.sql` | Missões e progresso |
| 8 | `legacy-patches/add_loyalty_points.sql` | Ledger de pontos, níveis, emblemas |
| 9 | `legacy-patches/add_loyalty_rewards.sql` | Catálogo de recompensas e cupons |
| 10 | `legacy-patches/link_mission_rewards_to_catalog.sql` | Missões liberam recompensas do catálogo |
| 11 | `legacy-patches/add_customer_welcome_and_referral_points.sql` | Pontos de boas-vindas e indicação |
| 12 | `legacy-patches/add_customer_portal.sql` | Portal do cliente |
| 13 | `legacy-patches/add_customer_web_push.sql` | Web Push |
| 14 | `legacy-patches/add_customer_engagement_reminders.sql` | Lembretes de reengajamento |
| 15 | `legacy-patches/add_communications_zernio.sql` | WhatsApp via Zernio |
| 16 | `legacy-patches/add_whatsapp_interactive_templates.sql` | Templates interativos de WhatsApp |
| 17 | `legacy-patches/add_manual_customer_campaigns.sql` | Campanhas manuais para clientes opted-in |
| 18 | `legacy-patches/add_business_sites.sql` | Site institucional |
| 19 | `legacy-patches/add_business_site_leads.sql` | Captura de leads |
| 20 | `legacy-patches/add_business_site_domains.sql` | Domínio próprio por comércio |
| 21 | `legacy-patches/add_dashboard_loyalty_summary.sql` | Resumo de fidelidade no painel |
| 22 | `legacy-patches/reset_owner_business_data.sql` | Botão "Reiniciar dados" nas Configurações |
| 23 | `legacy-patches/tighten_public_access.sql` | Restringe acesso público |
| 24 | `legacy-patches/repair_profiles.sql` | Repara perfis inconsistentes |

### Patches de correção pontuais

Aplicar **apenas** se você enfrentar o problema descrito:

| Patch | Quando aplicar |
|---|---|
| `fix_profiles_policy_recursion.sql` | Erro de recursão de política em `profiles` |
| `fix_profiles_policy_auth_metadata.sql` | Política de `profiles` lendo metadata errado |
| `fix_profiles_campaigns_policy_auth_eval.sql` | `auth.uid()` mal avaliado em políticas |
| `fix_transactions_policy_auth_eval.sql` | Idem em `transactions` |
| `fix_get_public_card_search_path.sql` | RPC pública do cartão sem `search_path` seguro |
| `fix_handle_new_user_search_path.sql` | Trigger de novo usuário sem `search_path` |
| `fix_is_slug_available_search_path.sql` | RPC de verificação de slug |
| `fix_staff_account_functions_search_path.sql` | Funções de conta de equipe |
| `fix_activate_license_key_search_path.sql` | Ativação de license key |
| `fix_license_keys_policy_auth_eval.sql` | Política de license keys |
| `fix_loyalty_points_card_revocation.sql` | Revogação de cartão falha com `loyalty_points_entry_shape` |

### Aplicar via Supabase CLI

Com a CLI instalada e o projeto vinculado, é possível aplicar sem Docker:

```bash
npx supabase db query --linked --file supabase/legacy-patches/add_loyalty_points.sql
```

---

## 8. Configurar os módulos opcionais

### WhatsApp via Zernio

Defina no ambiente **server-only**:

```dotenv
ZERNIO_ENCRYPTION_KEY=<valor aleatório com pelo menos 32 caracteres>
COMMUNICATIONS_CRON_SECRET=<ao menos 16 caracteres aleatórios>
CRON_SECRET=<mesmo valor de COMMUNICATIONS_CRON_SECRET>
```

Depois conecte a conta em **Configurações → Comunicações**. Detalhes em [`zernio_whatsapp_instagram_meta.md`](zernio_whatsapp_instagram_meta.md).

> Alterar `ZERNIO_ENCRYPTION_KEY` depois exige recriptografar as chaves já armazenadas.

### Web Push

Gere um par de chaves VAPID:

```bash
node scripts/generate-vapid-keys.mjs
```

Copie as quatro variáveis geradas para o ambiente. `WEB_PUSH_SUBJECT` deve ser uma URI `mailto:` ou `https:` — use um e-mail seu. Detalhes em [`web-push.md`](web-push.md).

### Domínio próprio por comércio

```dotenv
VERCEL_ACCESS_TOKEN=<token com permissão de gerenciar domínios>
VERCEL_PROJECT_ID=<id do projeto Vercel>
VERCEL_TEAM_ID=<opcional>
```

Adicione o **curinga** do hostname da aplicação no projeto Vercel (ex.: `*.exemplo.com.br`). Detalhes em [`business-site-domains.md`](business-site-domains.md).

### Agendar os workers

[`vercel.json`](../vercel.json) já define os cron jobs. Em outra plataforma, agende manualmente:

| Endpoint | Frequência sugerida | Segredo |
|---|---|---|
| `/api/zernio-worker` | A cada 5–15 min | `COMMUNICATIONS_CRON_SECRET` |
| `/api/customer-push-worker` | A cada 5–15 min | `PUSH_CRON_SECRET` ou `CRON_SECRET` |

---

## 9. Deploy

### Vercel (recomendado)

1. Importe o repositório na Vercel.
2. Cadastre as variáveis de ambiente — separando as `VITE_` (build) das server-only (runtime).
3. O preset de framework detecta Vite automaticamente.
4. Rode `supabase/migration.sql` no Supabase de destino.

[`vercel.json`](../vercel.json) já define:

- **functions** — tempo máximo de execução
- **crons** — workers de WhatsApp e push
- **headers** — cache de `sw.js` e do manifest, mais cabeçalhos de segurança
- **rewrites** — rotas SPA e roteamento por subdomínio para sites dos comércios

### Outras plataformas

O app é uma SPA Vite com funções serverless. Qualquer plataforma que sirva SPAs com funções funciona, desde que:

1. As rotas do cliente sejam reescritas para `index.html`.
2. `api/*.ts` seja implantado como funções serverless.
3. Os cron jobs sejam agendados manualmente.

### Checklist pós-deploy

- [ ] `VITE_APP_URL` aponta para o domínio de produção
- [ ] `robots.txt` e `sitemap.xml` regenerados com a URL correta (`npm run generate:sitemap`)
- [ ] URLs canônicas conferidas no `<head>` da página
- [ ] Wildcard adicionado no projeto Vercel, se usa sites institucionais
- [ ] Nenhuma variável server-only exposta no bundle do navegador
- [ ] Login, cadastro e cartão público testados

---

## 10. Verificação

```bash
npx tsc --noEmit     # verificação de tipos
npm run build        # build completo
```

**Não há suíte de testes automatizados.** O `build` é a verificação principal.

---

## 11. Solução de problemas

**A página abre, mas acusa erro de configuração do Supabase**
`VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` não estão definidas ou estão incorretas. Reinicie o servidor após editar `.env.local`.

**Erro de RLS ao listar dados**
`supabase/migration.sql` não foi executado, ou os patches do módulo não foram aplicados. Consulte a [seção 7](#7-patches-para-projetos-já-existentes).

**O site do comércio abre 404**
Confirme o slug em **Configurações** e se o subdomínio/wildcard está configurado. Veja [`business-site-domains.md`](business-site-domains.md).

**As funções em `api/` não respondem em desenvolvimento**
Use `npm run dev:vercel`. O `npm run dev` não serve funções serverless.

**Erro `loyalty_points_entry_shape` ao revogar cartão**
Aplique `legacy-patches/fix_loyalty_points_card_revocation.sql`.

**O build falha com "Could not find the empty application root"**
A pré-renderização da landing depende de `<div id="root"></div>` em `dist/index.html`. Verifique se algum plugin do Vite está alterando isso.

---

## Ver também

- [`white-label.md`](white-label.md) — rebranding e revenda
- [`venda-e-implementacao.md`](venda-e-implementacao.md) — guia comercial
- [`arquitetura.md`](arquitetura.md) — estrutura do código
- [`../SECURITY.md`](../SECURITY.md) — boas práticas de segurança