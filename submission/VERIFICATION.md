# Verification report — Cloud Courier

Final device testing: November 10, 2026 (America/New_York). This project verification report is not instructor-issued material. See Evidence/RESULTS.md in the ZIP for the complete device record. The local equivalent is docs/TEST_RESULTS.md.

## Commands and outcomes

Project: `/Users/hetjani/Desktop/INCLASS14`. Flutter/Dart commands used binaries under `/Users/hetjani/development/flutter_activity09/bin/`. adb/emulator used `/Users/hetjani/Library/Android/sdk/platform-tools/` and `emulator/`.

| Command | Actual outcome |
|---|---|
| `flutter doctor -v` | Flutter 3.47.7, Dart 3.13.5; Android toolchain passes; JDK 21. Flutter/Dart absent from shell PATH. Xcode incomplete, CocoaPods absent; iOS not targeted |
| `flutter create --platforms=android --org edu.student.hetjani --project-name cloud_courier .` | Created project in previously empty directory |
| `flutter pub get` | PASS; Core 4.15.2, Messaging 16.7.1 |
| `dart format lib test` | Completed |
| `flutter analyze` | PASS, no issues; repeated successfully before final build |
| `flutter test` | PASS, 2 unit tests; repeated successfully before final build |
| `flutter build apk --debug` | Initial attempt failed: disk exhaustion; automatic retry also failed |
| `flutter build apk --debug --target-platform android-arm64` | First retry failed on stale Gradle execution-history lock |
| `JAVA_HOME=/Users/hetjani/develop/jdk21/Contents/Home ./gradlew --stop` (android directory) | Stopped daemon; removed only this project's disposable android/.gradle cache |
| `flutter build apk --debug --target-platform android-arm64` | PASS; built build/app/outputs/flutter-apk/app-debug.apk in 57.2 seconds |
| `flutter devices`, `adb devices -l` | Initially no Android device; subsequently emulator-5554 connected |
| `emulator -avd Campus_Class -no-snapshot-save -no-audio` | Earlier attempt failed on insufficient disk space |
| `emulator -avd Pixel_4a -no-snapshot-save -no-audio -memory 2048` | Booted Android 17/API 37 with Google Play services |
| `npm exec --yes --package firebase-tools -- firebase projects:list --json` | SUCCESS; authenticated account can access inclass12-ee8cb |
| `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk` | Initial attempt before boot completion rejected; retry SUCCESS |
| `adb -s emulator-5554 shell am start -n edu.student.hetjani.campus_supply_desk/edu.student.hetjani.cloud_courier.MainActivity` | SUCCESS; app displayed and permission dialog accepted |
| `flutter run` | Not used; launch performed through adb as above |
| Authenticated HTTPS POST to `https://fcm.googleapis.com/v1/projects/inclass12-ee8cb/messages:send` | Five accepted sends: T1, T2, T3 first attempt, T3 retry, T4. Token and authorization header held in memory, excluded from submission |
| `adb -s emulator-5554 shell pidof edu.student.hetjani.campus_supply_desk` | T3 first attempt: PID 3220. After successful dismissal: exit 1, no process, before retry send |
| `adb -s emulator-5554 exec-out screencap -p` | Captured original screenshots, each visually inspected |
| `adb -s emulator-5554 shell dumpsys package edu.student.hetjani.campus_supply_desk` | POST_NOTIFICATIONS granted=true; only relevant diagnostic recorded |
| `git init`; `git status --short --branch` | Initially local only; prepared for authorized GitHub publication in the final handoff |
| `python3 scripts/package_submission.py` | Builds ZIP; reopens it; validates entry CRCs, SHA-256 hashes and required entries |

Python sender initially lacked a working default certificate bundle; using the installed certifi CA bundle resolved HTTPS validation without disabling certificate checking. This was a local sender setup issue, not an app defect. Firebase's legacy Kotlin plugin compatibility warning remains non-fatal. No app changes occurred during final device testing.

## Configuration and preservation

User confirmed ownership of `inclass12-ee8cb` and explicitly authorized replacing Campus Supply Desk on the emulator. Its Firebase client config was reused with the matching registered package ID. Prior coursework source and authentication were not changed. No other student's source, screenshots, reflection, repository, or Firebase configuration was used. Sender credentials and full device tokens are excluded. Firebase client API/app identifiers are normal client configuration, not service-account credentials.

## File inventory

- Source/lib/main.dart: initialization and background registration.
- Source/lib/services/fcm_service.dart: listener ownership, permissions/token diagnostics, three UI routes, cleanup; separate background handler.
- Source/lib/models/courier_state.dart: fixed asset/title allowlist and metadata.
- Source/lib/screens/courier_home.dart: proof UI and widget lifetime checks.
- Source/lib/firebase_options.dart and Source/android/app/google-services.json: matching client configuration.
- Source/android/: native project, manifest, Google Services plugin, Gradle wrapper (including jar and launchers).
- Source/assets/images/default.png and promo.png: locally generated neutral raster art.
- Source/pubspec.yaml, pubspec.lock, tests, lint config, README.
- Evidence/: four primary labeled screenshots, supplementary notification/failed-attempt captures, process check, results, redacted payload and build/source hashes.
- Reflection.md: three responses within 150–250 words, with actual test observations.
- SUBMISSION_NOTE.md: upload instructions and unverified requirements.
- SHA256SUMS.txt: package integrity manifest.

## Rubric alignment — based on supplied brief, not verified original rubric

| Category | Evidence | Remaining limitation |
|---|---|---|
| Engagement/ownership (10) | User-owned project confirmed; actual fixes and T3 retry documented | Student must review and be able to explain submitted work; instructor-specific rules unknown |
| Conceptual understanding (25) | Four APIs distinguished; T1–T3 visibly show receive/open/cold-start handlers | No guarantee of instructor scoring |
| Effective application (30) | Analysis/tests/build/launch pass; real T1–T4 behavior observed; cleanup and allowlist implemented | One Android emulator only, as requested; asynchronous disposal covered by guards, not dedicated integration tests |
| Testing/evidence (20) | Four final PASS rows, original screenshots, message IDs, device/permission and T3 process check | Whether instructor requires recording instead of screenshots is unknown |
| Creative problem-solving (15) | Invalid asset preserves UI; ineffective T3 dismissal diagnosed via process check; concrete testability improvement | Student review of reflection required |

No grade is guaranteed. GitHub publication subsequently authorized by user. Private repository created in the authenticated account: https://github.com/het1406/CSC4360-Activity14-Cloud-Courier. Grader access is not verified. LMS upload, actual due-date/late-work rules, evidence format and course policies must be checked against the missing instructor document.
