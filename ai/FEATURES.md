# MedSync Feature Breakdown

## 1. Feature Overview Table

| Feature | Phase | Tier | Priority | Suggested Folder |
| --- | --- | --- | --- | --- |
| Splash/Welcome | V1 | Free | P0 | `features/auth` |
| Onboarding/Auth | V1 | Free | P0 | `features/auth` |
| Email Sign Up | V1 | Free | P0 | `features/auth` |
| Email Login | V1 | Free | P0 | `features/auth` |
| Forgot/Reset Password | V1 | Free | P1 | `features/auth` |
| Email Verification | V1 | Free | P1 | `features/auth` |
| Apple Sign In | V1 | Free | P0 | `features/auth` |
| Google Sign In | V1 | Free | P0 | `features/auth` |
| Social Auth Loading | V1 | Free | P1 | `features/auth` |
| Home Dashboard | V1 | Free | P0 | `features/home` |
| Manual Medication Add | V1 | Free | P0 | `features/medications` |
| OCR-Assisted Entry | V1 | Free | P1 | `features/ocr` |
| Medication List | V1 | Free | P0 | `features/medications` |
| Medication Detail/Edit | V1 | Free | P0 | `features/medications` |
| Scheduled Reminders | V1 | Free | P0 | `features/reminders` |
| As-Needed Logging | V1 | Free | P1 | `features/dose_tracking` |
| Dose Status Tracking | V1 | Free | P0 | `features/dose_tracking` |
| Fixed Grace Period | V1 | Free | P0 | `features/dose_tracking` |
| Late Taken Support | V1 | Free | P0 | `features/dose_tracking` |
| Missed Dose Review | V1 | Free | P0 | `features/dose_tracking` |
| Global Streak | V1 | Free | P1 | `features/progress` |
| Adherence Percentage | V1 | Free | P1 | `features/progress` |
| Pill-Count Refills | V1 | Free | P1 | `features/refills` |
| Notification Settings | V1 | Free | P1 | `features/settings` |
| Pro Upgrade | V1 | Pro | P1 | `features/subscriptions` |
| RevenueCat Entitlements | V1 | Internal | P0 | `features/subscriptions` |
| Account Deletion | V1 | Free | P0 | `features/auth` |
| Local App Settings | V1 | Free | P2 | `features/settings` |
| Caregiver Invite | v1.5 | Future Pro | P1 | `features/caregiver` |
| Caregiver Dashboard | v1.5 | Future Pro | P1 | `features/caregiver` |
| Smart Insights | Future | Future Pro | P2 | `features/insights` |
| PDF Export | Future | Future Pro | P2 | `features/pdf_export` |
| Advanced Stats | Future | Pro | P2 | `features/progress` |

## 2. V1 P0 Features

### Feature: Splash/Welcome

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a new user, I want a clear first screen so I understand this is a personal medication routine tracker.
- Description: Lightweight entry screen that routes authenticated users to Home and unauthenticated users to onboarding.
- Functional requirements:
  - Check current auth state.
  - Show Clinical Performance Lab visual language.
  - Avoid medical claims.
  - Route to onboarding or Home.
- Edge cases:
  - Auth state loading.
  - Auth token expired.
  - Network unavailable during auth refresh.
- UI states:
  - Loading.
  - Signed out.
  - Signed in.
  - Auth refresh error.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `currentUserProvider`.
- Dependencies: Auth service abstraction, router.
- Acceptance criteria:
  - Signed-in users reach Home.
  - Signed-out users reach Onboarding/Auth.
  - Copy avoids clinical positioning.

### Feature: Onboarding/Auth

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a new user, I want to create or access my account before tracking medications.
- Description: Account-gated onboarding flow with email, Apple, and Google auth choices.
- Functional requirements:
  - No guest mode.
  - Present sign up, login, Apple Sign In, and Google Sign In.
  - Explain privacy-conscious routine tracking without medical claims.
- Edge cases:
  - User cancels social sign in.
  - Auth provider unavailable.
  - Existing account uses another provider.
- UI states:
  - Initial.
  - Loading.
  - Error.
  - Provider selection.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `authControllerProvider`, `currentUserProvider`.
- Dependencies: Auth repository, router.
- Acceptance criteria:
  - User can reach each auth path.
  - Guest mode is not offered.
  - Failed auth displays recoverable error copy.

### Feature: Email Sign Up

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to create an account with email so my routine data is tied to me.
- Description: Email and password account creation with email verification when required by backend configuration.
- Functional requirements:
  - Capture email and password.
  - Validate required fields.
  - Submit to auth repository.
  - Route to Email Verification or Home based on verification state.
- Edge cases:
  - Email already in use.
  - Weak password.
  - Invalid email.
  - Network failure.
