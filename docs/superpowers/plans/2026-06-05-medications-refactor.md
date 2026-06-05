# Medications Feature Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align the medications feature's file layout, controller structure, and tests with the auth reference pattern — one notifier per screen file, no dead code, no duplicated test helpers.

**Architecture:** Split `medication_controllers.dart` into per-screen files mirroring auth (`add_medication_controller.dart`, `medication_detail_screen_notifier.dart`), extract a `_submit` helper on `MedicationDetailScreenNotifier`, remove the unused `EditMedicationController`, and consolidate shared test fakes into a single helper file.

**Tech Stack:** Flutter, Riverpod v3 (`riverpod_annotation`), Freezed, `build_runner` for code-gen, `flutter_test`

---

## File Map

### Files to create

| Path | Responsibility |
|---|---|
| `lib/features/medications/state/add_medication_controller.dart` | `AddMedicationController` notifier + generated part |
| `lib/features/medications/state/medication_detail_screen_notifier.dart` | `MedicationDetailScreenNotifier` notifier + generated part |
| `test/features/medications/helpers/medication_test_helpers.dart` | Shared fakes: `_FakeUser`, `_FakeUserInfo`, `_FakeAuthRepository`, `_FakeMedicationRepository`, `_medication()`, `_validInput()` |

### Files to delete

| Path | Reason |
|---|---|
| `lib/features/medications/state/medication_controllers.dart` | Replaced by the two per-screen files above |
| `lib/generated/features/medications/state/medication_controllers.g.dart` | Stale generated file for the deleted source |
| `test/features/medications/medication_controller_test.dart` | Tests for dead `EditMedicationController` removed; `AddMedicationController` tests move to new file |
| `test/features/medications/medication_detail_notifier_test.dart` | Replaced by renamed file below |

### Files to create (tests)

| Path | Responsibility |
|---|---|
| `test/features/medications/add_medication_controller_test.dart` | `AddMedicationController` tests, uses shared helpers |
| `test/features/medications/medication_detail_screen_notifier_test.dart` | `MedicationDetailScreenNotifier` tests, uses shared helpers |

### Files to modify

| Path | Change |
|---|---|
| `lib/features/medications/views/add_medication_screen.dart` | Import path: `medication_controllers.dart` → `add_medication_controller.dart` |
| `lib/features/medications/views/medication_detail_screen.dart` | Import path: `medication_controllers.dart` → `medication_detail_screen_notifier.dart` |
| `test/features/medications/medication_ui_architecture_test.dart` | Update `expectedFiles` list to new file names |
| `test/features/medications/medication_screens_test.dart` | No import changes needed (imports providers, not controllers) |

---

## Task 1: Extract shared test helpers

**Files:**
- Create: `test/features/medications/helpers/medication_test_helpers.dart`

- [ ] **Step 1: Write the helper file**

