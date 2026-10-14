# Guia de venda e implementação

Guia para quem quer **vender, implementar ou operar** o Stampfy para comércios locais.

Este documento não é bindings legal. Preços aqui são **referências de mercado**, não recomendações oficiais. Ajuste à sua realidade comercial.

---

## 1. O que você está vendendo

O Stampfy é um sistema de fidelidade **auto-hospedado**. Você instala, configura e entrega. Não existe cobrança recorrente embutida — se você quiser cobrar mensalidade, precisa operar a cobrança por fora.

### O que está pronto

| Módulo | Estado |
|---|---|
| Cartões digitais, campanhas, QR Code, equipe | Pronto |
| Missões e desafios | Pronto |
| Pontos, níveis e emblemas | Pronto |
| Catálogo de recompensas e cupons | Pronto |
| Site institucional por comércio | Pronto |
| Domínio próprio por comércio | Pronto |
| Portal do cliente | Código pronto; patch requer aplicação no Supabase do cliente |
| Lembretes e reengajamento | Código pronto; patch requer aplicação |
| WhatsApp via Zernio | Código pronto; patch e credenciais Meta requerem configuração |

### O que NÃO está pronto

Não prometa o que não existe:

- ❌ **Cobrança recorrente** — não há integração com gateway de pagamento
- ❌ **Marketplace entre comércios** — cada cliente vê apenas o próprio comércio
- ❌ **Cadastro multi-unidade** — um owner = um comércio
- ❌ **Aplicativo mobile nativo** — é PWA instalável
- ❌ **Automação de Instagram** — a integração Zernio cobre apenas conexão, não publicação nem DM

---

## 2. Modelos de comercialização

### A. Licença de instalação única

Você cobra uma taxa de setup + licença anual. O cliente hospeda na própria conta.

**Comporta-se bem quando:** o cliente quer ter controle dos dados; você quer reduzir suporte recorrente.

**Atenção:** sem cobrança automática embutida, o lembrete de renovação é manual. Isso é trabalho recorrente seu — considere um contrato claro.

### B. Licença por tenant (SaaS auto-hospedado)

Uma instalação sua atende N comércios. Você cobra por comércio ativo.

**Comporta-se bem quando:** muitos comércios pequenos que não querem lidar com infraestrutura.

**Atenção:** você é operador. Suporte, backups, updates e disponibilidade são seus. Defina SLA desde o início — mesmo informal.

### C. Implementação como serviço

Cobra pela implantação: setup, migração de dados, treinamento, identidade visual.

**É o modelo mais defensável.** Mesmo com MIT, o cliente final não tem como buying a commodity sem contratar alguém. Combine com A ou B.

### D. Manutenção contínua

Contrato mensal de suporte, atualização e monitoramento.

---

## 3. Precificação de referência

Valores em Real.Ajuste à sua região e ao seu custo real.

| Serviço | Faixa de referência |
|---|---|
| Setup + implantação inicial | R$ 800 – R$ 3.000 |
| Licença anual (instalação própria do cliente) | R$ 1.200 – R$ 4.000/ano |
| SaaS por comércio (plano básico) | R$ 99 – R$ 299/mês |
| SaaS por comércio (plano com site + WhatsApp) | R$ 299 – R$ 799/mês |
| Personalização de marca | R$ 500 – R$ 2.000 |
| Migração de dados de sistema antigo | R$ 800 – R$ 3.000 |
| Treinamento presencial | R$ 300 – R$ 800/sessão |

**Como precificar:**
- Parta do seu custo de infra (veja abaixo) + seu tempo + margem.
- Cobre deslocamento e horas extras separadamente.
- Desconto para multi-lojas, mas certifique-se de que seu modelo suporta multi-unidade (hoje não suporta).

---

## 4. Custos de infraestrutura do cliente

Para o cliente operar sozinho, ele precisa de:

| Item | Custo aproximado | Observação |
|---|---|---|
| Vercel (Hobby/Pro) | US$ 0 – US$ 20/mês | Functions, cron, analytics |
| Supabase (Free/Pro) | US$ 0 – US$ 25/mês | Postgres, Auth, Storage |
| Domínio | R$ 40 – R$ 90/ano | Opcional; funciona por subdomínio |
| Vercel API (domínios próprios) | incluso no plano | Requer token com permissão |

**Margem bruto** do modelo B fica em 70%–90% porque o custo de infra é baixo. O custo real é **seu tempo de suporte**.

Se o cliente já tem infraestrutura, parte desse custo sai da conta dele.

---

## 5. Passo a passo de implantação

