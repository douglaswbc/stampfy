# Guia de contribuição

Obrigado pelo interesse em contribuir com o **Stampfy**.

Este projeto é open source sob licença MIT e aceita contribuições de qualquer pessoa.

---

## Código de conduta

Ao participar, você concorda com o [Código de Conduta](CODE_OF_CONDUCT.md).

---

## Reportando bugs

Abra uma issue com:

- **O que aconteceu** (comportamento observado)
- **O que deveria ter acontecido** (comportamento esperado)
- **Passos para reproduzir**
- **Ambiente**: versão do Node, navegador, e se é produção ou desenvolvimento
- **Mensagem de erro** completa, se houver (remova segredos)

Se o problema envolve **segurança**, **dados de clientes** ou **RLS**, **não** abra issue pública. Veja [`SECURITY.md`](SECURITY.md).

---

## Ambiente de desenvolvimento

Pré-requisitos: **Node.js 20+** e um projeto **Supabase** (o plano gratuito serve).

```bash
git clone https://github.com/douglaswbc/stampfy.git
cd stampfy
npm install
cp .env.example .env.local     # PowerShell: Copy-Item .env.example .env.local
```

Preencha `.env.local` com suas credenciais do Supabase e rode `supabase/migration.sql` no SQL Editor.

Detalhes completos em [`docs/instalacao.md`](docs/instalacao.md).

---

## Antes de enviar uma mudança

```bash
npx tsc --noEmit     # verificação de tipos (obrigatório)
npm run build        # build completo (obrigatório)
```

Ambos precisam passar. **Não há suíte de testes automatizados** — por isso esses dois comandos são a verificação principal.

Se sua mudança tocar banco de dados, aplique o patch em um projeto Supabase local e confirme que a migração é aditiva.

---

## Padrão de código

- **TypeScript estrito** — o `tsconfig.json` usa `strict`. Não relaxe as regras para fazer o código passar.
- **Sem formatter** — o projeto não tem Prettier/ESLint configurado. Siga o estilo do arquivo que você está editando.
- **Indentação** — 2 espaços.
- **Imports** — agrupados; use caminhos relativos (`../lib/...`) dentro de `components/`.
- **Comentários** — explique o *porquê*. Não comente o óbvio.

### Onde a regra de negócio deve viver

**Não no navegador.** Se a mudança envolve conceder pontos, concluir missão, resgatar recompensa ou gerar código de cupom, isso precisa ser uma **função RPC no Postgres**, não lógica no componente. O frontend exibe; o banco decide.

Motivo: o cliente pode chamar a API diretamente. Sem validação no servidor, é possível forjar progresso ou resgatar dois vezes.

Chamadas de dados ficam em `lib/db/`, com uma função tipada por operação. Componentes **não** chamam `supabase.from(...)` diretamente.

### Migrations

- Novos patches vão em `supabase/legacy-patches/`, com prefixo `add_` ou `fix_`.
- Sempre **aditivos**: `create table if not exists`, `drop policy if exists`.
- Nunca destrua ou recrie tabela que possa conter dados.
- Atualize a tabela de patches em [`docs/instalacao.md`](docs/instalacao.md).

---

## Commits

Mensagens no formato do repositório:

```
<tipo>: <descrição curta em imperativo>

<corpo opcional: o que mudou e por quê>
```

**Tipos usados:**

| Tipo | Quando |
|---|---|
| `feat` | Funcionalidade nova |
| `fix` | Correção de bug |
| `docs` | Apenas documentação |
| `refactor` | Mudança sem alterar comportamento |
| `perf` | Ganho de desempenho |
| `chore` | Tarefas de manutenção (deps, build, config) |
| `security` | Correção de vulnerabilidade |

Exemplos:

```
feat: add reward expiration date to rewards catalog
fix: prevent duplicate mission completion on concurrent requests
docs: clarify cron setup in installation guide
```

---

## Pull requests

1. **Abra uma issue antes** para mudanças grandes — evita trabalho duplicado.
2. Crie um branch descritivo a partir de `main`.
3. Mantenha o PR focado: **uma alteração por PR**.
4. Descreva o que muda e por quê.
5. Confirme que `tsc` e `build` passam.
6. Referencie a issue relacionada.

Evite formatação em massa e alterações não relacionadas no mesmo PR — dificultam a revisão.

---

## Áreas que sempre precisam de atenção

| Área | Por quê |
|---|---|
| `supabase/` | Afeta todos os tenants; migração errada quebra a instalação |
| `api/*.ts` | Roda com `SUPABASE_SERVICE_ROLE_KEY` — ignora RLS |
| `lib/siteConfig.ts` | White-label depende daqui estar correto |
| Migrações RLS | Impactam isolamento entre comércios |

Mudanças nessas áreas pedem revisão cuidadosa. Se não tem certeza do impacto, abra uma issue antes de codar.

---

## Traduções

A interface tem `pt-BR`, `en` e `es` em [`lib/i18n.ts`](lib/i18n.ts).

Ao adicionar um texto na interface, adicione em **todos** os três idiomas. Sem a chave em `en`, o app usa o texto original — o que costuma ficar errado em inglês.

---

##Onde a documentação entra

- Mudou o setup? → [`docs/instalacao.md`](docs/instalacao.md)
- Mudou a estrutura do código? → [`docs/arquitetura.md`](docs/arquitetura.md)
- Mudou comportamento de um módulo? → o `docs/` correspondente
- Adicionou uma variável de ambiente? → [`.env.example`](.env.example) **e** a tabela do README

---

## Código de conduta em pull requests

Participe com respeito. Mantenha as discussões focadas na mudança técnica. Assuma boa intenção.

---

## Licença

Ao contribuir, você concorda que sua contribuição seja licenciada sob a [MIT](LICENSE), a mesma licença do projeto.