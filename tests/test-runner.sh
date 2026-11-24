#!/usr/bin/env bash

# ==============================================================================
# test-runner.sh — BoardAI OS Automated Test Suite (v4.0.0)
# ==============================================================================
# Suite de pruebas automatizadas e integrales para verificar el correcto
# funcionamiento de todos los scripts, herramientas de migración y fixtures
# de BoardAI OS en entornos temporales aislados.
# ==============================================================================

set -euo pipefail

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

TESTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$TESTS_DIR/.." && pwd )"
SCRIPTS_DIR="$REPO_ROOT/scripts"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

assert_success() {
    local desc="$1"
    shift
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "  [TEST $TOTAL_TESTS] $desc ... "
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}FAIL${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

assert_failure() {
    local desc="$1"
    shift
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "  [TEST $TOTAL_TESTS] $desc ... "
    if "$@" >/dev/null 2>&1; then
        echo -e "${RED}FAIL (se esperaba fallo)${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    else
        echo -e "${GREEN}PASS (falló como se esperaba)${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
}

echo -e "${CYAN}====================================================${NC}"
echo -e "${CYAN}   🧪 Suite de Pruebas Automatizadas — BoardAI OS   ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "Repositorio Core: ${YELLOW}$REPO_ROOT${NC}\n"

# Crear entorno temporal aislado
TMP_TEST_DIR=$(mktemp -d -t boardai_test_XXXXXX)
trap 'rm -rf "$TMP_TEST_DIR"' EXIT

# Configurar repositorio git ficticio en TMP_TEST_DIR
cd "$TMP_TEST_DIR"
git init --quiet
git config user.name "BoardAI Test Runner"
git config user.email "test@boardai.local"

# Simular submódulo canónico en .boardai/core
mkdir -p .boardai
ln -s "$REPO_ROOT" .boardai/core

# ------------------------------------------------------------------------------
# 1. Test setup-ide.sh (Estructura Canónica .boardai/)
# ------------------------------------------------------------------------------
echo -e "${BLUE}--- 1. Testing setup-ide.sh (.boardai/) ---${NC}"

assert_success "setup-ide.sh --auto inicializa la estructura .boardai/ básica" \
    bash "$SCRIPTS_DIR/setup-ide.sh" --auto

assert_success ".boardai/context.md fue creado correctamente" \
    test -f "$TMP_TEST_DIR/.boardai/context.md"

assert_success ".boardai/knowledge-graph.yaml fue creado correctamente" \
    test -f "$TMP_TEST_DIR/.boardai/knowledge-graph.yaml"

assert_success ".boardai/memory/workflow-log.md fue creado correctamente" \
    test -f "$TMP_TEST_DIR/.boardai/memory/workflow-log.md"

assert_success "CLI wrapper ./boardai fue instalado y es ejecutable" \
    test -x "$TMP_TEST_DIR/boardai"

assert_success "CLI alias/symlink ./board fue creado y es ejecutable" \
    test -x "$TMP_TEST_DIR/board"

assert_success "CLI alias/symlink de compatibilidad ./abbia fue creado" \
    test -x "$TMP_TEST_DIR/abbia"

assert_success ".gitignore y .gitattributes fueron configurados para .boardai/" \
    grep -q "\.boardai/" "$TMP_TEST_DIR/.gitignore" -a grep -q "\.boardai/" "$TMP_TEST_DIR/.gitattributes"

# ------------------------------------------------------------------------------
# 2. Test new-initiative.sh
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- 2. Testing new-initiative.sh ---${NC}"

assert_success "new-initiative.sh crea una nueva feature FEAT-001" \
    bash "$SCRIPTS_DIR/new-initiative.sh" FEAT 001 user-auth

assert_success "FEAT-001 contiene spec.md y decision.md" \
    test -f "$TMP_TEST_DIR/.boardai/initiatives/FEAT-001-user-auth/spec.md" -a -f "$TMP_TEST_DIR/.boardai/initiatives/FEAT-001-user-auth/decision.md"

assert_success "FEAT-001 NO pre-crea archivos prematuros (ui-design, architecture, qa)" \
    test ! -f "$TMP_TEST_DIR/.boardai/initiatives/FEAT-001-user-auth/ui-design.md" -a \
         ! -f "$TMP_TEST_DIR/.boardai/initiatives/FEAT-001-user-auth/architecture.md" -a \
         ! -f "$TMP_TEST_DIR/.boardai/initiatives/FEAT-001-user-auth/qa.md"

assert_success "new-initiative.sh crea un bug BUG-001" \
    bash "$SCRIPTS_DIR/new-initiative.sh" BUG 001 db-timeout

assert_success "BUG-001 contiene bug-report.md" \
    test -f "$TMP_TEST_DIR/.boardai/initiatives/BUG-001-db-timeout/bug-report.md"

assert_failure "new-initiative.sh rechaza IDs o tipos inválidos" \
    bash "$SCRIPTS_DIR/new-initiative.sh" INVALID 001 slug

# ------------------------------------------------------------------------------
# 3. Test finish-phase.sh
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- 3. Testing finish-phase.sh ---${NC}"

assert_success "finish-phase.sh cierra fase spec para FEAT-001" \
    bash "$SCRIPTS_DIR/finish-phase.sh" FEAT-001 spec analyst \
        --model "claude-3-7-sonnet" --provider "claude-code" \
        --tokens-in 3500 --tokens-out 1200 --duration 14 --source measured \
        --note "Especificación funcional completada"

assert_success "workflow-log.md registró la entrada de FEAT-001" \
    grep -q "## \[FEAT-001\]" "$TMP_TEST_DIR/.boardai/memory/workflow-log.md"

assert_success "executions.yaml registró la telemetría medida" \
    grep -q "tokens_in: 3500" "$TMP_TEST_DIR/.boardai/metrics/executions.yaml"

assert_success "finish-phase.sh auto-estima telemetría si no se pasan tokens" \
    bash "$SCRIPTS_DIR/finish-phase.sh" BUG-001 implement developer --note "Corrección de bug con auto-estimación"

assert_success "executions.yaml contiene tokens estimados (no-null)" \
    grep -q "source: estimate" "$TMP_TEST_DIR/.boardai/metrics/executions.yaml"

assert_success "finish-phase.sh respeta --no-estimate dejando tokens en null" \
    bash "$SCRIPTS_DIR/finish-phase.sh" BUG-001 qa qa --no-estimate --note "Cierre qa sin estimación"

assert_success "executions.yaml registró null con --no-estimate" \
    grep -q "tokens_in: null" "$TMP_TEST_DIR/.boardai/metrics/executions.yaml"

assert_success "finish-phase.sh auto-descubre variables BOARDAI_TOKENS_IN y BOARDAI_TOKENS_OUT" \
    env BOARDAI_TOKENS_IN=4200 BOARDAI_TOKENS_OUT=850 bash "$SCRIPTS_DIR/finish-phase.sh" BUG-001 deploy devops --note "Deploy con env telemetría"

assert_success "executions.yaml registró tokens descubiertos por entorno" \
    grep -q "tokens_in: 4200" "$TMP_TEST_DIR/.boardai/metrics/executions.yaml"

assert_success "aggregates.yaml fue regenerado" \
    test -f "$TMP_TEST_DIR/.boardai/metrics/aggregates.yaml"

assert_success "context-snapshot.md fue regenerado con datos reales" \
    grep -q "FEAT-001" "$TMP_TEST_DIR/.boardai/memory/context-snapshot.md"

# ------------------------------------------------------------------------------
# 4. Test validate-project.sh
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- 4. Testing validate-project.sh ---${NC}"

assert_success "validate-project.sh valida exitosamente el proyecto BoardAI" \
    bash "$SCRIPTS_DIR/validate-project.sh"

mkdir -p "$TMP_TEST_DIR/.boardai/initiatives/INVALID_FOLDER_NAME"
assert_failure "validate-project.sh falla si hay una carpeta con nombre inválido" \
    bash "$SCRIPTS_DIR/validate-project.sh"
rm -rf "$TMP_TEST_DIR/.boardai/initiatives/INVALID_FOLDER_NAME"

# ------------------------------------------------------------------------------
# 5. Test archive-initiative.sh
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- 5. Testing archive-initiative.sh ---${NC}"

assert_failure "archive-initiative.sh bloquea el archivado si QA no está aprobado" \
    bash "$SCRIPTS_DIR/archive-initiative.sh" FEAT-001-user-auth

cat > "$TMP_TEST_DIR/.boardai/initiatives/FEAT-001-user-auth/architecture.md" << 'EOF'
# Diseño Técnico — FEAT-001-user-auth
Arquitectura validada.
EOF

cat > "$TMP_TEST_DIR/.boardai/initiatives/FEAT-001-user-auth/qa.md" << 'EOF'
# Reporte de QA — FEAT-001-user-auth
> **Veredicto:** APROBADO
EOF

assert_success "archive-initiative.sh archiva FEAT-001 tras QA Aprobado" \
    bash "$SCRIPTS_DIR/archive-initiative.sh" FEAT-001-user-auth --note "Deploy exitoso"

assert_success "FEAT-001 ahora reside en .boardai/archive/" \
    test -d "$TMP_TEST_DIR/.boardai/archive/FEAT-001-user-auth" -a ! -d "$TMP_TEST_DIR/.boardai/initiatives/FEAT-001-user-auth"

# ------------------------------------------------------------------------------
# 6. Test sync-initiatives.sh
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- 6. Testing sync-initiatives.sh ---${NC}"

assert_success "sync-initiatives.sh reconcilia sin errores" \
    bash "$SCRIPTS_DIR/sync-initiatives.sh"

# ------------------------------------------------------------------------------
# 7. Test migrate-to-boardai.sh (Migración de Proyecto Legacy .ai/ a .boardai/)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- 7. Testing migrate-to-boardai.sh ---${NC}"

LEGACY_TEST_DIR=$(mktemp -d -t boardai_legacy_test_XXXXXX)
trap 'rm -rf "$TMP_TEST_DIR" "$LEGACY_TEST_DIR"' EXIT

cd "$LEGACY_TEST_DIR"
git init --quiet
git config user.name "Legacy User"
git config user.email "legacy@test.local"

# Simular proyecto legacy .ai/
mkdir -p .ai/agents .ai/features/FEAT-099-payment-gateway .ai/memory .ai/metrics
ln -s "$REPO_ROOT" .ai/agents/core
cat > .ai/context.md << 'EOF'
# Contexto General
## Registro de IDs
- Último FEAT asignado: FEAT-099
EOF
cat > .ai/business-rules.md << 'EOF'
# Reglas
EOF
cat > .ai/architecture.md << 'EOF'
# Arquitectura
EOF
cat > .ai/decisions.md << 'EOF'
# Decisiones
EOF
cat > .ai/glossary.md << 'EOF'
# Glosario
EOF
cat > .ai/knowledge-graph.yaml << 'EOF'
version: 1
nodes: []
edges: []
EOF
cat > .ai/memory/workflow-log.md << 'EOF'
# Workflow Log
## [FEAT-099] — analyst (2026-09-01T00:00:00Z)
EOF
cat > .ai/features/FEAT-099-payment-gateway/spec.md << 'EOF'
# Spec Payment
EOF
cat > .ai/features/FEAT-099-payment-gateway/decision.md << 'EOF'
# Decision Payment
EOF

assert_success "migrate-to-boardai.sh ejecuta migración de .ai/ a .boardai/" \
    bash "$SCRIPTS_DIR/migrate-to-boardai.sh"

assert_success "La carpeta .boardai/initiatives/FEAT-099-payment-gateway existe" \
    test -d "$LEGACY_TEST_DIR/.boardai/initiatives/FEAT-099-payment-gateway"

assert_success "validate-project.sh valida exitosamente el proyecto migrado" \
    bash "$SCRIPTS_DIR/validate-project.sh"

# ------------------------------------------------------------------------------
# 8. Test examples/golden-project/ Fixture Integrity
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- 8. Testing examples/golden-project/ ---${NC}"

assert_success "golden-project cuenta con estructura canónica completa en .boardai/" \
    test -d "$REPO_ROOT/examples/golden-project/.boardai" -a \
         -f "$REPO_ROOT/examples/golden-project/.boardai/context.md" -a \
         -f "$REPO_ROOT/examples/golden-project/.boardai/knowledge-graph.yaml" -a \
         -d "$REPO_ROOT/examples/golden-project/.boardai/archive/FEAT-001-user-auth" -a \
         -d "$REPO_ROOT/examples/golden-project/.boardai/initiatives/FEAT-002-order-checkout"

assert_success "validate-project.sh pasa al 100% en golden-project" \
    bash -c "cd '$REPO_ROOT/examples/golden-project' && bash '$SCRIPTS_DIR/validate-project.sh'"

# ------------------------------------------------------------------------------
# 9. Test dashboard.sh (--no-open y auto-refresh)
# ------------------------------------------------------------------------------
echo -e "\n${BLUE}--- 9. Testing dashboard.sh & Auto-Refresh ---${NC}"

cd "$TMP_TEST_DIR"
assert_success "dashboard.sh --no-open genera .boardai/dashboard.html" \
    bash "$SCRIPTS_DIR/dashboard.sh" --no-open

assert_success ".boardai/dashboard.html fue generado y no está vacío" \
    test -s "$TMP_TEST_DIR/.boardai/dashboard.html"

assert_success "dashboard.html contiene soporte para Live Reload" \
    grep -q "/__version__" "$TMP_TEST_DIR/.boardai/dashboard.html"

# Modificar un archivo y cerrar fase para validar auto-refresh silencioso
sleep 1
DASH_MTIME_BEFORE=$(stat -f %m "$TMP_TEST_DIR/.boardai/dashboard.html" 2>/dev/null || stat -c %Y "$TMP_TEST_DIR/.boardai/dashboard.html" 2>/dev/null || echo "0")
bash "$SCRIPTS_DIR/new-initiative.sh" FEAT 002 auto-refresh-test >/dev/null 2>&1
DASH_MTIME_AFTER=$(stat -f %m "$TMP_TEST_DIR/.boardai/dashboard.html" 2>/dev/null || stat -c %Y "$TMP_TEST_DIR/.boardai/dashboard.html" 2>/dev/null || echo "1")

assert_success "new-initiative.sh actualizó automáticamente dashboard.html" \
    test "$DASH_MTIME_AFTER" -gt "$DASH_MTIME_BEFORE"


# ------------------------------------------------------------------------------
# Resumen Final
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}====================================================${NC}"
echo -e "${CYAN}   📊 Resumen de Resultados de la Suite BoardAI OS  ${NC}"
echo -e "${CYAN}====================================================${NC}"
echo -e "Total Pruebas: $TOTAL_TESTS"
echo -e "Aprobadas:     ${GREEN}$PASSED_TESTS${NC}"
echo -e "Fallidas:      ${RED}$FAILED_TESTS${NC}"
echo -e "===================================================="

if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}🎉 ¡Todas las pruebas de BoardAI OS pasaron exitosamente!${NC}"
    exit 0
else
    echo -e "${RED}❌ Se detectaron fallos en la suite de pruebas.${NC}"
    exit 1
fi
