# MedSync Code Architecture

## Purpose

This document is the code architecture reference for MedSync agents and developers. Use it with `ai/PRD.md` and `ai/FEATURES.md` before writing app code.

MedSync is a wellness-focused medication routine tracker. Code, naming, copy, and feature behavior must avoid clinical, diagnostic, treatment, patient-monitoring, HIPAA-heavy, or FDA-heavy positioning.

## Product Sources Of Truth

- `ai/PRD.md`: product scope, compliance guardrails, release phases, and acceptance criteria.
- `ai/FEATURES.md`: feature list, implementation order, suggested models, providers, dependencies, edge cases, and UI states.
- `ai/docs/CODE_ARCHITECTURE.md`: code structure, boundaries, and engineering conventions.
- `ai/DESIGN.md`: Clinical Performance Lab visual system and screen-design rules.
- `AGENTS.md`: repo-level instructions for coding agents.

If these files conflict, prefer the newest direct user request first, then `AGENTS.md`, then this architecture document, then `ai/PRD.md`, then `ai/FEATURES.md`.

## Platform Scope

The Flutter project currently includes Android and iOS scaffolding. Product requirements position v1 as iOS-first for App Store distribution. Do not remove Android scaffolding unless explicitly requested.

## Top-Level Structure

```text
ai/
  PRD.md
  FEATURES.md
  docs/
    CODE_ARCHITECTURE.md
android/
ios/
lib/
  app/
  core/
  features/
test/
```

## Flutter App Root

`lib/main.dart` should stay thin:

- Wrap the app in `ProviderScope`.
- Run `MedSyncApp`.
- Do not place routing, theme, feature logic, Firebase setup, or subscription setup directly in `main.dart` unless initialization order requires a tiny bootstrap call.

`lib/app/` owns app composition:

- `MedSyncApp`
- app-level initialization shell when needed
- app-level dependency wiring that does not belong to one feature

## Core Folder Ownership

`lib/core/` contains reusable app infrastructure only. It must not contain medication business rules that belong to a feature.

- `core/constants/`: app-wide constants and product limits, such as free medication limit and fixed grace period.
- `core/errors/`: shared failure types and exception mapping.
- `core/extensions/`: small Dart or Flutter extensions used across features.
- `core/routing/`: GoRouter setup, route names, route guards.
- `core/services/`: cross-feature services such as clock, analytics, notifications, OCR abstraction, RevenueCat abstraction, and backend client wrappers.
- `core/theme/`: Clinical Performance Lab theme, color tokens, typography, component themes.
- `core/utils/`: pure helpers that are not feature-specific.
- `core/widgets/`: shared UI widgets used by multiple features.

Do not dump feature repositories or controllers into `core/services/` just because they talk to Firebase. Feature ownership still matters.

## Feature Folder Ownership

Use feature-based folders under `lib/features/`.

Do not pre-create empty feature folders. Add each feature folder only when implementation for that feature starts.

Recommended internal shape for substantial features:

```text
lib/features/<feature>/
  application/
  data/
  domain/
  presentation/
```

Use only the folders a feature actually needs. Empty architecture theater is not useful.

- `domain/`: entities, value objects, product rules, pure calculations.
- `data/`: repositories, DTO mapping, backend implementations.
- `application/`: Riverpod providers, controllers, use-case orchestration.
- `presentation/`: screens and widgets.

For the MVP auth layer, use a simpler feature shape under `lib/features/auth/`:

```text
lib/features/auth/
  models/
  data/
  state/
  views/
  widgets/
```

This MVP auth folder owns email auth, Google Sign-In, Apple Sign-In, email verification, forgot password email requests, profile display/edit, logout, and account deletion. Do not split `features/account` or `features/profile` until account management grows beyond this basic auth surface.

