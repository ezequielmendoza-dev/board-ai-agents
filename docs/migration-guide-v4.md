# Guía de Migración: De `ai-agents` (.ai/) a BoardAI OS v4.0.0 (.boardai/)

Esta guía detalla el proceso para actualizar cualquier proyecto que consuma `ai-agents` (o `.stratum/`) a la nueva versión mayor **BoardAI OS v4.0.0**.

---

## 🚀 ¿Por qué migrar a BoardAI OS?

1. **Estructura Modular e Inequívoca:** Cambia la carpeta genérica `.ai/` por `.boardai/`, y el submódulo de `.ai/agents` a `.boardai/core`.
2. **CLI Wrapper Incluido (`./boardai`):** Ejecuta comandos de forma rápida desde la raíz sin recordar rutas largas de bash.
3. **Roles con Context Contracts Renovados:** Nuevas identidades de agentes con contratos estrictos de contexto y telemetría automática.
4. **Soporte de Retrocompatibilidad:** Tus scripts y workflows continuarán funcionando con normalidad.

---

## ⚡ Opción A: Migración Automática en 1 Paso (Recomendada)

Si ya tienes el submódulo en tu proyecto, simplemente ejecuta:

```bash
# 1. Actualizar el submódulo al core de BoardAI OS
git submodule update --remote

# 2. Ejecutar la herramienta de migración
bash .ai/agents/scripts/migrate-to-boardai.sh
```

El script se encargará automáticamente de:
- Renombrar `.ai/` o `.stratum/` a `.boardai/`
- Mover `.ai/features/` a `.boardai/initiatives/`
- Mover el submódulo a `.boardai/core/` y actualizar `.gitmodules`
- Actualizar reglas de `.gitignore` y `.gitattributes`
- Instalar el CLI wrapper `./boardai`
- Regenerar reglas de IDEs (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, etc.)
- Validar la consistencia total del proyecto

---

## 🛠️ Opción B: Migración Manual Paso a Paso

Si prefieres realizar el proceso manualmente:

### 1. Mover la carpeta de configuración
```bash
mv .ai .boardai
mv .boardai/features .boardai/initiatives
mv .boardai/agents .boardai/core
```

### 2. Actualizar `.gitmodules`
Edita `.gitmodules` para cambiar la ruta:
```ini
[submodule ".boardai/core"]
    path = .boardai/core
    url = https://github.com/ezequielmendoza-dev/board-ai-agents.git
```

### 3. Actualizar `.gitignore` y `.gitattributes`
En `.gitignore`:
```diff
- .ai/sessions/
- .ai/dashboard.html
- .ai/memory/context-snapshot.md
- .ai/metrics/aggregates.yaml
+ .boardai/sessions/
+ .boardai/dashboard.html
+ .boardai/memory/context-snapshot.md
+ .boardai/metrics/aggregates.yaml
```

En `.gitattributes`:
```diff
- .ai/memory/workflow-log.md merge=union
- .ai/metrics/executions.yaml merge=union
+ .boardai/memory/workflow-log.md merge=union
+ .boardai/metrics/executions.yaml merge=union
```

### 4. Regenerar Reglas de IDEs y Validar
```bash
bash .boardai/core/scripts/setup-ide.sh --auto
bash .boardai/core/scripts/validate-project.sh
```

---

## 💡 Uso Diario con el CLI Wrapper `./boardai`

Una vez migrado, puedes usar el CLI `./boardai` desde la raíz de tu proyecto:

```bash
# Crear nueva feature
./boardai new FEAT 001 login-seguro

# Cerrar fase con telemetría
./boardai finish FEAT-001 spec analyst --tokens-in 3000 --tokens-out 1000 --duration 120 --source measured

# Validar estado del proyecto
./boardai validate

# Abrir el dashboard interactivo (se actualiza automáticamente en cada cierre de fase)
./boardai dashboard

# Iniciar servidor en vivo con Live Reload automático
./boardai serve

# Vigilar cambios en segundo plano
./boardai watch

```
