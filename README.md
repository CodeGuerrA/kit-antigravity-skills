# 🛸 Antigravity Kit v2.0

Kit de templates de IA para transformar qualquer IDE assistida por agentes (Gemini CLI, Cursor, Windsurf) em um **Engenheiro de Software Sênior** e **Auditor Determinístico** para projetos Java/Spring Boot com Arquitetura Hexagonal.

---

## 📂 ARQUITETURA DO KIT

```
antigravity-kit/
├── bin/
│   └── cli.js                  # Motor CLI (Node.js)
├── templates/
│   ├── GEMINI.md               # Constituição (Mestre v2.0)
│   └── .agent/                 # O Cérebro
│       │   ├── reviewer-bugs.md                # (6) Bug Hunter — Crashes e Nulidade
│       │   ├── clean-coder.md                   # (E) Arquiteto de Escrita SOLID + Sonar
│       │   └── sonarqube-fixer.md               # (8) Cirurgião de Dívida Técnica (MCP)
│       ├── skills/             # Conhecimento Técnico
│       │   ├── code-standards.md               # Os 14 Pilares de Excelência
│       │   ├── hexagonal-architecture.md       # Ports & Adapters Completo
│       │   └── socratic-protocol.md            # Protocolo Socrático + sequential-thinking
│       ├── workflows/          # Processos Operacionais
│       │   ├── code-review.md                  # /code-review — Quality Gate Multi-Agente
│       │   └── implement.md                    # /implement — Implementação SOLID + Hexagonal
│       └── scripts/            # Verificações Estáticas
│           ├── checklist.sh                    # Auditoria geral (9 verificações)
│           ├── verify-ports.sh                 # Pureza de Ports — V2
│           ├── verify-messages.sh              # ErrorCodes vs messages.properties — V4
│           └── verify-exceptions.sh            # Hierarquia de Exceptions — V3
└── package.json
```

---

## 🚀 COMO INSTALAR

```bash
# 1. Clone ou navegue até a pasta do kit
cd ~/Documentos/antigravity-kit

# 2. Instale globalmente
npm link

# 3. Em qualquer projeto Java/Spring Boot:
antigravity-kit init

# Para atualizar templates existentes:
antigravity-kit init --force
```

---

## 🛡️ O QUE O KIT FAZ

### 👥 O TIME DE ELITE (The Dream Team)

O seu time do **Antigravity Kit** é uma unidade de elite composta por 9 especialistas digitais ultra-sincronizados:

#### 🏛️ Liderança e Execução
- **`@backend-auditor` (Tech Lead)**: O juiz final. Resolve conflitos entre agentes e garante o veredito (APROVADO/REPROVADO), cruzando dados com o servidor SonarQube real.
- **`@clean-coder` (O Arquiteto de Escrita)**: O braço direito na criação. Planeja cada passo via `sequential-thinking` e valida o código no Sonar local em tempo real antes da entrega.

#### 🔎 O "Conselho dos Seis" (Os Revisores)
1.  **`@reviewer-architect`**: Guardião das fronteiras hexagonais e do princípio DRY (zero duplicação sistêmica).
2.  **`@reviewer-quality`**: O esteta do Clean Code; exige perfeição na legibilidade e manutenibilidade para facilitar o onboarding de novos devs.
3.  **`@reviewer-security`**: O hacker ético; caça injeções SQL, vulnerabilidades OWASP e vazamentos de PII (dados sensíveis).
4.  **`@reviewer-performance`**: O caçador de milissegundos; elimina N+1, problemas de cache e complexidade algorítmica desnecessária.
5.  **`@reviewer-tester`**: O mestre da cobertura; usa o Sonar para identificar lacunas e blindar o código com testes BDD, Fixtures e E2E.
6.  **`@reviewer-bugs`**: O caçador de nulidades e transações quebradas; prevê falhas de runtime e inconsistências lógicas.

#### 🛠️ Especialistas de Suporte
- **`@sonarqube-fixer` (O Cirurgião)**: Atua pós-push. Identifica issues abertas no servidor e as corrige cirurgicamente, sincronizando o status no dashboard.
- **`@reviewer-crossfile-validator`**: O validador de consistência sistêmica entre múltiplos arquivos (SecurityConfig, Ports, Mappers).

### 🔄 CICLO DE VIDA DE DESENVOLVIMENTO (Workflow Order)

Para garantir a perfeição técnica, siga rigorosamente esta ordem de execução:

1.  **`/implement`**: O ponto de partida. O `@clean-coder` planeja via `sequential-thinking` e escreve código blindado com pré-validação Sonar em tempo real.
2.  **`/test`**: A blindagem. O `@reviewer-tester` identifica lacunas de cobertura através do Sonar e cria a camada de testes (BDD, Fixtures, E2E).
3.  **`/code-review`**: A barreira final de pré-commit. O `@backend-auditor` orquestra os 6 especialistas para dar o veredito binário antes de você subir o código.
4.  **`/analista`**: Auditoria sistêmica. Uma visão macro e holística da saúde do projeto, ideal para execuções periódicas ou antes de releases.
5.  **`/fix-sonar`**: Remediação pós-push. Utilizado apenas caso o servidor central capture falhas após o push ou o Quality Gate do pipeline falhe.

### Scripts de Verificação Estática

| Script | Descrição | Automatiza |
|:-------|:----------|:-----------|
| `checklist.sh` | Auditoria geral (9 verificações: @Autowired, leak domínio, PII, SQL injection, etc.) | Pilares 1-8, 14 |
| `verify-ports.sh` | Pureza de Ports — detecta imports e tipos de framework em domain/port/ | V2 (ALTA) |
| `verify-messages.sh` | ErrorCodes vs messages.properties — verifica chave + chave.detail | V4 (ALTA) |
| `verify-exceptions.sh` | Hierarquia de Exceptions — verifica extends, hardcoded e mapeamento | V3 (MÉDIA) |

```bash
# Executar verificações individualmente:
bash .agent/scripts/checklist.sh [diretório_raiz]
bash .agent/scripts/verify-ports.sh [diretório_raiz]
bash .agent/scripts/verify-messages.sh [diretório_raiz]
bash .agent/scripts/verify-exceptions.sh [diretório_raiz]
```

---

## 🧠 FILOSOFIA

- **Protocolo Socrático**: Validar o escopo antes de codar.
- **`sequential-thinking`**: Planejamento obrigatório antes de tarefas complexas.
- **Integração SonarQube (MCP)**: O kit agora conta com as regras de ouro do SonarQube para Java (Bugs, Vulnerabilidades e Performance) integradas nativamente nos checklists dos agentes.
- **Auditoria Binária**: APROVADO ou REPROVADO. Sem meio-termo.
- **14 Pilares de Excelência**: SOLID, Clean Code, Hexagonal, DDD, Segurança, Observabilidade.

---

## 📋 CHANGELOG

### v2.2.0
- **Agente @clean-coder (Agente E)**: Especialista em escrita de alta performance com uso mandatório de `analyze_code_snippet` para cada arquivo criado.
- **Agente @sonarqube-fixer (Agente 8)**: Introdução do "Cirurgião de Qualidade" para remediação ativa de issues do servidor SonarQube.
- **Workflow `/fix-sonar`**: Novo processo para zerar dívida técnica e status de Quality Gate após commits/pipelines falhos.
- **Mecanismo de Prova Real (Backtracking)**: Todos os agentes de correção agora utilizam o Sonar para validar o fix; se falhar, o fluxo retrocede automaticamente.

### v2.1.0
- **Integração Nativa SonarQube**: Todos os agentes reviewers agora seguem as regras de ouro do SonarQube Java (S-codes) para detecção de Bugs, Vulnerabilidades, Hotspots, Code Smells e Performance.
- **Workflow `/analista` atualizado**: Tabelas de verificação agora incluem identificadores S-code para auditoria determinística.
- **Skills Consolidadas**: `code-standards.md` expandido com tabelas de referência cruzada SonarQube.

### v2.0.0
- Adicionado Agente E (`@clean-coder`) com escopo semântico diferenciado.
- Expandido `code-standards.md` de ~60 para ~200+ linhas com Dispatch Table completa.
- Expandido `hexagonal-architecture.md` com camada `shared/`, imports proibidos e fluxo de dados.
- Expandido `socratic-protocol.md` com `sequential-thinking` obrigatório.
- Consolidado `quality-audit.md` em `code-review.md` — eliminada redundância.
- Adicionado frontmatter YAML a todos os .md de agents, skills e workflows.
- Expandido `checklist.sh` de 3 para 9 verificações com paths dinâmicos.
- Adicionados 3 scripts de verificação cross-file: `verify-ports.sh`, `verify-messages.sh`, `verify-exceptions.sh`.
- Adicionado formato padronizado de relatório ao `@backend-auditor`.
- Resolvida contradição de nomenclatura (sufixo `*Service` obrigatório).

### v1.0.0
- Versão inicial com 6 agentes, 3 skills, 3 workflows e CLI.
