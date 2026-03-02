#!/bin/bash
# 🛸 ANTIGRAVITY QUALITY CHECKER v2.0
# Varredura estática automatizada do backend Java/Spring Boot.
# Uso: bash checklist.sh [diretório_raiz]

ROOT_DIR="${1:-.}"
SRC_DIR="$ROOT_DIR/src/main/java"
ERRORS=0
WARNINGS=0

echo "🔍 Iniciando Auditoria Estática do Antigravity Kit v2.0..."
echo "📁 Diretório raiz: $ROOT_DIR"
echo ""

# === SEVERIDADE ALTA ===

# 1. @Autowired em campos (Pilar 2)
AUTOWIRED_COUNT=$(grep -rn "@Autowired" "$SRC_DIR" 2>/dev/null | grep -v "test" | grep -v ".agent" | wc -l)
if [ "$AUTOWIRED_COUNT" -gt 0 ]; then
    echo "❌ [ALTA] Encontrados $AUTOWIRED_COUNT usos de @Autowired em campos. (Pilar 2)"
    grep -rn "@Autowired" "$SRC_DIR" 2>/dev/null | grep -v "test" | grep -v ".agent"
    ERRORS=$((ERRORS + AUTOWIRED_COUNT))
else
    echo "✅ OK: Nenhum @Autowired em campo encontrado."
fi

# 2. Leak de infra no domínio (Pilar 3)
if [ -d "$SRC_DIR" ]; then
    INFRA_IN_DOMAIN=$(grep -rn "import.*infrastructure\|import.*jakarta\.persistence\|import.*org\.springframework\|import.*org\.keycloak" "$SRC_DIR" 2>/dev/null | grep "/domain/" | wc -l)
    if [ "$INFRA_IN_DOMAIN" -gt 0 ]; then
        echo "❌ [ALTA] Leak de framework no Domínio detectado! (Pilar 3)"
        grep -rn "import.*infrastructure\|import.*jakarta\.persistence\|import.*org\.springframework\|import.*org\.keycloak" "$SRC_DIR" 2>/dev/null | grep "/domain/"
        ERRORS=$((ERRORS + INFRA_IN_DOMAIN))
    else
        echo "✅ OK: Domínio isolado — zero imports de framework."
    fi
fi

# 3. PII em log.info/warn/error (Pilar 8)
PII_LEAK=$(grep -rn "log\.\(info\|warn\|error\).*\(email\|username\|cpf\|password\|token\|secret\)" "$SRC_DIR" 2>/dev/null | grep -v "test" | grep -v ".agent" | wc -l)
if [ "$PII_LEAK" -gt 0 ]; then
    echo "❌ [ALTA] PII ou Secrets detectados em logs acima de debug! (Pilar 8)"
    grep -rn "log\.\(info\|warn\|error\).*\(email\|username\|cpf\|password\|token\|secret\)" "$SRC_DIR" 2>/dev/null | grep -v "test" | grep -v ".agent"
    ERRORS=$((ERRORS + PII_LEAK))
else
    echo "✅ OK: Nenhum PII/Secret em log info/warn/error."
fi

# 4. SQL Injection — concatenação em @Query (Pilar 8)
SQL_CONCAT=$(grep -rn "@Query" "$SRC_DIR" 2>/dev/null -A 3 | grep "\" +" | wc -l)
if [ "$SQL_CONCAT" -gt 0 ]; then
    echo "❌ [ALTA] Possível SQL Injection — concatenação de strings em @Query! (Pilar 8)"
    ERRORS=$((ERRORS + SQL_CONCAT))
else
    echo "✅ OK: Nenhuma concatenação em @Query."
fi

# === SEVERIDADE MÉDIA ===
echo ""

# 5. Sufixos proibidos (Pilar 1)
FORBIDDEN_SUFFIX=$(find "$SRC_DIR" -name "*DTO.java" -o -name "*VO.java" -o -name "*Input.java" -o -name "*Output.java" -o -name "*Data.java" -o -name "*Payload.java" 2>/dev/null | grep -v "test" | wc -l)
if [ "$FORBIDDEN_SUFFIX" -gt 0 ]; then
    echo "⚠️  [MÉDIA] Encontrados arquivos com sufixos proibidos. (Pilar 1)"
    find "$SRC_DIR" -name "*DTO.java" -o -name "*VO.java" -o -name "*Input.java" -o -name "*Output.java" -o -name "*Data.java" -o -name "*Payload.java" 2>/dev/null | grep -v "test"
    WARNINGS=$((WARNINGS + FORBIDDEN_SUFFIX))
