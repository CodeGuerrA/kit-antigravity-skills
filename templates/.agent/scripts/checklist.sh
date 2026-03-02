#!/bin/bash
# 🛸 ANTIGRAVITY QUALITY CHECKER (Simulado)
# Este script realiza uma varredura rápida no projeto em busca de violações críticas.

echo "🔍 Iniciando Auditoria Estática do Antigravity Kit..."

# 1. Procurar por @Autowired (Proibido)
AUTOWIRED_COUNT=$(grep -rn "@Autowired" . | grep -v ".agent" | wc -l)
if [ "$AUTOWIRED_COUNT" -gt 0 ]; then
    echo "❌ FALHA: Encontrados $AUTOWIRED_COUNT usos de @Autowired em campos. (Proibição Pilar 2)"
else
    echo "✅ OK: Nenhum @Autowired em campo encontrado."
fi

# 2. Procurar por sufixos proibidos (DTO, VO, Input)
FORBIDDEN_SUFFIX=$(grep -rnE "(DTO|VO|Input|Output|Data|Payload)\.java" . | grep -v ".agent" | wc -l)
if [ "$FORBIDDEN_SUFFIX" -gt 0 ]; then
    echo "⚠️  AVISO: Encontrados arquivos com sufixos proibidos. (Violação Pilar 1)"
else
    echo "✅ OK: Nomenclatura de DTOs parece correta."
fi

# 3. Verificar import de infra no domínio
INFRA_IN_DOMAIN=$(grep -rn "import.*infrastructure" src/main/java/*/domain/ | wc -l)
if [ "$INFRA_IN_DOMAIN" -gt 0 ]; then
    echo "❌ FALHA CRÍTICA: Leak de infraestrutura no Domínio detectado! (Violação Pilar 3)"
else
    echo "✅ OK: Domínio isolado."
fi

echo "🏁 Auditoria rápida concluída. Para uma análise profunda, utilize o workflow /audit."