- UI states:
  - Empty form.
  - Field errors.
  - Submitting.
  - Success.
  - Error.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `authControllerProvider`.
- Dependencies: Auth repository, router.
- Acceptance criteria:
  - Valid signup creates an account.
  - Invalid fields show inline errors.
  - Existing email error is understandable.

### Feature: Email Login

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a returning user, I want to log in with email and password.
- Description: Standard email login flow.
- Functional requirements:
  - Capture email and password.
  - Validate required fields.
  - Submit login request.
  - Route verified users to Home.
- Edge cases:
  - Wrong password.
  - Unknown email.
  - Unverified email.
  - Disabled account.
- UI states:
  - Empty form.
  - Field errors.
  - Submitting.
  - Error.
  - Success.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `authControllerProvider`, `currentUserProvider`.
- Dependencies: Auth repository, router.
- Acceptance criteria:
  - Valid credentials log in.
  - Invalid credentials do not clear entered email.
  - Unverified account routes to verification flow.

### Feature: Apple Sign In

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As an iPhone user, I want to sign in with Apple.
- Description: Apple auth provider integration required when third-party auth is offered.
- Functional requirements:
  - Start Apple auth.
  - Handle cancellation.
  - Create or retrieve user profile.
  - Route to Home after success.
- Edge cases:
  - User cancels.
  - Provider returns missing email.
  - Credential already linked.
- UI states:
  - Idle.
  - Social auth loading.
  - Error.
  - Success.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `authControllerProvider`.
- Dependencies: Apple auth package, backend auth service.
- Acceptance criteria:
  - Apple Sign In completes successfully on supported iOS.
  - Cancellation returns to provider selection.

### Feature: Google Sign In

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to sign in with Google.
- Description: Google auth provider integration.
- Functional requirements:
  - Start Google auth.
  - Handle cancellation.
  - Create or retrieve user profile.
  - Route to Home after success.
- Edge cases:
  - User cancels.
  - Provider configuration failure.
  - Existing email linked to another provider.
- UI states:
  - Idle.
  - Social auth loading.
  - Error.
  - Success.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `authControllerProvider`.
- Dependencies: Google auth package, backend auth service.
- Acceptance criteria:
  - Google auth completes when configured.
  - Cancellation is non-destructive.

### Feature: Home Dashboard

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to see today's scheduled medication routine and act quickly.
- Description: Main daily dashboard showing due, completed, skipped, missed, refill, and streak context.
- Functional requirements:
  - Show today's scheduled doses.
  - Allow Taken and Skipped actions.
  - Surface missed items.
  - Show global streak summary.
  - Show refill alert entry point when threshold is reached.
- Edge cases:
  - No medications.
  - All doses complete.
  - Multiple overdue doses.
  - User offline.
- UI states:
  - Empty.
  - Loading.
  - Today active.
  - Complete day.
  - Error.
- Suggested Flutter feature folder: `features/home`.
- Suggested models/entities: `Medication`, `MedicationSchedule`, `DoseLog`, `AdherenceSummary`.
- Suggested Riverpod providers/controllers: `todayDoseScheduleProvider`, `doseActionControllerProvider`, `streakProvider`.
- Dependencies: Medication repository, dose log repository, reminder calculation.
- Acceptance criteria:
  - User can mark scheduled doses Taken or Skipped.
  - Empty state leads to Add Medication.
  - As-needed medication does not appear as overdue.

### Feature: Manual Medication Add

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to manually add a medication or supplement.
- Description: Form for creating scheduled or as-needed medication records.
- Functional requirements:
  - Capture name, dosage, instructions, medication type, schedule type, and refill fields when enabled.
  - Enforce Free medication limit.
  - Save active medication.
  - Support scheduled and as-needed types.
- Edge cases:
  - Free user already has 5 medications.
  - Missing required name.
  - Invalid quantity.
  - User exits with unsaved changes.
- UI states:
  - Empty form.
  - Editing fields.
  - Validation error.
  - Saving.
  - Saved.
- Suggested Flutter feature folder: `features/medications`.
- Suggested models/entities: `Medication`, `MedicationSchedule`, `RefillInfo`.
- Suggested Riverpod providers/controllers: `addMedicationControllerProvider`, `medicationRepositoryProvider`, `entitlementProvider`.
- Dependencies: Entitlement service, medication repository.
- Acceptance criteria:
  - User can save a valid scheduled medication.
  - User can save a valid as-needed medication.
  - Free limit blocks the sixth active medication and routes to Pro Upgrade.

### Feature: Medication List

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to view my medication routines in one place.
- Description: List of active scheduled and as-needed medication records.
- Functional requirements:
  - Display active medications.
  - Separate or label scheduled and as-needed medications.
  - Link to detail/edit.
  - Provide add medication action.
