---
name: "code-standards"
description: "Os 14 Pilares de Excelência — Documento de referência completo para auditoria do Quality Gate."
---

# 💎 SKILL: Os 14 Pilares de Excelência (Quality Gate)

Este documento é o **guia supremo de referência técnica** para todo o desenvolvimento no backend. Os agentes de auditoria (A-E, X) consultam este documento como base universal. Cada pilar é uma regra ABSOLUTA — não há exceções salvo onde explicitamente documentadas.

---

## Pilar 1: Nomenclatura

**PODE:**
- Código 100% em INGLÊS. Comentários/Javadoc em PT-BR. Todo código/módulo **DEVE** possuir Javadocs detalhados que explicam de forma inteligente e clara as regras de negócio de modo que um leigo ou iniciante possa ler e entender a intenção sistêmica sem precisar ver cada linha. Comentários óbvios como `// Seta o valor X` são PROIBIDOS.
- DTOs: sufixos `Request` e `Response` ÚNICOS aceitos para transferência de dados.
- Classes: `PascalCase` / Métodos e variáveis: `camelCase` / Constantes `static final`: `UPPER_SNAKE_CASE`.
- Pacotes: `lowercase` sem separadores.
- Booleanos: prefixo `is`, `has`, `can`, `should`.
- Controllers: `*Controller` / Services: `*Service` / Adapters: `*Adapter` / Ports: `*Port` ou `*UseCase`.
- Métodos: verbo + substantivo (`createUser`, `findOrderById`).

**NÃO PODE:**
- Sufixos em DTOs: `DTO`, `VO`, `Data`, `Input`, `Output`, `Payload`, `Body`, `Form`.
- Variáveis genéricas SEM tipo explícito: `val`, `data`, `list`, `info`, `temp`, `obj`, `item`, `element`.
  - **Exceção**: `result`, `response` com tipo explícito (ex: `AuthTokenResult result = ...`) são ACEITAS.

---

## Pilar 2: Injeção de Dependência & Lombok

**Injeção:**
- ✅ `private final` + `@RequiredArgsConstructor`
- ❌ `@Autowired` em campo — sem exceção.

**Stereotype Annotations:**

| Anotação | Uso Correto |
|:---------|:------------|
| `@RestController` | Controllers |
| `@Service` | Classes com lógica de negócio/orquestração (Services) |
| `@Component` | Utilitários (Adapters, Facades, Factories, Mappers, Validators, Converters) |
| `@Repository` | Acesso a dados |
| `@Configuration` | Classes com `@Bean` methods |

**Exemplo Concreto:**
- `UserJpaAdapter` -> `@Component` (é um Adapter de infra).
- `UserFacade` -> `@Component` (é um orquestrador utilitário).
- `UserService` -> `@Service` (contém lógica de domínio).

**NÃO PODE:**
- `@Service` em Facade/Factory/Mapper/Validator (use `@Component`).
- `@Value("${...}")` em campo (use `@ConfigurationProperties` record).
- `@Transactional` em Controller.
- `@RequestBody` sem `@Valid`.
- `@SneakyThrows`.

**Lombok por tipo de classe:**

