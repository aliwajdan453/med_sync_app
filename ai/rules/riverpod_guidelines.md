# Riverpod State Management Guidelines

Rules for every agent writing state management in this codebase. Companion to `flutter_widget_guidelines.md` — that file owns the widget layer, this file owns everything below it.

This codebase uses Riverpod v3 (`flutter_riverpod` 3.x, `riverpod_annotation` 4.x) with code generation. Every rule below assumes that stack.

---

## 1. Code Generation — The Only Way

Every provider and notifier is created with the `@riverpod` annotation and `riverpod_annotation`. Never write a provider by hand.

Every file that defines an annotated provider or a freezed class must declare its part file at the top. The generated file always lives under `lib/generated/`, mirroring the source file's path relative to `lib/`:

```dart
// Source: lib/features/medications/application/medication_controllers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/medications/application/medication_controllers.g.dart';
```

```dart
// Source: lib/features/medications/application/medication_form_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../generated/features/medications/application/medication_form_state.freezed.dart';
```

The relative path always climbs from the source file up to `lib/`, then descends into `lib/generated/` along the same folder tree.

After any change to an annotated file, regenerate:

```shell
dart run build_runner build --delete-conflicting-outputs
```

---

## 2. Provider Types

Use the right tool for the job. The annotation and return type on `build()` determine which provider Riverpod generates.

| What you need | How to write it | Generated type |
|---|---|---|
| Derived/computed value | `@riverpod` function returning `T` | `Provider<T>` |
| Single async fetch | `@riverpod` function returning `Future<T>` | `FutureProvider<T>` |
| Stream of data | `@riverpod` function returning `Stream<T>` | `StreamProvider<T>` |
| Mutable sync state | `@riverpod` class, `build()` returns `T` | `NotifierProvider<_, T>` |
| Mutable async state | `@riverpod` class, `build()` returns `Future<T>` | `AsyncNotifierProvider<_, T>` |

### Derived value (read-only, no mutation)

```dart
@riverpod
List<Medication> activeMedications(Ref ref) {
  final all = ref.watch(medicationListProvider).valueOrNull ?? [];
  
  return all.where((m) => m.isActive).toList();
}
```

### Async fetch (read-only)

```dart
@riverpod
Future<UserProfile> userProfile(Ref ref) async {
  final uid = ref.watch(currentUserIdProvider);
  
  return ref.read(userRepositoryProvider).fetchProfile(uid);
}
```

### Mutable sync state — `Notifier`

Use for UI-local state that is synchronous: form state, selection state, toggles.

```dart
@riverpod
class MedicationFormController extends _$MedicationFormController {
  
  @override
  MedicationFormState build() => const MedicationFormState();

  void clearFailure() {
    state = state.copyWith(failure: null);
  }
}
```

### Mutable async state — `AsyncNotifier`

Use when the initial load is async (e.g. fetching a list from an API).

```dart
@riverpod
class MedicationList extends _$MedicationList {
  @override
  Future<List<Medication>> build() async {
    return ref.read(medicationRepositoryProvider).fetchAll();
  }
}
```

---

## 3. `build()` Must Be Pure

`build()` computes and returns the initial state. It must never produce side effects. Riverpod re-runs `build()` every time a watched dependency changes or the provider is invalidated, so it has to be safe to run many times and deterministic: same inputs, same output.

Allowed inside `build()`:
- `ref.watch` / `ref.read` of other providers.
- `await`-ing async data and returning it.
- Registering `ref.onDispose`, `ref.listen`, `ref.keepAlive`.

Forbidden inside `build()`:
- Assigning to `state` (return the value instead).
- Calling a method that mutates another provider's state.
- Navigation, dialogs, snackbars, or anything touching `BuildContext`.
- Firing a side effect such as logging a user action or analytics event.

```dart
@override
Future<List<Medication>> build() async {
  // WRONG: side effect inside build()
  ref.read(analyticsProvider).logScreenView();
  
  return ref.read(medicationRepositoryProvider).fetchAll();
}
```

Side effects, mutations, and navigation belong in notifier methods or in `ref.listen` callbacks, never in `build()`.

---

## 4. Notifier Design Rules

**`build()` is the initializer, not the constructor.** It runs once when the provider is first read (or after it is invalidated). Put all setup logic here — not in a separate `init()` method.

**Methods represent actions, not state transitions.** Name them after what the user or system is doing:

