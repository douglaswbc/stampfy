# Guia de white-label

Este guia mostra como rodar o Stampfy com **a marca do seu cliente**, sem alterar o código-fonte.

Todo o branding visível — nome, descrição, imagens sociais, e-mails, telefone e URL canônica — é controlado por variáveis de ambiente. Nenhum arquivo precisa ser editado.

> Se você ainda não instalou, comece por [`instalacao.md`](instalacao.md).

---

## 1. Identidade da marca

Preencha no `.env.local` (desenvolvimento) e no painel da sua plataforma de deploy (produção):

```dotenv
# URL canônica do cliente — SEM barra final
VITE_APP_URL=https://fidelidade.suaempresa.com.br

# Nome exibido em título, Open Graph, JSON-LD e rodapés
VITE_APP_NAME=Fideliza Loja

# Descrição em SEO / Open Graph / Twitter Card
VITE_APP_DESCRIPTION=Programa de fidelidade digital da Fideliza Loja. Junte pontos e troque recompensas.

# Imagem de compartilhamento (1200x630 recomendado)
VITE_SOCIAL_IMAGE=https://fidelidade.suaempresa.com.br/social-preview.jpg

# E-mails exibidos no rodapé, termos e política de privacidade
VITE_SUPPORT_EMAIL=contato@fidelizaloja.com.br
VITE_SALES_EMAIL=vendas@fidelizaloja.com.br

# Telefone/WhatsApp comercial — APENAS dígitos, com código do país
VITE_NUMBER_COMERCIAL=5511988887777
```

Depois rode `npm run build`. O plugin de SEO reescreve `index.html` durante o build — o arquivo-fonte **não** é alterado.

### O que cada variável controla

| Variável | Onde aparece |
|---|---|
| `VITE_APP_URL` | `<link rel="canonical">`, `og:url`, `twitter:url`, JSON-LD, sitemap, `robots.txt`, URLs em rodapés e telas de captura de cartão |
| `VITE_APP_NAME` | `<title>`, `og:site_name`, Open Graph, JSON-LD, `apple-mobile-web-app-title`, rodapé público, favicon |
| `VITE_APP_DESCRIPTION` | `og:description`, `twitter:description`, JSON-LD |
| `VITE_SOCIAL_IMAGE` | `og:image` e `twitter:image` |
| `VITE_SUPPORT_EMAIL` | Rodapé público, Termos, Política de Privacidade, Política de Cookies |
| `VITE_SALES_EMAIL` | Tela de upgrade, aviso de limite de equipe |
| `VITE_NUMBER_COMERCIAL` | Botão de WhatsApp na landing page |

Se `VITE_SUPPORT_EMAIL` e `VITE_SALES_EMAIL` não forem definidos, os links de e-mail simplesmente não são renderizados — o app funciona normalmente sem eles.

---

## 2. Logotipo e ícones

Substitua os arquivos em `public/`. **Mantenha os nomes dos arquivos** para não precisar editar o código:

| Arquivo | Uso | Tamanho sugerido |
|---|---|---|
| `stampfy.svg` | Logotipo nos rodapés e telas legais | SVG vetorial |
| `favicon.ico` | Ícone de aba | 32x32 e 16x16 |
| `pwa-icon.svg` | Ícone do PWA | SVG |
| `pwa-icon-192.png` | PWA / Android | 192x192 |
| `pwa-icon-512.png` | PWA / splash screen | 512x512 |
| `pwa-icon-180.png` | Apple touch icon | 180x180 |
| `social-preview-v2.jpg` | Imagem de compartilhamento (padrão do `VITE_SOCIAL_IMAGE`) | 1200x630 |

Para gerar os PNG a partir do SVG, use os scripts existentes:

```bash
node scripts/generate-favicon.mjs
node scripts/generate-pwa-icons.mjs
```

---

## 3. Domínio

### Domínio principal da plataforma

Defina `VITE_APP_URL` com o domínio do seu cliente e adicione o domínio na Vercel.

### Domínio próprio de cada comércio

Verifique [`business-site-domains.md`](business-site-domains.md). Em resumo:

1. Configure `VERCEL_ACCESS_TOKEN`, `VERCEL_PROJECT_ID` (e `VERCEL_TEAM_ID` se aplicável) no ambiente server-side.
2. Adicione o **curinga** do hostname da aplicação no projeto Vercel — por exemplo `*.fidelidade.suaempresa.com.br`.
3. O menu **Site → Domínio próprio** no painel permite ao comércio conectar o próprio domínio.

Enquanto um comércio não configura domínio próprio, o site dele fica em `<slug>.fidelidade.suaempresa.com.br`.

---

## 4. Landing page de marketing

A rota `/` exibe uma landing institucional do provedor. Há três opções:

**Manter** — se o seu cliente quer que a landing venda a plataforma.

