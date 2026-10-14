# Política de Segurança

## Versões suportadas

| Versão | Recebe correções de segurança |
|---|---|
| `main` | Sim |

O projeto está em desenvolvimento ativo. Correções de segurança são aplicadas na `main` e publicadas nas notas de versão.

---

## Reportando uma vulnerabilidade

**Não abra issue pública para problemas de segurança.**

Issues públicas são visíveis para todos e podem permitir que o problema seja explorado antes de ser corrigido — e antes que os usuários afetados tomem conhecimento.

Reporte de forma privada por uma destas vias:

- **GitHub Security Advisories** — use o botão "Report a vulnerability" na aba **Security** do repositório (é o canal recomendado)
- **E-mail** — `douglas.cuimar@gmail.com`

### O que incluir

- Descrição da vulnerabilidade e impacto potencial
- Passos para reproduzir ou um PoC
- Versão ou commit afetado
- Ambiente (Supabase, Vercel, navegador)
- Qualquer sugestão de correção

### O que esperar

| Etapa | Prazo |
|---|---|
| Confirmação de recebimento | até 72 horas |
| Avaliação inicial | até 7 dias |
| Prazo de correção ou plano | acordado com o reportante |

Agradecemos relatórios responsáveis. Não há recompensa financeira, mas o crédito no `NOTICE` ou nas notas de versão é bem-vindo, se você quiser.

---

## Escopo

Este sistema processa **dados pessoais** de clientes finais de comércios: nome, e-mail, telefone, consentimento de comunicação e histórico de visitas. Isso o coloca sob a **LGPD** (Brasil) e regulamentos equivalentes.

Por isso, as seguintes áreas são tratadas como sensíveis:

- **Isolamento entre tenants** — um comércio nunca deve acessar dados de outro
- **RLS e funções RPC** — regras no banco, nunca só na interface
- **Credenciais server-only** — `SUPABASE_SERVICE_ROLE_KEY` ignora RLS por completo
- **Chaves de criptografia** — `ZERNIO_ENCRYPTION_KEY` protege tokens de terceiros
- **Endpoints públicos** — cartão público, entrada em campanha e site institucional são acessíveis sem autenticação

---

## Boas práticas para operadores

### Nunca exponha segredos no navegador

Variáveis com prefixo `VITE_` são **embutidas no bundle JavaScript** e ficam publicamente visíveis.

Correto:

```dotenv
SUPABASE_SERVICE_ROLE_KEY=...
WEB_PUSH_PRIVATE_KEY=...
ZERNIO_ENCRYPTION_KEY=...
```

Errado:

```dotenv
VITE_SUPABASE_SERVICE_ROLE_KEY=...
```

Confira após o deploy:

```bash
npm run build
grep -r "service_role" dist/assets/   # deve retornar vazio
```

### Não rode o seed em produção

`supabase/seed.sql` cria contas com **senhas públicas e conhecidas** (`admin@stampfy.local` e `platform@stampfy.local`). Use apenas em projeto de teste descartável.

Para produção, crie o administrador manualmente e use `supabase/bootstrap_platform_admin.sql`.

### Proteja os cron jobs

`/api/zernio-worker` e `/api/customer-push-worker` enviam mensagens em massa. Configure segredos longos e aleatórios:

```dotenv
COMMUNICATIONS_CRON_SECRET=<16+ caracteres aleatórios>
PUSH_CRON_SECRET=<16+ caracteres aleatórios>
CRON_SECRET=<mesmo valor de COMMUNICATIONS_CRON_SECRET>
```

O header `Authorization` é obrigatório; sem ele a função recusa a execução.

### Use um Supabase separado para testes

Cada instalação é independente. Nunca aponte um ambiente de teste para o banco de produção — um `migration.sql` acidental pode destruir dados de clientes.

### Limite a exposição do service role

`SUPABASE_SERVICE_ROLE_KEY` ignora **todas** as políticas RLS. Ela só deve existir no ambiente server-side das funções em `api/`. Nunca a envie ao navegador, nem a exponha em variáveis `VITE_`.

---

## Para quem revende ou implementa

Se você opera o Stampfy para clientes, duas responsabilidades passam a ser suas.

### 1. Titularidade de dados (LGPD)

Ao revender, você ou o seu cliente pode ser o controlador dos dados pessoais dos clientes finais. Isso tem consequências legais reais.

Verifique e ajuste antes de operar com dados reais:

- [ ] A política de privacidade identifica o controlador correto
- [ ] Os termos de uso estão coerentes com o tratamento
- [ ] A base legal para coletar e-mail e telefone está definida (consentimento é o mais seguro para marketing)
- [ ] O cliente final tem como exercer direitos do titular (acesso, correção, exclusão)

Os documentos padrão estão em `components/PrivacyPolicyPage.tsx`, `components/TermsPage.tsx` e `components/CookiePolicyPage.tsx`. **Revise-os antes de usar com dados reais** — um modelo genérico não substitui análise jurídica.

### 2. Consentimento de comunicação

O sistema só envia WhatsApp ou push para quem consentiu, e o cliente pode revogar a qualquer momento. **Não crie atalhos** que burlem essa regra — além do risco regulatório, isso quebra a confiança do consumidor.

---

## Boas práticas para contribuidores

Ao mexer em código que toca segurança:

- **Não mova regra de negócio para o cliente.** Se pode ser contornado chamando a API direto, está na camada errada.
- **Novas tabelas** devem ter RLS habilitado e políticas explícitas.
- **Funções RPC** que precisam de privilégio elevado devem usar `security definer` com `search_path` fixo.
- **Endpoints públicos** devem validar entrada e não revelar a existência de recursos (responda de forma genérica para recurso inexistente).

---

## Escopo dos relatórios

Agradecemos relatórios sobre:

- Escalação de privilégios entre tenants
- Vazamento de dados entre comércios ou entre clientes
- Bypass de RLS
- Exposição de segredos
- Falhas de autenticação ou sessão
- Injeção (SQL, XSS, command injection)
- Problemas de consentimento em comunicação

Fora do escopo:

- Ausência de rate limiting sem impacto demonstrável
- Problemas em dependências sem caminho de exploração real
- Achados de scanner automatizado sem demonstração prática
- Problemas de UX sem impacto de segurança

---

## Agradecimentos

Agradecemos a quem reporta Responsavelmente. Não temos programa de recompensa, mas o crédito no `NOTICE` ou nas notas de versão é bem-vindo, se você quiser.