else
    echo "✅ OK: Nomenclatura de DTOs correta."
fi

# 6. @Slf4j ausente (Pilar 14) — checa Controllers, Services, Adapters, Facades
if [ -d "$SRC_DIR" ]; then
    MISSING_SLF4J=0
    for pattern in "Controller.java" "Service.java" "Adapter.java" "FacadeImpl.java"; do
        FILES=$(find "$SRC_DIR" -name "*$pattern" 2>/dev/null | grep -v "test")
        for file in $FILES; do
            if ! grep -q "@Slf4j" "$file" 2>/dev/null; then
                echo "⚠️  [MÉDIA] @Slf4j ausente em: $file (Pilar 14)"
                MISSING_SLF4J=$((MISSING_SLF4J + 1))
            fi
        done
    done
    if [ "$MISSING_SLF4J" -eq 0 ]; then
        echo "✅ OK: @Slf4j presente em todas as classes obrigatórias."
    fi
    WARNINGS=$((WARNINGS + MISSING_SLF4J))
fi

# 7. Controller com try-catch (Pilar 6)
CONTROLLER_TRYCATCH=0
if [ -d "$SRC_DIR" ]; then
    for file in $(find "$SRC_DIR" -path "*/controller/*Controller.java" 2>/dev/null); do
        if grep -q "try {" "$file" 2>/dev/null; then
            echo "⚠️  [MÉDIA] Controller com try-catch: $file (Pilar 6)"
            CONTROLLER_TRYCATCH=$((CONTROLLER_TRYCATCH + 1))
        fi
    done
    if [ "$CONTROLLER_TRYCATCH" -eq 0 ]; then
        echo "✅ OK: Nenhum Controller com try-catch."
    fi
    WARNINGS=$((WARNINGS + CONTROLLER_TRYCATCH))
fi

# 8. @Data em entities (Pilar 2)
DATA_IN_ENTITY=$(grep -rn "@Data" "$SRC_DIR" 2>/dev/null | grep -i "entity" | grep -v "test" | wc -l)
if [ "$DATA_IN_ENTITY" -gt 0 ]; then
    echo "⚠️  [MÉDIA] @Data usado em Entity — use @Getter/@Setter. (Pilar 2)"
    WARNINGS=$((WARNINGS + DATA_IN_ENTITY))
else
    echo "✅ OK: Nenhum @Data em Entity."
fi

# 9. @Service em Facades/Validators (Pilar 2)
WRONG_STEREOTYPE=$(grep -rln "@Service" "$SRC_DIR" 2>/dev/null | grep -E "(Facade|Validator|Mapper|Factory|Converter)" | grep -v "test" | wc -l)
if [ "$WRONG_STEREOTYPE" -gt 0 ]; then
    echo "⚠️  [MÉDIA] @Service usado em Facade/Validator/Mapper — deveria ser @Component. (Pilar 2)"
    grep -rln "@Service" "$SRC_DIR" 2>/dev/null | grep -E "(Facade|Validator|Mapper|Factory|Converter)" | grep -v "test"
    WARNINGS=$((WARNINGS + WRONG_STEREOTYPE))
else
    echo "✅ OK: Stereotype annotations corretas."
fi

# === RESUMO ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛸 RESULTADO DA AUDITORIA ESTÁTICA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔴 Violações ALTA: $ERRORS"
echo "🟡 Violações MÉDIA: $WARNINGS"
TOTAL=$((ERRORS + WARNINGS))
echo "📊 Total: $TOTAL"
echo ""

if [ "$ERRORS" -gt 0 ]; then
    echo "🏆 VEREDITO: REPROVADO ❌ (Violações ALTA encontradas)"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    echo "🏆 VEREDITO: REPROVADO ❌ (Violações MÉDIA encontradas)"
    exit 1
else
    echo "🏆 VEREDITO: APROVADO ✅ (Zero violações)"
    exit 0
fi
