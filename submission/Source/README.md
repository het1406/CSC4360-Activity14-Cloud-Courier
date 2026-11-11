# Cloud Courier — CSC 4360 Activity 14

Android Flutter app receiving real Firebase Cloud Messaging notifications. Analysis, two unit tests, ARM64 debug build, installation, launch, and T1–T4 device verification passed. The submission's `Evidence/RESULTS.md` contains observed results; the workspace copy is `docs/TEST_RESULTS.md`. T3 passed after a documented failed first dismissal attempt and an independently confirmed process termination.

## Local setup

Use Flutter 3.47.7 / Dart 3.13.5 or a compatible SDK, Android SDK and JDK 21. On the author's machine Flutter is at `/Users/hetjani/development/flutter_activity09/bin/flutter`; add your own SDK bin directory to PATH.

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --target-platform android-arm64
flutter devices
flutter run -d DEVICE_ID
```

The ARM64 APK was installed with `adb install -r build/app/outputs/flutter-apk/app-debug.apk`, then launched with `adb shell am start -n edu.student.hetjani.campus_supply_desk/edu.student.hetjani.cloud_courier.MainActivity`. `flutter run` was not used for the recorded tests.

Dependencies are locked to Firebase Core 4.15.2 and Messaging 16.7.1. Both PNG assets are bundled. Native Android configuration and Gradle wrapper are included; machine-specific `local.properties` is omitted and Flutter regenerates it. Android is the only supported/configured platform.

Firebase project `inclass12-ee8cb` belongs to the user. Registered application ID is `edu.student.hetjani.campus_supply_desk`; Kotlin namespace is `edu.student.hetjani.cloud_courier`. Generated FlutterFire options and native google-services.json came from the user's previous coursework. Google Services Gradle plugin 4.4.4 processes the native config. These files contain Firebase client identifiers, not privileged service-account keys. User authorized replacement of the previous app on the test emulator; earlier project source/authentication was untouched. Installing this package replaces any app with that same application ID.

To regenerate configuration using your authorized Firebase login and installed Firebase/FlutterFire CLIs:

```sh
firebase login
flutterfire configure --project=inclass12-ee8cb --platforms=android --android-package-name=edu.student.hetjani.campus_supply_desk
```

## Firebase Console sending instructions

1. Open the app on Android with Google Play services, grant notifications, and confirm permission/token diagnostics.
2. Privately inspect `_token`'s argument in a Flutter debugger, or evaluate the service's `tokenForPrivateConsoleUse()` method. Copy the current token directly to Firebase Console's test-device field. Never log, commit, or screenshot it. Resume execution before sending.
3. In project `inclass12-ee8cb`, open Messaging and create a notification. Title: **New promotion**. Body: **Switch the screen to the promo asset**. Under additional options/custom data, add two string rows: `action=update_ui` and `asset=promo`. Use **Send test message** with the current registration token. Ensure custom data is included.
4. T1: foreground send. T2: Home/background, send, tap the notification. T3: dismiss from recents, confirm no process using `adb shell pidof edu.student.hetjani.campus_supply_desk`, send, and open only by tapping the notification. T4: foreground send with `asset=unknown`. Capture handler, count, ID, title/image, and diagnostic after each test.

Recorded tests used authenticated HTTP v1 sends, not the Console UI. A redacted complete request is in the submission's Evidence/PAYLOAD.json. The following is conceptual content, not a full HTTP request:

```json
{
  "notification": {"title": "New promotion", "body": "Switch the screen to the promo asset"},
  "data": {"action": "update_ui", "asset": "promo"}
}
```

Only `action` and `asset` are accepted. `default` and `promo` map to known PNG paths and fixed titles. Missing, unsupported, non-string assets, wrong actions, or extra keys are rejected. Rejection preserves title/image while updating metadata and diagnostics. Repeated selections still increment the event counter. Counter includes foreground receipts and notification-open events during this launch, not total server deliveries.

## Architecture and troubleshooting

- `main.dart` initializes Firebase, registers the top-level entry-point background handler, then starts the UI.
- `FcmService` owns subscriptions, notification permission/token checks and disposal guards. It routes `onMessage`, `onMessageOpenedApp`, and `getInitialMessage` to shared validation.
- `onBackgroundMessage` initializes Firebase and logs only a generic processing message; it never modifies widgets. Its registration is not a guarantee of delivery.
- `CourierState` validates data and tracks metadata; `CourierHome` renders it and checks widget lifetime.
- Foreground system banners are not required to observe `onMessage`. Settings force-stop prevents delivery until reopening; do not use it for T3.
- If build fails, check disk space. A stale Gradle history lock after disk exhaustion was fixed by stopping Gradle and clearing this project's disposable `android/.gradle` cache, then rebuilding.
- Confirm real dismissal for T3: the initial swipe during testing left the process alive and returned the background callback. The successful retry had no process before the send.

## Submission status

Original instructor Activity 14 instructions/rubric were not present: only a user-supplied implementation brief was available. Evidence-format requirements, reflection length, AI policy, GitHub requirement, LMS folder and acceptance of late work remain unverified. The brief states November 9, 2026, 11:59 PM EST with no late submissions. Check actual LMS availability yourself. Private GitHub repository: https://github.com/het1406/CSC4360-Activity14-Cloud-Courier. Publishing was authorized by the user; grader access is not yet verified. No LMS submission was made.