```dart
// CORRECT
Future<bool> save(MedicationFormInput input) async { ... }

void clearFailure() { ... }

Future<bool> archive() async { ... }

// WRONG — describes state, not intent
void setSubmitting(bool value) { ... }
void emitError(Failure f) { ... }
```

**Always check `ref.mounted` after every `await` before touching `state`:**

```dart
Future<bool> save(MedicationFormInput input) async {
  state = state.copyWith(isSubmitting: true);

  try {
    await ref.read(medicationRepositoryProvider).create(input);

    if (ref.mounted) state = state.copyWith(isSubmitting: false);
    
    return true;
  } catch (e) {
    if (ref.mounted) {
      state = state.copyWith(isSubmitting: false, failure: Failure.from(e));
    }
    
    return false;
  }
}
```

**Methods that trigger navigation or show alerts should return a meaningful value** (`bool` for success/failure, the created entity's ID, etc.) so the widget layer can react without reaching into state:

```dart
// Widget calls:
final success = await ref.read(addMedicationControllerProvider.notifier).save(input);

if (success && context.mounted) ref.read(appNavigatorProvider).pop();
```

The notifier returns the result; the widget owns the navigation (see §17).

---

## 5. Mutating `AsyncNotifier` State

An `AsyncNotifier` holds an `AsyncValue`. Never assign a raw value to `state`; always wrap it in `AsyncData`, `AsyncLoading`, or `AsyncError`.

Wrap async mutations in `AsyncValue.guard` so a thrown error lands in `AsyncError` automatically instead of escaping:

```dart
Future<void> refresh() async {
  state = const AsyncLoading();
  
  state = await AsyncValue.guard(
    () => ref.read(medicationRepositoryProvider).fetchAll(),
  );
}
```

Preserve the previous data during a reload so the UI keeps showing content while the new load runs:

```dart
state = const AsyncLoading<List<Medication>>().copyWithPrevious(state);
```

For optimistic updates, apply the new value immediately and roll back on failure:

```dart
Future<void> archive(String id) async {
  final previous = state;
  
  state = AsyncData([
    for (final m in state.valueOrNull ?? <Medication>[])
      if (m.id != id) m,
  ]);
  
  try {
    await ref.read(medicationRepositoryProvider).archive(id);
  } on Object catch (error, stackTrace) {
    state = AsyncError(error, stackTrace).copyWithPrevious(previous);
  }
}
```

Read the current value with `state.valueOrNull` (nullable) or `state.requireValue` (only when the value is guaranteed loaded). Never use `state.value!`.

---

## 6. State Classes

Every notifier with non-trivial state is a `@freezed` class. Never write `copyWith`, `==`, or `hashCode` by hand. Never use `Equatable`.

```dart
// lib/features/medications/application/medication_form_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../generated/features/medications/application/medication_form_state.freezed.dart';

@freezed
class MedicationFormState with _$MedicationFormState {
  const factory MedicationFormState({
    @Default(false) bool isSubmitting,
    MedicationFailure? failure,
    String? savedMedicationId,
  }) = _MedicationFormState;
}
```

Freezed generates `copyWith` automatically. To clear a nullable field, pass `null` directly — no `clearXxx` flags needed:

```dart
// Set isSubmitting, clear failure
state = state.copyWith(isSubmitting: true, failure: null);

// Clear savedMedicationId after navigation
state = state.copyWith(savedMedicationId: null);
```

Rules:
- Always `@freezed` with `const factory` constructor.
- Use `@Default(value)` for fields that have a non-null default.
- The `const factory` produces a valid initial state with no arguments when all fields have defaults or are nullable.
- Never hand-roll a `copyWith` with manual `clearXxx` boolean flags. Freezed already distinguishes "not passed" from "passed `null`".
- Never use an `enum` as the primary state type for screens — use a dedicated `@freezed` class with typed fields.
- State classes have no Riverpod dependency — they belong in `*_state.dart` with only `freezed_annotation` imported.
- State classes are ephemeral UI/notifier state, never persisted or transported. Do not add `json_serializable`, `fromJson`, or `toJson` to a state class. Serialization belongs to domain/data models (see §22), not to provider state objects.

---

## 7. Provider Families

When a provider depends on an external ID or parameter, add it to `build()`:

```dart
@riverpod
class MedicationDetail extends _$MedicationDetail {
  
  @override
  Future<Medication> build(String medicationId) async {
    return ref.read(medicationRepositoryProvider).fetchById(medicationId);
  }

  Future<bool> archive() async {
    // medicationId is available as a field — no need to pass it again
    await ref.read(medicationRepositoryProvider).archive(medicationId);
    
    return true;
  }
}
```

Call-site usage:

```dart
// Watch a specific medication
ref.watch(medicationDetailProvider('med-123'))

// Call a method on the notifier for a specific ID
ref.read(medicationDetailProvider('med-123').notifier).archive()
```

Rules for family parameters:
- Parameters must be stable and value-equal. Pass primitives, `Record`s, or value-equal `@freezed` objects only. Riverpod caches one provider instance per argument value, comparing arguments with `==`.
- Never pass a `BuildContext`, a callback, or a mutable object as a family parameter. Unstable arguments fail `==` and silently spawn a new provider instance on every read.
- Keep the parameter count small. If a `build()` needs many inputs, pass one `@freezed` parameter object instead of a long positional list.

---

## 8. ConsumerWidget — The Default

Use `ConsumerWidget` everywhere a `StatelessWidget` would be used. It is the direct equivalent.

```dart
class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicationListProvider);

    return BaseScaffold(
      appBar: const BasicNavBarWidget(title: 'Medications'),
      child: state.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => TextErrorWidget(message: e.toString()),
        data: (medications) {
          if (medications.isEmpty) {
            return const TextErrorWidget(message: 'No medications found');
          }
          return _MedicationListView(medications: medications);
        },
      ),
    );
  }
}
```

---

## 9. ConsumerStatefulWidget — Only When Needed

Use `ConsumerStatefulWidget` only when the widget needs local lifecycle that `ConsumerWidget` cannot provide: `AnimationController`, `TextEditingController`, `FocusNode`, `ScrollController`, `initState`-based setup, or `dispose`.

```dart
class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key});

  @override
  ConsumerState<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicationFormControllerProvider);

    // ...
  }
}
```

Never use `ConsumerStatefulWidget` just to get access to `ref` in `initState`. Use `ref.read` — it is available in `initState` via `ref`.

---

## 10. ref.watch vs ref.read vs ref.listen

**`ref.watch(provider)`** — inside `build()` only. Subscribes the widget to the provider; it rebuilds whenever the value changes.

**`ref.read(provider)`** — inside callbacks, methods, and `initState`. Does not subscribe. Never call in `build()`.

**`ref.read(provider.notifier)`** — to call a method on a `Notifier` or `AsyncNotifier`. This is how the widget layer triggers actions.

**`ref.listen(provider, (prev, next) { })`** — inside `build()` for side effects (showing snackbars, navigating). The direct equivalent of `BlocListener`. Put only side effects in the callback, never layout.

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Side effects — fires when state changes
  ref.listen(addMedicationControllerProvider, (prev, next) {
    if (next.failure != null) AppAlerts.showMessage(next.failure!.message);

    if (next.savedMedicationId != null) ref.read(appNavigatorProvider).pop();
  });

  // Reactive subscription — rebuilds widget
  final state = ref.watch(addMedicationControllerProvider);

  return _MedicationForm(isSubmitting: state.isSubmitting);
}
```

**The rule:** `watch` for layout data, `listen` for side effects, `read` for actions. Never mix them up.

---

## 11. Granular Rebuilds with `.select()`

A widget that calls `ref.watch(provider)` rebuilds on every state change. When the widget needs only one field, watch that field with `.select` so it rebuilds only when that field changes:

```dart
final isSubmitting = ref.watch(
  addMedicationControllerProvider.select((state) => state.isSubmitting),
);
```

`.select` also works through an `AsyncValue`:

```dart
final count = ref.watch(
  medicationListProvider.select((value) => value.valueOrNull?.length ?? 0),
);
```

Rules:
- Select a value that is cheap to compare with `==`. Never select a freshly allocated collection or object each build, or the comparison always fails and `.select` gives no benefit.
- `.select` is for reading. Method calls still go through `ref.read(provider.notifier)`.
- Reach for `.select` only when a widget over-rebuilds. Do not pre-emptively wrap every read.

---

## 12. AsyncValue UI Pattern

For any `AsyncNotifierProvider` or `FutureProvider`, always use `.when()`:

```dart
final state = ref.watch(medicationListProvider);

