# Changelog

Todas as mudanças relevantes deste projeto são registradas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o versionamento segue [SemVer](https://semver.org/lang/pt-BR/).

---

## [Não publicado]

### Adicionado
- White-label completo: nome, descrição, imagem social, e-mails, telefone e URL canônica agora vêm de variáveis de ambiente (`VITE_APP_NAME`, `VITE_APP_DESCRIPTION`, `VITE_SOCIAL_IMAGE`, `VITE_SALES_EMAIL`, `VITE_NUMBER_COMERCIAL`)
- Plugin de SEO (`scripts/seo-config.mjs`) que resolve tokens em `index.html` no dev e no build, sem alterar o arquivo-fonte
- Documentação reorganizada: `docs/instalacao.md`, `docs/arquitetura.md`, `docs/white-label.md`, `docs/venda-e-implementacao.md` e índice em `docs/README.md`
- Documentos em inglês: `README.en.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`
- `CHANGELOG.md`, templates de issue e pull request, CI com verificação de tipos, build e detecção de vazamento de segredos

### Corrigido
- **Segurança:** credenciais pessoais que estavam commitadas em `supabase/seed.sql` foram substituídas por placeholders de desenvolvimento, com aviso explícito no arquivo
- **Segurança:** histórico do Git reescrito para remover as credenciais de todos os commits anteriores
- **Licença:** o `LICENSE` passou a preservar o aviso de copyright do autor original, como exige a MIT
- Links quebrados: `vercel.ts` (arquivo inexistente) corrigido para `vercel.json`
- README e documentos que descreviam o site institucional como "não implementado" — o módulo está implementado

### Removido
- Arquivos internos e pessoais do versionamento: `TASK.md`, `opencode.json`, `metadata.json`
- Assets de branding obsoletos: `public/stampverse.svg`, `public/stampverse-logo.svg`
- Domínio de produção fixado no código (`vercel.json` passou a usar o padrão genérico `*.vercel.app`)

### Alterado
- `lib/siteConfig.ts` e `lib/businessSiteDomain.ts` não têm mais nenhum domínio fixo; passam a derivar do ambiente
- Funções em `api/` e scripts de build leem a origem do ambiente, sem fallback fixo
- `.gitignore` cobre configuração de assistentes de IA, documentos internos e artefatos de build
- Documentos renomeados: `operacao-de-missoes.md` → `missoes.md`, `sites-institucionais.md` → `sites.md`

---

## [Base do projeto]

O Stampfy nasceu do fork de [Stampee](https://github.com/danlim26/stampee) (Danilo Lim, MIT). O detalhamento completo do que este fork agrega está em [`NOTICE`](NOTICE).

### Adicionado (desde o projeto original)

**Plataforma multi-tenant**
- Isolamento de dados por `owner_id`
- Console de plataforma em `/platform`, restrito à tabela `platform_admins`
- Gestão de tenants: listar, suspender e restaurar acesso

**Missões e desafios**
- Missões de frequência e de meta de campanha
- Progresso derivado de transações válidas no servidor
- Conclusão e concessão de recompensa idempotentes e atômicas
- Períodos avaliados no fuso horário da empresa

**Pontos, níveis e emblemas**
- Ledger imutável de pontos com chave de idempotência
- Níveis configuráveis por faixa de pontos
- Emblemas por marcos verificáveis
- Ajustes manuais auditados, exclusivos do owner

**Catálogo de recompensas**
- Recompensas globais ou por campanha, com estoque e elegibilidade
- Códigos únicos e expiráveis, validados pela equipe
- Cancelamento com devolução de pontos
- Trilha de auditoria completa

**Site institucional**
- Editor assistido, uploads, catálogo de produtos e SEO básico
- Histórico de publicação e páginas renderizadas no servidor
- Captura de leads
- **Domínio próprio** por comércio via API da Vercel, com verificação DNS

**Portal do cliente**
- Conta única agregando cartões de vários comércios
- Vínculo por e-mail verificado ou por link do cartão
- Preferências de comunicação revisáveis e revogáveis por comércio

**Comunicação**
- WhatsApp via Zernio, com templates aprovados pela Meta
- Outbox idempotente com revalidação de consentimento
- Lembretes de reengajamento com gatilhos, cadência e supressão

**PWA e Web Push**
- Instalável, com fallback offline
- Notificações opcionais, com permissão só após clique explícito

**Outros**
- Interface bilíngue/trilíngue (pt-BR, en, es)
- Moeda e fuso horário por empresa
- TypeScript estrito
- Cron jobs e headers de segurança no `vercel.json`

---

## Como versionar

O projeto ainda não segue releases formais. Ao publicar a primeira release:

1. Atualize `version` em `package.json`
2. Mova as entradas de `[Não publicado]` para a nova seção
3. Registre a data no formato `AAAA-MM-DD`
4. Crie a tag no formato `vX.Y.Z`

---

## Links

- [README](README.md)
- [Documentação](docs/README.md)
- [Instalação](docs/instalacao.md)
- [White-label](docs/white-label.md)
- [Créditos e atribuição](NOTICE)