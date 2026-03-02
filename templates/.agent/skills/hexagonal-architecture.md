---
name: "hexagonal-architecture"
description: "Guia completo de Arquitetura Hexagonal (Ports & Adapters) com restrições de import e fluxo de dados."
---

# 🏗️ SKILL: Arquitetura Hexagonal (Ports & Adapters)

Este documento define as regras de **Arquitetura Hexagonal** obrigatórias no projeto. O objetivo é manter o domínio (lógica de negócio) 100% isolado de infraestrutura e frameworks.

## 📁 ESTRUTURA DE CAMADAS

### 1. DOMAIN (`.domain`) — O Coração
- Contém: `entity/`, `port/` (interfaces), `dto/` (record), `enums/`.
- **REGRA ABSOLUTA**: Não deve importar nada de fora (Jakarta, Spring, JPA, Keycloak).
- Ports: parâmetros e retornos DEVEM ser tipos do domínio.
- Tipos PROIBIDOS em Ports: `ResponseEntity`, `HttpStatus`, `UserRepresentation`, `AccessTokenResponse`, entidades JPA.
- Exceptions: Exceções de negócio (extensões de `BusinessException`) vivem na camada de **Application**, não no domínio.

### 1.1 Decisões Pragmáticas (Trade-offs)
Embora a pureza seja o objetivo, algumas concessões são feitas para manter a produtividade:
- **Pagination**: O uso de `org.springframework.data.domain.Page` é PERMITIDO em Ports de leitura para evitar a reimplementação complexa de wrappers de paginação.
- **Enums**: Enums de domínio podem ser usados em todas as camadas.
- **Records**: Records de domínio podem ser usados como retorno em Ports.

### 2. APPLICATION (`.application`) — A Orquestração
- Contém: `facade/`, `service/`, `validator/`, `exception/`.
- **REGRA**: Depende apenas do Domínio (Ports e DTOs). Nunca de implementações concretas de infra.
- Imports PROIBIDOS: `*Adapter`, `*Impl`, `jakarta.persistence.*`, `org.keycloak.*`.
- **Exceptions de Negócio**: Vivem aqui em `exception/`.
- NÃO contém regras de negócio complexas — apenas orquestra fluxo entre Ports e Entities.

### 3. INFRASTRUCTURE (`.infrastructure`) — A Ponte
- Contém: `adapter/`, `repository/`, `external/` (Keycloak, APIs), `exception/`.
- **REGRA**: Implementa os `Ports` do domínio. Converte tipos de framework para tipos de domínio.
- NÃO pode conter lógica de negócio (if/else complexos com regra de domínio).
- Try-catch OBRIGATÓRIO — captura exceções de framework e converte em exceções de domínio.

### 4. API (`.api`) — A Entrada
- Contém: `controller/`, `dto/request/`, `dto/response/`.
- **REGRA**: Recebe DTOs da API (com Bean Validation), converte para DTOs de Domínio e chama a Application.
- NÃO pode ter lógica de negócio, acesso direto a repositórios, try-catch, ou `@Transactional`.

### 5. SHARED (`shared/`) — Camada Transversal
- Contém: `config/` (SecurityConfig, CORS, Jackson), `exception/handler/` (GlobalExceptionHandler), `converter/`.
- Pode importar de frameworks (Spring, Jackson).
- NÃO contém lógica de negócio.
- `SecurityConfig`, `ExceptionHandler` e `Converter` vivem aqui.

## 🔄 FLUXO DE DADOS

```
[Request HTTP] → Controller (api/)
                    ↓ converte API DTO → Domain DTO
               Facade/Service (application/)
                    ↓ chama Port (interface do domínio)
               Adapter (infrastructure/)
                    ↓ implementa Port, usa framework (JPA, Keycloak, SMTP)
                    ↓ converte tipo de framework → Domain DTO
               ← retorna para Service/Facade
                    ↓
               Controller converte Domain DTO → Response DTO
[Response HTTP] ←
```

**Fluxo de dependência**: `API` → `Application` → `Domain` ← `Infrastructure`

## 🚫 TABELA DE IMPORTS PROIBIDOS

| Import | Permitido SOMENTE em |
|:-------|:---------------------|
| `org.keycloak.admin.client.*` | `.infrastructure/external/keycloak/` |
| `org.keycloak.representations.*` | `.infrastructure/external/keycloak/` |
| `jakarta.persistence.*` | `.infrastructure/repository/` |
| `jakarta.validation.*` | `.api/dto/` |
| `io.swagger.*` / `io.swagger.v3.*` | `.api/` |
| `org.springframework.data.*` | `.infrastructure/repository/` |
| `org.springframework.mail.*` | `.infrastructure/external/email/` |

## 🛡️ CHECKLIST DE CONFORMIDADE
- [ ] O domínio é 100% Java puro (zero imports de framework)?
- [ ] O Controller NÃO tem try-catch?
- [ ] Os DTOs de Request/Response são diferentes dos DTOs de Domínio?
- [ ] Existe um Mapper para converter Domain Entity ↔ JPA Entity?
- [ ] Os Ports NÃO têm tipos de framework nas assinaturas?
- [ ] A camada `shared/` não contém lógica de negócio?
- [ ] Os Adapters convertem exceções de framework para exceções de domínio?

---

_Se houver vazamento de camada (leak), o código deve ser REPROVADO._
