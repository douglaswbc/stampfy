# Documentação

Documentação do **Stampfy** — plataforma de fidelidade digital white-label para comércios locais.

Para o guia de início rápido, comece pelo [README principal](../README.md).

---

## Primeiros passos

| Documento | Quando usar |
|---|---|
| [Instalação](instalacao.md) | Configurar o ambiente, criar o banco, fazer deploy |
| [Arquitetura](arquitetura.md) | Entender a estrutura do código antes de contribuir |
| [White-label](white-label.md) | Rebrandar e revender com a marca do seu cliente |
| [Venda e implementação](venda-e-implementacao.md) | Precificar, montar proposta e implanted para clientes |

## Funcionalidades

| Documento | Módulo |
|---|---|
| [Missões](missoes.md) | Missões, desafios e como operar |
| [Pontos e níveis](saas-foundation.md) | Modelo multi-tenant e roadmap da plataforma |
| [Site institucional](sites.md) | Site público por comércio, editor e SEO |
| [Domínio próprio](business-site-domains.md) | Conectar domínio do comércio via Vercel |

## Comunicação e retenção

| Documento | Módulo |
|---|---|
| [WhatsApp via Zernio](zernio_whatsapp_instagram_meta.md) | Integração, templates e workers |
| [Lembretes de reengajamento](customer-engagement-reminders.md) | Gatilhos, cadência e consentimento |
| [PWA e Web Push](web-push.md) | Instalação e notificações push |

## Contribuindo

| Documento | Conteúdo |
|---|---|
| [Guia de contribuição](../CONTRIBUTING.md) | Setup, padrão de commits e pull requests |
| [Código de conduta](../CODE_OF_CONDUCT.md) | Expectativas de comportamento |
| [Segurança](../SECURITY.md) | Reportar vulnerabilidades e boas práticas |
| [Changelog](../CHANGELOG.md) | Histórico de versões |

## Referência

| Item | Onde |
|---|---|
| Variáveis de ambiente | [README](../README.md#variáveis-de-ambiente) e [`.env.example`](../.env.example) |
| Patches SQL | [`supabase/legacy-patches/`](../supabase/legacy-patches/) |
| Schema canônico | [`supabase/migration.sql`](../supabase/migration.sql) |
| Comandos disponíveis | [README](../README.md#scripts) |
| Créditos e atribuição | [`NOTICE`](../NOTICE) |

---

## Status dos módulos

| Módulo | Estado |
|---|---|
| Cartões, campanhas, QR Code, equipe | Pronto |
| Missões | Pronto |
| Pontos, níveis e emblemas | Pronto |
| Catálogo de recompensas e cupons | Pronto |
| Site institucional e leads | Pronto |
| Domínio próprio | Pronto |
| Portal do cliente | Código pronto; requer patch no Supabase de destino |
| Web Push | Código pronto; requer patch e chaves VAPID |
| Lembretes de reengajamento | Código pronto; requer patch e agendamento |
| WhatsApp via Zernio | Código pronto; requer patch, credenciais e aprovação de templates |

Não implementado: cobrança recorrente, marketplace entre comércios, cadastro multi-unidade, automação de Instagram.

---

## Convenções

- Documentação principal em **português (Brasil)**. O [README em inglês](../README.en.md) cobre apenas a visão geral.
- Nomes de arquivo em minúsculas com hífen.
- Ao alterar um behaviour, atualize o documento correspondente.
- Links entre documentos usam caminho relativo.