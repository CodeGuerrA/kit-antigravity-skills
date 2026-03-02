---
name: "socratic-protocol"
description: "Protocolo Socrático de Tomada de Decisão — Obrigatório antes de qualquer implementação."
---

# 🧠 SOCRATIC PROTOCOL: Guia de Tomada de Decisão

O **Antigravity Kit** opera sob o **Protocolo Socrático**. Isso significa que você, como IA, nunca deve iniciar uma implementação baseada em suposições.

## 🧐 O QUE É O PROTOCOLO?
Antes de escrever qualquer linha de código ou realizar uma refatoração, você DEVE:

### Passo 1 — Perguntas Estratégicas (1 a 3)
Faça de 1 a 3 perguntas ao usuário para:
1. **Validar o Escopo**: "Isso deve afetar apenas a camada de API ou também o Domínio?"
2. **Entender Restrições**: "Há alguma restrição de performance ou segurança que devo considerar?"
3. **Confirmar Design**: "Devemos seguir o padrão Strategy aqui ou um simples Factory resolve?"

**Exemplos de perguntas por tipo de tarefa:**

| Tipo de Tarefa | Perguntas Estratégicas |
|:---------------|:-----------------------|
| Novo endpoint | "Qual módulo? Precisa de autenticação? Quais status HTTP esperados?" |
| Refatoração | "Qual o escopo exato? Apenas renomear ou reestruturar camadas?" |
| Nova exception | "Qual a hierarquia? Qual HTTP status? Precisa de ErrorCode no enum?" |
| Integração externa | "Qual API? Há retry policy? Como tratar timeout?" |

### Passo 2 — Planejamento com `sequential-thinking` (OBRIGATÓRIO)
Após as respostas do usuário, **utilize obrigatoriamente o `sequential-thinking`** para:
1. Mapear **artefatos** (classes, interfaces, DTOs) a serem criados ou modificados.
2. Definir **localização** na arquitetura hexagonal para cada artefato.
3. Identificar **impacto** em arquivos existentes.
4. Planejar **dependências** e injeções necessárias.
5. Antecipar **riscos** e como mitigá-los.

> ⚠️ **NÃO prossiga para código até o `sequential-thinking` concluir com um plano de ação claro.**

## 🛡️ REGRAS DE OURO
- **Nunca suponha o que o usuário quer.**
- **Se a instrução for vaga, peça detalhes ANTES de agir.**
- **Se a tarefa for complexa (>= 3 arquivos), o `sequential-thinking` é OBRIGATÓRIO.**
- **Se a tarefa for simples (1-2 arquivos triviais), as perguntas podem ser dispensadas, mas o `sequential-thinking` continua recomendado.**

---

_Instrução Mestre: Se o usuário der uma ordem direta, valide se você tem 100% dos requisitos. Se não tiver, aplique o Protocolo._
