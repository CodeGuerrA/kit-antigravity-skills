---
name: "testing-patterns"
description: "Estratégia obrigatória de testes: Unitários, Integração, Persistência e Naming Conventions."
---

# 🧪 SKILL: Estratégia de Testes (Testing Patterns)

**REGRA OURO E IMPLACÁVEL**: Nenhuma funcionalidade é considerada "pronta" (Done) sem testes correspondentes cobrindo 100% do seu comportamento, caminhos felizes e infelizes (exceções e falhas de banco de dados). O sistema **NÃO PODE QUEBRAR**. A ausência de testes unitários ou relacionais/integração é uma **VIOLAÇÃO ALTA (Bloqueio Automático)** no Quality Gate. O nível de exigência aqui beira a **perfeição**.
**CULTURA DE ZERO RETRABALHO**: Testes não existem apenas para passar no Sonar. Eles não podem quebrar e devem ser implementados sem margem de erro na primeira entrega. **Comentários informativos em testes são OBRIGATÓRIOS**: um dev leigo que reprovar seu teste deve entender o que ele prova lendo o Javadoc.

---

## 📐 TIPOS DE TESTES POR CAMADA

### 1. Service Tests (Unitários)
- **Ferramentas**: JUnit 5 + Mockito + `@ExtendWith(MockitoExtension.class)`.
- **Foco**: Lógica de negócio, orquestração, exceções.
- **Regra**: Mockar todos os `Ports`. Cada Service tem seu próprio arquivo de teste.
- **Local**: `src/test/java/.../application/service/`.

```java
@ExtendWith(MockitoExtension.class)
class CreateProducerServiceTest {

    @Mock
    private ProducerSavePort savePort;

    @InjectMocks
    private CreateProducerService service;

    @Test
    void should_create_producer_when_valid_data() {
        // Arrange
        Producer expectedProducer = ProducerFixture.validProducer();
        when(savePort.save(any(Producer.class))).thenReturn(expectedProducer);

        // Act
        Producer result = service.execute(
            "João Silva", "joao@email.com", "34999990000",
            "34999990000", "12345678900", DocumentType.CPF
        );

        // Assert
        assertNotNull(result);
        assertEquals("João Silva", result.getName());
        verify(savePort, times(1)).save(any(Producer.class));
    }
}
```

### 2. Facade Tests (Unitários)
- **Ferramentas**: JUnit 5 + Mockito.
- **Foco**: Validar delegação correta para cada Service.
- **Regra**: Mockar todos os Services injetados.
- **Local**: `src/test/java/.../application/facade/`.

```java
@ExtendWith(MockitoExtension.class)
class ProducerModuleFacadeImplTest {

    @Mock
    private CreateProducerService createService;
    @Mock
    private FindProducerService findService;

    @InjectMocks
    private ProducerModuleFacadeImpl facade;

    @Test
    void should_delegate_to_create_service_when_creating() {
        // Arrange
        Producer expected = ProducerFixture.validProducer();
        when(createService.execute(anyString(), anyString(), anyString(),
                anyString(), anyString(), any())).thenReturn(expected);

        // Act
        Producer result = facade.createProducer(
            "João", "joao@email.com", "34999", "34999", "123", DocumentType.CPF
        );

        // Assert
        assertNotNull(result);
        verify(createService, times(1)).execute(
            anyString(), anyString(), anyString(), anyString(), anyString(), any()
        );
    }
}
```

### 3. Controller Tests (Integração/Web)
- **Ferramentas**: `@WebMvcTest` + MockMvc.
- **Foco**: Contratos de API, status codes, Bean Validation, serialização JSON.
- **Regra**: Mockar Facade e Mapper. Validar request/response JSON.
- **Local**: `src/test/java/.../api/controller/`.

```java
@WebMvcTest(ProducerController.class)
class ProducerControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ProducerModuleFacade facade;
    @MockBean
    private ProducerApiMapper mapper;

    @Test
    void should_return_201_when_creating_valid_producer() throws Exception {
        // Arrange
        Producer producer = ProducerFixture.validProducer();
        ProducerResponse response = ProducerFixture.validResponse();
        when(facade.createProducer(anyString(), anyString(), anyString(),
                anyString(), anyString(), any())).thenReturn(producer);
        when(mapper.toResponse(any())).thenReturn(response);

        String requestJson = """
            {
                "name": "João Silva",
                "email": "joao@email.com",
                "phone": "34999990000",
                "whatsapp": "34999990000",
                "document": "12345678900",
                "documentType": "CPF"
            }
            """;

        // Act & Assert
        mockMvc.perform(post("/api/v1/producers")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("João Silva"));
    }

    @Test
    void should_return_400_when_name_is_blank() throws Exception {
        // Arrange
        String requestJson = """
            {
                "name": "",
                "email": "joao@email.com",
                "document": "12345678900",
                "documentType": "CPF"
            }
            """;

        // Act & Assert
        mockMvc.perform(post("/api/v1/producers")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson))
                .andExpect(status().isBadRequest());
    }
}
```

