# MedSync Product Requirements Document

## 1. Product Summary

MedSync is an iOS-only Flutter app for personal medication reminders, adherence tracking, refill awareness, and routine accountability. The product is a wellness and routine tracker, not a medical device, clinical platform, patient monitoring product, or treatment tool.

Medication tracking is the core product. Supplements, refill tracking, streaks, caregiver support, progress stats, and future AI insights support the medication reminder loop without changing the app's wellness positioning.

## 2. Problem Statement

People often lose track of scheduled medications, as-needed logs, refill timing, and whether they completed their daily routine. Existing apps can feel clinical, heavy, or too complex for a solo personal routine. MedSync should provide a focused, calm medication routine experience that helps users record what happened and review their consistency over time.

## 3. Target Audience

- Adults managing their own recurring medication or supplement routines.
- Users who want reminders, simple logging, and refill awareness without a clinical workflow.
- Users comfortable using an iPhone app with account-based sync.
- Future audience: caregivers who need read-only visibility with user permission.

## 4. Product Positioning

MedSync is a personal wellness medication routine tracker. It helps users remember, log, and review medication routines. It must not claim to diagnose, treat, prevent, monitor patients, improve health outcomes, replace professional medical advice, or provide clinical recommendations.

## 5. Goals

- Provide a reliable scheduled medication reminder and logging flow.
- Support manual and OCR-assisted medication entry with user confirmation.
- Track taken, skipped, missed, and late taken medication events.
- Show motivational global streaks and basic adherence stats.
- Support pill-count refill reminders in v1.
- Monetize with a simple freemium model through RevenueCat.
- Keep backend implementation flexible, with Firebase as the likely initial choice.

## 6. Non-Goals

- No diagnosis, treatment, clinical decision support, or medical advice.
- No patient monitoring positioning.
- No HIPAA-heavy or FDA-heavy positioning.
- No caregiver sharing in v1 launch.
- No PDF export in v1 launch.
- No full AI or LLM-based medical insight generation in v1.
- No snooze behavior in v1.
- No guest mode in v1.
- No configurable missed-dose grace period in v1.

## 7. V1 Scope

- Account creation with email, Apple Sign In, and Google Sign In.
- Email login, password reset, email verification, and social auth loading states.
- Manual medication creation.
- OCR-assisted medication entry that creates a draft requiring user confirmation.
- Scheduled medication reminders.
- As-needed medication manual logging.
- Dose statuses: Taken, Skipped, Missed.
- Fixed 1-hour missed-dose grace period.
- Late taken support.
- Missed dose review.
- Global streak.
- Per-medication adherence percentage.
- Basic progress screen.
- Pill-count refill reminders.
- Notification settings.
- Free and Pro entitlement handling through RevenueCat.
- Account deletion.
- Basic local app settings.

## 8. Future Scope

- v1.5 caregiver invite and read-only access.
- Daily caregiver email summaries.
- Caregiver dashboard.
- Instant caregiver revocation.
- Optional caregiver invite expiration.
- Generic caregiver notifications that avoid medication names by default.
- Pattern-based smart insights.
- Advanced stats.
- PDF export.
- Multiple caregiver support.
- Configurable grace period.
- More detailed notification preferences.
- More robust OCR extraction.
- Data export and delete management.

## 9. User Personas

### Routine Tracker

Uses MedSync to remember scheduled medications and keep a simple history. Needs clear daily status, reminders, and quick taken or skipped actions.

### As-Needed Logger

Uses MedSync to log occasional medications without reminders or streak penalties. Needs fast manual logging and history separation from scheduled routines.

### Refill Planner

Wants to avoid running out of medication. Needs pill count, dose quantity, threshold, and estimated runout date.

### Future Caregiver

Has a MedSync account and read-only access granted by a user. Needs high-level routine updates without editing access or unnecessary exposure of medication names.

## 10. Core User Journeys

### Create Account

User opens the app, completes onboarding, signs up with email or social auth, verifies email when required, and lands on Home.

### Add Scheduled Medication

User opens Add Medication, enters medication details manually or scans a label, confirms extracted fields, sets schedule and refill details, then saves.

### Complete Today's Dose

User opens Home, sees due medication items, marks each scheduled dose Taken or Skipped, and sees daily completion and streak state update.

### Handle Missed Dose

A scheduled dose passes the fixed 1-hour grace period and becomes Missed. User reviews it on the Missed Dose screen and may mark it taken later. Late completion restores day completion but can remain visually or internally marked as Late Taken.

### Log As-Needed Medication

User opens a medication detail or quick logging flow, records an as-needed dose, and the event appears in history without creating missed status or affecting streaks.