return state.when(
  loading: () => const Center(child: LoadingIndicator()),
  error: (error, _) => TextErrorWidget(message: error.toString()),
  data: (medications) => _MedicationListView(medications: medications),
);
```

**Empty state lives inside `data:`**, not as a separate AsyncValue case:

```dart
data: (medications) {
  if (medications.isEmpty) {
    return const TextErrorWidget(message: 'No medications found');
  }
  
  return _MedicationListView(medications: medications);
},
```

**Skip the loading indicator on background refreshes** using `skipLoadingOnReload`:

```dart
ref.watch(medicationListProvider).when(
  skipLoadingOnReload: true,
  loading: () => const Center(child: LoadingIndicator()),
  error: (e, _) => TextErrorWidget(message: e.toString()),
  data: (medications) => _MedicationListView(medications: medications),
)
```

**For sync `Notifier` state**, read the state directly — no `.when()` needed:

```dart
final state = ref.watch(medicationFormControllerProvider);

// state is MedicationFormState, not AsyncValue — access fields directly
final isSubmitting = state.isSubmitting;
```

Use `valueOrNull` to read an `AsyncValue` outside of `.when()` (it is `null` while loading or on error). Use `requireValue` only when the value is guaranteed present. Never use `value!`.

---

## 13. Provider Invalidation

`ref.invalidate(provider)` resets a provider back to its `build()` state. Use it after mutations to force a refresh of dependent providers:

```dart
// After successfully creating a medication, invalidate the list so it refetches
ref.invalidate(medicationListProvider);