```dart
// test/features/medications/helpers/medication_test_helpers.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/data/auth_repository.dart';
import 'package:med_sync/features/auth/models/user_profile.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';

Medication fakeMedication({
  required String id,
  String ownerUid = 'uid-1',
  String name = 'Vitamin D',
}) => Medication(
  id: id,
  ownerUid: ownerUid,
  name: name,
  category: MedicationCategory.supplement,
  routineType: MedicationRoutineType.scheduled,
  status: MedicationStatus.active,
  doseAmount: 1,
  doseUnit: 'tablet',
  instructions: 'Take with breakfast.',
  schedule: const MedicationSchedule(
    pattern: MedicationSchedulePattern.daily,
    times: <MedicationTime>[MedicationTime(hour: 8, minute: 0)],
  ),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

MedicationFormInput validMedicationInput() => const MedicationFormInput(
  name: 'Vitamin D',
  category: MedicationCategory.supplement,
  routineType: MedicationRoutineType.scheduled,
  doseAmount: 1,
  doseUnit: 'tablet',
  customDoseUnit: '',
  instructions: 'Take with breakfast.',
  schedule: MedicationSchedule(
    pattern: MedicationSchedulePattern.daily,
    times: <MedicationTime>[MedicationTime(hour: 8, minute: 0)],
  ),
  refillInfo: null,
);

class FakeMedicationRepository implements MedicationRepository {
  FakeMedicationRepository({this.error, this.medications = const []});

  final Exception? error;
  final List<Medication> medications;
  final List<Medication> created = <Medication>[];
  final List<String> archived = <String>[];
  final List<String> deleted = <String>[];

  @override
  Stream<List<Medication>> watchActiveMedications(String ownerUid) =>
      Stream.value(medications);

  @override
  Stream<Medication?> watchMedication({
    required String ownerUid,
    required String medicationId,
  }) => Stream.value(fakeMedication(id: medicationId));

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    final medication = fakeMedication(
      id: 'med-1',
      ownerUid: ownerUid,
      name: input.name,
    );
    created.add(medication);
    return medication;
  }

  @override
  Future<void> updateMedication({
    required String ownerUid,
    required String medicationId,
    required MedicationFormInput input,
  }) async {}

  @override
  Future<void> archiveMedication({
    required String ownerUid,
    required String medicationId,
  }) async {
    archived.add(medicationId);
  }

  @override
  Future<void> permanentlyDeleteMedication({
    required String ownerUid,
    required String medicationId,
  }) async {
    deleted.add(medicationId);
  }
}

class FakeAuthRepository implements AuthRepository {
  final _user = FakeUser();

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream<User?>.value(_user);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteCurrentUser() => throw UnimplementedError();

  @override
  Future<void> reauthenticateForDeletion({
    required UserProfile profile,
    String? password,
  }) => throw UnimplementedError();

  @override
  Future<void> reloadCurrentUser() => throw UnimplementedError();

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) => throw UnimplementedError();

  @override
  Future<User> signInWithApple() => throw UnimplementedError();

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<User> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<User> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) => throw UnimplementedError();
}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'uid-1';

  @override
  String? get email => 'raees@example.com';

  @override
  bool get emailVerified => true;

  @override
  List<UserInfo> get providerData => <UserInfo>[FakeUserInfo()];
}

class FakeUserInfo extends Fake implements UserInfo {
  @override
  String get providerId => 'password';
}
```

- [ ] **Step 2: Verify file is parseable (no dart errors)**

```bash
dart analyze test/features/medications/helpers/medication_test_helpers.dart
```
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add test/features/medications/helpers/medication_test_helpers.dart
git commit -m "test(medications): extract shared fake helpers for medication tests"
```

---

## Task 2: Create `add_medication_controller.dart`

**Files:**
- Create: `lib/features/medications/state/add_medication_controller.dart`

- [ ] **Step 1: Write the file**

```dart
// lib/features/medications/state/add_medication_controller.dart
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/models/medication_failure.dart';
import 'package:med_sync/features/medications/models/medication_form_state.dart';
import 'package:med_sync/features/medications/state/medication_form_validator.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/medications/state/add_medication_controller.g.dart';

@riverpod
class AddMedicationController extends _$AddMedicationController {
  @override
  MedicationFormState build() => const MedicationFormState();

  void clearFailure() {
    state = state.copyWith(failure: null);
  }

  Future<String?> save(MedicationFormInput input) async {
    final validation = MedicationFormValidator.validate(input);
    if (!validation.isValid) {
      state = state.copyWith(
        failure: MedicationFailures.validation(validation.fieldErrors),
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, failure: null);

    try {
      final ownerUid = _currentUserUid();
      final medication = await ref
          .read(medicationRepositoryProvider)
          .createMedication(ownerUid: ownerUid, input: input);
      if (!ref.mounted) return null;
      ref.invalidate(medicationListProvider);
      state = state.copyWith(isSubmitting: false, failure: null);
      return medication.id;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        failure: _mapFailure(error, stackTrace),
      );
      return null;
    }
  }

  String _currentUserUid() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw MedicationFailures.missingSession();
    return user.uid;
  }

  BaseFailure _mapFailure(Object error, StackTrace stackTrace) {
    if (error is BaseFailure) return error;
    return AppFailureMapper.map(
      error,
      stackTrace: stackTrace,
      logger: ref.read(appLoggerProvider('medications.controller')),
    );
  }
}
```

- [ ] **Step 2: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: `lib/generated/features/medications/state/add_medication_controller.g.dart` is created with no errors.

- [ ] **Step 3: Verify analysis is clean**

```bash
dart analyze lib/features/medications/state/add_medication_controller.dart
```
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/medications/state/add_medication_controller.dart lib/generated/
git commit -m "feat(medications): extract AddMedicationController to its own file"
```

