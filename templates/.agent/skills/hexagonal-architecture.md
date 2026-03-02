# 🏗️ SKILL: Arquitetura Hexagonal (Ports & Adapters)

Este documento define as regras de **Arquitetura Hexagonal** obrigatórias no projeto. O objetivo é manter o domínio (lógica de negócio) 100% isolado de infraestrutura e frameworks.

## 📁 ESTRUTURA DE CAMADAS

1.  **DOMAIN (`.domain`)**: O coração.
    - Contém: `entity/`, `port/` (interfaces), `dto/` (record), `exception/`.
    - **REGRA ABSOLUTA**: Não deve importar nada de fora (Jakarta, Spring, JPA).
2.  **APPLICATION (`.application`)**: A orquestração.
    - Contém: `facade/`, `service/`, `validator/`.
    - **REGRA**: Depende apenas do Domínio. Nunca de implementações concretas de infra.
3.  **INFRASTRUCTURE (`.infrastructure`)**: A ponte com o mundo externo.
    - Contém: `adapter/`, `repository/`, `external/` (Keycloak, APIs).
    - **REGRA**: Implementa os `Ports` do domínio. Converte tipos de framework para tipos de domínio.
4.  **API (`.api`)**: A entrada.
    - Contém: `controller/`, `dto/request/`, `dto/response/`.
    - **REGRA**: Recebe DTOs da API, converte para DTOs de Domínio e chama a Application.

## 🛡️ CHECKLIST DE CONFORMIDADE
- [ ] O domínio é 100% Java puro?
- [ ] O Controller não tem try-catch?
- [ ] Os DTOs de Request/Response são diferentes dos DTOs de Domínio?
- [ ] Existe um Mapper para converter Domain Entity em JpaEntity?

---

_Se houver vazamento de camada (leak), o código deve ser REPROVADO._