| Tipo | Permitido | Proibido |
|:-----|:----------|:---------|
| Service/Component/Adapter | `@RequiredArgsConstructor`, `@Slf4j` | Qualquer outro |
| JPA Entity | `@Getter`, `@Setter`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor` | `@Data` |
| Domain Entity (POJO) | `@Getter`, `@Setter`, `@Builder` | `@Data`, `@Slf4j` |
| Record (DTO/Config) | NENHUM (redundante) | Qualquer Lombok |

---

## Pilar 3: Arquitetura Hexagonal (Fronteiras)

**Domínio Limpo**: Zero imports de frameworks (Spring, JPA, Keycloak, etc.) em `.domain`.

| Import | Permitido SOMENTE em |
|:-------|:---------------------|
| `org.keycloak.*` | `.infrastructure/` |
| `jakarta.persistence.*` | `.infrastructure/repository/` |
| `jakarta.validation.*` | `.api/dto/` |
| `io.swagger.*` | `.api/` |

**Fluxo de dependência**: `API` → `Application` → `Domain` ← `Infrastructure`

---

## Pilar 4: Separação de DTOs por Camada

| Camada | Local | Requisitos |
|:-------|:------|:-----------|
| API DTOs | `api/dto/` | Bean Validation, `record`, uso exclusivo em `api/` |
| Domain DTOs | `domain/dto/` | `record`, Java puro, zero anotações de framework |
| Infrastructure DTOs | `infrastructure/.../dto/` | `record`, anotações do sistema externo |

**Fluxo**: Controller recebe API DTO → converte → Domain DTO → Port/Service. 
**Conversão DTO ↔ Domain**: Sempre utilize obrigatoriamente **MapStruct** (`@Mapper(componentModel = "spring")`). Mapeadores manuais são PROIBIDOS.

---

## Pilar 5: SOLID

- **SRP**: **1 Service = 1 operação = 1 método público `execute()`**. Padrão obrigatório: `CreateExampleService`, `FindExampleService`, `UpdateExampleService`, `DeleteExampleService`, `ListExampleService`. Extração obrigatória de validações para `Validator`.
- **OCP**: Cadeias if/else por tipo extensível → Strategy. Conjunto fixo pequeno → ACEITAR.
- **Comentários de Negócio:** Tudo que tiver uma regra não-trivial DEVE ser acompanhado de um comentário inteligente que conte "A História e o Motivo" da regra, para conhecimento de domínio.
- **LSP**: Subclasses não podem restringir contrato do pai nem lançar `UnsupportedOperationException`.
- **ISP**: Interfaces com métodos não usados por todos implementadores → dividir. **Ports obrigatoriamente separados**: `SavePort`, `FindPort`, `ListPort`, `UpdatePort` — nunca um `RepositoryPort` genérico.
- **DIP**: Domínio depende apenas de abstrações (Ports). `new` de classes de infra em Services → VIOLAÇÃO Alta.

---

## Pilar 6: Clean Code, DRY & KISS

- Máximo de **20 linhas** por método (exceção: builder chains até 30).
- Aninhamento máximo: 2 níveis (use early return).
- **PROIBIDO**: `return null`, `.get()` sem verificação, `.orElse(null)`, código comentado, imports não usados.
- **Imports**: Sempre prefira imports no topo do arquivo, NUNCA utilize fully qualified names diretamente no código.
- **DRY**: ≥ 3 linhas duplicadas em 2+ locais → extrair. Cross-file também vale.
- **KISS**: Se remover uma camada e funciona igual → over-engineering.

**Try-Catch por Camada:**

| Camada | Regra |
|:-------|:------|
| Infrastructure (Adapters) | OBRIGATÓRIO |
| Application (Orchestrators) | PERMITIDO com ação compensatória |
| Application (Services/Facades) | PROIBIDO |
| Domain / API (Controller) | PROIBIDO |

---

## Pilar 7: OpenAPI / Swagger

- Controller: `@Tag(name, description)`.
- Cada endpoint: `@Operation(summary, description)` + `@ApiResponse` por status code.
- Records de Request/Response: `@Schema(description)` nos campos.

---

## Pilar 8: Segurança e PII

- PII (email, username, documento) **SOMENTE** em `log.debug()`. **NUNCA** em `info/warn/error`.
- Tokens/senhas NUNCA em QUALQUER nível de log.
- PROIBIDO: Expor entidades JPA como Response.

### 🔐 SQL Safety (Anti SQL Injection)

**REGRAS DE OURO — sem exceção:**

| Técnica | Quando usar | Exemplo seguro |
|:--------|:------------|:---------------|
| Spring Data Derived Query | Queries simples por campo | `findByEmail(String email)` |
| JPQL `@Query` + `@Param` | Queries complexas | `@Query("... WHERE u.id = :id") ... (@Param("id") Long id)` |
| Native SQL `nativeQuery=true` + `@Param` | Quando JPQL é insuficiente | `@Query(value="SELECT * FROM t WHERE id=:id", nativeQuery=true)` |

**PROIBIDO (VIOLAÇÃO ALTA):**
- Concatenação de string em query: `"WHERE name = '" + name + "'"` → SQL Injection direto
- Parâmetros posicionais `?1`, `?2` → use sempre `@Param("nomeExplicito")`
- `@Query` sem `@Param` em qualquer parâmetro
- Usar `EntityManager.createNativeQuery()` com string interpolada

**Input Sanitization:**
- Campos usados em `LIKE`: sanitize removendo `%`, `_`, `\` antes de usar como bind param.
  Utilize `StringSanitizer` (já existe no `shared/util/`) antes de passar para o Repository.
- Nunca confie em input do usuário — sempre valide via Bean Validation (`@NotBlank`, `@Pattern`, etc.)
  na camada de API antes de chegar ao Domain/Infrastructure.

### 🛡️ Regras SonarQube de Segurança (Vulnerabilidades & Hotspots)
| Regra | Descrição | Pillar |
|:------|:----------|:-------|
| **S2077** | SQL Injection (Concatenação em queries) | Pilar 8.1 |
| **S6437** | Hardcoded Secrets (Senhas/Tokens no código) | Pilar 8 |
| **S5131** | XSS (Dados não sanitizados na UI) | Pilar 8 |
| **S5144** | SSRF (URLs de usuário sem validação) | Pilar 8 |
| **S2083** | Path Traversal (Acesso a arquivos via input) | Pilar 8 |
| **S5122** | CORS Misconfiguration (`allowedOrigins("*")`) | Pilar 8 |
| **S4502** | CSRF Protection (Proteção desabilitada) | Pilar 8 |
| **S5527** | Certificate Validation (SSL/TLS desabilitado) | Pilar 8 |
| **S2245** | Weak Randomness (Use `SecureRandom`, não `Random`) | Pilar 8 |
| **S4423** | Insecure Protocols (Versões obsoletas de TLS) | Pilar 8 |

---

## Pilar 9: DDD (Domain-Driven Design)

- Regras de negócio vivem no domínio (Entities ou Domain Services).
- Application Services apenas orquestram o fluxo — SEM regras de negócio.
- Domain Services: regras puras, SEM acesso a infra.
- PROIBIDO: Verbos CRUD genéricos em regras com significado semântico.

---

## Pilar 10: Entity Separation

- **Domain Entity** (`domain/entity/`): POJO puro, sem framework.
- **JPA Entity** (`infrastructure/repository/entity/`): sufixo `*JpaEntity`.
- **PROIBIDO**: Utilizar cascade (ex: `cascade = CascadeType.ALL`). Sempre utilizar anotações de mapeamento de relacionamento explicitamente.
- Anotações JPA em `domain/` → **VIOLAÇÃO Alta**.
- Mapper obrigatório entre Domain Entity ↔ JPA Entity: Deve-se utilizar **OBRIGATORIAMENTE o MapStruct**.

---

## Pilar 11: POO e Encapsulamento

- Campos `private`, coleções com cópia defensiva.
- Composição sobre herança, máx. 3 níveis.
- Cadeias if/else por tipo → Strategy.
- Tell Don't Ask: não exponha estado interno.

---

## Pilar 12: Performance

- **PROIBIDO**: `list.contains()` em loops O(n²) → `Set`.
- **PROIBIDO**: `Pattern.compile()` em método → `static final`.
- **PROIBIDO**: `findById().isPresent()` → `existsById()`.
- **PROIBIDO**: Listagem sem paginação.
- **PROIBIDO**: Concatenação String em loop → `StringBuilder`.

### ⚡ Regras SonarQube de Performance & Bugs Críticos
| Regra | Tipo | Descrição |
|:------|:-----|:----------|
| **S1155** | Perf | Usar `.isEmpty()` em vez de `.size() == 0` |
| **S3824** | Perf | Usar `Map.computeIfAbsent` (Java 8+) |
| **S1643** | Perf | Usar `StringBuilder` em loops (não `+`) |
| **S2119** | Perf | Não instanciar `Random` repetidamente |
| **S2259** | Bug | NullPointerException (Possível caminho nulo) |
| **S2095** | Bug | Resource Leak (Falta de try-with-resources) |
| **S2123** | Bug | Infinity Loops (Erros em loops) |
| **S1656** | Bug | Self-Assignment (`this.x = x` erro de digitação) |
| **S2111** | Bug | BigDecimal Double Constructor (Perda de precisão) |
| **S2250** | Bug | Non-Atomic Check-then-Act (Race conditions) |
| **S3776** | Smell | Cognitive Complexity (Código espaguete) |
| **S110** | Smell | Inheritance Depth (> 5 níveis) |
| **S1192** | Smell | String Literals (Literais repetidos → constantes) |
| **S1118** | Smell | Utility Classes (Falta construtor privado) |

---

## Pilar 13: Exceptions Padronizadas

- Toda exceção concreta estende `BusinessException` → `ModuleException` abstrata (com campo contextual) → Concretas.
- Exceções de negócio vivem em `application/exception/`. ErrorCodes vivem em `domain/enums/`.
- ErrorCodes em Enums (`ProducerErrorCode`, `UserErrorCode`), NUNCA hardcoded. Use `.getMessageKey()`.
- Cada ErrorCode DEVE ter entrada no `messages.properties` com `chave` + `chave.detail`.
- Metadata contextual via `addMetadata()` no corpo do construtor, NÃO via `Map.of()` no `super()`.
- **Template de Construtor (Padrão Obrigatório):**
```java
public FieldNotFoundException(String message, Long fieldId, Throwable cause) {
    super(FieldErrorCode.FIELD_NOT_FOUND.getMessageKey(), message, cause, HttpStatus.NOT_FOUND);
    this.fieldErrorCode = FieldErrorCode.FIELD_NOT_FOUND;
    this.fieldId = fieldId;
    addMetadata(METADATA_FIELD_ID, fieldId);
}
```
- **PersistenceException**: Exceções de infra devem preservar `cause` e usar construtor com `Throwable`.

---

## Pilar 14: Logging (Observabilidade)

- `@Slf4j` obrigatório em Controllers, Facades, Services, Adapters e ExceptionHandlers.
- `log.info` → operações de negócio. `log.debug` → consultas (ÚNICO para PII). `log.warn` → dados não encontrados. `log.error` → falhas com stacktrace completo.
- Formato: `log.error("contexto: id={}, erro={}", id, e.getMessage(), e)` — `e` como ÚLTIMO argumento.

---

## Pilar 15: Estratégia de Testes (Obrigatório)

- **Obrigatoriedade**: Toda nova funcionalidade deve vir acompanhada de testes unitários e/ou integração.
- **Naming**: `should_[resultado]_when_[contexto]`.
- **Cobertura**: Mínimo de 80% em Services.
- **Qualidade**: Ausência de testes = Violação MÉDIA.

---

## Padrão Facade (Orquestração)

A `Facade` é o **ponto de entrada obrigatório** entre Controller e Services. Todo módulo CRUD deve ter uma Facade.
- **Onde vive**: `application/facade/`.
- **Estrutura**: **Interface + Implementação** obrigatórios.
  - `ExampleModuleFacade` (interface): define o contrato de operações.
  - `ExampleModuleFacadeImpl` (`@Component`): implementa, injeta e delega para os Services.
- **Papel**: Orquestrar o fluxo delegando para Services especializados (Create, Find, Update, Delete, List).
- O Controller injeta apenas a interface `Facade`, nunca a implementação.

---

## Dispatch Table — Pilares por Tipo de Arquivo

| Tipo de Arquivo | Identificação | Pilares Aplicáveis |
|:----------------|:--------------|:-------------------|
| Controller | `api/controller/*Controller.java` | 1, 2, 3, 4, 6, 7, 8, 14 |
| Request DTO | `api/dto/request/*Request.java` | 1, 2 (record), 4, 7 |
| Response DTO | `api/dto/response/*Response.java` | 1, 2 (record), 4, 7 |
| Facade | `application/facade/*Facade*.java` | 1, 2, 3, 5 (SRP), 6, 14 |
| Application Service | `application/service/*.java` | 1, 2, 3, 5, 6, 9, 14 |
| Validator | `application/validator/*.java` | 1, 2, 3, 5, 6 |
| Domain Port | `domain/port/*Port.java` | 1, 3 (ZERO framework), 4, 5 |
| Domain Entity | `domain/entity/*.java` | 1, 3 (ZERO framework), 10, 11 |
| Domain DTO | `domain/dto/*.java` | 1, 2 (record), 3, 4 |
| Domain Exception | `domain/exception/*.java` | 1, 3, 13 |
| Adapter | `infrastructure/adapter/*.java` | 1, 2, 3, 5, 6 (try-catch), 8, 14 |
| JPA Entity | `infrastructure/repository/entity/` | 1, 2 (Lombok JPA), 10, 12 |
| Repository | `infrastructure/repository/*.java` | **1, 2, 3, 8 (SQL Safety), 12** |
| SecurityConfig | `shared/config/Security*.java` | CROSS-FILE: rotas vs controllers |
| ExceptionHandler | `shared/exception/handler/` | CROSS-FILE: exceptions mapping |

---

_Se qualquer pilar for violado, o código deve ser REPROVADO._