- Edge cases:
  - Empty list.
  - Archived medication hidden or separated.
  - Repository error.
- UI states:
  - Loading.
  - Empty.
  - Loaded.
  - Error.
- Suggested Flutter feature folder: `features/medications`.
- Suggested models/entities: `Medication`.
- Suggested Riverpod providers/controllers: `medicationListProvider`.
- Dependencies: Medication repository.
- Acceptance criteria:
  - All active medications appear.
  - Tapping an item opens detail/edit.

### Feature: Medication Detail/Edit

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to review and edit a medication routine.
- Description: Detail screen with medication fields, schedule, refill details, and history entry points.
- Functional requirements:
  - Show medication details.
  - Edit supported fields.
  - Save changes.
  - Support active or archived state if archive is implemented.
- Edge cases:
  - Medication deleted or unavailable.
  - Invalid edits.
  - Concurrent repository update.
- UI states:
  - Loading.
  - Viewing.
  - Editing.
  - Saving.
  - Error.
- Suggested Flutter feature folder: `features/medications`.
- Suggested models/entities: `Medication`, `MedicationSchedule`, `RefillInfo`.
- Suggested Riverpod providers/controllers: `medicationRepositoryProvider`.
- Dependencies: Medication repository.
- Acceptance criteria:
  - User can update valid medication details.
  - Invalid edits are blocked with field-level errors.

### Feature: Scheduled Medication Reminders

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want reminders for scheduled medications.
- Description: Reminder configuration for scheduled medications only.
- Functional requirements:
  - Support reminder enabled state.
  - Schedule notifications for scheduled medications.
  - Use privacy-conscious notification copy by default.
  - Exclude as-needed medications.
- Edge cases:
  - Notification permission denied.
  - Time zone change.
  - Medication schedule edited.
  - Medication disabled.
- UI states:
  - Permission not requested.
  - Permission granted.
  - Permission denied.
  - Reminder enabled.
  - Reminder disabled.
- Suggested Flutter feature folder: `features/reminders`.
- Suggested models/entities: `ReminderConfig`, `MedicationSchedule`, `NotificationPreference`.
- Suggested Riverpod providers/controllers: `notificationSettingsProvider`, `todayDoseScheduleProvider`.
- Dependencies: Local notifications or FCM, medication schedule.
- Acceptance criteria:
  - Scheduled medications can produce reminders.
  - As-needed medications do not produce reminders.
  - Notification copy does not include medication names by default.

### Feature: Dose Status Tracking

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to mark scheduled doses as Taken, Skipped, or Missed.
- Description: Core dose log state machine.
- Functional requirements:
  - Support Taken, Skipped, Missed, and Late Taken representation.
  - Scheduled medications can move to missed after grace period.
  - User actions create dose logs.
  - Dose logs feed adherence and streak calculations.
- Edge cases:
  - Double tap action.
  - Offline action.
  - Late taken after missed.
  - Duplicate scheduled dose instance.
- UI states:
  - Pending.
  - Taken.
  - Skipped.
  - Missed.
  - Late Taken.
- Suggested Flutter feature folder: `features/dose_tracking`.
- Suggested models/entities: `DoseLog`, `MedicationSchedule`.
- Suggested Riverpod providers/controllers: `doseActionControllerProvider`, `doseLogRepositoryProvider`.
- Dependencies: Dose repository, schedule calculation.
- Acceptance criteria:
  - Taken and Skipped update the dose instance.
  - Missed is applied after the fixed grace period.
  - Late Taken can resolve a missed item.

### Feature: Fixed 1-Hour Grace Period

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want overdue scheduled doses handled consistently.
- Description: Fixed v1 missed-dose rule.
- Functional requirements:
  - Grace period is exactly 1 hour.
  - Grace period is not user-configurable in v1.
  - Missed logic applies only to scheduled medications.
- Edge cases:
  - App closed during grace period.
  - Time zone change.
  - Device time changed.
- UI states:
  - Due.
  - In grace period.
  - Missed.
- Suggested Flutter feature folder: `features/dose_tracking`.
- Suggested models/entities: `DoseLog`, `MedicationSchedule`.
- Suggested Riverpod providers/controllers: `todayDoseScheduleProvider`.
- Dependencies: Clock abstraction, schedule calculation.
- Acceptance criteria:
  - Scheduled dose is not missed before 1 hour.
  - Scheduled dose is missed after 1 hour unresolved.
  - As-needed medication is ignored.

### Feature: Missed Dose Review

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to review missed doses and resolve them if I took them late.
- Description: Screen focused on missed scheduled dose instances.
- Functional requirements:
  - List missed scheduled doses.
  - Allow mark as taken later.
  - Preserve late taken status internally or visually.
  - Feed streak restoration rules.