// Invalidate a family member specifically
ref.invalidate(medicationDetailProvider(medicationId));
```

`ref.invalidateSelf()` inside a notifier resets itself:

```dart
Future<void> reset() async {
  ref.invalidateSelf();
}
```

Do not use `ref.refresh()` — it invalidates and immediately reads. Prefer `ref.invalidate()` and let the UI trigger the read via `watch`.

---

## 14. Accessing Other Providers

Inside a notifier, always use `ref.read` (not `ref.watch`) to access other providers:

```dart
@riverpod
class AddMedicationController extends _$AddMedicationController {
  @override
  MedicationFormState build() => const MedicationFormState();

  Future<bool> save(MedicationFormInput input) async {
    // ref.read — one-time access inside an async method
    final repo = ref.read(medicationRepositoryProvider);
    final uid = ref.read(currentUserIdProvider);

    final result = await repo.create(ownerUid: uid, input: input);

    if (!ref.mounted) return true;

    ref.invalidate(medicationListProvider);

    state = state.copyWith(savedMedicationId: result.id);

    return true;
  }
}
```

Using `ref.watch` inside a notifier `build()` is allowed only if the notifier truly needs to reset and rebuild when another provider changes — which is rare and resets all in-progress state. Default to `ref.read`.

When a notifier must *react* to another provider changing without resetting itself, register `ref.listen` inside `build()` and mutate state in the callback:

```dart
@override
MedicationFormState build() {
  ref.listen(currentUserProvider, (previous, next) {
    if (next.valueOrNull == null) state = const MedicationFormState();
  });
  
  return const MedicationFormState();
}
```

---

## 15. Lifecycle and Cleanup

Every `@riverpod` provider is `autoDispose` by default: it is destroyed when nothing watches it. Design for this.

Release any resource a provider creates with `ref.onDispose`:

```dart
@riverpod
Stream<int> ticker(Ref ref) {
  final controller = StreamController<int>();
  
  final timer = Timer.periodic(
    const Duration(seconds: 1),
    (t) => controller.add(t.tick),
  );
  
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  
  return controller.stream;
}
```

To cache an async result after a successful load while still allowing disposal, call `ref.keepAlive()` and hold the link so failures are not cached:

```dart
@riverpod
Future<RemoteConfig> remoteConfig(Ref ref) async {
  final link = ref.keepAlive();
  
  try {
    return await ref.read(configServiceProvider).load();
  } on Object {
    link.close(); // do not cache failures; allow retry on next read
  
    rethrow;
  }
}
```

Use `@Riverpod(keepAlive: true)` only for true app-lifetime singletons (repositories, clients, services). Prefer `autoDispose` plus `ref.keepAlive()` for anything that can be reclaimed when idle.

---

## 16. Scoping Providers to a Screen

Riverpod providers are global by default. To scope a provider's lifetime to a screen (equivalent to `BlocProvider` scoped to a widget subtree), use `ProviderScope` with an override, or rely on `autoDispose`.

**`autoDispose` is the default with code gen** — all `@riverpod` annotations generate `autoDispose` providers. This means the provider is destroyed when the last widget watching it unmounts. No manual cleanup needed.

To keep a provider alive (e.g. a shared service), mark it `@Riverpod(keepAlive: true)`:

```dart
@Riverpod(keepAlive: true)
MedicationRepository medicationRepository(Ref ref) {
  return MedicationRepository(ref.read(apiClientProvider));
}
```

---

## 17. Provider Layer is UI-Agnostic

Providers, notifiers, and state classes never import Flutter UI. No `package:flutter/material.dart`, no `BuildContext`, no `Widget`, no `Theme`, no navigation, no snackbars.

- A notifier method may return a result (`bool`, an id, a value object) so the widget can react. It must not perform the reaction itself.
- Never pass `BuildContext` into a provider or a notifier method.
- `package:flutter/foundation.dart` is acceptable only for non-UI primitives that genuinely belong in the application layer (for example `defaultTargetPlatform`).

This keeps the application layer testable without a widget tree and stops UI concerns from leaking into state.

### Navigation

Navigation goes through go_router and the app-wide navigation provider — never `AppNavigator` static calls, never `context.go` / `Navigator.of(context)`, and never from inside a notifier. A notifier only updates state or returns a result. There are exactly two places navigation happens:

**1. Reactive redirection — driven by providers through the router.** Session and auth based routing lives in the go_router `redirect`, which re-evaluates whenever a watched provider changes. A notifier that changes auth state does nothing more; the router reacts. The router itself is a provider that listens to the providers it depends on:

```dart
@riverpod
GoRouter appRouter(Ref ref) {
  final refresh = _RouterRefreshNotifier();
  ref
    ..onDispose(refresh.dispose)
    ..listen(currentUserProvider, (_, _) => refresh.notify());

  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider).valueOrNull;
  
      // return a route path derived from provider state, or null to stay
    },
    routes: [...],
  );
}
```

**2. Imperative navigation — in the widget layer, after a notifier returns.** Read the app-wide navigation provider with `ref.read` and call it once the action reports success:

```dart
final saved = await ref.read(addMedicationControllerProvider.notifier).save(input);
if (saved && context.mounted) ref.read(appNavigatorProvider).pop();
```

Use `ref.listen` when navigation should fire from a state change rather than a direct return value:

```dart
ref.listen(editMedicationControllerProvider(medicationId), (previous, next) {
  if (next.didCompleteDelete) {
    ref.read(appNavigatorProvider).go(MedicationsListScreen.routePath);
  }
});
```

Always read the navigator with `ref.read(appNavigatorProvider)` (an action, never `ref.watch`), and guard `BuildContext` use with `context.mounted` after an `await`.

---

## 18. File and Folder Structure

Mirror the screen structure from `flutter_widget_guidelines.md`. Each feature folder has an `application/` layer for source files. All generated files live under `lib/generated/` at the matching path — never alongside the source.

```
lib/
  features/
    medications/
      application/
        medication_providers.dart       # FutureProviders, StreamProviders, derived values
        medication_controllers.dart     # Notifiers / AsyncNotifiers with mutations
        medication_form_state.dart       # @freezed state class
      domain/
        medication.dart
        medication_failure.dart
      data/
        medication_repository.dart

  generated/
    features/
      medications/
        application/
          medication_providers.g.dart        # generated — do not edit
          medication_controllers.g.dart      # generated — do not edit
          medication_form_state.freezed.dart  # generated — do not edit