1. **Discovery** — entender o processo atual do cliente: como ele dá o carimbo hoje? Usa papel, WhatsApp, app?
2. **Provisionamento** — criar projeto Supabase e deploy Vercel com a marca do cliente (ver [`white-label.md`](white-label.md)).
3. **Banco** — executar `supabase/migration.sql`. Aplicar patches adicionais conforme os módulos contratados (ver [`instalacao.md`](instalacao.md)).
4. **Conta do proprietor** — o cliente cria a empresa em `/signup`. Anote o `slug`.
5. **Configuração** — nome, cor, logo, moeda, fuso horário, site institucional.
6. **Importação** — cadastrar clientes e cartões existentes, se aplicável.
7. **Treinamento** — fluxo do owner, fluxo da equipe (leitura de QR), fluxo do cliente.
8. **Go-live** — testar em modo real: um cliente compra, recebe o carimbo, resgata.
9. **Documentação de entrega** — entregar as credenciais e as variáveis de ambiente ao cliente.

---

## 6. Argumentos de venda

Pontos fortes verificáveis do produto:

- **Sem app para o cliente instalar** — card accessed por link. Isso derruba a barreira de adesão, que é o principal problema de fidelidade em comércio local.
- **Isolamento por tenant** — dados de cada comércio separados por `owner_id` com RLS.
- **Site do comércio incluso** — o cliente ganha presença digital própria, não só um sistema de pontos.
- **WhatsApp integrado** — usa o canal que o comércio já usa, com templates aprovados pela Meta.
- **Código aberto** — o cliente não fica refém. Auditável, MIT, sem lock-in de fornecedor.

**Não diga:** que a plataforma é "o Enggaja brasileiro" ou que garante ROI. Não faça promessa de resultado comercial. O produto é uma ferramenta; o resultado depende da operação do comércio.

---

## 7. Perguntas frequentes

**O cliente precisa saber programar?**
Para instalar sozinho, não. Se você faz a implantação (modelo C), ele precisa apenas ter contas Supabase e Vercel — ou você usa contas suas.

**Posso revender com minha marca?**
Sim. MIT permite uso comercial. Substitua nome, logo, domínio e e-mails — ver [`white-label.md`](white-label.md). A licença MIT não concede direitos de marca do "Stampfy", então renomeie.

**Preciso comprar o domínio do cliente?**
Para site institucional com subdomínio, não. Para domínio próprio, o cliente deve ter o domínio dele.

**O cliente final precisa criar conta Supabase?**
Não. Ele usa seu instalação; você opera.

**Quanto tempo leva a implantação?**
Instalação básica: 1–2 dias. Com site institucional, rebranding e importação de dados: 1–2 semanas.

**Posso mudar os textos e as cores?**
Sim. Cores em Tailwind (`tailwind.config.cjs`, CSS), textos em `lib/i18n.ts`, páginas legais nos componentes correspondentes. Ver [`white-label.md`](white-label.md#5-textos-da-interface).

**E se o cliente quiser functionality que não existe?**
Desenvolvimento sob medida. MIT permite isso — o fork é seu, e você pode cobrar pelo custom.

**O que acontece se eu descontinuar o produto?**
Como o cliente hospeda na própria conta (modelo A), ele continua operando. Por isso o modelo A é o mais defensável para o cliente final.

---

## 8. Limitações que você deve comunicar

Transparência aqui evita litígio e builds de expectativa:

- Comunicação por WhatsApp depende de **aprovação de templates pela Meta** — pode levar dias e não é garantido.
- Push notification depende do navegador e do sistema; **não há garantia de entrega** nem de visualização.
- Instagram: apenas conectado, **sem automação** de DM ou publicação.
- Cobrança recorrente **não existe** no produto — se o cliente final cobrar do consumidor final, isso é responsabilidade dele.
- Patches de portal do cliente, push e lembretes ainda **não foram validados em produção** em larga escala — comunique como beta.

---

## 9. Checklist comercial

Antes de fechar contrato:

- [ ] Escopo por escrito: quais módulos estão incluídos
- [ ] Explicitado que cobrança recorrente não está inclusa
- [ ] Explicitadas as limitações de WhatsApp/push
- [ ] Definido quem paga a infraestrutura
- [ ] Definido prazo de suporte pós-venda
- [ ] Acordo de titularidade de dados (LGPD) assinado
- [ ] Confirmado que o cliente final sairá com acesso aos próprios dados

---

## Ver também

- [`white-label.md`](white-label.md) — rebranding técnico
- [`instalacao.md`](instalacao.md) — setup técnico
- [`arquitetura.md`](arquitetura.md) — o que dá para estender
- [`../SECURITY.md`](../SECURITY.md) — obrigações de segurança com dados de clientes