- Edge cases:
  - No missed doses.
  - Dose already resolved.
  - Medication deleted.
- UI states:
  - Empty.
  - Loaded.
  - Resolving.
  - Error.
- Suggested Flutter feature folder: `features/dose_tracking`.
- Suggested models/entities: `DoseLog`, `Medication`.
- Suggested Riverpod providers/controllers: `doseActionControllerProvider`, `doseLogRepositoryProvider`.
- Dependencies: Dose repository.
- Acceptance criteria:
  - Missed items appear.
  - Late Taken action resolves the item.
  - Resolved late item updates day completion.

### Feature: RevenueCat Entitlement Handling

- Release phase: V1 launch.
- Tier: Internal.
- Priority: P0.
- User story: As the app, I need reliable entitlement state to enforce Free and Pro access.
- Description: Subscription entitlement abstraction backed by RevenueCat.
- Functional requirements:
  - Load current entitlement.
  - Expose Free or Pro state.
  - Refresh after purchase or restore.
  - Gate medication limit and Pro entry points.
- Edge cases:
  - RevenueCat unavailable.
  - Receipt restore failure.
  - Expired subscription.
  - Unknown entitlement state.
- UI states:
  - Loading.
  - Free.
  - Pro.
  - Error.
- Suggested Flutter feature folder: `features/subscriptions`.
- Suggested models/entities: `SubscriptionEntitlement`.
- Suggested Riverpod providers/controllers: `subscriptionControllerProvider`, `entitlementProvider`.
- Dependencies: RevenueCat SDK.
- Acceptance criteria:
  - Entitlement provider exposes current tier.
  - Pro purchase updates gated features.
  - Free medication limit uses entitlement state.

### Feature: Account Deletion

- Release phase: V1 launch.
- Tier: Free.
- Priority: P0.
- User story: As a user, I want to delete my account from the app.
- Description: App Store compliant account deletion flow.
- Functional requirements:
  - Confirm destructive action.
  - Delete account through auth backend.
  - Delete or queue deletion of user-owned app data.
  - Sign user out after completion.
- Edge cases:
  - Reauthentication required.
  - Network failure.
  - Partial deletion queued.
- UI states:
  - Confirmation.
  - Deleting.
  - Error.
  - Deleted.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `accountDeletionControllerProvider`, `authControllerProvider`.
- Dependencies: Auth repository, user data repository.
- Acceptance criteria:
  - User can start deletion from account settings.
  - Confirmation is required.
  - Successful deletion signs out the user.
  - Password-provider users reauthenticate with password.
  - Social-only users reauthenticate through their provider.

## 3. V1 P1 Features

### Feature: Forgot Password

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want to request password recovery.
- Description: Email-based password reset request.
- Functional requirements:
  - Capture email.
  - Submit reset request.
  - Show confirmation copy.
- Edge cases:
  - Invalid email.
  - Unknown email.
  - Rate limited request.
- UI states:
  - Empty.
  - Submitting.
  - Sent.
  - Error.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `authControllerProvider`.
- Dependencies: Auth repository.
- Acceptance criteria:
  - User can request reset.
  - Confirmation does not reveal whether account exists.

### Feature: Reset Password

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want to set a new password after recovery.
- Description: Password reset is completed through the Firebase email link for the MVP.
- Functional requirements:
  - Send Firebase reset email from Forgot Password.
  - Show neutral confirmation copy.
  - Do not reveal whether an account exists for the email.
- Edge cases:
  - Expired token.
  - Weak password.
  - Link opened on unsupported device.
- UI states:
  - Loading token.
  - Form.
  - Submitting.
  - Success.
  - Error.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `authControllerProvider`.
- Dependencies: Auth repository.
- Acceptance criteria:
  - User can request a reset email.
  - Confirmation copy is neutral.

### Feature: Email Verification

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want to verify my email when required.
- Description: Verification pending screen with resend action.
- Functional requirements:
  - Show verification pending state.
  - Allow resend.
  - Refresh verification status.
- Edge cases:
  - Resend rate limited.
  - Email already verified.
  - User signs out.
- UI states:
  - Pending.
  - Resending.
  - Sent.
  - Error.
  - Verified.
- Suggested Flutter feature folder: `features/auth`.
- Suggested models/entities: `UserProfile`.
- Suggested Riverpod providers/controllers: `authControllerProvider`, `currentUserProvider`.
- Dependencies: Auth repository.
- Acceptance criteria:
  - Unverified users see verification flow.
  - Verified users can continue to Home.

### Feature: OCR-Assisted Medication Entry

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want to scan medication text and confirm a draft instead of typing everything.
- Description: OCR flow that extracts possible name, dosage, quantity, and instructions, then requires manual confirmation.
- Functional requirements:
  - Capture or select image if supported.
  - Run OCR extraction.
  - Create `OcrMedicationDraft`.
  - Show confirmation form before save.
  - Fall back to manual add on failure.