---

## Task 3: Create `medication_detail_screen_notifier.dart` with `_submit` helper

**Files:**
- Create: `lib/features/medications/state/medication_detail_screen_notifier.dart`

- [ ] **Step 1: Write the file**

```dart
// lib/features/medications/state/medication_detail_screen_notifier.dart
import 'package:med_sync/core/base_failure.dart';
import 'package:med_sync/core/errors/app_failure_mapper.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/models/medication.dart';
import 'package:med_sync/features/medications/models/medication_detail_state.dart';
import 'package:med_sync/features/medications/models/medication_failure.dart';
import 'package:med_sync/features/medications/state/medication_form_validator.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../../generated/features/medications/state/medication_detail_screen_notifier.g.dart';

@riverpod
class MedicationDetailScreenNotifier
    extends _$MedicationDetailScreenNotifier {
  @override
  Future<MedicationDetailState> build(String medicationId) async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) throw MedicationFailures.missingSession();

    ref.listen(medicationDetailProvider(medicationId), (_, next) {
      if (!ref.mounted) return;
      next.whenData((medication) {
        if (medication == null || !state.hasValue) return;
        state = AsyncData(state.requireValue.copyWith(medication: medication));
      });
    });

    final medication = await ref.read(
      medicationDetailProvider(medicationId).future,
    );
    if (medication == null) throw MedicationFailures.missingMedication();
    return MedicationDetailState(medication: medication);
  }

  void startEditing() {
    if (!state.hasValue) return;
    state = AsyncData(
      state.requireValue.copyWith(isEditing: true, actionFailure: null),
    );
  }

  void cancelEditing() {
    if (!state.hasValue) return;
    state = AsyncData(
      state.requireValue.copyWith(isEditing: false, actionFailure: null),
    );
  }

  Future<bool> saveEdit(MedicationFormInput input) async {
    if (!state.hasValue) return false;
    final validation = MedicationFormValidator.validate(input);
    if (!validation.isValid) {
      state = AsyncData(
        state.requireValue.copyWith(
          actionFailure: MedicationFailures.validation(validation.fieldErrors),
        ),
      );
      return false;
    }

    return _submit(() async {
      final ownerUid = _currentUserUid();
      await ref
          .read(medicationRepositoryProvider)
          .updateMedication(
            ownerUid: ownerUid,
            medicationId: medicationId,
            input: input,
          );
      ref.invalidate(medicationListProvider);
    }, onSuccess: (current) => current.copyWith(isEditing: false));
  }

  Future<bool> archive() => _submit(() async {
    final ownerUid = _currentUserUid();
    await ref
        .read(medicationRepositoryProvider)
        .archiveMedication(ownerUid: ownerUid, medicationId: medicationId);
    ref.invalidate(medicationListProvider);
  });

  Future<bool> permanentlyDelete() => _submit(() async {
    final ownerUid = _currentUserUid();
    await ref
        .read(medicationRepositoryProvider)
        .permanentlyDeleteMedication(
          ownerUid: ownerUid,
          medicationId: medicationId,
        );
    ref.invalidate(medicationListProvider);
  }, onSuccess: (current) => current.copyWith(didCompleteDelete: true));

  Future<bool> _submit(
    Future<void> Function() action, {
    MedicationDetailState Function(MedicationDetailState current)? onSuccess,
  }) async {
    if (!state.hasValue) return false;
    state = AsyncData(
      state.requireValue.copyWith(isSubmitting: true, actionFailure: null),
    );

    try {
      await action();
      if (!ref.mounted) return true;
      final successState = onSuccess?.call(state.requireValue) ??
          state.requireValue;
      state = AsyncData(successState.copyWith(isSubmitting: false));
      return true;
    } on Object catch (error, stackTrace) {
      if (!ref.mounted) return false;
      state = AsyncData(
        state.requireValue.copyWith(
          isSubmitting: false,
          actionFailure: _mapFailure(error, stackTrace),
        ),
      );
      return false;
    }
  }

  String _currentUserUid() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) throw MedicationFailures.missingSession();
    return user.uid;
  }

  BaseFailure _mapFailure(Object error, StackTrace stackTrace) {
    if (error is BaseFailure) return error;
    return AppFailureMapper.map(
      error,
      stackTrace: stackTrace,
      logger: ref.read(appLoggerProvider('medications.controller')),
    );
  }
}
```

