---
description: "Barreira final de aprovação sistêmica — Audita bugs, vulnerabilidades, performance e integridade de módulos Java/Spring Boot."
---

# 🔬 WORKFLOW: Analista de Saúde Sistêmica (/analista)

**Descrição**: Última barreira antes do deploy. Diferente do `/code-review` (padrões e estilo), o `/analista` foca em **saúde funcional**: bugs, segurança, performance e integridade relacional.

**Filosofia**: _"Código bonito que quebra em produção é inútil. Código perfeito funciona, escala e resiste."_

---

## 🎯 ESCOPO

- **Módulos Específicos**: `/analista producer farm` → analisa somente os pacotes indicados.
- **Varredura Total**: Sem argumentos → analisa TODOS os módulos em `src/main/java`.

---

## 🚀 Fases da Análise

### FASE 0 — Planejamento (Obrigatório)
- Use `sequential-thinking` para: identificar módulos, listar classes críticas (Controllers, Services, Adapters, Entities), mapear relacionamentos entre entidades e fluxos E2E.
- Carregue: `code-standards.md`, `hexagonal-architecture.md`, `testing-patterns.md`.

---

### FASE 0.1 — Auditoria Estática Real-Time (MCP SonarQube)
**Obrigatório para 100% de precisão**: Execute as seguintes ferramentas ANTES de iniciar a revisão manual:

1.  **`search_my_sonarqube_projects`**: Identifique o `projectKey` correto.
2.  **`get_project_quality_gate_status`**: Verifique se o módulo já está com o portão fechado no servidor.
3.  **Para cada arquivo crítico**:
    *   Execute `analyze_code_snippet`: Peça análise de `Bugs` e `Vulnerabilities`.
    *   Execute `get_file_coverage_details`: Identifique buracos de teste matematicamente.
    *   Execute `get_component_measures`: Valide `cognitive_complexity` e métricas de dívida técnica.
4.  **Varredura Sistêmica**:
    *   **`search_sonar_issues_in_projects`**: Liste issues OPEN com severidade `HIGH` ou `BLOCKER`.
    *   **`search_files_by_coverage`**: Liste os 5 arquivos com menor cobertura para auditoria prioritária.
    *   **`search_duplicated_files`**: Identifique blocos de código duplicados que violam o DRY.
5.  **A Prova Real (Backtracking)**:
    *   Sempre que uma correção for aplicada durante este workflow, utilize **`analyze_code_snippet`** imediatamente.
    *   **Regra de Ouro**: Se o Sonar ainda detectar o erro, **reverta a alteração**, volte à fase de planejamento e reinicie a correção. O ciclo só fecha com o "Clean" do Sonar.

---

### FASE 1 — Bugs e Erros Críticos 🐛

Verificar ARQUIVO POR ARQUIVO:

| ID | Verificação | Sev. |
|:---|:-----------|:-----|
| BUG-01 | `Optional.get()` sem `isPresent()`/`orElseThrow()` | CRÍTICA |
| BUG-02 | `@Transactional` ausente em escrita (save/update/delete) | CRÍTICA |
| BUG-03 | **S2259**: NullPointer potencial: campo nullable acessado sem check | CRÍTICA |
| BUG-04 | Comparação de objetos com `==` ao invés de `.equals()` | ALTA |
| BUG-05 | `@NotNull`/`@NotBlank` no domínio sem `@Valid` no Controller | ALTA |
| BUG-06 | Exceção engolida (catch vazio ou log sem re-throw) | ALTA |
| BUG-07 | Return prematuro ignorando limpeza de estado/recurso | ALTA |
| BUG-08 | Lógica condicional invertida (`!` esquecido ou comparação trocada) | ALTA |
| BUG-09 | **S2123 / BUG-09**: Loop infinito potencial ou off-by-one | MÉDIA |
| BUG-10 | **S2250**: Estado mutável compartilhado ou Check-then-act não atômico | MÉDIA |
| BUG-11 | Cast inseguro sem `instanceof` | MÉDIA |
| BUG-12 | `@ToString` incluindo `@OneToMany` → StackOverflow em lazy collections | MÉDIA |
| BUG-13 | **S1656 / S2111**: Self-assignment ou BigDecimal constructor (double) | ALTA |
| BUG-14 | **S2095**: Resource Leak (Falta de try-with-resources) | ALTA |

---

### FASE 2 — Vulnerabilidades 🔒

| ID | Verificação | Sev. |
|:---|:-----------|:-----|
| SEC-01 | **S2077**: Concatenação de strings em `@Query` (SQL Injection) | CRÍTICA |
| SEC-02 | PII (email, CPF, password, token) em log info/warn/error | CRÍTICA |
| SEC-03 | **S6437**: Secret/senha hardcoded no código ou config | CRÍTICA |
| SEC-04 | Endpoint sem autenticação (`@PreAuthorize`/`@Secured`) | ALTA |
| SEC-05 | Response expondo campos internos sensíveis (password, auditFields) | ALTA |
| SEC-06 | Entity JPA retornada diretamente como Response (sem DTO) | ALTA |
| SEC-07 | **S5122**: CORS com `allowedOrigins("*")` | MÉDIA |
| SEC-08 | Dependência com CVE conhecida no `pom.xml` | MÉDIA |
| SEC-09 | **S5131 / S2083**: XSS ou Path Traversal via input do usuário | ALTA |
| SEC-10 | **S4502 / S5527**: CSRF Protection ou SSL validation desabilitado | ALTA |
| SEC-11 | **S5144 / S2245**: SSRF ou Weak Randomness | ALTA |