- Edge cases:
  - Camera permission denied.
  - OCR extraction empty.
  - Low-quality image.
  - Extracted quantity invalid.
- UI states:
  - Permission request.
  - Camera or image input.
  - Processing.
  - Draft confirmation.
  - Error.
- Suggested Flutter feature folder: `features/ocr`.
- Suggested models/entities: `OcrMedicationDraft`, `Medication`.
- Suggested Riverpod providers/controllers: `ocrMedicationControllerProvider`, `addMedicationControllerProvider`.
- Dependencies: OCR service abstraction, medication add flow.
- Acceptance criteria:
  - OCR never saves directly.
  - User can edit all extracted fields before saving.
  - Failure returns user to manual entry path.

### Feature: As-Needed Medication Manual Logging

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want to log medication I take only when needed.
- Description: Manual-only dose logging for as-needed medications.
- Functional requirements:
  - Create as-needed medication records.
  - Allow manual dose log creation.
  - Exclude from reminders.
  - Exclude from missed-dose logic.
  - Exclude from streak penalties.
- Edge cases:
  - Multiple logs in a day.
  - Missing dosage.
  - User edits as-needed medication after logs exist.
- UI states:
  - Ready to log.
  - Logging.
  - Logged.
  - Error.
- Suggested Flutter feature folder: `features/dose_tracking`.
- Suggested models/entities: `Medication`, `DoseLog`.
- Suggested Riverpod providers/controllers: `doseActionControllerProvider`, `doseLogRepositoryProvider`.
- Dependencies: Medication repository, dose repository.
- Acceptance criteria:
  - As-needed logs save successfully.
  - As-needed logs never create Missed records.
  - As-needed logs do not affect streak.

### Feature: Global Streak

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want motivation from seeing my completed routine streak.
- Description: Global streak based on completed scheduled medication days.
- Functional requirements:
  - Day complete when all scheduled medications are Taken or Skipped.
  - Missed unresolved doses break completion.
  - Late Taken can restore day completion.
  - As-needed logs ignored.
- Edge cases:
  - No scheduled medications.
  - Medication added mid-day.
  - Time zone change.
- UI states:
  - No streak yet.
  - Active streak.
  - Streak restored.
- Suggested Flutter feature folder: `features/progress`.
- Suggested models/entities: `AdherenceSummary`, `DoseLog`.
- Suggested Riverpod providers/controllers: `streakProvider`.
- Dependencies: Dose logs, schedule calculation.
- Acceptance criteria:
  - Complete days increment streak.
  - Unresolved missed scheduled dose breaks day completion.

### Feature: Per-Medication Adherence Percentage

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want to understand consistency for each scheduled medication.
- Description: Basic adherence metric per scheduled medication.
- Functional requirements:
  - Calculate adherence from scheduled dose logs.
  - Count Taken and Skipped as day completion for streak.
  - Count Missed as negative for adherence unless resolved late based on product rule.
  - Exclude as-needed medications.
- Edge cases:
  - No logs.
  - Medication newly created.
  - Late taken status.
- UI states:
  - Not enough data.
  - Percentage available.
  - Loading.
- Suggested Flutter feature folder: `features/progress`.
- Suggested models/entities: `AdherenceSummary`, `DoseLog`.
- Suggested Riverpod providers/controllers: `adherenceSummaryProvider`.
- Dependencies: Dose repository.
- Acceptance criteria:
  - Scheduled medication shows adherence percentage.
  - As-needed medication is excluded from adherence penalty.

### Feature: Basic Progress Screen

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want a simple progress view for streak and adherence.
- Description: Progress screen using teal only for data visuals.
- Functional requirements:
  - Show global streak.
  - Show per-medication adherence.
  - Use Clinical Performance Lab colors.
  - Avoid clinical outcome language.
- Edge cases:
  - No medication data.
  - Only as-needed medications.
  - Free history limit reached.
- UI states:
  - Empty.
  - Loading.
  - Loaded.
  - Error.
- Suggested Flutter feature folder: `features/progress`.
- Suggested models/entities: `AdherenceSummary`.
- Suggested Riverpod providers/controllers: `adherenceSummaryProvider`, `streakProvider`.
- Dependencies: Dose repository, entitlement state.
- Acceptance criteria:
  - Progress screen renders basic stats.
  - Teal is used only for data visuals.

### Feature: Pill-Count Refill Reminders

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want to know when my medication quantity may be running low.
- Description: Simple refill tracking based on current quantity, dose quantity, threshold, and estimated runout date.
- Functional requirements:
  - Capture current quantity.
  - Capture dose quantity.
  - Capture reminder threshold.
  - Calculate estimated runout date.
  - Surface refill reminder when threshold is reached.
