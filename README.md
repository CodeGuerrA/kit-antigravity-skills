# 🛸 Antigravity Kit (Sua Versão)

Este é o seu kit pessoal de templates de IA para transformar qualquer IDE assistida por agentes (Gemini CLI, Cursor, Windsurf) em um **Engenheiro de Software Sênior** e **Auditor Determinístico**.

## 📖 ROTEIRO TÉCNICO (O que construímos)

Seguimos o seguinte fluxo de engenharia para criar este kit:

### ✅ FASE 1: Motor CLI e Infraestrutura
1.  **Configuração do Manifesto (`package.json`)**: Definimos o comando global `antigravity-kit` e as dependências profissionais (`commander`, `chalk`, `fs-extra`).
2.  **Motor CLI (`bin/cli.js`)**: Desenvolvemos um script robusto em Node.js que detecta o contexto do projeto e "instala" as regras de IA via comando `init`. Incluímos:
    - Arte ASCII e logs coloridos.
    - Flag `--force` para atualizações de templates.
    - Suporte para cópia recursiva de agentes e workflows.
3.  **Template Mestre (`templates/GEMINI.md`)**: Criamos a "Constituição" que serve de entrada para a IA, instruindo-a a ler os especialistas antes de qualquer tarefa.

### ✅ FASE 2: O Cérebro (Agentes e Workflows)
1.  **Modularização de Regras**: Conversão de regras rigorosas de **Quality Gate** em especialistas individuais. [CONCLUÍDO]
2.  **Especialistas (Agents)**:
    - `@backend-auditor`: Guardião do Hexagonal e Clean Backend. [CRIADO]
    - `@clean-coder`: Especialista em SOLID, DRY e KISS. [CRIADO]
3.  **Fluxos (Workflows)**:
    - `/quality-audit`: Protocolo sistemático de auditoria binária. [CRIADO]

---

## 📂 ARQUITETURA DO KIT

```
antigravity-kit/
├── bin/
│   └── cli.js          # O Motor (CLI)
├── templates/
│   ├── GEMINI.md       # A Constituição (Mestre)
│   └── .agent/         # O Cérebro
│       ├── agents/     # Especialistas (Backend, Clean Code, etc)
│       └── workflows/  # Passo-a-passo (Audit, Refactor, Deploy)
└── package.json        # Configuração Global
```

---

## 🚀 COMO INSTALAR GLOBALMENTE

Para usar o seu kit em qualquer projeto do seu computador:

1.  Abra o terminal na pasta `~/Documentos/antigravity-kit`.
2.  Execute o comando:
    ```bash
    npm link
    ```
3.  Agora, em qualquer outro projeto, basta rodar:
    ```bash
    antigravity-kit init
    ```

---

## 🛡️ FILOSOFIA DE DESENVOLVIMENTO

- **Protocolo Socrático**: Validar o escopo antes de codar.
- **Auditoria Binária**: APROVADO ou REPROVADO. Sem meio-termo.
- **Foco em Qualidade**: SOLID, Clean Code e Arquitetura Hexagonal acima de velocidade.