### 4. PersistenceAdapter Tests (Persistência)
- **Ferramentas**: `@DataJpaTest` + `@Import(PersistenceAdapter.class)`.
- **Foco**: Queries customizadas, mapeamento JPA, restrições de banco, soft delete.
- **Local**: `src/test/java/.../infrastructure/repository/adapter/`.

```java
@DataJpaTest
@Import({ProducerPersistenceAdapter.class, ProducerPersistenceMapperImpl.class})
class ProducerPersistenceAdapterTest {

    @Autowired
    private ProducerPersistenceAdapter adapter;

    @Autowired
    private ProducerRepository repository;

    @Test
    void should_save_and_find_producer() {
        // Arrange
        Producer producer = ProducerFixture.validProducer();

        // Act
        Producer saved = adapter.save(producer);
        Optional<Producer> found = adapter.findById(saved.getId());

        // Assert
        assertTrue(found.isPresent());
        assertEquals(saved.getId(), found.get().getId());
    }

    @Test
    void should_not_find_inactive_producer() {
        // Arrange — salva e desativa (soft delete)
        Producer producer = ProducerFixture.validProducer();
        Producer saved = adapter.save(producer);
        saved.deactivate();
        adapter.save(saved);

        // Act
        Optional<Producer> found = adapter.findById(saved.getId());

        // Assert — @SQLRestriction filtra automaticamente
        assertFalse(found.isPresent());
    }
}
```

### 5. Domain Entity Tests (Unitários)
- **Ferramentas**: JUnit 5 (sem mocks).
- **Foco**: Métodos de negócio da entidade (`update()`, `deactivate()`).
- **Local**: `src/test/java/.../domain/entity/`.

```java
class ProducerTest {

    @Test
    void should_deactivate_producer() {
        // Arrange
        Producer producer = Producer.builder().name("João").active(true).build();

        // Act
        producer.deactivate();

        // Assert
        assertFalse(producer.isActive());
    }

    @Test
    void should_update_producer_fields() {
        // Arrange
        Producer producer = Producer.builder().name("João").email("old@email.com").build();

        // Act
        producer.update("Maria", "new@email.com", "34999", "34999", "111", DocumentType.CNPJ);

        // Assert
        assertEquals("Maria", producer.getName());
        assertEquals("new@email.com", producer.getEmail());
    }
}
```

### 6. Mapper Tests (Unitários)
- **Ferramentas**: JUnit 5 + `@SpringBootTest(classes = MapperImpl.class)` ou instanciação direta.
- **Foco**: Validar conversão de campos, campos nulos, enums.
- **Local**: `src/test/java/.../infrastructure/repository/mapper/` ou `api/mapper/`.

```java
class ProducerPersistenceMapperTest {

    private final ProducerPersistenceMapper mapper = new ProducerPersistenceMapperImpl();

    @Test
    void should_convert_domain_to_jpa_entity() {
        // Arrange
        Producer domain = ProducerFixture.validProducer();

        // Act
        ProducerJpaEntity jpa = mapper.toJpaEntity(domain);

        // Assert
        assertEquals(domain.getName(), jpa.getName());
        assertEquals(domain.getEmail(), jpa.getEmail());
        assertEquals(domain.getDocumentType(), jpa.getDocumentType());
    }
}
```

