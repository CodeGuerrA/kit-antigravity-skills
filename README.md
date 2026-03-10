# Antigravity Kit

Framework de configuração de agentes de IA para projetos **Java/Spring Boot com Arquitetura Hexagonal**. Transforma qualquer IDE com assistente de IA (Gemini CLI, Cursor, Windsurf) em um time de especialistas com papéis bem definidos, workflows determinísticos e Quality Gate binário.

---

## O que é

O Antigravity Kit instala no seu projeto um conjunto de arquivos Markdown que definem:

- **Agentes** — personas especializadas (arquiteto, revisor de segurança, tester, etc.)
- **Skills** — conhecimento técnico (arquitetura hexagonal, padrões de exceção, testes, etc.)
- **Workflows** — processos com passos obrigatórios ativados por comandos (`/implement`, `/code-review`, etc.)
- **Scripts** — verificações estáticas executáveis em shell

Quando você abre o projeto na sua IDE, o agente de IA lê esses arquivos e passa a se comportar segundo as regras definidas — sem precisar repetir contexto a cada sessão.

---

## Pré-requisitos

- **Node.js** >= 14 (para instalar o CLI)
- Uma IDE com agente de IA que leia arquivos de contexto do projeto:
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli) — lê `GEMINI.md`
- **SonarQube** (opcional) — necessário para os workflows `/code-review` e `/fix-sonar` com validação real

---

## Instalação

```bash
# 1. Clone o repositório
git clone <url-do-repo>
cd antigravity-kit

# 2. Instale o CLI globalmente via npm link
npm install
npm link

# Agora o comando "antigravity-kit" está disponível globalmente
```

---

## Uso

### Inicializar em um projeto

Navegue até a raiz do seu projeto Java e rode:

```bash
antigravity-kit init
```

Isso copia para o projeto:
- `GEMINI.md` — arquivo de constituição lido pela IDE ao iniciar a sessão
- `.agent/` — diretório com todos os agentes, skills, workflows e scripts

Para atualizar (sobrescrever arquivos existentes):

```bash
antigravity-kit init --force
```

### Estrutura instalada no projeto

```
projeto/
├── GEMINI.md                        # Constituição — lida pela IDE ao iniciar
└── .agent/
    ├── agents/                      # Personas dos especialistas
    │   ├── backend-auditor.md       # Tech Lead / orquestrador do Quality Gate
    │   ├── clean-coder.md           # Arquiteto de implementação (usa sequential-thinking)
    │   ├── reviewer-architect.md    # Guardião da arquitetura hexagonal e SOLID
    │   ├── reviewer-bugs.md         # Caçador de nulidades e bugs de runtime
    │   ├── reviewer-performance.md  # Detecta N+1, cache e problemas de complexidade
    │   ├── reviewer-quality.md      # Clean Code, nomenclatura, legibilidade
    │   ├── reviewer-security.md     # OWASP, SQL injection, vazamento de PII
    │   ├── reviewer-tester.md       # Cobertura de testes via Sonar, BDD, fixtures
    │   └── sonarqube-fixer.md       # Remediação ativa de issues do SonarQube
    ├── skills/                      # Conhecimento técnico consultado pelos agentes
    │   ├── code-standards.md        # 14 Pilares de Excelência + Dispatch Table
    │   ├── exception-patterns.md    # Padrões de hierarquia de exceções
    │   ├── hexagonal-architecture.md# Ports & Adapters, imports proibidos, fluxo de dados
    │   ├── modular-monolith.md      # Padrões de monólito modular
    │   ├── module-template.md       # Template Bottom-Up para novos módulos
    │   ├── socratic-protocol.md     # Protocolo de perguntas antes de codar
    │   └── testing-patterns.md      # Padrões de testes (BDD, fixtures, E2E)
    ├── workflows/                   # Processos ativados por comandos slash
    │   ├── implement.md             # /implement
    │   ├── test.md                  # /test
    │   ├── code-review.md           # /code-review
    │   ├── analista.md              # /analista
    │   └── fix-sonar.md             # /fix-sonar
    └── scripts/                     # Scripts de verificação estática (bash)
        └── checklist.sh             # Auditoria geral (9 verificações)
```

---

## Workflows (comandos)

Após `init`, abra o projeto na sua IDE e use os comandos abaixo nas conversas com o agente:

### `/implement <descrição>`

Implementa uma funcionalidade ou módulo completo.

O agente (`@clean-coder`) executa:
1. **Protocolo Socrático** — faz 1–3 perguntas para clarificar escopo antes de codar
2. **Planejamento via `sequential-thinking`** — arquitetura, artefatos, impacto, riscos
3. **Implementação Bottom-Up** (para novos módulos): Domain → Infrastructure → Application → API
4. **Pré-validação no SonarQube** (se disponível) antes de entregar o código

```
/implement adicionar endpoint de criação de produtor com validação de CPF/CNPJ
```

---

### `/test <arquivo ou módulo>`

Gera ou completa a camada de testes.

O agente (`@reviewer-tester`) executa:
1. Consulta o SonarQube para identificar lacunas de cobertura
2. Cria testes nos padrões BDD, Fixtures e E2E
3. Garante cobertura das regras de negócio críticas

```
/test ProducerService
```

---

### `/code-review <arquivo(s)>`

Quality Gate multi-agente com veredito binário: **APROVADO** ou **REPROVADO**.

O `@backend-auditor` orquestra 6 sub-agentes em paralelo:

| Agente | Foco |
|--------|------|
| `@reviewer-architect` | SOLID, DRY, fronteiras hexagonais |
| `@reviewer-quality` | Nomenclatura, Clean Code, complexidade |
| `@reviewer-security` | OWASP Top 10, SQL injection, PII |
| `@reviewer-performance` | N+1, cache, algoritmos |
| `@reviewer-tester` | Cobertura, cenários de teste |
| `@reviewer-bugs` | Nulidades, transações, lógica de runtime |

Ao final, o `@backend-auditor` consolida os relatórios e emite o veredito com os itens bloqueantes.

```
/code-review src/main/java/com/example/producer/
```

---

### `/analista`

Auditoria macro de saúde do projeto. Ideal antes de releases ou periodicamente.

Produz um relatório holístico com métricas de arquitetura, segurança, cobertura e dívida técnica.

```
/analista
```

---

### `/fix-sonar`

Remediação ativa de issues abertas no servidor SonarQube após push ou falha de pipeline.

O `@sonarqube-fixer` executa:
1. Consulta as issues abertas no servidor
2. Corrige cirurgicamente cada uma
3. Revalida no Sonar para confirmar a correção (backtracking automático se falhar)

```
/fix-sonar
```

---

## Scripts de verificação estática

Podem ser executados manualmente a qualquer momento, independente de IDE ou agente:

```bash
# Auditoria geral: @Autowired, leak de domínio, PII, SQL injection, etc. (9 verificações)
bash .agent/scripts/checklist.sh [diretório_raiz]

# Exemplo apontando para a raiz do projeto:
bash .agent/scripts/checklist.sh src/main/java
```

---

## Fluxo recomendado

```
1. antigravity-kit init          # uma vez, na raiz do projeto
2. /implement <feature>          # implementar nova funcionalidade
3. /test <arquivo>               # cobrir com testes
4. /code-review <arquivo>        # Quality Gate antes do commit
5. git push
6. /fix-sonar                    # se o pipeline falhar no Sonar
```

---

## Changelog

### v2.2.0
- Agente `@clean-coder`: especialista em escrita com validação Sonar em tempo real
- Agente `@sonarqube-fixer`: remediação ativa com backtracking automático
- Workflow `/fix-sonar`: zera dívida técnica pós-pipeline

### v2.1.0
- Integração nativa SonarQube em todos os agentes revisores (regras S-code)
- Workflow `/analista` com identificadores S-code para auditoria determinística
- `code-standards.md` expandido com tabelas de referência cruzada SonarQube

### v2.0.0
- Adicionado `@clean-coder` com `sequential-thinking` obrigatório
- `code-standards.md` expandido para 200+ linhas com Dispatch Table completa
- `hexagonal-architecture.md` com imports proibidos e fluxo de dados
- `checklist.sh` expandido de 3 para 9 verificações com paths dinâmicos
- Frontmatter YAML em todos os arquivos `.md`
- Eliminada redundância entre `quality-audit.md` e `code-review.md`

### v1.0.0
- Versão inicial: 6 agentes, 3 skills, 3 workflows, CLI
