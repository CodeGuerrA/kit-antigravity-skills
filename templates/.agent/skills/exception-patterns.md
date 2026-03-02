---
name: "exception-patterns"
description: "Padrões de tratamento de exceções, hierarquia e mensagens multinível."
---

# ⚠️ SKILL: Padrões de Exceção (Exception Patterns)

O projeto utiliza uma hierarquia de exceções baseada em `BusinessException` para garantir que todos os erros sejam capturados pelo `GlobalExceptionHandler` e retornados de forma padronizada.

## 🌳 HIERARQUIA DE EXCEÇÕES

```
RuntimeException
 └── BusinessException (abstract, shared/)
      ├── errorCode: String
      ├── httpStatus: HttpStatus
      ├── metadata: Map<String, Object>
      └── addMetadata(key, value)
           │
           ├── ProducerException (abstract, application/exception/)
           │    ├── producerId: Long                    ← campo contextual
           │    ├── ProducerNotFoundException (concreta, HTTP 404)
           │    └── ProducerPersistenceException (concreta, HTTP 500)
           │
           └── UserException (abstract, application/exception/)
                ├── userId: Long                        ← campo contextual
                └── UserNotFoundException (concreta, HTTP 404)
```

## 📍 LOCALIZAÇÃO DOS ARQUIVOS

| Artefato | Pacote |
|:---------|:-------|
| `BusinessException` | `shared/exception/` |
| `ModuleException` (abstract) | `modules/<modulo>/application/exception/` |
| Exceções concretas de negócio | `modules/<modulo>/application/exception/` |
| ErrorCode Enums | `modules/<modulo>/domain/enums/` |
| ErrorCodes de infraestrutura | `modules/<modulo>/infrastructure/exception/` |

## 🏗️ TEMPLATE: BusinessException (Base)

```java
@Getter
public abstract class BusinessException extends RuntimeException {

    private final String errorCode;
    private final HttpStatus httpStatus;
    private final Map<String, Object> metadata = new HashMap<>();

    protected BusinessException(String errorCode, String message, HttpStatus httpStatus) {
        super(message);
        this.errorCode = errorCode;
        this.httpStatus = httpStatus;
    }

    protected BusinessException(String errorCode, String message, Throwable cause, HttpStatus httpStatus) {
        super(message, cause);
        this.errorCode = errorCode;
        this.httpStatus = httpStatus;
    }

    public void addMetadata(String key, Object value) {
        if (value != null) {
            metadata.put(key, value);
        }
    }
}
```

## 🏗️ TEMPLATE: ModuleException (Abstrata por Módulo)

Cada módulo tem uma exceção abstrata intermediária com campo contextual (ID do recurso):

```java
@Getter
public abstract class ProducerException extends BusinessException {

    private final Long producerId;  // ← campo contextual do módulo

    protected ProducerException(String errorCode, String message,
                                 HttpStatus httpStatus, Long producerId) {
        super(errorCode, message, httpStatus);
        this.producerId = producerId;
        if (producerId != null) {
            addMetadata("producerId", producerId);  // ← addMetadata, NÃO Map.of()
        }
    }

    protected ProducerException(String errorCode, String message,
                                 HttpStatus httpStatus, Long producerId, Throwable cause) {
        super(errorCode, message, cause, httpStatus);
        this.producerId = producerId;
        if (producerId != null) {
            addMetadata("producerId", producerId);
        }
    }
}
```

## 🏗️ TEMPLATE: Exceções Concretas

### NotFoundException (HTTP 404)
```java
public class ProducerNotFoundException extends ProducerException {
    public ProducerNotFoundException(Long producerId) {
        super(
            ProducerErrorCode.PRODUCER_NOT_FOUND.getMessageKey(),
            "Producer not found",
            HttpStatus.NOT_FOUND,
            producerId
        );
    }
}
```

### PersistenceException (HTTP 500, infra errors)
```java
public class ProducerPersistenceException extends ProducerException {
    public ProducerPersistenceException(String errorCode, String message,
                                         Long producerId, Throwable cause) {
        super(errorCode, message, HttpStatus.INTERNAL_SERVER_ERROR, producerId, cause);
    }
}
```

## 🔢 TEMPLATE: ErrorCode Enum

```java
@Getter
@RequiredArgsConstructor
public enum ProducerErrorCode {

    PRODUCER_CREATION_FAILED("producer.creation.failed"),
    PRODUCER_NOT_FOUND("producer.not.found"),
    PRODUCER_UPDATE_FAILED("producer.update.failed"),
    PRODUCER_DELETION_FAILED("producer.deletion.failed");

    private final String messageKey;  // ← mapeia para messages.properties
}
```

## 📝 MENSAGENS (messages.properties)

Cada `ErrorCode` deve possuir duas chaves no arquivo de mensagens:

```properties
producer.not.found=Produtor não encontrado
producer.not.found.detail=Verifique o ID informado e tente novamente

producer.creation.failed=Erro ao criar produtor
producer.creation.failed.detail=Verifique os dados informados e tente novamente
```

## 🛠️ CHECKLIST DE EXCEÇÃO

- [ ] A exceção estende `BusinessException` ou uma `ModuleException`?
- [ ] O `ErrorCode` está definido em um Enum semântico (em `domain/enums/`)?
- [ ] O campo contextual (ex: `producerId`) é adicionado via `addMetadata()`?
- [ ] O status HTTP é apropriado (400 negócio, 404 busca, 409 conflito, 500 infra)?
- [ ] As chaves (`messageKey` + `.detail`) foram adicionadas ao `messages.properties`?
- [ ] Exceções de infra (PersistenceException) preservam a `cause` original?

---
_Exceções mal formadas ou sem ErrorCode resultam em REPROVAÇÃO MÉDIA._
