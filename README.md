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
│       ├── agents/             # 7 Especialistas (A-E, X + Auditor)
│       │   ├── backend-auditor.md              # Orquestrador e Veredito Final
│       │   ├── reviewer-structure-guardian.md   # (A) Nomenclatura, DI, DTOs, OpenAPI
│       │   ├── reviewer-hexagonal-architect.md  # (B) Hexagonal, DDD, Entity Separation
│       │   ├── reviewer-code-quality.md         # (C) SOLID, Clean Code, OOP, Performance
│       │   ├── reviewer-security-observability.md # (D) Segurança, Exceptions, Logging
│       │   ├── reviewer-crossfile-validator.md  # (X) Validações Cross-File (V1-V6)
│       │   └── clean-coder.md                   # (E) Legibilidade Semântica
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

### Agentes de Auditoria (Quality Gate Binário)
| ID | Agente | Responsabilidade |
|:---|:-------|:-----------------|
| — | `@backend-auditor` | Orquestra sub-agentes e emite veredito final |
| A | `@reviewer-structure-guardian` | Nomenclatura, DI/Lombok, DTOs, OpenAPI (Pilares 1,2,4,7) |
| B | `@reviewer-hexagonal-architect` | Fronteiras Hexagonais, DDD, Entity Separation (Pilares 3,9,10) |
| C | `@reviewer-code-quality` | SOLID, Clean Code mecânico, OOP, Performance (Pilares 5,6,11,12) |
| D | `@reviewer-security-observability` | Segurança/PII, Exceptions, Logging (Pilares 8,13,14) |
| E | `@clean-coder` | Legibilidade semântica, clareza de intenção |
| X | `@reviewer-crossfile-validator` | 6 validações cross-file (SecurityConfig, Ports, Exceptions, etc.) |

### Workflows Disponíveis
- **`/code-review`**: Auditoria multi-agente completa com relatório formatado.
- **`/implement`**: Implementação guiada por SOLID + Hexagonal com checklist.

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
- **Auditoria Binária**: APROVADO ou REPROVADO. Sem meio-termo.
- **14 Pilares de Excelência**: SOLID, Clean Code, Hexagonal, DDD, Segurança, Observabilidade.

---

## 📋 CHANGELOG

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