- Edge cases:
  - Quantity unknown.
  - Dose quantity zero.
  - As-needed medication with irregular usage.
  - User manually updates count.
- UI states:
  - Disabled.
  - Editing.
  - Active.
  - Threshold reached.
  - Invalid fields.
- Suggested Flutter feature folder: `features/refills`.
- Suggested models/entities: `RefillInfo`, `Medication`.
- Suggested Riverpod providers/controllers: `refillReminderProvider`.
- Dependencies: Medication repository.
- Acceptance criteria:
  - Valid refill fields produce estimated runout date.
  - Threshold reached state is visible.

### Feature: Notification Settings

- Release phase: V1 launch.
- Tier: Free.
- Priority: P1.
- User story: As a user, I want control over medication reminder notifications.
- Description: Settings for notification permission, reminder toggles, and privacy-conscious content.
- Functional requirements:
  - Show notification permission state.
  - Allow reminder enable or disable.
  - Default to generic notification text without medication names.
- Edge cases:
  - Permission denied.
  - Permission changed in iOS Settings.
  - Notifications unavailable.
- UI states:
  - Permission unknown.
  - Granted.
  - Denied.
  - Disabled.
- Suggested Flutter feature folder: `features/settings`.
- Suggested models/entities: `NotificationPreference`.
- Suggested Riverpod providers/controllers: `notificationSettingsProvider`.
- Dependencies: Notification service.
- Acceptance criteria:
  - User can see and update notification preferences.
  - Medication names are hidden by default.

## 4. V1 Pro Features

### Feature: Pro Upgrade Screen

- Release phase: V1 launch.
- Tier: Pro.
- Priority: P1.
- User story: As a user, I want to understand Pro benefits and upgrade when useful.
- Description: Subscription screen for monthly and yearly plans.
- Functional requirements:
  - Show $3.99/month and $29.99/year plans.
  - Show unlimited medications.
  - Show advanced stats, future caregiver sharing, future AI insights, future PDF export, and future multiple caregiver support as Pro roadmap benefits.
  - Start purchase flow.
  - Restore purchases.
- Edge cases:
  - Purchase cancelled.
  - Store unavailable.
  - Restore finds no purchase.
- UI states:
  - Loading offerings.
  - Offerings loaded.
  - Purchasing.
  - Purchase success.
  - Purchase error.
- Suggested Flutter feature folder: `features/subscriptions`.
- Suggested models/entities: `SubscriptionEntitlement`.
- Suggested Riverpod providers/controllers: `subscriptionControllerProvider`, `entitlementProvider`.
- Dependencies: RevenueCat SDK.
- Acceptance criteria:
  - Plan prices are visible.
  - Purchase success unlocks Pro entitlement.
  - Restore action exists.

### Feature: Unlimited Medications

- Release phase: V1 launch.
- Tier: Pro.
- Priority: P1.
- User story: As a Pro user, I want to track more than 5 medications.
- Description: Entitlement-based medication limit.
- Functional requirements:
  - Free users can create up to 5 active medications.
  - Pro users can create unlimited active medications.
  - Free users at limit see Pro upgrade entry point.
- Edge cases:
  - Pro expires with more than 5 active medications.
  - Entitlement loading failure.
  - Medication archived then new medication added.
- UI states:
  - Under free limit.
  - At free limit.
  - Pro active.
  - Entitlement loading.
- Suggested Flutter feature folder: `features/subscriptions`.
- Suggested models/entities: `SubscriptionEntitlement`, `Medication`.
- Suggested Riverpod providers/controllers: `entitlementProvider`, `medicationListProvider`.
- Dependencies: RevenueCat entitlement, medication repository.
- Acceptance criteria:
  - Free user cannot create sixth active medication.
  - Pro user can create more than 5 medications.

### Feature: Advanced Stats Placeholder

- Release phase: V1 launch.
- Tier: Pro.
- Priority: P2.
- User story: As a Pro user, I want to see that deeper stats are part of the Pro roadmap.
- Description: Simple gated entry point without full advanced stats implementation.
- Functional requirements:
  - Show Pro-gated stats entry point.
  - Avoid pretending advanced stats are complete if they are not.
  - Route Free users to Pro Upgrade.
- Edge cases:
  - Pro user taps unavailable feature.
  - Feature hidden by remote config later.
- UI states:
  - Gated.
  - Coming soon.
  - Available in future.
- Suggested Flutter feature folder: `features/progress`.
- Suggested models/entities: `SubscriptionEntitlement`.
- Suggested Riverpod providers/controllers: `entitlementProvider`.
- Dependencies: Subscription state.
- Acceptance criteria:
  - Placeholder does not imply clinical analysis.
  - Free users see Pro upgrade path.