### Manage Refill Reminder

User enters current quantity, dose quantity, and reminder threshold. MedSync calculates estimated runout date and surfaces refill reminders.

### Upgrade to Pro

User reaches the free tier medication limit or opens Pro Upgrade, views Pro benefits, purchases through RevenueCat, and receives updated entitlement state.

## 11. Functional Requirements

- App must be iOS-only at launch.
- App must require an account in v1.
- App must support scheduled and as-needed medication types.
- App must keep scheduled missed-dose logic separate from as-needed logging.
- App must support manual add and OCR-assisted draft add.
- App must require user confirmation before saving OCR-extracted medication details.
- App must support Free and Pro entitlement checks.
- App must allow account deletion.
- App must use copy that avoids medical advice and clinical claims.

## 12. Non-Functional Requirements

- Flutter app with feature-based folder structure.
- Riverpod v3.x.x for state management.
- `riverpod_generator` and `riverpod_annotation` for generated providers.
- Freezed and `json_serializable` for immutable models and serialization.
- Generated files must output to `lib/generated/`.
- No `flutter_hooks`.
- UI-first implementation with business logic added progressively.
- Backend details remain flexible. Firebase is the likely initial backend for Auth, Firestore, FCM, Cloud Functions, and Cloud Scheduler.
- Light mode only.
- App must remain responsive on supported iPhone screen sizes.

## 13. Authentication Requirements

- Email sign up.
- Email login.
- Forgot password.
- Reset password.
- Email verification.
- Apple Sign In.
- Google Sign In.
- Social auth loading state.
- No guest mode in v1.
- Signed-in user identity must be available to medication, subscription, and account flows.

## 14. Medication Tracking Requirements

- Medication can be scheduled or as-needed.
- Medication and supplement entries use the same routine model.
- Scheduled medications can have reminders and missed-dose behavior.
- As-needed medications are manual logging only.
- User can edit medication details after creation.
- User can view medication list and medication detail.
- Free tier must limit active medications to 5.
- Pro tier must allow unlimited medications.

## 15. Reminder and Missed-Dose Requirements

- Scheduled medications support reminders.
- No snooze in v1.
- Grace period is fixed at 1 hour in v1.
- After grace period, unresolved scheduled doses become Missed.
- Missed scheduled doses affect adherence and streak unless resolved later.
- User can mark missed medication as taken later.
- Late taken should restore day completion and be trackable internally or visually.
- As-needed medications must never create missed doses.

## 16. Streak and Adherence Requirements

- Global streak is shown for motivation.
- A day is complete when all scheduled medications are Taken or intentionally Skipped.
- Missed items break or reduce completion unless later resolved by the user.
- Per-medication adherence percentage is used for stats.
- As-needed medications do not affect streaks or adherence penalties.

## 17. Refill Reminder Requirements

- Refill reminders are pill-count based in v1.
- Fields:
  - Current quantity.
  - Dose quantity.
  - Reminder threshold.
  - Estimated runout date.
- Refill calculations must be based on scheduled dose quantity and user-provided inventory fields.
- Refill reminder copy must avoid urgent clinical language.

## 18. OCR-Assisted Entry Requirements

- OCR scan should extract possible medication name, dosage, quantity, and instructions.
- OCR output must be treated as a draft.
- User must manually confirm or edit OCR results before saving.
- OCR confidence should not be presented as medical certainty.
- OCR failure should fall back to manual entry.

## 19. Subscription and Entitlement Requirements

- RevenueCat handles subscription products and entitlement state.
- Free tier:
  - Up to 5 medications.
  - 90 days of history.
  - Refill reminders.
  - Basic streaks.
  - Basic progress.
- Pro tier:
  - $3.99/month.
  - $29.99/year.
  - Unlimited medications.
  - Advanced stats entry point.
  - Future caregiver sharing.
  - Future AI insights.
  - Future PDF export.
  - Future multiple caregiver support.
- Pro-only future features must remain gated until implemented.

## 20. Privacy and Safety Requirements

- Avoid medication names in push notifications by default.
- Future caregiver emails and notifications should avoid medication names by default.
- App copy must tell users to follow professional medical advice and medication labels.
- App must not provide dosing recommendations.
- App must support account deletion.
- Sensitive data access should require authenticated user context.
- Data model should keep user-owned records scoped to the authenticated user.

## 21. App Store Compliance Notes

- Position the app as a wellness routine tracker.
- Avoid medical device, treatment, diagnosis, monitoring, or clinical claims.
- Use Apple Sign In if third-party social login is offered.
- Provide account deletion.
- Provide clear subscription pricing and entitlement information.
- Ensure OCR flow requires confirmation before saving.
- Keep notification content privacy-conscious.