- [ ] **Step 2: Run code generation**

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: `lib/generated/features/medications/state/medication_detail_screen_notifier.g.dart` is created.

- [ ] **Step 3: Verify analysis is clean**

```bash
dart analyze lib/features/medications/state/medication_detail_screen_notifier.dart
```
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/medications/state/medication_detail_screen_notifier.dart lib/generated/
git commit -m "feat(medications): extract MedicationDetailScreenNotifier with _submit helper"
```

---

## Task 4: Update views to import from new per-screen files

**Files:**
- Modify: `lib/features/medications/views/add_medication_screen.dart`
- Modify: `lib/features/medications/views/medication_detail_screen.dart`

- [ ] **Step 1: Update `add_medication_screen.dart` import**

Replace this import in `lib/features/medications/views/add_medication_screen.dart`:
```dart
import 'package:med_sync/features/medications/state/medication_controllers.dart';
```
With:
```dart
import 'package:med_sync/features/medications/state/add_medication_controller.dart';
```

- [ ] **Step 2: Update `medication_detail_screen.dart` import**

Replace this import in `lib/features/medications/views/medication_detail_screen.dart`:
```dart
import 'package:med_sync/features/medications/state/medication_controllers.dart';
```
With:
```dart
import 'package:med_sync/features/medications/state/medication_detail_screen_notifier.dart';
```

- [ ] **Step 3: Verify analysis is clean**

```bash
dart analyze lib/features/medications/views/
```
Expected: no errors.

- [ ] **Step 4: Run existing tests to confirm nothing broke**

```bash
flutter test test/features/medications/medication_screens_test.dart
```
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/medications/views/add_medication_screen.dart lib/features/medications/views/medication_detail_screen.dart
git commit -m "refactor(medications): update views to import from per-screen state files"
```

---

## Task 5: Delete `medication_controllers.dart` and its generated file

**Files:**
- Delete: `lib/features/medications/state/medication_controllers.dart`
- Delete (auto-cleaned by build_runner): `lib/generated/features/medications/state/medication_controllers.g.dart`

- [ ] **Step 1: Delete the source file**

```bash
rm lib/features/medications/state/medication_controllers.dart
```

- [ ] **Step 2: Run build_runner to clean the orphaned generated file**

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: `medication_controllers.g.dart` is removed (no longer has a source).

- [ ] **Step 3: Verify the full feature still analyzes cleanly**

```bash
dart analyze lib/features/medications/
```
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add -A lib/features/medications/state/ lib/generated/features/medications/state/
git commit -m "refactor(medications): delete merged medication_controllers.dart and stale generated file"
```

---

## Task 6: Write `add_medication_controller_test.dart` using shared helpers

**Files:**
- Create: `test/features/medications/add_medication_controller_test.dart`

- [ ] **Step 1: Write the test file**

```dart
// test/features/medications/add_medication_controller_test.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/core/logging/app_logger.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/state/add_medication_controller.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';
import 'package:med_sync/features/medications/data/medication_repository.dart';
import 'package:med_sync/features/medications/models/medication.dart';

import 'helpers/medication_test_helpers.dart';