**Personalizar** — edite `components/MarketingLandingPage.tsx` e `components/MarketingLandingPage.css`. A landing é pre-renderizada no build (`npm run prerender:landing`), então alterações aparecem no HTML estático, o que melhora SEO e velocidade.

**Remover** — se você quer produto puro, sem página institucional:

1. Em `App.tsx`, aponte a rota `/` para o redirect de autenticação (veja como `/login` já faz).
2. Remova `scripts/prerender:landing` de `package.json` e o passo correspondente do `build`.
3. Remova `/showcase` e `/articles` se não forem desejados — os arquivos de conteúdo estão em `data/articles.data.js` e `data/templates.tsx`.

> Remover a landing **não** afeta o painel nem os sites dos comércios.

---

## 5. Textos da interface

A interface é bilíngue e as traduções ficam em `lib/i18n.ts`:

- `pt-BR` — português brasileiro
- `en` — inglês
- `es` — espanhol

Para renomear termos que aparecem para o cliente final, edite o dicionário `pt-BR`:

```ts
messages['pt-BR'] = {
  'Save': 'Salvar',
  // ...
};
```

Para **remover** um idioma, apague a entrada em `INTERFACE_LANGUAGES` e o dicionário correspondente.

### Textos legais

- `components/TermsPage.tsx` — Termos de Uso
- `components/PrivacyPolicyPage.tsx` — Política de Privacidade
- `components/CookiePolicyPage.tsx` — Política de Cookies

> **Importante:** ao revender, ajuste o **titular do tratamento de dados** e a **base legal** nesses documentos conforme a LGPD, já que o tratamento passa a ser responsabilidade do seu cliente ou da sua empresa. Um modelo genérico não substitui revisão jurídica.

---

## 6. Onde ficam os textos de venda e pricing

O projeto é **self-host puro**: não há cobrança recorrente embutida. Não existe tela de checkout.

O componente `components/UpgradePrompt.tsx` é um aviso de limite de plano no formato "beta". Para editá-lo ou removê-lo, veja [`venda-e-implementacao.md`](venda-e-implementacao.md#modelos-de-comercialização).

---

## 7. Checklist de rebranding

- [ ] `VITE_APP_URL` aponta para o domínio do cliente
- [ ] `VITE_APP_NAME` definido
- [ ] `VITE_APP_DESCRIPTION` e `VITE_SOCIAL_IMAGE` definidos
- [ ] `VITE_SUPPORT_EMAIL` e `VITE_SALES_EMAIL` definidos
- [ ] `VITE_NUMBER_COMERCIAL` definido (ou removido da landing)
- [ ] Logotipo substituído em `public/stampfy.svg`
- [ ] Favicon e ícones PWA regerados
- [ ] Imagem `social-preview-v2.jpg` substituída
- [ ] Domínio adicionado na Vercel
- [ ] Curinga (`*.seudominio.com.br`) adicionado no projeto Vercel
- [ ] Textos legais revisados para o novo titular de dados
- [ ] Landing page mantida, personalizada ou removida — conforme decisão
- [ ] `npx tsc --noEmit` e `npm run build` passando
- [ ] `git grep -i "stampfy\|stampee"` retorna apenas o que for intencional

---

## 8. O que **não** é necessário alterar

Graças à configuração por ambiente, você **não precisa** editar nenhum destes arquivos ao rebendar:

- `index.html` — os tokens são resolvidos no build
- `vercel.json` — o roteamento por subdomínio é genérico
- `lib/siteConfig.ts`, `lib/businessSiteDomain.ts` — leem do ambiente
- `api/*.ts` — leem `APP_ORIGIN` do ambiente
- `scripts/generate-sitemap.mjs` — lê `VITE_APP_URL`

---

## 9. Manutenção em múltiplos clientes

Se você atende vários clientes com marcas diferentes, as opções são:

**Instalações separadas** — um deploy por cliente. Mais isolamento, mais infraestrutura. Recomendado quando cada cliente quer branding, domínio e banco próprios.

**Instalação compartilhada** — um único deploy com branding neutro; os clientes finais são apenas tenants dentro dele. Mais barato de operar; o branding fica no seu domínio.

Em ambos os casos, os dados são isolados por `owner_id` no Supabase. Ao criar um cliente em `/signup`, anote o `slug` — ele define o subdomínio do site e a URL pública dos cartões:

```
https://fidelidade.suaempresa.com.br/{slug}                    -> site institucional
https://fidelidade.suaempresa.com.br/{slug}/join/{campaignId}   -> entrada em campanha
https://fidelidade.suaempresa.com.br/{slug}/{uniqueId}          -> cartão público
```

---

## Ver relacionados

- [`instalacao.md`](instalacao.md) — setup e patches SQL
- [`business-site-domains.md`](business-site-domains.md) — domínios próprios
- [`venda-e-implementacao.md`](venda-e-implementacao.md) — guia comercial
- [`arquitetura.md`](arquitetura.md) — onde o código de cada função mora