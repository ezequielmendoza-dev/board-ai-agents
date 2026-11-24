# 🌟 Golden Project — Ejemplo de Referencia de BoardAI OS

Este subproyecto sirve como **referencia canónica** de cómo se estructura e implementa un proyecto de software real utilizando el framework **BoardAI OS** y la metodología **Specification-Driven Development (SDD)**.
*Layered Context, Structured Memory, Autonomous Delivery.*

---

## 🎯 ¿Qué demuestra este proyecto?

1. **Estructura Documental `.boardai/`:** Muestra la memoria permanente en la raíz de `.boardai/` (`context.md`, `business-rules.md`, `architecture.md`, `decisions.md`, `knowledge-graph.yaml`, `glossary.md`).
2. **Ciclo Completo Archivado (`.boardai/archive/FEAT-001-user-auth`):**
   - `spec.md` (especificación funcional con criterios Gherkin).
   - `ui-design.md` (diseño visual de interfaz y accesibilidad).
   - `architecture.md` (diseño técnico de contratos y endpoints).
   - `decision.md` (registro de decisiones locales).
   - `qa.md` (reporte de pruebas con veredicto `APROBADO`).
3. **Iniciativa en Progreso (`.boardai/initiatives/FEAT-002-order-checkout`):**
   - `spec.md` y `decision.md` creados al bootstrap sin esqueletos prematuros.
4. **Memoria y Telemetría:**
   - `.boardai/memory/workflow-log.md` con historial de sesiones.
   - `.boardai/memory/context-snapshot.md` generado automáticamente.
   - `.boardai/metrics/executions.yaml` con telemetría de tokens y duraciones.

---

## 🔍 Cómo verificar este proyecto

Desde la raíz del repositorio:
```bash
# Validar cumplimiento de reglas documentales
./boardai validate # o ./board validate

# Ejecutar la suite completa de tests automatizados
bash tests/test-runner.sh
```
