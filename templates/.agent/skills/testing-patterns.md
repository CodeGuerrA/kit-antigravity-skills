---
name: "testing-patterns"
description: "Estratégia obrigatória de testes: Unitários, Integração, Persistência e Naming Conventions."
---

# 🧪 SKILL: Estratégia de Testes (Testing Patterns)

**REGRA OURO**: Nenhuma funcionalidade é considerada "pronta" (Done) sem testes correspondentes. A ausência de testes é uma **VIOLAÇÃO MÉDIA** no Quality Gate.

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

---

## 📛 NAMING CONVENTION (BDD Style)

O nome do método deve descrever o cenário e o resultado esperado em **Inglês**:

`should_[EXPECTED_RESULT]_when_[CONTEXT]`

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

| Tipo | Obrigatório |
|:-----|:------------|
| Service | 100% dos caminhos (Happy Path + cada Exception Path) |
| Facade | Delegação correta para cada Service |
| Controller | Principais status codes (200/201, 400, 404, 500) |
| Adapter | Save, find, soft delete, paginação |
| Domain Entity | Todos os métodos de negócio |
| Mapper | Conversão de campos críticos e enums |

---

_Testes devem ser rápidos, independentes e determinísticos. Use Fixtures para evitar duplicação._
