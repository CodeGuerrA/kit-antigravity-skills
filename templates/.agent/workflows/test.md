---
description: "Cria e organiza a camada de testes seguindo a arquitetura hexagonal e cobertura obrigatória do projeto."
---

# 🛠️ WORKFLOW: Implementar Testes (/test)

**Descrição**: Utilizado para criar a estrutura completa de testes focado no **Quality Gate** do projeto, garantindo isolamento total por meio das diretrizes do `testing-patterns.md`.

---

## 🚀 Processo Obrigatório — Etapas da Testagem

### FASE 0 — Diagnóstico Técnico (SonarQube MCP)
**Antes de escrever uma linha de teste**, você deve saber onde o sistema está vulnerável:
1.  **`search_files_by_coverage`**: Liste os arquivos com pior cobertura. Se o arquivo que você está mexendo estiver na lista, a meta é retirá-lo de lá.
2.  **`get_file_coverage_details`**: Identifique as linhas exatas do código que não estão sendo testadas. Seus cenários de teste DEVEM forçar a execução dessas linhas.
3.  **`search_duplicated_files`**: Verifique se a lógica que você vai testar está duplicada. Se estiver, recomende a extração para um método comum (DRY) primeiro, para evitar criar testes redundantes.
4.  **`get_duplications`**: Analise o bloco exato de duplicidade para entender se o comportamento é proposital ou erro de arquitetura.

---

### FASE 1 — Socrático dos Testes e Planejamento
- Ao iniciar o comando `/test`, primeiro identifique as classes modificadas e escopos de cobertura através do `sequential-thinking`.
- Analise os fluxos e branches de controle (if/else/throws/return value) para definir os cenários BDD a serem criados. Ex: "`should_[Expected]_when_[Condition]`".

### FASE 2 — Mental Double-Check & Fixture Scaffolding (Zero Rework)
- Antes de redigir o teste com a mão na massa, cheque mentalmente seu plano de cenários felizes e tristes: _"Eu não posso errar meu teste, ele tem que funcionar de primeira. Como forçar essa ramificação falhar no Service via Mock?"_
- Crie ou use a **`Fixture`** para aquele contexto:
  `src/test/java/.../<modulo>/fixture/<Domain>Fixture.java`.
- Crie métodos estáticos claros (ex: `validProducer()`). Esse dado precisa ser utilizado com flexibilidade.
- Antes do Assert no arquivo, OBRIGATORIAMENTE adicione um comentário inteligente de negócio explicando a intenção.

### FASE 3 — Escrita de Testes por Camada (Agente T: Revisor)
Baseado nos requisitos do Pilar 15, crie as classes seguindo a matriz:
1. **Controller Tests (`@WebMvcTest`)**: Valide Status Codes. Mocks na Facade e no Mapper. Requisições JSON puras.
2. **Facade Tests**: Assegure o fluxo e delegações através de instâncias injetadas `Mock` dos serviços. Valide invocações (Mockito `verify()`).
3. **Application Services Tests (`@ExtendWith(MockitoExtension.class)`)**: Mock do Port Externo e Validações detalhadas. Cobertura dos "happy e sad paths" obrigatória (AssertThrows, verify times=X). Todos os retornos condicionais nulos ou exceções devem ser previstos.
4. **Adapter Tests (`@DataJpaTest`)**: Salve na base via in-memory Database e verifique restrições `@SQLRestriction` e integridade JPA.
5. **Entity Tests**: Validação da regra pura contida no objeto POJO (Domínio limpo).
6. **Mapeamento (MapStruct)**: Garantia de que a biblioteca MapStruct resolve atributos sem NullPointers.

### FASE 4 — Testes Relacionais e de Ouro (E2E)
- Para garantir estabilidade e ausência de problemas por integridade relacional, **construa arquivos E2E** com `@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)`.
- Chame a criação da entidade pai, seguida da entidade filha. 
- Realize o GET ou query na base após ação atestando o funcionamento perfeito (Ex: `FarmController Integration Test` que cria o Produtor e o salva real no banco H2 para acoplar no DTO). 

### FASE 5 — Build & Validação
- O fluxo `/test` conclui após a certeza de cobertura verde, seja por CI/CD e revisão técnica (Agente `@reviewer-tester`).

> ⚠️ Nota: Um arquivo SEM um acompanhante testável (com exceção de Records de POJO simples que não contêm lógica de verificação, e enums constantes) NÃO está `Done`.