```

Rules:
- Providers (read-only) go in `*_providers.dart`.
- Notifiers with mutation methods go in `*_controllers.dart`.
- State classes go in a separate `*_state.dart` — only `freezed_annotation` imported, no Riverpod dependency.
- Never put business logic inside a notifier — delegate to the repository/service via `ref.read`.
- Never manually edit any file inside `lib/generated/`.

---

## 19. Naming

| Thing | Convention | Example |
|---|---|---|
| `@riverpod` function | `camelCase` → generates `xyzProvider` | `medicationList` → `medicationListProvider` |
| `@riverpod` class (Notifier) | `PascalCase` → generates `xyzProvider` | `MedicationList` → `medicationListProvider` |
| Controller (form/action-based) | `XxxController` | `AddMedicationController` |
| State class | `XxxState` | `MedicationFormState` |
| State field for async loading | `isSubmitting` (not `isLoading`) for mutation ops | `state.isSubmitting` |
| Family parameter in `build()` | same name as the entity ID | `build(String medicationId)` |

`isLoading` is reserved for the initial async `build()` load. For user-triggered actions, use `isSubmitting`.

---

## 20. Failure Hierarchy — `BaseFailure`

Every domain failure in the project extends `BaseFailure` (`lib/core/base_failure.dart`). This gives the widget layer — `AppErrorBanner`, `AppAsyncValueWidget`, and any screen that displays an error — a single, stable type to program against.

```dart
// lib/core/base_failure.dart
abstract class BaseFailure implements Exception {
  const BaseFailure();

