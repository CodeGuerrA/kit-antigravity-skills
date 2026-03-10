---
description: "Implementa uma nova funcionalidade ou módulo completo seguindo SOLID, Hexagonal e Clean Code."
---

# 🛠️ WORKFLOW: Implementar Funcionalidade ou Módulo (/implement)

**Descrição**: Implementa uma nova funcionalidade, classe, endpoint ou um **Módulo Completo** (Bounded Context) seguindo rigorosamente os padrões de SOLID, Arquitetura Hexagonal e Clean Code.

---

## 🚀 Processo Obrigatório — Siga SEMPRE nesta ordem

### FASE 0 — Protocolo Socrático (Obrigatório)
- Aplique o **Protocolo Socrático** (ver Skill `socratic-protocol.md`): faça 1-3 perguntas estratégicas.
- **Utilize obrigatoriamente o `sequential-thinking`** para planejar a estratégia de implementação.
- **Carregue a Skill `code-standards.md`** para identificar quais dos 14 pilares serão afetados.

### FASE 1 — Raciocínio de Arquitetura
O planejamento via `sequential-thinking` deve cobrir obrigatoriamente:
1. **Escopo**: É uma funcionalidade em módulo existente ou um **Novo Módulo**?
   - Se for **Novo Módulo**, utilize a estratégia **Bottom-Up** (Domain → Infrastructure → Application → API) detalhada na Skill `module-template.md`.
2. **Mapeamento de Artefatos**: O que precisa ser criado (camadas, classes, interfaces).
3. **Localização na Arquitetura**: Onde cada artefato vai viver na estrutura hexagonal.
4. **Impacto**: Quais arquivos existentes serão modificados.
5. **Dependências**: Injeções de dependência necessárias (usando SEMPRE constructor injection).
6. **Mitigação de Riscos**: Possíveis problemas e como evitá-los.

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

### FASE 2 — Mental Double-Check & Fixture Scaffolding (Zero Rework)
- Antes de redigir o teste com a mão na massa, cheque mentalmente seu plano de cenários felizes e tristes: _"Eu não posso errar meu teste, ele tem que funcionar de primeira. Como forçar essa ramificação falhar no Service via Mock e eu ter controle total?"_
- Crie ou use a **`Fixture`** para aquele contexto:
  `src/test/java/.../<modulo>/fixture/<Domain>Fixture.java`.
- Crie métodos estáticos claros (ex: `validProducer()`, `invalidEmailRequest()`, `inactiveProducerModel()`). Esse dado precisa ser utilizado com flexibilidade.
- Antes da Asserção final no arquivo, OBRIGATORIAMENTE **adicione um comentário inteligente (Javadoc)** documentando o que esse teste aprova no negócio: "Ex: Simulação de criar e integrar produtor sem falhas de contraint."

---

### FASE 3 — Estrutura de Pacotes e Scaffolding

Respeite a hierarquia do projeto. Se estiver criando um módulo novo, utilize a Skill `module-template.md` como checklist de arquivos obrigatórios.

```
modules/<modulo>/
  api/
    controller/     → @RestController, sem lógica.
    dto/
      request/      → record com @Schema e validações (Jakarta).
      response/     → record com @Schema.
    mapper/         → @Component, conversão Domain ↔ API.
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
- [ ] Adapter usa `@Component` e implementa um Port do domínio.
- [ ] Logs com `@Slf4j` presentes nos pontos de entrada e saída das operações.
- [ ] Exceções específicas do negócio são lançadas (nunca `RuntimeException` genérica).
- [ ] Código em Inglês, Javadoc/Comentários em Português.
- [ ] ErrorCodes de novos exceptions estão nos enums E no `messages.properties`.
- [ ] Novas exceptions mapeadas no `BusinessExceptionHttpStatusResolver`.
- [ ] Controller tem `@Tag`, `@Operation`, `@ApiResponse` e DTOs com `@Schema`.
- [ ] **Novo Módulo?** Registrar novas mensagens e configurar `SecurityConfig` para as novas rotas.

---

### FASE 4.5 — Check Twice (ZERO WORKAROUND & ZERO REWORK)
- Pare e respire. Exija de si mesmo: _"Meu código reflete a perfeição do Clean Code e arquitetura adotada?"_
- Verifique duas vezes (Double-Check) a estrutura: Há import inútil? Tem Javadoc que traduz as ações do negócio como `A História do Código`? 
- Se encontrar "TODO", remova ou resolva. Não construa coisas para "arrumar depois". Faça certo na primeira vez.

---

### FASE 5 — Hand-off para Testes

A implementação das funcionalidades de produto/técnica foi finalizada. Agora, deve-se invocar obrigatoriamente o processo de construção e execução de testes automatizados:
- **Execute o workflow `/test`** para delegar a escrita de testes unitários, integração e repositórios.
- Nenhum código deve ser considerado entregue (Quality Gate final aprovado) antes do agente `@reviewer-tester` (Agente T) avaliar o resultado da implementação via `/test`.

---

### FASE 6 — O Atualizador do README Dinâmico (MANDATÓRIO)
Após testar e finalizar a implementação (Fases 1 a 5 validadas):
- **VOCÊ DEVE ATUALIZAR O `README.md`** do projeto com a recém-criada modelagem/recurso atual. 
- Essa documentação exige **perfeição profissional**. Uma lista rala e básica não será aprovada.
- Adicione as descrições de negócio para novos end-points, o que resolve contextualmente e estruturalmente, para que qualquer leigo (ou DevOps novo) olhe e consiga assumir a manutenção do repositório em 1 dia.
- Explique se existem integrações de banco interligadas e fluxos E2E.
- Sem isso, a feature de "Implement" NÃO estará `Done`.