`lib/features/auth/` is the reference implementation for the app. Mirror its layering, dependency direction, typed failures, Freezed form state, action-focused controller with a private `_submit` helper and `ref.mounted` checks, and repository interface plus backend implementation when building new features. Use the fuller `application/`, `domain/`, `data/`, and `presentation/` split only when a feature is large enough to need it, and keep the same patterns regardless of the folder names. For within-layer conventions, follow `ai/rules/riverpod_guidelines.md` for state and `ai/rules/flutter_widget_guidelines.md` for UI.

Initial feature ownership:

- `features/auth`: email auth, Apple Sign In, Google Sign In, verification, forgot password email requests, profile, logout, and account deletion for the MVP auth layer.
- `features/onboarding`: welcome and onboarding screens.
- `features/home`: today dashboard shell.
- `features/medications`: medication CRUD and medication detail/edit.
- `features/reminders`: reminder configuration and notification scheduling for scheduled medications.
- `features/dose_tracking`: dose logs, Taken, Skipped, Missed, Late Taken, grace period logic.
- `features/refills`: pill-count refill info and estimated runout calculation.
- `features/progress`: global streak and per-medication adherence views.
- `features/subscriptions`: RevenueCat offerings, purchases, restore, entitlement state.
- `features/settings`: notification settings and local app settings.
- `features/account`: future account management expansion if it outgrows the MVP auth folder.
- `features/ocr`: OCR-assisted medication draft extraction and confirmation flow.
- `features/caregiver`: future v1.5 caregiver invite and read-only access.
- `features/pdf_export`: future Pro PDF export.
- `features/insights`: future pattern-based smart insights.

## State Management

Use Riverpod v3.

- Use `flutter_riverpod` for widget integration.
- Use `riverpod_annotation` and `riverpod_generator` for generated providers.
- Keep provider names aligned with `ai/FEATURES.md`.
- Do not use `flutter_hooks`.
- Do not put mutable UI state in global singletons.
- Keep controller methods small and action-focused.

Preferred provider names from the feature spec:

- `authControllerProvider`
- `currentUserProvider`
- `medicationRepositoryProvider`
- `medicationListProvider`
- `addMedicationControllerProvider`
- `doseLogRepositoryProvider`
- `todayDoseScheduleProvider`
- `doseActionControllerProvider`
- `adherenceSummaryProvider`
- `streakProvider`
- `refillReminderProvider`
- `notificationSettingsProvider`
- `ocrMedicationControllerProvider`
- `subscriptionControllerProvider`
- `entitlementProvider`
- `accountDeletionControllerProvider`
- `caregiverInviteControllerProvider`
- `smartInsightsProvider`

## Models And Generated Files

Use Freezed for immutable models and `json_serializable` for serialization when models need persistence, backend transport, or generated copy methods.

Suggested model names:

- `UserProfile`
- `Medication`
- `MedicationSchedule`
- `DoseLog`
- `ReminderConfig`
- `RefillInfo`
- `AdherenceSummary`
- `SubscriptionEntitlement`
- `OcrMedicationDraft`
- `NotificationPreference`
- `CaregiverInvite`
- `CaregiverAccess`
- `SmartInsight`

Generated files should output under `lib/generated/` according to `build.yaml`. The folder does not need to exist until code generation creates output. Do not manually edit generated files.

Source files that use generated parts must point to the mirrored generated path under `lib/generated/`. For example, a file in `lib/features/auth/models/` uses parts such as `../../../generated/features/auth/models/user_profile.freezed.dart`.

## Auth Error And Form Contract

Firebase and social provider exceptions must be mapped into typed auth failures before reaching UI widgets.

- Common Firebase codes such as `invalid-email`, `email-already-in-use`, `weak-password`, `wrong-password`, `invalid-credential`, `too-many-requests`, `network-request-failed`, and `requires-recent-login` map to explicit user-safe messages.
- Form validation errors must be field-level where possible, using the same keys as the form fields.
- Unknown exceptions may keep diagnostic details in the failure object, but visible copy must stay recoverable and non-clinical.
- Shared auth text fields live in `lib/core/widgets/` and must support labels, errors, focus traversal, keyboard type, text input action, autofill hints, secure entry, and accessible readable errors.

