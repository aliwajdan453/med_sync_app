# Auth Form Screen Guidelines

Use these rules for MedSync auth form screens, including login, signup, forgot password, verification actions, password change, and account confirmation forms.

`lib/features/auth/views/login_view.dart` and `lib/features/auth/state/login_screen_notifier.dart` are the current reference pattern.

## Screen Provider Ownership

- Create one screen-specific generated Riverpod notifier for a form screen when the screen needs form resources.
- The screen notifier owns `GlobalKey<FormState>`, `TextEditingController`s, and `FocusNode`s.
- Initialize those resources in `build()` and dispose controller/focus resources with `ref.onDispose`.
- Expose the notifier-owned `formKey`, controllers, and focus nodes to the widget tree through typed getters.
- Keep shared auth actions in `AuthController`. Do not rename `AuthController` to login-specific naming because it owns signup, social auth, password reset, verification, sign out, and password change.

## Widget Shape

- The route view should be a `ConsumerWidget`.
- Private form widgets should be `StatelessWidget`s that receive the notifier-owned form key, controllers, focus nodes, current state, and action callbacks through constructor parameters.
- The widget tree references the notifier-owned `formKey` in a `Form`.
- Use `AppTextField` for auth fields. `AppTextField` wraps `TextFormField` and accepts direct `validator` callbacks.
- Do not store `GlobalKey<FormState>` inside a private stateful widget when the screen already has a screen notifier.

## Validation Flow

- Local validation belongs to `TextFormField` validators and `FormState.validate()`.
- Submit/tap handling should be isolated in the screen notifier where practical.
- The notifier `submit()` method should call `formKey.currentState?.validate()` before delegating to shared auth or repository actions.
- If local validation fails, return without calling backend/shared auth actions.
- Local validation failures appear inline through field validators before backend calls.
- Do not push local validation failures into provider failure state just to render field errors.

## Backend Failure Flow

- Backend, Firebase, repository, or shared auth failures after submission should appear in the screen banner.
- Do not pass backend `fieldErrors` into login text fields after a backend credential failure.
- A wrong-password or invalid-credential response should show a banner such as `The email or password is incorrect.` without also showing `Check your password.` inline.
- Field-level backend errors may still be appropriate on screens where the backend is validating unique or account-specific fields before save, but login credential failures are banner-only.

## Tests

Add or update tests that pin both structure and behavior:

- The view is a `ConsumerWidget`.
- The view uses one screen-specific provider.
- The screen notifier owns `GlobalKey<FormState>`.
- The private form widget is stateless.
- The form uses notifier-owned `formKey`.
- Fields use direct validators.
- Empty local form submit shows field validator errors and does not show the generic validation banner.
- Backend credential failure shows the banner and does not show inline backend field errors.
