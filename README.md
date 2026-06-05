# MedSync

MedSync is a wellness-focused Flutter medication routine and adherence tracking app. The product is positioned as a personal routine tracker, not a clinical tool, medical device, patient-monitoring product, treatment product, or medical advice product.

The repository is scaffolded for Android and iOS because the initial setup request included both platforms. Product launch requirements currently position v1 as iOS-first. Treat that as a product decision, not a reason to delete Android scaffolding unless the scope is explicitly changed.

## Source Documents

Read these before implementing product behavior:

- `ai/PRD.md`: product requirements, scope, safety positioning, release phases, and acceptance criteria.
- `ai/FEATURES.md`: implementation-oriented feature breakdown, provider names, model names, folder guidance, and release priorities.
- `ai/docs/CODE_ARCHITECTURE.md`: code architecture, folder ownership, state management, model generation, routing, and verification rules.
- `ai/DESIGN.md`: Clinical Performance Lab design system details for screen and component work.

## Current Foundation

- Flutter app shell wired through `ProviderScope`.
- `MaterialApp.router` using GoRouter.
- Clinical Performance Lab light theme in `lib/core/theme/`.
- Feature folders are created one by one as features are implemented. Current shell code lives under `lib/features/home/`.
- Shared infrastructure currently lives under `lib/core/routing/` and `lib/core/theme/`.
- Generated output convention points to `lib/generated/`; the folder can be created by code generation when needed.
- Riverpod v3, `riverpod_annotation`, `riverpod_generator`, Freezed, and `json_serializable` are installed.
- `flutter_hooks` is intentionally not used.

## Product Guardrails

- Medication tracking is the core product.
- Scheduled medications can create reminders, missed doses, streak impact, adherence stats, and refill calculations.
- As-needed medications are manual logging only.
- As-needed medications must not create missed doses, break streaks, or affect missed-dose penalties.
- OCR-assisted entry must create an editable draft. Never save OCR output without user confirmation.
- V1 has no guest mode and no snooze.
- V1 missed-dose grace period is fixed at 1 hour.
- Notifications and future caregiver emails should avoid medication names by default.
- Caregiver sharing, advanced AI, PDF export, multiple caregivers, and advanced stats are future or Pro-phase work unless a later task explicitly changes scope.

## Firebase Setup

The Firebase config files are not committed to this repo. To run the app locally:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password) and **Firestore**
3. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
4. Run: `flutterfire configure --project=<your-project-id>`

This generates `lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist` locally.

Deploy the Firestore security rules: `firebase deploy --only firestore:rules`

## Development Commands

Use these during setup and implementation:

```sh
flutter analyze
flutter test
```

Do not run a build unless the task asks for it. The current app is a wired foundation shell, not a finished product.