void main() {
  test('save creates medication and returns its id', () async {
    final repository = FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      addMedicationControllerProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);

    final medicationId = await container
        .read(addMedicationControllerProvider.notifier)
        .save(validMedicationInput());

    expect(medicationId, 'med-1');
    expect(repository.created.single.name, 'Vitamin D');
  });

  test('save returns null and sets failure when validation fails', () async {
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(FakeMedicationRepository()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(addMedicationControllerProvider, (_, _) {});

    final invalidInput = const MedicationFormInput(
      name: '',
      category: MedicationCategory.supplement,
      routineType: MedicationRoutineType.scheduled,
      doseAmount: null,
      doseUnit: '',
      customDoseUnit: '',
      instructions: '',
      schedule: null,
      refillInfo: null,
    );

    final result = await container
        .read(addMedicationControllerProvider.notifier)
        .save(invalidInput);

    expect(result, isNull);
    final state = container.read(addMedicationControllerProvider);
    expect(state.failure, isNotNull);
    expect(state.fieldErrors['name'], 'Enter a medication name.');
  });

  test('save captures failure and logs when repository throws', () async {
    final repository = FakeMedicationRepository(
      error: Exception('firestore-down'),
    );
    final logger = _FakeLogger();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
        appLoggerProvider('medications.controller').overrideWithValue(logger),
      ],
    );
    addTearDown(container.dispose);
    container.listen(addMedicationControllerProvider, (_, _) {});

    final medicationId = await container
        .read(addMedicationControllerProvider.notifier)
        .save(validMedicationInput());

    final state = container.read(addMedicationControllerProvider);
    expect(medicationId, isNull);
    expect(
      state.failure?.description,
      'We could not complete that request. Try again.',
    );
    expect(state.failure?.diagnosticMessage, contains('firestore-down'));
    expect(
      logger.errors.single.message,
      'Unhandled exception mapped to BaseFailure.',
    );
    expect(logger.errors.single.error.toString(), contains('firestore-down'));
    expect(logger.errors.single.stackTrace, isNotNull);
    expect(logger.errors.single.context['failureTitle'], 'Request failed');
  });

  test('save does not write state after disposal', () async {
    final completer = Completer<void>();
    final repository = _DelayedFakeMedicationRepository(completer);
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    container.listen(addMedicationControllerProvider, (_, _) {});

    final save = container
        .read(addMedicationControllerProvider.notifier)
        .save(validMedicationInput());

    container.dispose();
    completer.complete();

    await expectLater(save, completes);
  });
}

class _FakeLogger implements AppLogger {
  final errors = <_LogEntry>[];

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    errors.add(_LogEntry(
      message: message,
      error: error,
      stackTrace: stackTrace,
      context: context,
    ));
  }

  @override
  void info(String message, {Map<String, Object?> context = const {}}) {}

  @override
  void warning(String message, {Map<String, Object?> context = const {}}) {}
}

class _LogEntry {
  const _LogEntry({
    required this.message,
    required this.error,
    required this.stackTrace,
    required this.context,
  });

  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, Object?> context;
}

class _DelayedFakeMedicationRepository extends FakeMedicationRepository {
  _DelayedFakeMedicationRepository(this._completer);
  final Completer<void> _completer;

  @override
  Future<Medication> createMedication({
    required String ownerUid,
    required MedicationFormInput input,
  }) async {
    await _completer.future;
    return fakeMedication(id: 'med-1', ownerUid: ownerUid, name: input.name);
  }
}
```

- [ ] **Step 2: Run the new test file**

```bash
flutter test test/features/medications/add_medication_controller_test.dart
```
Expected: all 4 tests pass.

- [ ] **Step 3: Commit**

```bash
git add test/features/medications/add_medication_controller_test.dart
git commit -m "test(medications): add AddMedicationController tests using shared helpers"
```

---

## Task 7: Write `medication_detail_screen_notifier_test.dart` using shared helpers

**Files:**
- Create: `test/features/medications/medication_detail_screen_notifier_test.dart`

- [ ] **Step 1: Write the test file**

```dart
// test/features/medications/medication_detail_screen_notifier_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_sync/features/auth/state/auth_providers.dart';
import 'package:med_sync/features/medications/state/medication_detail_screen_notifier.dart';
import 'package:med_sync/features/medications/state/medication_providers.dart';

import 'helpers/medication_test_helpers.dart';

