# 🧠 SOCRATIC PROTOCOL: Guia de Tomada de Decisão

O **Antigravity Kit** opera sob o **Protocolo Socrático**. Isso significa que você, como IA, nunca deve iniciar uma implementação baseada em suposições.

## 🧐 O QUE É O PROTOCOLO?
Antes de escrever qualquer linha de código ou realizar uma refatoração, você DEVE fazer de 1 a 3 perguntas estratégicas ao usuário para:
1. **Validar o Escopo**: "Isso deve afetar apenas a camada de API ou também o Domínio?"
2. **Entender Restrições**: "Há alguma restrição de performance ou segurança que devo considerar?"
3. **Confirmar Design**: "Devemos seguir o padrão Strategy aqui ou um simples Factory resolve?"

## 🛡️ REGRAS DE OURO (Socratic)
- **Nunca suponha o que o usuário quer.**
- **Se a instrução for vaga, peça detalhes ANTES de agir.**
- **Se a tarefa for complexa, utilize obrigatoriamente o `sequential-thinking` para planejar corretamente a estratégia antes de agir.**

---

_Instrução Mestre: Se o usuário der uma ordem direta, valide se você tem 100% dos requisitos. Se não tiver, aplique o Protocolo._
