---
name: "module-template"
description: "Template padrão para criação de novos módulos CRUD com estrutura de produção e testes."
---

# 📦 SKILL: Template de Módulo (CRUD Completo)

Este documento define o esqueleto padrão para qualquer novo módulo. A criação deve seguir a ordem **Bottom-Up** (do Domínio para a API). Este template reflete fielmente os padrões do projeto de produção.

## 📂 ESTRUTURA DE ARQUIVOS (Módulo: `example`)

### 1. Camada DOMAIN (O Coração)
- `domain/entity/Example.java`: POJO puro (Lombok: `@Getter`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`). Métodos de negócio como `update()` e `deactivate()`. Zero imports de frameworks.
- `domain/enums/ExampleErrorCode.java`: Enum com códigos de erro e `messageKey` para `messages.properties`.
- `domain/port/ExampleSavePort.java`: Interface de saída — operação `save()`.
- `domain/port/ExampleFindPort.java`: Interface de saída — operação `findById()`.
- `domain/port/ExampleListPort.java`: Interface de saída — operação `findAll()` com paginação.
- `domain/port/ExampleUpdatePort.java`: Interface de saída — operação `update()`.

> ⚠️ **ISP obrigatório**: Cada Port DEVE ter uma única responsabilidade. Nunca crie um `ExampleRepositoryPort` genérico com save + find + list + update.

### 2. Camada APPLICATION (A Orquestração)
- `application/service/CreateExampleService.java`: `@Service`, método `execute()`, usa `ExampleSavePort`.
- `application/service/FindExampleService.java`: `@Service`, método `execute()`, usa `ExampleFindPort`.
- `application/service/ListExampleService.java`: `@Service`, método `execute()`, usa `ExampleListPort`.
- `application/service/UpdateExampleService.java`: `@Service`, método `execute()`, usa `ExampleFindPort` + `ExampleUpdatePort`.
- `application/service/DeleteExampleService.java`: `@Service`, método `execute()`, usa `ExampleFindPort` + `ExampleSavePort`.
- `application/facade/ExampleModuleFacade.java`: **Interface** definindo o contrato da camada Application.
- `application/facade/ExampleModuleFacadeImpl.java`: `@Component`, implementa `ExampleModuleFacade`, orquestra os 5 Services.
- `application/exception/ExampleException.java`: Exceção base abstrata do módulo, estende `BusinessException`, campo contextual (ex: `exampleId`).
- `application/exception/ExampleNotFoundException.java`: Exceção concreta (HTTP 404).
- `application/exception/ExamplePersistenceException.java`: Exceção concreta para erros de infra (HTTP 500).

> ⚠️ **SRP obrigatório**: 1 Service = 1 operação = 1 método público `execute()`. Nunca crie um Service com `create()`, `find()`, `update()` etc. juntos.

### 3. Camada INFRASTRUCTURE (A Ponte)
- `infrastructure/repository/ExampleRepository.java`: Interface Spring Data `JpaRepository`.

#### 📌 Regras Obrigatórias para Repository

**Spring Data Derived Queries** — para queries simples e leitura por campo único:
```java
boolean existsByEmail(String email);
Optional<UserJpaEntity> findByEmail(String email);
```

**JPQL com `@Query` + `@Param`** — para queries complexas ou que precisam de clareza:
```java
@Modifying
@Query("UPDATE UserJpaEntity u SET u.email = :email WHERE u.id = :id")
void updateEmail(@Param("id") Long id, @Param("email") String email);

@Query("SELECT u.username FROM UserJpaEntity u WHERE u.username = :base OR u.username LIKE CONCAT(:base, '%')")
List<String> findUsernamesByBaseUsername(@Param("base") String base);
```

**SQL Nativo com `nativeQuery = true`** — APENAS quando JPQL for insuficiente:
```java
@Query(value = "SELECT * FROM users WHERE user_keycloak_id = :id", nativeQuery = true)
Optional<UserJpaEntity> findByIdIncludingInactive(@Param("id") String id);
```

**PROIBIDO:**
- Concatenação de strings em queries: `"WHERE name = '" + name + "'"` → VIOLAÇÃO ALTA
- `@Query` sem `@Param` nos parâmetros
- Queries com `?1`, `?2` (posicionais) — use sempre `@Param` nomeados

- `infrastructure/repository/entity/ExampleJpaEntity.java`: `@Entity` JPA com `@SQLRestriction("active = true")` para soft delete, `@PrePersist` e `@PreUpdate`.
- `infrastructure/repository/mapper/ExamplePersistenceMapper.java`: `@Mapper(componentModel = "spring")` MapStruct — converte Domain Entity ↔ JPA Entity.
- `infrastructure/repository/adapter/ExamplePersistenceAdapter.java`:
  `@Component`, implementa ports de **escrita** (`ExampleSavePort`, `ExampleUpdatePort`).
  Try-catch obrigatório. Anotação `@Transactional` somente neste Adapter.

- `infrastructure/repository/adapter/ExampleQueryAdapter.java`:
  `@Component`, implementa ports de **leitura** (`ExampleFindPort`, `ExampleListPort`).
  Métodos marcados com `@Transactional(readOnly = true)`.

> ⚠️ **ISP Real**: Adapters são agrupados por NATUREZA FUNCIONAL (escrita vs. leitura),
> NÃO um Adapter por Port individual. Se houver port de Existência, criar `ExampleExistenceAdapter`.
- `infrastructure/exception/ExampleInfraErrorCode.java`: ErrorCodes específicos de infra (se necessário).

### 4. Camada API (A Entrada)
- `api/controller/ExampleController.java`: `@RestController`, `@Tag`, `@Operation`, `@ApiResponse`. Injeta `ExampleModuleFacade` + `ExampleApiMapper`.
- `api/dto/request/CreateExampleRequest.java`: `record` com `@Schema` e Jakarta Bean Validation (`@NotBlank`, `@NotNull`, `@Size`, `@Email`).
- `api/dto/request/UpdateExampleRequest.java`: `record` com `@Schema` e validações.
- `api/dto/response/ExampleResponse.java`: `record` com `@Schema`.
- `api/mapper/ExampleApiMapper.java`: `@Mapper(componentModel = "spring")` MapStruct — converte Domain Entity → Response DTO.

## 📂 ÁRVORE COMPLETA

```
modules/example/
├── api/
│   ├── controller/
│   │   └── ExampleController.java
│   ├── dto/
│   │   ├── request/
│   │   │   ├── CreateExampleRequest.java
│   │   │   └── UpdateExampleRequest.java
│   │   └── response/
│   │       └── ExampleResponse.java
│   └── mapper/
│       └── ExampleApiMapper.java
├── application/
│   ├── exception/
│   │   ├── ExampleException.java
│   │   ├── ExampleNotFoundException.java
│   │   └── ExamplePersistenceException.java
│   ├── facade/
│   │   ├── ExampleModuleFacade.java          ← Interface
│   │   └── ExampleModuleFacadeImpl.java      ← @Component
│   └── service/
│       ├── CreateExampleService.java
│       ├── DeleteExampleService.java
│       ├── FindExampleService.java
│       ├── ListExampleService.java
│       └── UpdateExampleService.java
├── domain/
│   ├── entity/
│   │   └── Example.java
│   ├── enums/
│   │   └── ExampleErrorCode.java
│   └── port/
│       ├── ExampleFindPort.java
│       ├── ExampleListPort.java
│       ├── ExampleSavePort.java
│       └── ExampleUpdatePort.java
└── infrastructure/
    └── repository/
        ├── ExampleRepository.java
        ├── adapter/
        │   ├── ExamplePersistenceAdapter.java   ← Escrita (Save, Update)
        │   └── ExampleQueryAdapter.java          ← Leitura (Find, List)
        ├── entity/
        │   └── ExampleJpaEntity.java
        └── mapper/
            └── ExamplePersistenceMapper.java
```

## 🧪 ESTRUTURA DE TESTES (`src/test/java/...`)

A estrutura de testes deve **espelhar** exatamente a de produção:

```
src/test/java/com/company/project/modules/example/
├── api/
│   └── controller/
│       └── ExampleControllerTest.java         → @WebMvcTest (MockMvc)
├── application/
│   ├── facade/
│   │   └── ExampleModuleFacadeImplTest.java   → Unitário (mock Services)
│   └── service/
│       ├── CreateExampleServiceTest.java      → Unitário (mock Ports)
│       ├── DeleteExampleServiceTest.java
│       ├── FindExampleServiceTest.java
│       ├── ListExampleServiceTest.java
│       └── UpdateExampleServiceTest.java
├── domain/
│   └── entity/
│       └── ExampleTest.java                   → Unitário (métodos de negócio)
└── infrastructure/
    └── repository/
        ├── adapter/
        │   ├── ExamplePersistenceAdapterTest.java → @DataJpaTest (escrita/soft delete)
        │   └── ExampleQueryAdapterTest.java        → @DataJpaTest (leitura/paginação)
        └── mapper/
            └── ExamplePersistenceMapperTest.java  → Unitário (conversão)
```

> ⚠️ Cada Service é testado individualmente. O Facade também tem seu próprio teste. Mappers são validados para garantir conversão correta de campos.

## 🛠️ ORDEM DE IMPLEMENTAÇÃO (Bottom-Up)

1. **Domain**: Entidade POJO, Enums (ErrorCodes), Interfaces (Ports ISP).
2. **Infrastructure**: JPA Entity, Repository, PersistenceMapper, PersistenceAdapter.
3. **Application**: Exceptions, Services (um por operação), Facade (Interface + Impl).
4. **API**: Request/Response DTOs, ApiMapper, Controller.
5. **Testes**: Implemente junto a cada camada conforme a Skill `testing-patterns.md`.

---

_Utilize o comando `/implement` para seguir este template passo-a-passo._