### 7. Testes de Integração e Relacionamentos E2E (Crucial)
- **Foco**: Fluxos completos envolvendo banco de dados real e múltiplas entidades.
- **Ferramentas**: `@SpringBootTest` + `Testcontainers` (PostgreSQL/MySQL isolado).
- **Regra**: Todo relacionamento (ex: `Producer 1:N Farm`) DEVE ter um teste relacional de ponta a ponta que garanta a integridade referencial.
- **Caso de Uso Obrigatório**: "Eu crio um produtor, e então crio uma fazenda vinculada a esse produtor. Devo testar se ambos existem e estão perfeitamente amarrados sem erro de constraint, e o que ocorre ao tentar atrelar a um produtor inexistente ou ao desativar o pai (cascading)."

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
// Configurar Testcontainers aqui
class ProducerFarmIntegrationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ProducerRepository producerRepo;
    @Autowired private FarmRepository farmRepo;

    @Test
    void should_create_farm_linked_to_existing_producer_end_to_end() throws Exception {
        // 1. Criar e persistir Produtor
        var producer = producerRepo.save(ProducerFixture.validProducer());

        // 2. Chamar o endpoint da Fazenda vinculada ao ID do produtor
        var request = FarmFixture.createLinkedRequest(producer.getId());
        
        mockMvc.perform(post("/api/v1/farms")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated());

        // 3. Validar consistência de banco no relacionamento (A Prova de Fogo)
        var farms = farmRepo.findByProducerId(producer.getId());
        assertFalse(farms.isEmpty());
        assertEquals(producer.getId(), farms.get(0).getProducer().getId());
    }
}
```

---

## 📛 NAMING CONVENTION E COMENTÁRIOS DE NEGÓCIO

O nome do método deve descrever o cenário e o resultado esperado em **Inglês**:

`should_[EXPECTED_RESULT]_when_[CONTEXT]`

**Obrigatoriedade de Documentação no Teste**:  
Acima de qualquer teste complexo de banco de dados ou Service core, **DEVE** haver um comentário ou Javadoc em *Português Brasileiro* detalhando o fluxo exato de negócio:
- Exemplo: `// Cria o produtor João e vincula a fazenda Alvorada. Garante que se a fazenda não tiver os dados de CAR, retorne Http 400 sem salvar ninguém em banco.`

**Exemplos**:
- `should_create_producer_when_valid_data()`
- `should_throw_not_found_exception_when_invalid_id()`
- `should_return_404_when_producer_not_found()`
- `should_not_find_inactive_producer()`
- `should_delegate_to_create_service_when_creating()`

---

## 🏭 FIXTURE FACTORY (Padrão de Dados de Teste)

Para evitar duplicação de dados de teste, crie uma classe `Fixture` por módulo:

```java
public final class ProducerFixture {

    private ProducerFixture() {} // utility class

    public static Producer validProducer() {
        return Producer.builder()
                .id(1L)
                .name("João Silva")
                .email("joao@email.com")
                .phone("34999990000")
                .whatsapp("34999990000")
                .document("12345678900")
                .documentType(DocumentType.CPF)
                .active(true)
                .build();
    }

    public static ProducerResponse validResponse() {
        return new ProducerResponse(
                1L, "João Silva", "joao@email.com",
                "34999990000", "34999990000", "12345678900",
                DocumentType.CPF, LocalDateTime.now(), null
        );
    }

    public static CreateProducerRequest validCreateRequest() {
        return new CreateProducerRequest(
                "João Silva", "joao@email.com",
                "34999990000", "34999990000",
                "12345678900", DocumentType.CPF
        );
    }
}
```

**Local**: `src/test/java/.../modules/<modulo>/fixture/` ou diretamente no pacote de testes.

---

## 📝 ESTRUTURA DO TESTE (AAA)

1. **Arrange**: Preparação do cenário, mocks, dados via Fixture.
2. **Act**: Execução do método a ser testado.
3. **Assert**: Verificação dos resultados e interações (`verify`).

---

## 📊 COBERTURA MÍNIMA

| Tipo | Obrigatório | Expectativa de Perfeição |
|:-----|:------------|:-------------------------|
| Service | **100%** absoluto de linhas e branches | Mock de cada falha lógica e Ports. Se um branch if/else não for coberto, o PR é Rejeitado. |
| Facade | Delegação 100% correta | Mocks devem verificar as passagens exatas de parâmetros. |
| Controller | 100% (200, 201, 400, 404, 500) | Validar respostas JSON, constraints nulas e vazias com rigidez. |
| Adapter DB | Save, find, delete, paginação | `DataJpaTest` validando `@SQLRestriction` em entidades desativadas. |
| Entidades | 100% Lógica de Negócio Interna | Nenhuma entidade com campo relacional é aprovada sem teste sobre seus métodos intrínsecos. |
| Integração (E2E) | Fluxos Completos e Relacionais | Sempre testar Pai ↔ Filho acoplados. O sistema deve provar que o DB não quebra. |
| Mapper | Conversão de todos os campos | Null checks garantidos em Mappers. |

---

_Testes devem ser rápidos, independentes e determinísticos. Use Fixtures para evitar duplicação._