---

### FASE 3 — Performance e Escalabilidade ⚡

| ID | Verificação | Sev. |
|:---|:-----------|:-----|
| PERF-01 | N+1 Queries: loop chamando `findById()` por item | CRÍTICA |
| PERF-02 | `FetchType.EAGER` em `@OneToMany`/`@ManyToMany` | CRÍTICA |
| PERF-03 | Listagem sem `Pageable`/`Page<>` | ALTA |
| PERF-04 | Falta de `@Index` em campos usados em WHERE/ORDER BY | ALTA |
| PERF-05 | Algoritmo O(n²) onde O(n) é possível | ALTA |
| PERF-06 | Stream/Connection/Resource sem try-with-resources | ALTA |
| PERF-07 | `LazyInitializationException` potencial fora de `@Transactional` | ALTA |
| PERF-08 | **S1643**: Concatenação de String em loop (usar StringBuilder) | MÉDIA |
| PERF-09 | Falta de `@Cacheable` em dados lidos frequentemente | MÉDIA |
| PERF-10 | `SELECT *` quando poucos campos são necessários | MÉDIA |
| PERF-11 | `@Transactional` de leitura sem `readOnly = true` | MÉDIA |
| PERF-12 | **S1155**: Usar `.isEmpty()` em vez de `.size() == 0` | MÉDIA |
| PERF-13 | **S3824 / S2119**: Map.computeIfAbsent ou Random repetido | MÉDIA |

---

### FASE 4 — Integridade Sistêmica 🔗

| ID | Verificação | Sev. |
|:---|:-----------|:-----|
| INT-01 | Campo JPA sem coluna correspondente na migration | CRÍTICA |
| INT-02 | `CascadeType.ALL`/`REMOVE` sem justificativa documentada | ALTA |
| INT-03 | `@ManyToOne` sem `@JoinColumn` explícito | ALTA |
| INT-04 | Entidade com soft delete sem `@SQLRestriction` | ALTA |
| INT-05 | Entidade filha sem FK obrigatória para pai (orphan) | ALTA |
| INT-06 | `@Enumerated(ORDINAL)` → quebra ao reordenar enum | MÉDIA |
| INT-07 | Port/Interface sem implementação (Adapter) | ALTA |
| INT-08 | Import cross-module direto (violação Bounded Context) | ALTA |
| INT-09 | Módulo sem teste E2E relacional (Pai ↔ Filho) | ALTA |
| INT-10 | `@Disabled` em teste sem justificativa formal | ALTA |
| INT-11 | Beans duplicados sem `@Primary`/`@Qualifier` | MÉDIA |
| INT-12 | Valores de produção hardcoded em `application.properties` | MÉDIA |

---

### FASE 5 — Verificação de Testes 🧪

| ID | Verificação | Sev. |
|:---|:-----------|:-----|
| TST-01 | Testes unitários para TODOS os Services? | ALTA |
| TST-02 | Testes de Controller para TODOS os endpoints? | ALTA |
| TST-03 | Testes de Persistence Adapter? | ALTA |
| TST-04 | Teste E2E relacional (Pai ↔ Filho) presente? | ALTA |
| TST-05 | Cenários de ERRO cobertos (exceções, 400/404/500)? | ALTA |
| TST-06 | Javadoc/comentários profissionais de negócio nos testes? | MÉDIA |
| TST-07 | Fixture Factory usada (sem `new Entity()` literal)? | MÉDIA |
| TST-08 | Naming BDD: `should_[result]_when_[context]`? | MÉDIA |
| TST-09 | Testes determinísticos (sem dependência de ordem/tempo)? | ALTA |

---

### FASE 6 — Relatório Final

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔬 ANTIGRAVITY — RELATÓRIO DO ANALISTA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Módulos: [lista]   📊 Verificações: [N]

🐛 BUGS:            🔴[N] Crít  🟠[N] Alta  🟡[N] Méd
🔒 VULNERABILIDADES: 🔴[N] Crít  🟠[N] Alta  🟡[N] Méd
⚡ PERFORMANCE:      🔴[N] Crít  🟠[N] Alta  🟡[N] Méd
🔗 INTEGRIDADE:      🔴[N] Crít  🟠[N] Alta  🟡[N] Méd
🧪 TESTES:                       🟠[N] Alta  🟡[N] Méd

🏆 VEREDITO: [SAUDÁVEL ✅ | COMPROMETIDO ❌]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

- **SAUDÁVEL ✅**: Zero CRÍTICOS e zero ALTOS.
- **COMPROMETIDO ❌**: ≥ 1 item CRÍTICO ou ALTO. Sistema NÃO sobe para produção.

---

## 🛡️ REGRAS DO ANALISTA

1. Use `Read` para ler cada arquivo INTEIRO. Não assuma o que não leu.
2. Cite ARQUIVO, LINHA e TRECHO exato para cada achado.
3. Zero falsos positivos (só reporte com 100% de certeza) e zero falsos negativos (não esconda nada).
4. Performance é requisito, não luxo. Código lento = código quebrado.
5. Double-Check: releia seus achados antes de emitir o relatório.

> ⚠️ Se o `/analista` diz **COMPROMETIDO**, o código NÃO sobe. Ponto final.
