# MedSync Agent Guide

Read `AGENTS.md` first. It is the primary instruction file for this repo and covers product scope, architecture rules, business rules, design rules, and verification commands.

## Reference implementation: the `auth` feature

`lib/features/auth/` is the model to follow when architecting or adding any feature. Study it first and mirror its layering across data, state, and UI:

- `models/`: Freezed models, a typed `*Failure`, and a `@freezed` form-state class with `@Default` fields (clear nullable fields with `null`, never `clearXxx` flags).
- `data/`: a repository interface plus its backend implementation, with provider and platform exceptions mapped to typed failures.
- `state/`: `@riverpod` providers, an action-focused controller (Notifier with a private `_submit` helper and `ref.mounted` checks), and pure validators.
- `views/` and `widgets/`: screens and feature widgets that read state and call controller methods; controllers return a result and widgets own navigation.

Follow the same layering, dependency direction (`views`/`widgets` to `state` to `data` to `models`), naming, and error handling for new features.

## Guidelines: conventions within each layer

Use these for the rules inside each layer. The `auth` feature shows how they fit together:

- State management (providers, notifiers, state classes) → `ai/rules/riverpod_guidelines.md`
- UI (widgets, screens, layout) → `ai/rules/flutter_widget_guidelines.md`
- Design system (colors, typography, spacing, surfaces, component styling) → `ai/DESIGN.md`, the Clinical Performance Lab design system

<!-- code-review-graph MCP tools -->
## MCP Tools: code-review-graph

**IMPORTANT: This project has a knowledge graph. ALWAYS use the
code-review-graph MCP tools BEFORE using Grep/Glob/Read to explore
the codebase.** The graph is faster, cheaper (fewer tokens), and gives
you structural context (callers, dependents, test coverage) that file
scanning cannot.

### When to use graph tools FIRST

- **Exploring code**: `semantic_search_nodes` or `query_graph` instead of Grep
- **Understanding impact**: `get_impact_radius` instead of manually tracing imports
- **Code review**: `detect_changes` + `get_review_context` instead of reading entire files
- **Finding relationships**: `query_graph` with callers_of/callees_of/imports_of/tests_for
- **Architecture questions**: `get_architecture_overview` + `list_communities`

Fall back to Grep/Glob/Read **only** when the graph doesn't cover what you need.

### Key Tools

| Tool | Use when |
|------|----------|
| `detect_changes` | Reviewing code changes — gives risk-scored analysis |
| `get_review_context` | Need source snippets for review — token-efficient |
| `get_impact_radius` | Understanding blast radius of a change |
| `get_affected_flows` | Finding which execution paths are impacted |
| `query_graph` | Tracing callers, callees, imports, tests, dependencies |
| `semantic_search_nodes` | Finding functions/classes by name or keyword |
| `get_architecture_overview` | Understanding high-level codebase structure |
| `refactor_tool` | Planning renames, finding dead code |

### Workflow

1. The graph auto-updates on file changes (via hooks).
2. Use `detect_changes` for code review.
3. Use `get_affected_flows` to understand impact.
4. Use `query_graph` pattern="tests_for" to check coverage.

### Substantial Work Completion

After substantial feature work or plan-mode implementation work, run:

```sh
code-review-graph build --repo /Users/aliwajdan/development/flutter/portfolio/med_sync
```

Do not require this graph build for tiny copy edits, basic bug fixes, or isolated one-file changes unless the change affects shared architecture or routing.