  /// Short label naming what went wrong (e.g. "Sign in failed").
  String get title;

  /// User-facing explanation and next action (e.g. "Check your password and try again.").
  String get description;

  /// The original caught exception or error object, if one was available.
  Object? get error;

  /// Stack trace captured at the throw site, if available.
  StackTrace? get stackTrace;
}
```

### Defining a domain failure

Plain classes extend `BaseFailure` directly:

```dart
class MedicationFailure extends BaseFailure {
  const MedicationFailure({
    required this.title,
    required this.description,
    this.fieldErrors = const <String, String>{},
    this.error,
    this.stackTrace,
  });

  @override final String title;
  @override final String description;
  @override final Object? error;
  @override final StackTrace? stackTrace;

  final Map<String, String> fieldErrors;

  static MedicationFailure save(Object error, [StackTrace? stackTrace]) =>
      MedicationFailure(
        title: 'Save failed',
        description: 'We could not save this medication. Try again.',
        error: error,
        stackTrace: stackTrace,
      );
}
```

Freezed-based failures use `extends BaseFailure` with the `._()` private constructor and implement the abstract getters in the class body. Freezed constructor fields (`error`, `stackTrace`) satisfy the base getters automatically; computed getters (`title`, `description`) are written as `@override` getter bodies:

```dart
@freezed
abstract class AuthFailure extends BaseFailure with _$AuthFailure {
  const AuthFailure._();

  const factory AuthFailure({
    required AuthFailureKind kind,
    required String message,
    @Default(<String, String>{}) Map<String, String> fieldErrors,
    String? diagnosticCode,
    String? diagnosticMessage,
    // Object? is excluded from JSON — mark it accordingly:
    @JsonKey(includeFromJson: false, includeToJson: false) Object? error,
  }) = _AuthFailure;

  factory AuthFailure.fromJson(Json json) => _$AuthFailureFromJson(json);

  @override
  String get title => switch (kind) {
    AuthFailureKind.invalidCredentials => 'Sign in failed',
    AuthFailureKind.networkUnavailable => 'Network unavailable',
    // ... map every kind to a short label
    _ => 'Error',
  };

  @override
  String get description => message;

  @override
  StackTrace? get stackTrace => null; // AuthFailure decomposes errors structurally via kind/diagnosticCode
}
```

### Rules

- Every new failure class must extend `BaseFailure` and implement all four getters.
- `title` is a short noun phrase ("Save failed", "Session expired"). Never a full sentence.
- `description` is the complete user-facing message with a next action ("Check your connection and try again.").
- `error` stores the original caught `Object` when available. It is for logging — never display it directly in production UI.
- `stackTrace` is captured at the `catch` site. Pass it through to `MedicationFailure.save(e, st)` or equivalent.
- Never leak raw `Object` or `Exception` into state. Always convert in the `catch` block before assigning to state.

---

## 21. Error Handling

Wrap async operations in `try/catch`. Map unknown exceptions to domain failures before setting state:

```dart
} catch (e, st) {
  final failure = e is MedicationFailure ? e : MedicationFailure.save(e, st);

  if (ref.mounted) {
    state = state.copyWith(isSubmitting: false, failure: failure);
  }
  
  return false;
}
```

For `AsyncNotifier`, set `AsyncError` explicitly when the operation fails after an initial successful load:

```dart
state = AsyncError(failure, StackTrace.current).copyWithPrevious(state);
```

Rules:
- Never let exceptions propagate silently. Every `catch` block must either update state or rethrow.
- Riverpod v3 automatically retries a provider whose `build()` throws, using exponential backoff. Rely on that instead of writing manual retry loops inside `build()`. Retry policy is configured globally on `ProviderScope`, not per provider.
- Catch `Object`, not `Exception` — repository and platform code can throw `Error` subtypes.

---

## 22. Testing Providers

Providers are tested through a `ProviderContainer`, never through the widget tree. This is the reason dependencies (repositories, clients) are themselves providers: tests override them.

- Build a container with overrides and always tear it down.
- Override leaf dependencies with fakes using `overrideWithValue`; override notifiers or computed providers with `overrideWith`.
- Read async values via `.future`; trigger actions via `.notifier`.
- `container.read` does not keep an `autoDispose` provider alive. When state must survive an `await`, hold a subscription with `container.listen`.

```dart
final container = ProviderContainer(
  overrides: [
    medicationRepositoryProvider.overrideWithValue(FakeMedicationRepository()),
  ],
);

