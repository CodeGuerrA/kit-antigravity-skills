---
description: "Orquestrador multi-agente de revisão de código — Quality Gate binário (APROVADO/REPROVADO)."
---

# 🔍 WORKFLOW: Quality Gate — Code Review (/code-review)

**Descrição**: Orquestração multi-agente de revisão de código. Coordena 5 sub-agentes especializados (A-E) + 1 validador cross-file (X) para auditoria binária.

---

## 🚀 Processo Obrigatório de Orquestração

### PASSO 0 — Planejamento Estratégico (Obrigatório)
- **Utilize obrigatoriamente o `sequential-thinking`** para planejar quais sub-agentes serão necessários para cada arquivo baseado na **Dispatch Table** (ver Skill `code-standards.md`).
- **Carregue a Skill `code-standards.md`** como base universal de auditoria.

### PASSO 1 — Leitura Inicial e Pré-Validação
Para CADA arquivo no escopo:
1. Use `Read` para ler o arquivo **INTEIRO**. Se não apareceu no output, a violação NÃO EXISTE.
2. Classifique o tipo (Controller, Service, Domain, etc.) usando a Dispatch Table.
3. **Pré-validação de Sufixo (Obrigatória)**: Verifique se o nome da classe corresponde ao sufixo da camada. Se violado → ALTA imediatamente.

### PASSO 2 — Análise por Sub-Agentes
Para cada arquivo, aplique TODOS os pilares correspondentes da Dispatch Table. Cada sub-agente produz um relatório:

| ID | Agente | Escopo |
|:---|:-------|:-------|
| **A** | `@reviewer-structure-guardian` | Nomenclatura, DI/Lombok, DTOs, OpenAPI |
| **B** | `@reviewer-hexagonal-architect` | Hexagonal, DDD, Entity Separation |
| **C** | `@reviewer-code-quality` | SOLID, Clean Code (mecânico), OOP, Performance |
| **D** | `@reviewer-security-observability` | Segurança/PII, Exceptions, Logging, **Testes** |
| **E** | `@clean-coder` | Legibilidade semântica, clareza de intenção |
| **X** | `@reviewer-crossfile-validator` | V1-V6: Validações entre arquivos |

**Como funciona na prática**: A IA DEVE analisar o arquivo sob a perspectiva de CADA agente aplicável, seguindo rigorosamente o checklist e protocolo cognitivo de cada um.

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
- **Checklist de Testes (OBRIGATÓRIO)**: Auditor deve verificar existência de arquivos de teste para:
  - Cada novo Service.
  - Cada novo Controller endpoint.
  - Cada novo PersistenceAdapter.
  - Cada método de negócio novo em Domain Entities.
  - Falta de testes = Violação MÉDIA automática.

### PASSO 5 — Pós-Review
Pergunte: *"Foram encontradas [N] violações. Correção automática ou manual?"*

Se automático:
1. Corrija na ordem **Alta → Média → Baixa**.
2. Mostre SOMENTE o trecho corrigido (NÃO reescreva o arquivo inteiro).
3. Re-execute o review após correções para validar.
