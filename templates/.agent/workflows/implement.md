---
description: "Implementa uma nova funcionalidade seguindo SOLID, Arquitetura Hexagonal e Clean Code."
---

# 🛠️ WORKFLOW: Implementar Funcionalidade (/implement)

**Descrição**: Implementa uma nova funcionalidade, classe, endpoint ou módulo seguindo rigorosamente os padrões de SOLID, Arquitetura Hexagonal e Clean Code.

---

## 🚀 Processo Obrigatório — Siga SEMPRE nesta ordem

### FASE 0 — Protocolo Socrático (Obrigatório)
- Aplique o **Protocolo Socrático** (ver Skill `socratic-protocol.md`): faça 1-3 perguntas estratégicas.
- **Utilize obrigatoriamente o `sequential-thinking`** para planejar a estratégia de implementação.
- **Carregue a Skill `code-standards.md`** para identificar quais dos 14 pilares serão afetados.

### FASE 1 — Raciocínio de Arquitetura
O planejamento via `sequential-thinking` deve cobrir obrigatoriamente:
1. **Mapeamento de Artefatos**: O que precisa ser criado (camadas, classes, interfaces).
2. **Localização na Arquitetura**: Onde cada artefato vai viver na estrutura hexagonal.
3. **Impacto**: Quais arquivos existentes serão modificados.
4. **Dependências**: Injeções de dependência necessárias (usando SEMPRE constructor injection).
5. **Mitigação de Riscos**: Possíveis problemas e como evitá-los.

> ⚠️ Só avance para o código após o `sequential-thinking` concluir com um plano de ação claro.

---

### FASE 2 — Implementação SOLID + Hexagonal
Consulte a Skill `code-standards.md` para detalhes dos pilares S, O, L, I, D.

#### S — Single Responsibility (SRP)
- Cada classe tem **uma única razão para mudar**.
- Controller não tem lógica de negócio; Service não conhece HTTP nem JPA; Adapter não tem regras de domínio.

#### O — Open/Closed (OCP)
- Estenda comportamento via **interfaces e ports**, nunca modificando classes estáveis existentes.

#### L — Liskov Substitution (LSP)
- Implementações de ports devem ser 100% intercambiáveis e respeitar o contrato da interface.

#### I — Interface Segregation (ISP)
- Ports pequenos e focados. Não force classes a implementar métodos que não usam.

#### D — Dependency Inversion (DIP)
- **Domínio NUNCA importa infraestrutura**.
- Fluxo: Controller → Service → Port (interface) ← Adapter (implementação).
- Injeção sempre por construtor com `@RequiredArgsConstructor`.

---

### FASE 3 — Estrutura de Pacotes Obrigatória

Respeite a hierarquia do projeto para cada módulo:

```
modules/<modulo>/
  api/
    controller/     → @RestController, sem lógica.
    dto/
      request/      → record com @Schema e validações (Jakarta).
      response/     → record com @Schema.
  application/
    facade/         → @Component, orquestra múltiplos services.
    service/        → @Service, orquestra fluxo, converte DTOs.
    validator/      → @Component, validações extraídas de services.
  domain/
    dto/            → records puros (Java puro), sem Swagger.
    port/           → interfaces (contratos de entrada/saída).
    entity/         → POJOs puros de domínio.
    exception/      → exceções de domínio.
    enums/          → enums de domínio e ErrorCodes.
  infrastructure/
    adapter/        → @Component, implementa ports de saída.
    repository/
      entity/       → JPA Entities (*JpaEntity).
    external/       → Integrações externas (Keycloak, Email, APIs).
    exception/      → Exceções específicas de infraestrutura.
shared/
  config/           → SecurityConfig, CORS, Jackson.
  exception/handler → GlobalExceptionHandler.
  converter/        → Conversores globais.
```

---

### FASE 4 — Checklist Final (Quality Gate)

Antes de declarar a implementação concluída, verifique:

- [ ] Nenhuma classe de domínio importa Spring, JPA ou frameworks externos.
- [ ] Toda injeção de dependência é via construtor (`@RequiredArgsConstructor`).
- [ ] DTOs de API (`api/dto`) são separados dos DTOs de domínio (`domain/dto`).
- [ ] Logs com `@Slf4j` presentes nos pontos de entrada e saída das operações.
- [ ] Exceções específicas do negócio são lançadas (nunca `RuntimeException` genérica).
- [ ] Código em Inglês, Javadoc/Comentários em Português.
- [ ] ErrorCodes de novos exceptions estão nos enums E no `messages.properties`.
- [ ] Novas exceptions mapeadas no `BusinessExceptionHttpStatusResolver`.
- [ ] Controller tem `@Tag`, `@Operation`, `@ApiResponse` e DTOs com `@Schema`.