### Feature: Future AI Insights Placeholder

- Release phase: V1 launch.
- Tier: Pro.
- Priority: P2.
- User story: As a Pro user, I want to know that pattern insights are planned.
- Description: Waitlist-style or coming-soon entry point for future pattern-based insights.
- Functional requirements:
  - Present as future feature.
  - Describe pattern-based routine observations only.
  - Avoid medical advice or clinical recommendations.
- Edge cases:
  - User expects feature to be live.
  - Entitlement unavailable.
- UI states:
  - Coming soon.
  - Gated for Free.
- Suggested Flutter feature folder: `features/insights`.
- Suggested models/entities: `SmartInsight`.
- Suggested Riverpod providers/controllers: `smartInsightsProvider`.
- Dependencies: Subscription state.
- Acceptance criteria:
  - Copy says future or coming soon.
  - Copy avoids clinical claims.

## 5. Future v1.5 Caregiver Features

### Feature: Caregiver Invite

- Release phase: Future v1.5.
- Tier: Future Pro.
- Priority: P1.
- User story: As a user, I want to invite a caregiver to read my routine updates.
- Description: Pro-gated future invite flow requiring caregiver account.
- Functional requirements:
  - Caregiver must have an account.
  - Access is read-only.
  - Invite is permanent until revoked.
  - Optional expiration may be set during invite creation.
- Edge cases:
  - Caregiver email not registered.
  - Invite expired.
  - Invite already active.
- UI states:
  - Create invite.
  - Pending.
  - Accepted.
  - Expired.
  - Revoked.
- Suggested Flutter feature folder: `features/caregiver`.
- Suggested models/entities: `CaregiverInvite`, `CaregiverAccess`.
- Suggested Riverpod providers/controllers: `caregiverInviteControllerProvider`.
- Dependencies: Auth, backend sharing rules, entitlement state.
- Acceptance criteria:
  - Caregiver cannot edit medication data.
  - User can revoke access instantly.

### Feature: Caregiver Dashboard

- Release phase: Future v1.5.
- Tier: Future Pro.
- Priority: P1.
- User story: As a caregiver, I want read-only updates about a user's routine.
- Description: Read-only caregiver surface.
- Functional requirements:
  - Show permitted routine status.
  - No medication editing.
  - Respect privacy defaults.
  - Avoid medication names in notifications and emails by default.
- Edge cases:
  - Access revoked while dashboard is open.
  - User deletes account.
  - Caregiver account deleted.
- UI states:
  - Loading.
  - Access active.
  - Access revoked.
  - Error.
- Suggested Flutter feature folder: `features/caregiver`.
- Suggested models/entities: `CaregiverAccess`, `AdherenceSummary`.
- Suggested Riverpod providers/controllers: `caregiverInviteControllerProvider`.
- Dependencies: Backend sharing rules, auth.
- Acceptance criteria:
  - Caregiver sees read-only data only.
  - Revocation removes access immediately.

### Feature: Daily Caregiver Email Summary

- Release phase: Future v1.5.
- Tier: Future Pro.
- Priority: P1.
- User story: As a caregiver, I want a daily summary without sensitive medication details by default.
- Description: Backend-generated daily email summary.
- Functional requirements:
  - Send daily summary to approved caregiver.
  - Use generic medication wording by default.
  - Stop sending after revocation.
- Edge cases:
  - Email bounce.
  - Access revoked before send.
  - User has no scheduled medications.
- UI states:
  - Enabled.
  - Disabled.
  - Delivery unavailable.
- Suggested Flutter feature folder: `features/caregiver`.
- Suggested models/entities: `CaregiverAccess`, `NotificationPreference`.
- Suggested Riverpod providers/controllers: `caregiverInviteControllerProvider`.
- Dependencies: Backend scheduler, email provider.
- Acceptance criteria:
  - Revoked caregiver receives no future summaries.
  - Email avoids medication names by default.

## 6. Future AI/Stats/Export Features

### Feature: AI-Lite Smart Insights

- Release phase: Future.
- Tier: Future Pro.
- Priority: P2.
- User story: As a user, I want simple observations about my routine patterns.
- Description: Pattern-based insights such as "You usually miss evening doses on weekends." Not LLM-based in the first version.
- Functional requirements:
  - Use dose logs and schedule metadata.
  - Generate routine pattern observations.
  - Avoid medical advice.
  - Avoid diagnosis, treatment, or outcome claims.
- Edge cases:
  - Not enough data.
  - Pattern is weak.
  - User has only as-needed logs.
- UI states:
  - Not enough data.
  - Insights available.
  - Loading.
