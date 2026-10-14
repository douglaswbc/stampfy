## Descrição

<!-- O que este PR muda e por quê. -->

Closes #

## Tipo de mudança

- [ ] `feat` — funcionalidade nova
- [ ] `fix` — correção de bug
- [ ] `docs` — apenas documentação
- [ ] `refactor` — sem mudança de comportamento
- [ ] `perf` — ganho de desempenho
- [ ] `chore` — manutenção
- [ ] `security` — correção de vulnerabilidade

## Verificação

- [ ] `npx tsc --noEmit` passa
- [ ] `npm run build` passa
- [ ] Testei manualmente o fluxo afetado
- [ ] Se alterou o banco: o patch é **aditivo** e preserva dados existentes
- [ ] Se alterou regras de negócio: a validação está no **servidor/RPC**, não só na interface
- [ ] Se adicionei texto de interface: adicionado em `pt-BR`, `en` e `es` em `lib/i18n.ts`

## Documentação

- [ ] Atualizei o `README` (se mudou setup, scripts ou variáveis de ambiente)
- [ ] Atualizei ou criei documento em `docs/`
- [ ] Atualizei `.env.example` (se criei variável de ambiente)
- [ ] Links entre documentos funcionam

## White-label

- [ ] Não introduzi domínio, e-mail ou telefone fixo no código
- [ ] Se adicionei branding, usei `lib/siteConfig.ts` ou variável de ambiente

## Segurança

- [ ] Não adicionei segredos, chaves ou dados pessoais ao repositório
- [ ] Não movi validação de segurança para o cliente
- [ ] Se envolve vulnerabilidade, **não** describi o detalhe aqui — veja [`SECURITY.md`](../../SECURITY.md)