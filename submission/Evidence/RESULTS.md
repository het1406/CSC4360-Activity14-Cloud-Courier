# Cloud Courier — observed device results

Test date: November 10, 2026, approximately 8:14–8:17 PM America/New_York.
Device: user's Pixel_4a AVD, `emulator-5554`, model `sdk_gphone16k_arm64`, Android 17 / API 37, ARM64, Google Play services present. Notification permission: **authorized** in app; Android POST_NOTIFICATIONS `granted=true`. Token: available, masked in UI; never included in this submission.

Firebase project: `inclass12-ee8cb` (ownership confirmed by user, accessible to saved Firebase login). Package: `edu.student.hetjani.campus_supply_desk`. User explicitly authorized replacing its prior emulator installation. Earlier coursework source and authentication code were not modified.

Messages were real FCM HTTP v1 sends using the user's authenticated Firebase session, not simulated callbacks or Console screenshots. Payload: notification title `New promotion`; body prefixed with test ID; string data `action=update_ui`, `asset=promo` (T4: `unknown`); Android priority HIGH. `PAYLOAD.json` contains a redacted send example. Send acceptance alone was not counted as a pass: screenshots were captured from the emulator and inspected.

| Test ID | Expected handler/result | Observed result | PASS/FAIL/BLOCKED | Evidence filename |
|---|---|---|---|---|
| T1 | Foreground valid promo → `onMessage`, promo title/image, count increases | `onMessage`; New promotion and orange promo asset; count 0 → 1; message ID displayed | PASS | `T1_foreground.png` |
| T2 | Home/background, valid notification, tap → `onMessageOpenedApp` | Notification observed and tapped; `onMessageOpenedApp`; promo retained; count 1 → 2; new ID | PASS | `T2_background_open.png`, `T2_notification.png` |
| T3 | Dismiss recents, valid notification, tap → `getInitialMessage` | On retry, process absent before sending; notification tapped; `getInitialMessage`; promo UI; new-launch count 1 | PASS (retry) | `T3_initial_message.png`, `T3_retry_notification.png`, `T3_process_check.txt` |
| T4 | Foreground `asset=unknown` → `onMessage`, rejection, preserve title/image, increment count | `onMessage`; count 1 → 2; new ID; unsupported-asset diagnostic; same New promotion title and orange image as T3; no crash observed | PASS | `T4_invalid_asset.png`; compare `T3_initial_message.png` |

## T3 process confirmation and first attempt

The first attempted recents swipe did not establish termination: `pidof` still returned PID 3220. The subsequent notification tap produced `onMessageOpenedApp` and count 3. That attempt FAILED the expected T3 condition; original evidence is retained as `T3_attempt1_background_callback.png`, `T3_notification.png`, and `T3_recents.png`.

A second recents swipe dismissed Cloud Courier successfully. Before the retry send, `adb -s emulator-5554 shell pidof edu.student.hetjani.campus_supply_desk` returned exit 1 with empty output: **process termination independently confirmed**. No Settings force-stop or `am force-stop` was used. The new notification, not the launcher icon, opened the app. The resulting screenshot shows `getInitialMessage` and count 1. Process-check results are retained in `T3_process_check.txt`.

## Message IDs matching the screenshots

- T1: `0:1794359690916356%5382de995382de99`
- T2: `0:1794359705237920%5382de995382de99`
- T3 first attempt: `0:1794359750912037%5382de995382de99`
- T3 successful retry: `0:1794359794597489%5382de995382de99`
- T4: `0:1794359818429956%5382de995382de99`

These are message identifiers, not registration tokens. Counts include foreground receipts and notification-open events in the current launch. Supporting source/APK hashes are in `BUILD_SOURCE_SHA256.txt`; app code was unchanged throughout these tests. No video was captured. Four primary labeled original screenshots are supplied, with supplemental notification/attempt evidence. Whether a recording is mandatory cannot be verified without the actual instructor assignment.