- Suggested Flutter feature folder: `features/insights`.
- Suggested models/entities: `SmartInsight`, `DoseLog`.
- Suggested Riverpod providers/controllers: `smartInsightsProvider`.
- Dependencies: Dose repository, entitlement state.
- Acceptance criteria:
  - Insight is pattern-based.
  - Insight does not recommend medication changes.

### Feature: PDF Export

- Release phase: Future.
- Tier: Future Pro.
- Priority: P2.
- User story: As a user, I want to export my routine history for my own records.
- Description: Pro-gated export of medication routine logs.
- Functional requirements:
  - Generate PDF from user-selected date range.
  - Include adherence and logs.
  - Avoid clinical report positioning.
- Edge cases:
  - No data.
  - Large date range.
  - Export generation failure.
- UI states:
  - Select range.
  - Generating.
  - Ready.
  - Error.
- Suggested Flutter feature folder: `features/pdf_export`.
- Suggested models/entities: `DoseLog`, `AdherenceSummary`.
- Suggested Riverpod providers/controllers: none initially, future export controller.
- Dependencies: PDF package, file sharing.
- Acceptance criteria:
  - PDF is framed as personal records.
  - Export is Pro-gated.

### Feature: Advanced Stats

- Release phase: Future.
- Tier: Pro.
- Priority: P2.
- User story: As a user, I want deeper routine stats.
- Description: More detailed adherence and trend visualizations.
- Functional requirements:
  - Show trends over time.
  - Use teal only for data visuals.
  - Keep medical claims out of copy.
- Edge cases:
  - Sparse data.
  - History limit for Free users.
  - Medication archived.
- UI states:
  - Not enough data.
  - Loaded.
  - Error.
- Suggested Flutter feature folder: `features/progress`.
- Suggested models/entities: `AdherenceSummary`.
- Suggested Riverpod providers/controllers: `adherenceSummaryProvider`.
- Dependencies: Dose repository, entitlement state.
- Acceptance criteria:
  - Stats use routine language.
  - No clinical outcome claims.

## 7. Feature Dependencies

- Theme and routing must exist before feature screens.
- Auth state gates Home, medication, settings, subscription, and account deletion.
- Medication repository must exist before dose tracking, refills, reminders, and progress.
- Dose logs must exist before streak and adherence calculations.
- Entitlement provider must exist before Free medication limits and Pro screens.
- OCR depends on the manual add flow because OCR output must become an editable draft.
- Caregiver support depends on stable auth, backend access rules, and notification privacy settings.
- Smart insights depend on reliable dose history and adherence calculations.

## 8. Suggested Implementation Order

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

## 9. Suggested Folder Structure

```text
lib/
  app/
  core/
    constants/
    errors/
    extensions/
    routing/
    services/
    theme/
    utils/
    widgets/
  features/
    account/
    auth/
      data/
      models/
      state/
      views/
      widgets/
    caregiver/
    dose_tracking/
    home/
    insights/
    medications/
    ocr/
    onboarding/
    pdf_export/
    progress/
    refills/
    reminders/
    settings/
    subscriptions/
  generated/
```

## 10. Suggested Model List

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

## 11. Suggested Provider/Controller List

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

## 12. Acceptance Criteria By Release Phase

### V1 Launch

- iOS-only Flutter project is configured.
- Clinical Performance Lab theme is implemented.
- Auth includes email, Apple, and Google paths.
- Guest mode is absent.
- User can manually create scheduled and as-needed medications.
- OCR creates a user-confirmed draft before saving.
- Scheduled medications support reminders and missed logic.
- As-needed medications are manual logs only.
- Fixed 1-hour grace period is applied.
- No snooze exists.
- Missed doses can be marked taken later.
- Global streak and per-medication adherence are visible.
- Refill reminders use pill count.
- RevenueCat entitlement state gates medication limit and Pro screen.
- Account deletion exists.
- Copy avoids medical claims.

### v1.5

- Caregiver must have an account.
- Caregiver access is read-only.
- User can revoke access instantly.
- Daily caregiver summaries avoid medication names by default.
- Optional invite expiration is supported if included.

### Future

- Smart insights are pattern-based first.
- PDF export is Pro-gated and framed as personal records.
- Advanced stats avoid clinical interpretation.
- Multiple caregiver support remains Pro-gated.
- Configurable grace period is added only after v1.

## 13. Out-of-Scope List

- Guest mode in v1.
- Snooze in v1.
- Caregiver sharing in v1 launch.
- Full AI in v1.
- LLM-generated medical advice.
- Diagnosis, treatment, patient monitoring, or clinical claims.
- HIPAA-heavy or FDA-heavy product positioning.
- Backend overcommitment before app model stabilizes.
- Medication name exposure in notifications by default.
- Full PDF export in v1.
- Multiple caregiver support in v1.
- Configurable grace period in v1.
