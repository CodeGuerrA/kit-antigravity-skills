# 🔍 WORKFLOW: Auditoria Completa de Qualidade (Quality Gate)

Este fluxo define o processo sistemático para auditar um arquivo ou funcionalidade, garantindo conformidade com o **Quality Gate do Antigravity Kit**.

## 📋 PASSO-A-PASSO DA AUDITORIA

Ao receber um arquivo para revisão, siga esta sequência:

### 0. Planejamento Estratégico (Obrigatório)
- **Utilize obrigatoriamente o `sequential-thinking`** para mapear todos os arquivos relacionados e os pilares de auditoria aplicáveis antes de iniciar a leitura.

### 1. Chamada dos Especialistas
- Acione o **`@backend-auditor`** para verificar a integridade estrutural (Hexagonal, Injeção, Camadas).
- Acione o **`@clean-coder`** para verificar legibilidade, nomenclatura e princípios SOLID.

### 2. Análise Determinística (Sim/Não)
- Cada especialista deve emitir um veredito binário (**APROVADO/REPROVADO** ou **LIMPO/SUJO**).
- Se qualquer especialista reprovar, o resultado final da auditoria é **REPROVADO**.

### 3. Relatório de Inconformidades
Para cada erro encontrado, você deve fornecer:
1.  **Localização**: Nome do arquivo e número da linha.
2.  **Violação**: Qual regra do Quality Gate foi quebrada.
3.  **Severidade**: (Alta/Média/Baixa) conforme a matriz de severidade.
4.  **Correção Proposta**: Snippet de código sugerido para resolver o problema.

### 4. Pergunta Final ao Usuário
Após o relatório, pergunte:
> "Deseja que eu realize a correção automática das violações encontradas?"

---

## 🛡️ MATRIZ DE SEVERIDADE (Resumo)

- **ALTA**: Injeção via `@Autowired`, leak de camada hexagonal, framework no domínio.
- **MÉDIA**: Sufixos proibidos (`DTO`), métodos > 20 linhas, falta de `@Slf4j`.
- **BAIXA**: Magic strings, imports não usados, comentários desatualizados.
