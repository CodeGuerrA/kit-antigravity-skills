---
name: "modular-monolith"
description: "Arquitetura Macro: Monolito Modular por Domínios e Bounded Contexts."
---

# 🛸 SKILL: Monolito Modular (Modular Monolith)

Esta skill define a arquitetura macro do projeto. O sistema é organizado como um **Monolito Modular**, onde cada domínio principal é tratado como um módulo isolado (Bounded Context), preparando o terreno para uma futura migração para microserviços, se necessário.

## 🏗️ PRINCÍPIOS FUNDAMENTAIS

1. **Domínios Isolados**: Cada módulo em `src/main/java/com/company/project/modules/<module_name>` deve ser autossuficiente.
2. **Zero Cross-Module Import (Compile Time)**: Um módulo **NUNCA** deve importar classes de outro módulo diretamente (exceto a camada `shared/`).
3. **Comunicação via Ports**: Se o Módulo A precisa de dados do Módulo B, ele deve chamar um `Port` (interface) definido no Módulo B, ou utilizar eventos/mensagens.
4. **Camada Shared**: Apenas infraestrutura transversal (Segurança, ExceptionHandler, Configurações Globais) reside em `shared/`.
5. **Estrutura Hexagonal**: Cada módulo implementa internamente a estrutura de 4 camadas (API, Application, Domain, Infrastructure).

## 📁 ORGANIZAÇÃO DE PASTAS

```
src/main/java/com/company/project/
├── modules/
│   ├── producer/          → Bounded Context: Produtor
│   │   ├── api/
│   │   ├── application/
│   │   ├── domain/
│   │   └── infrastructure/
│   ├── property/          → Bounded Context: Propriedade Rural
│   └── safra/             → Bounded Context: Safra/Colheita
├── shared/                → Infraestrutura transversal
│   ├── config/            → Security, Jackson, Swagger
│   ├── exception/         → GlobalExceptionHandler, BusinessException
│   ├── converter/         → Mappers/Converters genéricos
│   └── util/              → Utilitários puros
```

## 🛡️ REGRAS DE ISOLAMENTO

| De \ Para | Outro Módulo | Shared |
|:---|:---:|:---:|
| **Módulo (API/App)** | ❌ PROIBIDO | ✅ PERMITIDO |
| **Módulo (Domain)** | ❌ PROIBIDO | ⚠️ SÓ EXCEÇÕES/DTOs |
| **Módulo (Infra)** | ❌ PROIBIDO | ✅ PERMITIDO |

**Vantagens**:
- **Testabilidade**: Módulos podem ser testados isoladamente.
- **Refatoração**: Alterações em um domínio não quebram outros (baixo acoplamento).
- **Escalabilidade Humana**: Diferentes desenvolvedores podem focar em diferentes módulos.

---
_A violação do isolamento de módulos é considerada uma VIOLAÇÃO ALTA no Quality Gate._
