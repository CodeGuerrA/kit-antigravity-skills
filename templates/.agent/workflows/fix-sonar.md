---
description: "Workflow pós-commit/push para corrigir falhas de Quality Gate e zerar issues do SonarQube."
---

# 🔧 WORKFLOW: Correção Automática de Quality Gate (/fix-sonar)

**Descrição**: Este workflow deve ser invocado sempre que um commit/push resultar em falha no SonarQube ou quando se deseja zerar a dívida técnica ativa do servidor. Ele aciona o especialista em remediação para garantir que o projeto volte ao estado "Aprovado".

---

## 🚀 Processo de Remediação

### FASE 1 — Carregamento de Evidências (Agente @sonarqube-fixer)
O agente deve iniciar conectando com o servidor MCP:
1.  **`search_my_sonarqube_projects`**: Localizar o `projectKey` alvo.
2.  **`get_project_quality_gate_status`**: Verificar matematicamente onde o portão falhou (Ex: Falhou por Coverage < 80% ou Bugs > 0).
3.  **`search_sonar_issues_in_projects`**: Obter a lista completa de débitos ativos.

### FASE 2 — Triagem e Priorização
O agente deve priorizar o trabalho na seguinte ordem:
1.  **Vulnerabilidades (Security)**: Risco de invasão ou vazamento.
2.  **Bugs Críticos**: Risco de crash no ambiente de produção.
3.  **Security Hotspots**: Áreas sensíveis que precisam de veredito humano.
4.  **Code Smells**: Dívida técnica de manutenção.

### FASE 3 — Execução da Cirurgia (Prova Real)
Para cada arquivo com problemas:
1.  O agente lê o arquivo e aplica a correção proporcional à falha.
2.  **Prova Real Obrigatória**: Deve-se rodar `analyze_code_snippet` no arquivo modificado.
3.  **Regra de Backtracking**: Se o Sonar ainda detectar o problema, a correção é abortada e uma nova solução deve ser planejada.

### FASE 4 — Sincronização e Done
1.  O agente atualiza o status no servidor real via MCP (`change_sonar_issue_status`).
2.  Gera-se um relatório final das issues sanadas.
3.  O workflow termina solicitando um novo push para o usuário para validar no CI/CD final.

---

### Exemplo de Comando:
> "/fix-sonar: O pipeline de produção falhou por causa de dois novos bugs de nulidade. Conserte-os."

---
_Qualidade não é opcional. É o nosso padrão._