ProviderContainer _buildContainer() {
  final container = ProviderContainer(
    overrides: [
      currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      medicationRepositoryProvider.overrideWithValue(FakeMedicationRepository()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('build loads medication and returns initial state', () async {
    final container = _buildContainer();
    final subscription = container.listen(
      medicationDetailScreenNotifierProvider('med-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    final state = await container.read(
      medicationDetailScreenNotifierProvider('med-1').future,
    );
    expect(state.medication.id, 'med-1');
    expect(state.isEditing, isFalse);
    expect(state.isSubmitting, isFalse);
    expect(state.actionFailure, isNull);
  });

  test('startEditing sets isEditing to true', () async {
    final container = _buildContainer();
    final subscription = container.listen(
      medicationDetailScreenNotifierProvider('med-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container.read(medicationDetailScreenNotifierProvider('med-1').future);
    container
        .read(medicationDetailScreenNotifierProvider('med-1').notifier)
        .startEditing();

    final state = container
        .read(medicationDetailScreenNotifierProvider('med-1'))
        .requireValue;
    expect(state.isEditing, isTrue);
  });

  test('cancelEditing clears isEditing', () async {
    final container = _buildContainer();
    container.listen(medicationDetailScreenNotifierProvider('med-1'), (_, _) {});

    await container.read(medicationDetailScreenNotifierProvider('med-1').future);
    final notifier = container
        .read(medicationDetailScreenNotifierProvider('med-1').notifier);
    notifier.startEditing();
    notifier.cancelEditing();

    final state = container
        .read(medicationDetailScreenNotifierProvider('med-1'))
        .requireValue;
    expect(state.isEditing, isFalse);
  });

  test('archive calls repository and returns true', () async {
    final repository = FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container.listen(medicationDetailScreenNotifierProvider('med-1'), (_, _) {});

    await container.read(medicationDetailScreenNotifierProvider('med-1').future);
    final success = await container
        .read(medicationDetailScreenNotifierProvider('med-1').notifier)
        .archive();

    expect(success, isTrue);
    expect(repository.archived, contains('med-1'));
  });

  test('permanentlyDelete calls repository and sets didCompleteDelete', () async {
    final repository = FakeMedicationRepository();
    final container = ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) => Stream.value(FakeUser())),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container.listen(medicationDetailScreenNotifierProvider('med-1'), (_, _) {});

    await container.read(medicationDetailScreenNotifierProvider('med-1').future);
    final success = await container
        .read(medicationDetailScreenNotifierProvider('med-1').notifier)
        .permanentlyDelete();

    expect(success, isTrue);
    expect(repository.deleted, contains('med-1'));
    final state = container
        .read(medicationDetailScreenNotifierProvider('med-1'))
        .requireValue;
    expect(state.didCompleteDelete, isTrue);
  });

  test('saveEdit with invalid input sets actionFailure and returns false', () async {
    final container = _buildContainer();
    container.listen(medicationDetailScreenNotifierProvider('med-1'), (_, _) {});

    await container.read(medicationDetailScreenNotifierProvider('med-1').future);
    final success = await container
        .read(medicationDetailScreenNotifierProvider('med-1').notifier)
        .saveEdit(const MedicationFormInput(
          name: '',
          category: MedicationCategory.supplement,
          routineType: MedicationRoutineType.scheduled,
          doseAmount: null,
          doseUnit: '',
          customDoseUnit: '',
          instructions: '',
          schedule: null,
          refillInfo: null,
        ));

    expect(success, isFalse);
    final state = container
        .read(medicationDetailScreenNotifierProvider('med-1'))
        .requireValue;
    expect(state.actionFailure, isNotNull);
    expect(state.actionFailure!.fieldErrors['name'], 'Enter a medication name.');
  });
}
```

Note: you need to add `import 'package:med_sync/features/medications/models/medication.dart';` for `MedicationFormInput` and enums in the saveEdit test case.

- [ ] **Step 2: Run the new test file**

```bash
flutter test test/features/medications/medication_detail_screen_notifier_test.dart
```
Expected: all 6 tests pass.

- [ ] **Step 3: Commit**

```bash
git add test/features/medications/medication_detail_screen_notifier_test.dart
git commit -m "test(medications): add MedicationDetailScreenNotifier tests using shared helpers"
```

---

## Task 8: Delete old test files and update `medication_ui_architecture_test.dart`

**Files:**
- Delete: `test/features/medications/medication_controller_test.dart`
- Delete: `test/features/medications/medication_detail_notifier_test.dart`
- Modify: `test/features/medications/medication_ui_architecture_test.dart`

- [ ] **Step 1: Delete the old test files**

```bash
rm test/features/medications/medication_controller_test.dart
rm test/features/medications/medication_detail_notifier_test.dart
```

- [ ] **Step 2: Update `medication_ui_architecture_test.dart`**

Replace the full `expectedFiles` list in `test/features/medications/medication_ui_architecture_test.dart` with:

```dart
final expectedFiles = [
  'lib/features/medications/models/medication.dart',
  'lib/features/medications/models/medication_detail_state.dart',
  'lib/features/medications/models/medication_failure.dart',
  'lib/features/medications/models/medication_form_state.dart',
  'lib/features/medications/data/medication_repository.dart',
  'lib/features/medications/data/firestore_medication_repository.dart',
  'lib/features/medications/state/add_medication_controller.dart',
  'lib/features/medications/state/medication_detail_screen_notifier.dart',
  'lib/features/medications/state/medication_form_validator.dart',
  'lib/features/medications/state/medication_providers.dart',
  'lib/features/medications/views/add_medication_screen.dart',
  'lib/features/medications/views/medication_detail_screen.dart',
  'lib/features/medications/views/medications_list_screen.dart',
  'lib/features/medications/widgets/medication_form.dart',
  'lib/features/medications/widgets/medication_dose_fields.dart',
  'lib/features/medications/widgets/medication_refill_fields.dart',
  'lib/features/medications/widgets/medication_schedule_fields.dart',
];
```

Also update the `deprecatedFolders` check to include the old blob file:

```dart
final deprecatedFiles = [
  'lib/features/medications/state/medication_controllers.dart',
];

for (final path in deprecatedFiles) {
  expect(File(path).existsSync(), isFalse, reason: '$path should be deleted');
}
```

- [ ] **Step 3: Run the architecture test**

```bash
flutter test test/features/medications/medication_ui_architecture_test.dart
```
Expected: passes.

- [ ] **Step 4: Run all medication tests**

```bash
flutter test test/features/medications/
```
Expected: all tests pass, no references to deleted files.

- [ ] **Step 5: Commit**

```bash
git add -A test/features/medications/
git commit -m "test(medications): delete old merged test files, update architecture guard"
```

---

## Task 9: Final full-suite verification

- [ ] **Step 1: Full analysis pass**

```bash
dart analyze lib/ test/
```
Expected: no errors, no hints about dead imports.

- [ ] **Step 2: Full test run**

```bash
flutter test
```
Expected: all tests pass.

- [ ] **Step 3: Final commit if any stragglers**

```bash
git status
```
If working tree is clean, nothing to do. If there are any auto-generated files still pending, stage and commit them:

```bash
git add lib/generated/
git commit -m "chore: regenerate code after medications state refactor"
```

---

## Self-Review

**Spec coverage:**
- ✅ `EditMedicationController` removed (dead code)
- ✅ `medication_controllers.dart` split into `add_medication_controller.dart` + `medication_detail_screen_notifier.dart`
- ✅ `_submit` helper extracted on `MedicationDetailScreenNotifier`
- ✅ `_mapFailure` converted from top-level function to private method on each controller
- ✅ Shared test helpers extracted to `medication_test_helpers.dart`
- ✅ Old test files deleted
- ✅ `medication_ui_architecture_test.dart` updated
- ✅ View imports updated

**Placeholder scan:** No TBDs, all code blocks are complete.

**Type consistency:**
- `medicationDetailScreenNotifierProvider` is the generated name for `MedicationDetailScreenNotifier` — consistent across tests and screen.
- `addMedicationControllerProvider` is the generated name for `AddMedicationController` — consistent.
- `FakeMedicationRepository`, `FakeAuthRepository`, `FakeUser`, `FakeUserInfo`, `fakeMedication()`, `validMedicationInput()` — all public in helpers file, all referenced correctly in test files.
