```text
           ▲
          ╱ ╲
         ╱╱ ╲╲       BOARDAI OS
        ╱╱   ╲╲      AI Software Engineering Operating System — v4.0.0
       ●═══◆═══●     Layered Context · Structured Memory · Autonomous Delivery
      ╱╱       ╲╲
     ●═══════════●
```

# BoardAI OS — Guía para Contribuir al Framework

> Este `AGENTS.md` es específico para el desarrollo del **propio repositorio de BoardAI OS**.
> No confundir con el template `templates/ide-configs/AGENTS.md`, que es la versión que se instala en los proyectos que consumen este framework.
>
> **ℹ️ Relación entre ambos:** Este archivo (raíz) gobierna el desarrollo **del framework BoardAI** — reglas documentales R1–R6, estructura interna, convenciones de contribución. El template `templates/ide-configs/AGENTS.md` gobierna los **proyectos que consumen** el framework bajo `.boardai/`.

---

## 🎯 ¿Qué es BoardAI OS?

**BoardAI OS** es un **sistema operativo de ingeniería de software asistida por IA** y framework de orquestación multi-agente basado en *Specification-Driven Development (SDD)*, memoria persistente en 3 capas (*3-Tier Memory*), flujos DAG deterministas y observabilidad técnica.

*Lema:* **Layered Context, Structured Memory, Autonomous Delivery.**

### Estructura del Repositorio

```
boardai-core/
├── roles/                    # Definiciones de agentes de BoardAI OS
│   ├── analyst.md
│   ├── ui-designer.md
│   ├── architect.md
│   ├── tech-lead.md
│   ├── developer.md
│   ├── qa.md
│   ├── devops.md
│   ├── skill-manager.md
│   └── prompt-guide.md
├── skills/                   # BoardAI Framework Skills (15 skills metodológicas)
│   ├── README.md             # Catálogo de skills
│   ├── registry.md           # Reglas de orquestación
│   ├── analysis/             # requirements-discovery, ux-heuristics
│   ├── architecture/         # api-design, backend-architecture, database-design, performance-tuning, ai-integration
│   ├── development/          # code-review, frontend-patterns, mobile-development
│   ├── qa/                   # test-strategy, testing-automation, security-audit
│   └── workflow/             # release-readiness, devops-pipeline
├── templates/                # Plantillas reutilizables
│   ├── ide-configs/          # Configuraciones para IDEs de IA (Cursor, Claude Code, Windsurf, Cline, Copilot)
│   ├── boardai               # Wrapper ejecutable CLI para proyectos destino (alias: board)
│   ├── knowledge-graph.yaml  # Template del grafo de decisiones (Tier 3)
│   ├── metrics-executions.yaml # Template de telemetría de ejecuciones
│   ├── dag-manifest.yaml     # Template de DAG para workflows
│   └── *.md                  # Templates de documentos de proyecto
├── checklists/               # Checklists por área técnica
├── workflows/                # Flujos de trabajo con DAG formal
├── scripts/                  # Suite de automatización CLI
├── tests/                    # Suite de pruebas automatizadas (test-runner.sh)
├── examples/                 # Proyectos de referencia canónicos (golden-project)
├── docs/                     # Documentación técnica y arquitectura
├── AGENTS.md                 # ← Este archivo (contribución al framework)
├── README.md
└── CHANGELOG.md
```

---

## 📋 Reglas para Contribuir (R1-R6)

| Regla | Enunciado |
| :--- | :--- |
| **R1** | Antes de crear un documento, verificar si existe uno equivalente para actualizar |
| **R2** | Priorizar la **actualización** sobre la creación |
| **R3** | No crear versiones del tipo `architect-v2.md`. Modificar el existente |
| **R4** | Los cambios en roles/workflows deben reflejarse en `CHANGELOG.md` |
| **R5** | Los documentos representan el **estado actual**, no el histórico |
| **R6** | **Cierre Mandatorio y Telemetría:** Al culminar cualquier fase o tarea, el agente **DEBE SIEMPRE ejecutar en la terminal** `bash .boardai/core/scripts/finish-phase.sh <INICIATIVA> <FASE> <ROL> --model <MODELO> --tokens-in <IN> --tokens-out <OUT> --duration <S> --source <measured|estimate>` (o `./boardai finish ...`) antes de responder o dar por finalizado su turno. |

---

## 👥 Roles de los Agentes en BoardAI OS

Los agentes están definidos en `roles/`:

| Agente | Archivo | Responsabilidad |
| :--- | :--- | :--- |
| **Skill Manager** | [skill-manager.md](file:///Volumes/ExternalSSD/Dev/board-ai-agents/roles/skill-manager.md) | Capability & Context Advisor, resolución de skills y memoria técnica |
| **Product Analyst** | [analyst.md](file:///Volumes/ExternalSSD/Dev/board-ai-agents/roles/analyst.md) | Requerimientos, reglas de negocio y especificaciones funcionales |
| **UI Designer** | [ui-designer.md](file:///Volumes/ExternalSSD/Dev/board-ai-agents/roles/ui-designer.md) | Diseño de interfaz de usuario, tokens visuales y a11y |
| **Software Architect** | [architect.md](file:///Volumes/ExternalSSD/Dev/board-ai-agents/roles/architect.md) | Diseño técnico, esquemas de BD y ADRs |
| **Tech Lead** | [tech-lead.md](file:///Volumes/ExternalSSD/Dev/board-ai-agents/roles/tech-lead.md) | Revisión, estándares y veredicto final |
| **Senior Developer** | [developer.md](file:///Volumes/ExternalSSD/Dev/board-ai-agents/roles/developer.md) | Implementación de código y tests |
| **QA Engineer** | [qa.md](file:///Volumes/ExternalSSD/Dev/board-ai-agents/roles/qa.md) | Validación adversarial y reportes |
| **DevOps Engineer** | [devops.md](file:///Volumes/ExternalSSD/Dev/board-ai-agents/roles/devops.md) | CI/CD, infraestructura y despliegue |

---

## ⚙️ Scripts de Automatización

| Script | Propósito | Uso |
| :--- | :--- | :--- |
| [`setup-ide.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/setup-ide.sh) | Inicializa `.boardai/`, seeds de memoria/métricas/KG y reglas de IDE | `bash .boardai/core/scripts/setup-ide.sh` |
| [`migrate-to-boardai.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/migrate-to-boardai.sh) | Migra de forma segura proyectos legacy (`.abbia/`, `.ai/` o `.stratum/` $\rightarrow$ `.boardai/`) | `bash .boardai/core/scripts/migrate-to-boardai.sh` |
| [`update-boardai.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/update-boardai.sh) | Actualiza el framework en un comando (submódulo + setup + sync + validación) | `bash .boardai/core/scripts/update-boardai.sh [vX.Y.Z]` |
| [`new-initiative.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/new-initiative.sh) | Bootstrap automático de feature, bug, auditoría o refactor | `bash .boardai/core/scripts/new-initiative.sh <TIPO> <ID> <slug>` |
| [`finish-phase.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/finish-phase.sh) | Cierre de fase: registra memory, metrics (model, provider, env, branch, tokens, duration) y snapshot | `bash .boardai/core/scripts/finish-phase.sh <INICIATIVA> <FASE> <ROL> --model <M> --tokens-in <IN> --tokens-out <OUT> --duration <S> --source <measured|estimate>` |
| [`archive-initiative.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/archive-initiative.sh) | Archiva una iniciativa a `.boardai/archive/` tras QA Aprobado | `bash .boardai/core/scripts/archive-initiative.sh <INICIATIVA>` |
| [`sync-initiatives.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/sync-initiatives.sh) | Sincroniza, auto-repara (`--fix`) y auto-archiva (`--archive-approved`) | `bash .boardai/core/scripts/sync-initiatives.sh [--fix]` |
| [`validate-project.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/validate-project.sh) | Valida estructura documental y sistemas de BoardAI OS | `bash .boardai/core/scripts/validate-project.sh` |
| [`dashboard.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/dashboard.sh) | Genera y abre el visualizador interactivo (`--watch` para observar, `--serve` para Live Server) | `bash .boardai/core/scripts/dashboard.sh [--watch\|--serve]` o `./boardai dashboard` / `./board dashboard` |
| [`common.sh`](file:///Volumes/ExternalSSD/Dev/board-ai-agents/scripts/common.sh) | Librería compartida de soporte (interno, DRY) | *(Interno)* |

---

## 🌿 Higiene de Git y Prevención de Conflictos en Proyectos

1. **Archivos generados y cachés locales:** En `.gitignore` (`.boardai/sessions/`, `.boardai/dashboard.html`, `.boardai/memory/context-snapshot.md`, `.boardai/metrics/aggregates.yaml`).
2. **Archivos append-only (Logs y Telemetría):** Directiva `merge=union` en `.gitattributes` (`.boardai/memory/workflow-log.md`, `.boardai/metrics/executions.yaml`).
3. **Reconciliación post-merge:** Tras un `pull` o `merge`, ejecutar `./boardai sync` (o `./board sync`) o `bash .boardai/core/scripts/sync-initiatives.sh`.
