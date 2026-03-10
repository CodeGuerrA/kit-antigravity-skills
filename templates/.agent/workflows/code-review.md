---
description: "Orquestrador multi-agente de revisão de código — Quality Gate binário (APROVADO/REPROVADO)."
---

# 🔍 WORKFLOW: Quality Gate — Code Review (/code-review)

**Descrição**: Orquestração multi-agente de revisão de código. Coordena 6 sub-agentes especializados + 1 orquestrador (Tech Lead) para auditoria binária.

---

## 🚀 Processo Obrigatório de Orquestração

### PASSO 0 — Planejamento Estratégico (Obrigatório)
- **Utilize obrigatoriamente o `sequential-thinking`** para planejar quais sub-agentes serão necessários para cada arquivo baseado na **Dispatch Table** (ver Skill `code-standards.md`).
- **Carregue a Skill `code-standards.md`** como base universal de auditoria.
- **Acione o MCP `sonarqube`** para carregar métricas de Bugs, Vulnerabilidades, Hotspots e Code Smells do projeto/módulo atual.

### PASSO 1 — Leitura Inicial e Pré-Validação
Para CADA arquivo no escopo:
1. Use `Read` para ler o arquivo **INTEIRO**. Se não apareceu no output, a violação NÃO EXISTE.
2. Classifique o tipo (Controller, Service, Domain, etc.) usando a Dispatch Table.
3. **Pré-validação de Sufixo (Obrigatória)**: Verifique se o nome da classe corresponde ao sufixo da camada. Se violado → ALTA imediatamente.

### PASSO 2 — Análise por Sub-Agentes
Para cada arquivo, aplique TODOS os pilares correspondentes da Dispatch Table. Cada sub-agente produz um relatório:

| ID | Agente | Escopo |
|:---|:-------|:-------|
| **1** | `@reviewer-architect` | SOLID, DRY, Hexagonal, Design Patterns, Fronteiras |
| **2** | `@reviewer-quality` | Nomenclatura, Clean Code, Complexidade, Javadocs, Convenções |
| **3** | `@reviewer-security` | OWASP, PII, SQL Injection, Exceptions, Logging |
| **4** | `@reviewer-performance` | Big O, N+1, Cache, Índices, Escalabilidade |
| **5** | `@reviewer-tester` | Cobertura, Edge Cases, E2E Relacional, Fixtures |
| **6** | `@reviewer-bugs` | NullPointer, Transações, Lógica invertida, Concorrência |

**Como funciona na prática**: A IA DEVE analisar o arquivo sob a perspectiva de CADA agente aplicável, cruzando os achados manuais com as violações reportadas pelo **MCP `sonarqube`** (ferramentas `analyze_code_snippet` ou `search_sonar_issues_in_projects`), seguindo rigorosamente o checklist de cada um.

### PASSO 3 — Coleta e Reconciliação
1. **Consolide** todos os achados em uma lista única.
2. **Remova duplicatas** — se dois agentes detectaram a mesma violação, conte apenas uma vez.
3. **Double-Check do Orquestrador**: Verificação final de sufixos, imports de framework e PII em logs como "rede de segurança".
4. **Reconciliação R10**: Total no resumo DEVE ser EXATAMENTE igual ao total de detalhamentos. Se divergir, corrija ANTES de responder.

### PASSO 4 — Relatório e Veredito

Emita o relatório no formato padronizado do `@backend-auditor`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛸 ANTIGRAVITY QUALITY GATE — RELATÓRIO FINAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Arquivos auditados: [N]
🔴 Violações ALTA: [N]
🟡 Violações MÉDIA: [N]
🔵 Violações BAIXA: [N]

🏆 VEREDITO: [APROVADO ✅ | REPROVADO ❌]
```

- **APROVADO**: Código 100% conforme (zero violações ALTA e MÉDIA).
- **REPROVADO**: Se houver >= 1 violação ALTA ou MÉDIA.
- **Checklist de Testes (OBRIGATÓRIO)**: Agente 5 (`@reviewer-tester`) deve verificar rigorosamente a existência de testes para:
  - Cada novo Service, Controller endpoint, Adapter e Mapper.
  - Cada método de negócio novo em Domain Entities.
  - Teste E2E relacional para entidades com dependências.
  - O não cumprimento = Violação ALTA automática.

### PASSO 5 — Pós-Review
Pergunte: *"Foram encontradas [N] violações. Correção automática ou manual?"*

Se automático:
1. Corrija na ordem **Alta → Média → Baixa**.
2. Mostre SOMENTE o trecho corrigido (NÃO reescreva o arquivo inteiro).
3. **Validação de Prova Real**: Após a correção, você **DEVE** executar **`analyze_code_snippet`** no código corrigido.
   - Se o Sonar ainda detectar erro: **O fluxo retrocede**. Você deve explicar a falha da primeira tentativa e tentar uma nova abordagem.
   - Se o Sonar der "Clean": Siga para a próxima correção.
4. Re-execute o review completo após todas as correções para fechar o ciclo.