addTearDown(container.dispose);

final medications = await container.read(medicationListProvider.future);

await container.read(addMedicationControllerProvider.notifier).save(input);
```

---

## 23. Screen State Pattern

Every screen is backed by exactly **one `AsyncNotifier`**. That notifier owns both the initial data load and every mutation the screen can trigger. Never wire two separate providers to the same screen.

### Structure

`build()` loads the data and returns the screen's data class. All mutation methods live on the same notifier and update `state` directly.

```dart
// XxxScreenState — the loaded data + any in-progress action fields
@freezed
class MedicationDetailState with _$MedicationDetailState {
  const factory MedicationDetailState({
    required Medication medication,
    @Default(false) bool isEditing,
    BaseFailure? actionFailure,
  }) = _MedicationDetailState;
}

// One notifier — owns load AND all mutations
@riverpod
class MedicationDetailNotifier extends _$MedicationDetailNotifier {
  @override
  Future<MedicationDetailState> build(String medicationId) async {
    final medication = await ref
        .read(medicationRepositoryProvider)
        .fetchById(medicationId);
    return MedicationDetailState(medication: medication);
  }

  void startEditing() {
    state = AsyncData(state.requireValue.copyWith(isEditing: true));
  }

  Future<void> save(MedicationFormInput input) async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(actionFailure: null));
    try {
      await ref.read(medicationRepositoryProvider).update(input);
      state = AsyncData(current.copyWith(isEditing: false, actionFailure: null));
    } on Object catch (error, stackTrace) {
      state = AsyncData(current.copyWith(
        actionFailure: MedicationFailures.save(error, stackTrace),
      ));
    }
  }
}
```

### In the screen

The screen watches one provider and passes it straight to `AppAsyncValueWidget`:

```dart
AppAsyncValueWidget<MedicationDetailState>(
  value: ref.watch(medicationDetailNotifierProvider(id)),
  onRetry: () => ref.invalidate(medicationDetailNotifierProvider(id)),
  data: (context, state) => _MedicationDetailBody(state: state),
)
```

### Two failure slots, two meanings

| Failure slot | Set by | Shown as |
|---|---|---|
| `AsyncError` (Riverpod) | `build()` throwing | Full-screen error via `AppAsyncValueWidget` |
| `actionFailure: BaseFailure?` inside the data class | mutation methods | Inline `AppErrorBanner` inside the loaded UI |

### Rules

- One `AsyncNotifier` per screen. Never split load and mutation across separate providers for the same screen.
- The data class is named `XxxState` and lives in `*_state.dart`. It is `@freezed` with no Riverpod dependency.
- `actionFailure` is always `BaseFailure?`. Clear it to `null` at the start of every mutation before setting it on failure.
- Never store navigation or UI callbacks inside the state class.
- The notifier is named `XxxNotifier` and lives in `*_controllers.dart`.

---

## 24. What This File Does Not Cover

These topics are out of scope for these guidelines and belong elsewhere:
- Widget composition and screen layout → `flutter_widget_guidelines.md`
- Repository and data layer implementation
- Dependency injection configuration (`ProviderScope` at app root)
- Route definitions and the router/navigator implementation → `lib/core/routing` and `lib/core/navigation` (this file covers only how providers drive reactive redirection and how the widget layer triggers navigation)
- API clients and serialization