## 22. Analytics Events To Track

- `app_opened`
- `onboarding_started`
- `sign_up_started`
- `sign_up_completed`
- `login_completed`
- `email_verification_sent`
- `medication_add_started`
- `medication_created_manual`
- `medication_created_ocr`
- `ocr_scan_started`
- `ocr_scan_confirmed`
- `dose_marked_taken`
- `dose_marked_skipped`
- `dose_marked_missed`
- `dose_marked_late_taken`
- `missed_dose_review_opened`
- `refill_info_added`
- `refill_threshold_reached`
- `progress_viewed`
- `pro_screen_viewed`
- `purchase_started`
- `purchase_completed`
- `purchase_failed`
- `account_deletion_started`
- `account_deleted`

## 23. Data Model Overview At Product Level

- `UserProfile`: authenticated user metadata, preferences, subscription state reference.
- `Medication`: core routine item with type, name, dosage, instructions, active state, and refill info reference.
- `MedicationSchedule`: scheduled timing and reminder configuration for scheduled medications.
- `DoseLog`: event record for Taken, Skipped, Missed, and Late Taken.
- `ReminderConfig`: notification timing and enabled state.
- `RefillInfo`: current quantity, dose quantity, threshold, estimated runout date.
- `AdherenceSummary`: per-medication and global calculated stats.
- `SubscriptionEntitlement`: RevenueCat-derived entitlement state.
- `OcrMedicationDraft`: extracted fields awaiting user confirmation.
- `NotificationPreference`: privacy and notification settings.
- `CaregiverInvite`: future invite metadata.
- `CaregiverAccess`: future read-only access grant.
- `SmartInsight`: future pattern-based insight.

## 24. Screen Inventory

- Splash/Welcome.
- Onboarding/Auth.
- Sign Up.
- Log In.
- Forgot Password.
- Reset Password.
- Email Verification.
- Social Auth Loading.
- Home.
- Add Medication.
- Medications List.
- Medication Detail/Edit.
- Progress.
- Missed Dose.
- Refill Reminder.
- Notification Settings.
- Pro Upgrade.
- Account Deletion.
- Basic Local Settings.
- Caregiver Invite Pro, future.
- Caregiver Dashboard, future.
- Profile Management Pro, future or reconsidered.
- PDF Export Pro, future.

## 25. Release Phases

### Phase 0: Foundation

- Flutter iOS app setup.
- Clinical Performance Lab theme.
- Routing shell.
- Feature folder structure.
- Generated code configuration.

### Phase 1: Account And Shell

- Auth flows.
- Home shell.
- Settings shell.
- Account deletion structure.

### Phase 2: Medication Core

- Manual medication add.
- Medication list.
- Medication detail/edit.
- Scheduled medication model.
- As-needed medication logging.

### Phase 3: Dose Logic And Progress

- Today dashboard.
- Taken, Skipped, Missed, and Late Taken logic.
- Fixed 1-hour grace period.
- Streak and adherence calculations.
- Basic progress screen.

### Phase 4: Refill, OCR, And Monetization

- Pill-count refill reminders.
- OCR-assisted draft entry.
- RevenueCat entitlement structure.
- Pro Upgrade screen.

### Phase 5: Future Pro Expansion

- Caregiver v1.5.
- Advanced stats.
- Pattern-based insights.
- PDF export.

## 26. Open Questions

- Which minimum iOS version should be targeted?
- Should Firebase be confirmed before implementing auth, or should repositories remain mocked until UI is stable?
- Which OCR provider should be used initially?
- Should medication history beyond the Free 90-day limit be hidden, archived, or paywalled?
- Should Late Taken be a visible status in v1 or only an internal attribute?
- Which analytics provider should be used?
- Should push notifications use generic copy only, or allow an opt-in setting for medication names?

## 27. Acceptance Criteria

- The app is configured as iOS-only Flutter for launch scope.
- User can create and access an authenticated account using supported v1 methods.
- User can add at least one scheduled medication manually.
- User can add a medication from OCR draft only after confirming extracted fields.
- User can mark scheduled doses as Taken or Skipped.
- Scheduled doses become Missed after a fixed 1-hour grace period.
- User can mark missed doses as taken later.
- As-needed logs do not create missed doses or break streaks.
- Home shows daily medication routine state.
- Progress shows global streak and per-medication adherence percentage.
- Refill reminder supports pill count fields and estimated runout date.
- Free tier enforces up to 5 medications.
- RevenueCat entitlement state unlocks Pro medication limits.
- Account deletion flow exists.
- App copy avoids medical claims and clinical positioning.
