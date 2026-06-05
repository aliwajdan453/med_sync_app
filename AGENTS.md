# AGENTS.md

## Required Context

Before writing code in this repository, read:

1. `ai/docs/CODE_ARCHITECTURE.md`
2. `ai/PRD.md`
3. `ai/FEATURES.md`
4. `ai/DESIGN.md`
5. The specific files already present in the feature folder you are changing

Use `ai/docs/CODE_ARCHITECTURE.md` as the primary code architecture reference. Use `ai/PRD.md` for product scope and safety positioning. Use `ai/FEATURES.md` for feature-specific requirements, providers, models, edge cases, UI states, dependencies, and acceptance criteria.

`lib/features/auth/` is the reference implementation for this app. When architecting or adding any feature, study `auth` first and mirror how it is built across every layer:

- `models/`: Freezed models, a typed `*Failure`, and a `@freezed` form-state class with `@Default` fields. Clear nullable fields by passing `null`, never with `clearXxx` flags.
- `data/`: a repository interface (`abstract interface class`) plus its backend implementation. Map provider and platform exceptions into typed failures here, not in the UI.
- `state/`: `@riverpod` providers for dependency wiring, an action-focused controller (`@riverpod` Notifier with a private `_submit` helper and `ref.mounted` checks after every `await`), and pure validators.
- `views/` and `widgets/`: screens and feature widgets that read state and call controller methods. Controllers return a result; widgets own navigation and alerts.

Match the same layering, dependency direction (`views`/`widgets` to `state` to `data` to `models`), naming, and error handling for new features.

The layer guideline files specify the conventions within each layer. The `auth` feature is the worked example of how they fit together:

- State management (providers, notifiers, state classes) → `ai/rules/riverpod_guidelines.md`
- Widgets, screens, and UI → `ai/rules/flutter_widget_guidelines.md`
- Auth form screens → `ai/rules/auth_form_screen_guidelines.md`
- Visuals and the design system → `ai/DESIGN.md`, the Clinical Performance Lab design system

## MCP Tools: code-review-graph

This project uses the `code-review-graph` MCP server. Use its graph tools before broad file scanning when exploring code structure, reviewing changes, checking impact, or tracing dependencies.

Prefer graph tools for:

- Exploring code with `semantic_search_nodes` or `query_graph`.
- Reviewing changes with `detect_changes` and `get_review_context`.
- Checking blast radius with `get_impact_radius` and `get_affected_flows`.
- Tracing callers, callees, imports, and tests with `query_graph`.
- Understanding architecture with `get_architecture_overview` and `list_communities`.

After substantial feature work or plan-mode implementation work, run:

```sh
code-review-graph build --repo /Users/aliwajdan/development/flutter/portfolio/med_sync
```

Do not require this graph build for tiny copy edits, basic bug fixes, or isolated one-file changes unless the change affects shared architecture or routing.

## Product Positioning

MedSync is a wellness-focused medication routine tracker. It is not a medical device, clinical platform, treatment product, diagnostic tool, patient-monitoring product, or medical advice product.

Do not add copy, code comments, docs, analytics names, or feature behavior that implies diagnosis, treatment, clinical monitoring, health outcome improvement, or professional medical advice.

## Scope Rules

- Medication tracking is the core product.
- Supplements are part of the same routine model.
- V1 has no guest mode.
- V1 has no snooze.
- V1 missed-dose grace period is fixed at 1 hour.
- Caregiver sharing is future v1.5 or later.
- PDF export, advanced AI, advanced stats, and multiple caregiver support are future or Pro-phase features unless a direct user request changes scope.
- Backend details are intentionally flexible. Firebase is likely first, but do not couple widgets directly to Firebase APIs.
- RevenueCat owns subscription and entitlement behavior.

## Architecture Rules

- Use the feature-based structure under `lib/features/`. Use `lib/features/auth/` as the reference feature and mirror its `models/`, `data/`, `state/`, `views/`, and `widgets/` layering and patterns when adding features.
- Use shared infrastructure under `lib/core/` only when it is genuinely cross-feature.
- Keep `lib/main.dart` thin.
- Keep app composition in `lib/app/`.
- Use GoRouter from `lib/core/routing/`.
- Use Riverpod v3 with `riverpod_annotation` and `riverpod_generator`. Follow `ai/rules/riverpod_guidelines.md` for all provider, notifier, and state-class conventions.
- Follow `ai/rules/flutter_widget_guidelines.md` for all widget and screen conventions.
- Use Freezed and `json_serializable` for immutable persisted or transported models.
- Generated files belong under `lib/generated/`.
- Do not manually edit generated files.
- Do not use `flutter_hooks`.

## Business Rules

- Scheduled medications can have reminders, missed-dose logic, streak impact, adherence stats, and refill calculations.
- As-needed medications are manual logging only.
- As-needed medications must not create missed doses.
- As-needed medications must not break streaks.
- As-needed medications must not affect missed-dose penalties.
- A day is complete when all scheduled medications are Taken or intentionally Skipped.
- Missed scheduled items affect adherence and streak unless later resolved.
- Late Taken must be supported for missed items resolved later.
- OCR-assisted entry must create a draft that the user confirms before saving.
- Medication names should not appear in push notifications or future caregiver emails by default.

## Design Rules

Follow the Clinical Performance Lab design system:

- Light mode only.
- Warm white background.
- Primary `#FF8C42`.
- Text `#0D1B2A`.
- Label `#6B7A8D`.
- Card surface `#F8F6F3`.
- Teal `#3ABFBF` only for data visuals.
- Pill-shaped buttons.
- Tonal elevation only.
- No dark backgrounds.
- No glassmorphism.
- No borders as a primary visual style.
- No gradient blobs.
- Manrope for display and headlines.
- Inter for body and labels.

The list above is a summary. See `ai/DESIGN.md` for the full Clinical Performance Lab design system, and `ai/rules/flutter_widget_guidelines.md` for how to apply it in widgets.

## Verification

For code changes, run:

```sh
dart format lib test
flutter analyze
flutter test
```

Do not run `flutter build` unless the user explicitly asks for a build.

## Communication

Never validate claims just because the user made them. Treat claims as hypotheses and correct bad assumptions directly.

Never use em dashes in responses or documentation edits.