## Core Business Rules

Scheduled medications:

- Can have reminders.
- Can become Missed.
- Affect streaks and adherence.
- Participate in refill calculations when refill info exists.

As-needed medications:

- Are manual logging only.
- Must not schedule reminders.
- Must not become Missed.
- Must not break streaks.
- Must not count as missed-dose penalties.

Dose statuses:

- Taken.
- Skipped.
- Missed.
- Late Taken as an internal or visible state when a missed item is resolved later.

V1 rules:

- No snooze.
- Fixed 1-hour missed-dose grace period.
- A day is complete when all scheduled medications are Taken or intentionally Skipped.
- Missed items affect adherence and streak unless later resolved.
- Refill reminders are pill-count based.

## Routing

Use GoRouter in `lib/core/routing/`.

- Define stable route names and paths.
- Keep route declarations thin.
- Put screen implementation inside feature `presentation/` folders.
- Add route guards only when auth and entitlement state exist.

## Design System

Clinical Performance Lab:

Use `ai/DESIGN.md` as the detailed design source before building or changing screens.

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

If fonts are not bundled yet, keep the theme names in place and add font assets in a dedicated task.

## Backend Boundary

Backend details are intentionally flexible. Firebase is the likely initial choice for Auth, Firestore, FCM, Cloud Functions, and Cloud Scheduler, but feature code should depend on repositories and service abstractions, not Firebase APIs directly from widgets.

Repository interfaces should live near the feature that owns the data. Backend implementations can live in feature `data/` folders or shared service wrappers when genuinely cross-feature.

## Subscription Boundary

RevenueCat owns subscription purchase and entitlement state.

- Free tier: up to 5 medications, 90 days of history, refill reminders, basic streaks, basic progress.
- Pro tier: unlimited medications, advanced stats entry point, future caregiver sharing, future AI insights, future PDF export, future multiple caregiver support.

Do not hardcode entitlement assumptions inside UI widgets. Read entitlement from `entitlementProvider`.

## Privacy And Safety

- Avoid medication names in push notifications by default.
- Future caregiver emails and notifications should avoid medication names by default.
- OCR output must be confirmed by the user before saving.
- Do not provide dosing recommendations.
- Do not describe insights as clinical advice.
- Account deletion must remain supported.

## Testing And Verification

Before claiming work is complete, run the narrowest useful verification:

```sh
flutter analyze
flutter test
```

For pure business rules, write unit tests close to the relevant feature. For screens, add widget tests that verify visible state and critical interactions.

Do not run `flutter build` unless the task explicitly asks for a build.

## Implementation Order

Follow the implementation order from `ai/FEATURES.md` unless a user request narrows the task:

1. Theme and routing.
2. Auth shell.
3. Home shell.
4. Medication model and manual add flow.
5. Medication list.
6. Dose schedule and today dashboard.
7. Taken, Skipped, Missed, and Late Taken logic.
8. Streak and adherence calculations.
9. Refill tracking.
10. Notification settings.
11. OCR-assisted entry.
12. RevenueCat entitlement structure.
13. Pro screen.
14. Account deletion.
15. Progress screen.
16. Future caregiver scaffolding only if needed.

## Coding Rules For Agents

- Read `AGENTS.md`, `ai/docs/CODE_ARCHITECTURE.md`, `ai/PRD.md`, and the relevant section of `ai/FEATURES.md` before implementing a feature.
- Keep edits scoped to the requested feature.
- Do not overbuild future caregiver, AI, PDF export, or advanced stats work in v1 tasks.
- Keep UI copy wellness-focused and non-clinical.
- Prefer small focused files over large mixed-purpose files.
- Use generated providers and models where they add real value.
- Do not introduce `flutter_hooks`.
- Do not manually edit generated files.
- Run formatter, analyzer, and relevant tests after code changes.
