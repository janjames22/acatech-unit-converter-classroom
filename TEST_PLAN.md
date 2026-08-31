# Unit Converter Test Plan

**Plan date:** 2026-08-31
**Applies to:** Android, iOS/iPadOS, Web/PWA, and responsive desktop browsers

This plan verifies the converter, Assessment Mode, and progressive PWA installation without claiming capabilities that platform APIs do not provide. The current automated suite contains 95 passing VM/widget tests, and the 14-test installation-service suite also passes through Chrome's Web interop branch. Physical installation, HTTPS eligibility, offline/update, and platform-interruption acceptance remain manual release gates.

## 1. Objectives

- Prove conversion results are correct, deterministic, and appropriately formatted.
- Prove assessment classification follows one pure, deterministic state machine.
- Prevent duplicate incidents and common false positives.
- Verify reports remain accurate across navigation, suspension, restart, and storage errors.
- Verify layouts from 320 through 2560 logical pixels without overflow or clipped content.
- Verify PWA installation, update, browser compatibility, performance, accessibility, privacy, and security behavior.
- Make platform limitations visible in the product and test evidence.

## 2. Test levels

### Static checks

- Dart formatting
- flutter analyze
- Dependency and platform compatibility review
- Search for forbidden or sensitive permissions
- Search for plaintext PINs, secrets, and student data in logs

### Unit tests

- Conversion formulas and formatting
- Catalog search and filtering
- Assessment state machine with fake signals and an injected fake clock
- Duration boundary classification
- Candidate coalescing and exclusions
- Report serialization, schema migration, and repository behavior
- Controller state transitions and typed failures

### Widget tests

- Application shell and adaptive navigation
- Converter entry, swap, selectors, and result
- Search, clear action, and empty state
- Assessment start, active, end, report, and limitation copy
- PIN flows and lockout presentation
- Responsive layout, text scaling, keyboard, focus order, semantics, and errors
- Install action availability, installing, installed-hidden, and iOS manual states
- Requested install-action widths: 360, 390, 430, 768, 1024, 1366, and 1920 logical pixels
- Intentional install-prompt lifecycle suppression during an active assessment

### Integration tests

- Root monitor survives route and responsive-shell changes.
- One physical lifecycle excursion creates at most one result.
- Open candidates persist and recover without duplication.
- Reports survive application restart.
- PWA browser and installed modes behave consistently.

### Manual platform tests

Calls, notification UI, app switchers, Control Center, device lock, browser tabs, Alt+Tab, file pickers, process termination, and installation require representative real devices or operating-system environments. Emulator-only evidence is not sufficient for release acceptance.

## 3. Quality gates

A release candidate is acceptable only when:

1. flutter analyze has no unresolved errors or warnings accepted without rationale.
2. All unit, widget, and integration tests pass.
3. Android, iOS, and Web release builds complete.
4. All critical and high-priority scenarios in the platform matrix pass.
5. There are no open severity-one or severity-two defects.
6. No supported viewport has overflow, clipped controls, or page-level horizontal scrolling.
7. Monitoring reports use neutral focus/visibility terminology.
8. Known platform limitations are displayed and match this plan.
9. No forbidden monitoring permission or unrelated activity collection is present.
10. Performance and accessibility checks pass on the agreed baseline devices.

## 4. Converter test matrix

Every supported category and unit pair must cover:

| Test class | Required cases |
|---|---|
| Identity | Same source and target unit |
| Known reference | Published or independently calculated reference values |
| Forward and reverse | A to B and B to A |
| Round trip | A to B to A within documented tolerance |
| Zero | Including affine units such as temperature |
| Negative | Accepted where mathematically meaningful; otherwise validated |
| Fractional | Values below one and repeating decimal results |
| Large and small | Values near the supported formatting range |
| Precision | No premature rounding in intermediate calculations |
| Invalid input | Empty, sign only, duplicate decimal separator, nonnumeric text, unsupported magnitude |
| Formatting | Decimal precision, trailing zeros, scientific notation policy, and negative zero |

Additional assertions:

- Swap preserves the represented quantity.
- Changing either unit recalculates once with the current valid input.
- Invalid input never produces NaN or Infinity as a user-facing result.
- Search matches category and unit names case-insensitively.
- Search clear restores the complete catalog.
- An unmatched search displays an accessible empty state.

## 5. Assessment state-machine tests

All state-machine tests use injected signals and a controllable monotonic/UTC clock. They do not wait in real time.

### Exact threshold cases

| Duration | Expected duration band | Expected default treatment |
|---:|---|---|
| 0 ms | transient | ignored |
| 1,999 ms | transient | ignored |
| 2,000 ms | review | stored for review |
| 9,999 ms | review | stored for review |
| 10,000 ms | extended | stored as extended absence |
| More than 10,000 ms | extended | stored as extended absence |

Tests must prove there is no gap at two seconds, no overlap at ten seconds, and no duration-based “confirmed app switch” classification.

### Transition sequences

| Sequence | Expected result |
|---|---|
| start → focused | No event |
| inactive → resumed on mobile | No counted absence |
| inactive → hidden → paused → hidden → inactive → resumed | One candidate, one resolution |
| focusLost → focusLost → focused | One candidate, not duplicates |
| hidden for 1,999 ms → visible | Ignored |
| hidden for 2,000 ms → visible | One review event |
| hidden for 10,000 ms → visible | One extended event |
| hidden → known exclusion → visible | Excluded disposition with neutral reason |
| expected external flow → hidden → visible | Excluded only for the matching, unexpired flow token |
| hidden → process restart → resumed | One unknown process gap |
| session end while candidate is open | One neutral resolution using available evidence |
| route change while focused | No event and no monitor recreation |
| width crosses responsive breakpoint | No event and no monitor recreation |
| duplicate platform callback delivery | Idempotent state and persistence |
| wall clock moves backward | Clock anomaly, never a negative incident |

### Property and invariant tests

- At most one open candidate exists per session.
- Every resolved candidate has at most one persisted event identifier.
- A returnedAt timestamp is not earlier than leftAt without a clock-anomaly marker.
- A known exclusion cannot become recorded merely because its duration crosses ten seconds.
- Ending or deleting one session cannot mutate another session.
- Monitoring is disabled before start and after end.
- Unknown evidence never becomes a cheating or confirmed-switch label.

## 6. Monitoring scenario matrix

The expected result is based on observable evidence, not presumed user intent.

| Scenario | Expected policy |
|---|---|
| Internal route navigation | No platform absence |
| Flutter dialog or dropdown | No platform absence |
| On-screen keyboard | No platform absence |
| Notification banner with no lifecycle loss | No event |
| Notification shade or Control Center producing inactive only | Not counted on mobile |
| Biometric/system UI producing inactive only | Not counted on mobile |
| Full-screen system activity causing background | Unknown unless a supported hint or expected-flow token exists |
| Incoming call producing inactive only | Not counted |
| Full-screen call causing background | Unknown; never labeled an app switch |
| Device idle with no lifecycle change | No event |
| Android screen/keyguard with recognized hint | Excluded, subject to supported-device verification |
| iOS or Web screen lock | Indistinguishable from other hidden/background causes; unknown |
| Open app switcher and immediately return | Threshold and mobile inactive-only rules apply |
| Select another mobile app and return | Record observable not-visible duration; cause remains neutral |
| Android split-screen loses focus but remains visible | Review evidence, not “left device” |
| Web switches tab | documentHidden evidence |
| Web minimizes browser/PWA | documentHidden evidence |
| Desktop Alt+Tab | windowFocusLost evidence; foreground app is unknown |
| Browser address bar or browser chrome gets focus | Focus-loss evidence only; test false-positive policy |
| App-initiated file picker or permission UI | Matching, time-limited expected-flow exclusion |
| Browser refresh or navigation away | Persist pageHide/open candidate where available; recover neutrally |
| Browser or OS kills the process | Missing callback is allowed; recovered gap remains unknown |

Release evidence must not claim that screen lock, calls, tab switching, and app switching can always be distinguished on every platform.

## 7. Root-monitor integration tests

- Pump or launch the root application and confirm exactly one signal subscription.
- Navigate Home → Assessment → Tools → Home and confirm the same monitor identity.
- Start an assessment, navigate internally, and verify the active session remains armed.
- Rebuild MaterialApp, theme, locale, and adaptive navigation without duplicating the observer.
- Dispose the root application and confirm the subscription is released.
- Deliver a platform signal during route animation and verify one state-machine input.
- Return from background onto a different internal route and resolve the same candidate.

## 8. Local repository and report tests

### Repository contract

- Create, read, list, update, and delete sessions.
- Append events atomically and idempotently.
- Save and restore an active session and open candidate.
- Preserve UTC timestamps, duration bands, dispositions, evidence, and schema version.
- Sort sessions and incidents deterministically.
- Isolate data between sessions.
- Handle empty storage and first launch.

### Failure and migration cases

- Storage unavailable or permission denied
- Storage quota/full condition
- Corrupt or partially written record
- Unsupported future schema
- Migration from every retained schema version
- Application termination during write
- Duplicate retry after uncertain write result
- Browser storage cleared between launches

The UI must show a clear neutral error and must not invent, silently drop, or double-count incidents.

### Report calculations

- Total outside time equals the sum of included event durations under the documented policy.
- Review, extended, excluded, and unknown totals remain separate.
- An excluded event does not increase the recorded-absence count.
- Open or unknown gaps are clearly marked.
- Displayed local time is derived from stored UTC without mutating stored values.
- Deletion requires teacher authorization and follows the documented retention behavior.

## 9. Responsive UI matrix

### Breakpoint boundaries

| Width | Expected tier |
|---:|---|
| 320 | Compact |
| 599 | Compact |
| 600 | Medium |
| 1023 | Medium |
| 1024 | Expanded |
| 2560 | Expanded |

### Representative viewports

- 320 × 568
- 360 × 800
- 375 × 667
- 390 × 844
- 430 × 932
- 600 × 960
- 768 × 1024
- 1024 × 768
- 1280 × 720
- 1440 × 900
- 1920 × 1080
- 2560 × 1440

For each applicable viewport, test portrait and landscape, browser zoom, keyboard appearance, and text scale at 100%, 150%, and 200%.

Assertions:

- No RenderFlex overflow or clipped primary text.
- No page-level horizontal scrolling.
- Inputs, selectors, swap, and result remain reachable.
- Primary actions have accessible names and adequate touch targets.
- Focus order follows visual order.
- Bottom navigation changes to rail/sidebar only at the documented boundaries.
- Grid columns respond to available width and content.
- Dialogs fit or scroll within the viewport.
- Active assessment state and timer remain legible without relying only on color.
- Breakpoint changes do not reset conversion input or an active assessment.

## 10. Platform and browser matrix

| Environment | Form factors | Required coverage |
|---|---|---|
| Android native | Small phone, current mid-range phone, large phone/tablet | Lifecycle, keyboard, notification UI, lock, call, split-screen where supported, restart |
| iOS native | Small iPhone, current iPhone, iPad | Lifecycle, Control Center, lock, call, multitasking, restart |
| Android Chrome Web/PWA | Phone and tablet | Browser mode, install mode, tab/app switch, lock, offline/update policy |
| iOS/iPadOS Safari Web/PWA | iPhone and iPad | Browser mode, Add to Home Screen, visibility, lock, process eviction |
| Windows Web | Chrome, Edge, Firefox | Resize, zoom, tab switch, Alt+Tab, minimize, install where supported |
| macOS Web | Safari, Chrome, Firefox | Resize, zoom, tab switch, application switch, minimize, install where supported |

Record the exact OS, browser, Flutter version, device, build identifier, and date with every manual test run. Final minimum OS/browser versions are set only after the dependency audit and release support policy are approved.

Native Windows/macOS/Linux testing is out of scope until native desktop runners are explicitly added.

## 11. PWA verification

- Manifest parses and contains approved name, short name, icons, theme/background colors, start URL, scope, and standalone display.
- 192 × 192 and 512 × 512 regular and maskable icons render correctly.
- Favicon and installed icon use approved branding.
- The application is served over HTTPS in production.
- Installation succeeds in each supported install flow.
- Browser and standalone launches restore only intended local state.
- Service-worker/update behavior matches the supported Flutter version and does not strand users on incompatible report schemas.
- A failed update leaves the previous usable version or presents a recoverable path.
- The agreed offline behavior is tested explicitly; “PWA” alone is not treated as proof of complete offline support.
- Background timer throttling does not affect duration classification.
- Local data clearing behavior and consequences are documented.

### Supported offline and update behavior

- The release Web build uses locally packaged Web renderer resources so the service worker can cache them. Build with:

      flutter build web --release --no-web-resources-cdn

- sw.js is the only application service worker. The custom Flutter bootstrap calls the loader without serviceWorkerSettings so Flutter's deprecated generated worker cannot replace it.
- The worker uses network-first requests and falls back to its versioned cache when the network is unavailable.
- The first visit requires a network connection. Offline acceptance begins only after the worker is activated and the page has completed one controlled online reload.
- A new build token produces a new application cache. The prior worker can remain active while an old tab is open; close all application tabs/windows and reopen to accept the update.
- Cache cleanup removes only names beginning with unit-converter-shell-. It must not delete unrelated same-origin caches.
- Firebase's reserved /__/ namespace bypasses the worker.
- Clearing browser site data can remove the worker, cached shell, and local reports. This is not an application switch and must be explained before destructive troubleshooting.

### Static validation procedure

Run from the repository root:

    python3 -m json.tool web/manifest.json
    python3 -m json.tool firebase.json
    file web/favicon.png web/icons/*.png
    flutter build web --release --no-web-resources-cdn

Inspect build/web and confirm:

1. index.html loads pwa_install_bridge.js before flutter_bootstrap.js.
2. The custom footer in flutter_bootstrap.js contains one sw.js registration and its final invocation is _flutter.loader.load(); with no options argument. The embedded generic Flutter loader may still contain unused serviceWorkerSettings support code.
3. No source manifest path or base-href placeholder remains unresolved.
4. sw.js, manifest.json, all declared icons, main.dart.js, CanvasKit files, fonts, and shaders listed in APP_SHELL exist.
5. The generated flutter_service_worker.js, if emitted by a transitional Flutter SDK, is not the active registration. In browser tools, the active script URL must end in sw.js with its build-version query.

### Local service-worker and offline procedure

The worker stays disabled on localhost by default so it cannot interfere with flutter run or hot reload. Test the release build with the explicit query opt-in:

    python3 -m http.server 8080 --directory build/web

Then:

1. Open http://localhost:8080/?enable-sw=1 in Chromium.
2. In DevTools → Application → Service Workers, wait for sw.js to show Activated and running.
3. Reload once while still online so the page is controlled and successful same-origin requests are cached.
4. In Application → Manifest, confirm identity, standalone display, regular icons, and maskable icons have no parse or installability errors.
5. In Cache Storage, confirm a unit-converter-shell- cache exists and contains the declared shell.
6. Enable DevTools Network → Offline and reload.
7. Confirm the app shell opens, conversions still work, and existing local reports remain readable.
8. Confirm unknown uncached resources fail without corrupting reports or creating assessment incidents.
9. Disable Offline, unregister sw.js, and clear the application cache before returning to flutter run development.

### Install procedure

#### Chromium desktop

1. Use the release build on HTTPS, or the localhost opt-in procedure above.
2. Confirm the in-app Install action appears only after beforeinstallprompt is captured.
3. Trigger Install, accept the browser prompt, and verify a standalone window opens.
4. Confirm the installed icon, title, theme color, navigation, conversion, and local report behavior.
5. Relaunch from the operating-system application list and verify display-mode standalone.
6. Confirm the Install action is no longer offered after appinstalled or while already standalone.

#### Android Chrome

1. Open an HTTPS staging or preview URL in Chrome.
2. Confirm the browser offers Install app or Add to Home screen.
3. Install and verify regular and adaptive/maskable launcher crops on at least two launcher shapes.
4. Launch from the home screen and verify standalone display, rotation, keyboard, local reports, and monitoring limitation copy.
5. Repeat the controlled offline check after one online reload.

#### iPhone and iPad Safari

1. Open an HTTPS staging or preview URL in Safari.
2. Confirm the UI presents manual Share → Add to Home Screen guidance; iOS does not provide beforeinstallprompt.
3. Add the app, launch from the Home Screen, and verify the title, icon, safe areas, rotation, and standalone presentation.
4. Verify local reports remain device-local and that clearing website data removes them.
5. Repeat on iPhone and iPad because installation and multitasking behavior differ.

### Update procedure

1. Build and serve release A, opt into sw.js, activate it, and reload online once.
2. Build release B into the same served directory.
3. Reload with release A still open and verify the browser detects a waiting or updated sw.js with a different version query.
4. Confirm no mixed-version blank screen or report corruption occurs.
5. Close every controlled tab/window, reopen, and verify release B and its cache become active.
6. Confirm the previous unit-converter-shell- cache is removed only after activation.

### Firebase Hosting configuration procedure

firebase.json is safe to validate locally without a production project. No .firebaserc is committed until a real project ID is selected.

1. Build build/web with the documented release command.
2. If Firebase CLI is installed, run the Hosting emulator with a non-production demo identifier:

       firebase emulators:start --only hosting --project demo-unit-converter

3. Verify direct navigation to a non-file route returns index.html.
4. Verify sw.js has no-cache/no-store headers and index.html, manifest.json, bootstrap, main script, and version metadata require revalidation.
5. Verify /__/ requests are not served by the SPA rewrite or service-worker fallback.
6. Stop the emulator. Do not run firebase deploy during local acceptance.

## 12. Accessibility and usability

- Semantics labels exist for icons, unit selectors, swap, report status, and navigation.
- All functionality is keyboard reachable on desktop Web.
- Visible focus indicators remain present.
- Screen-reader order matches reading order.
- Text at 200% remains usable without loss of content.
- Color contrast meets the project’s adopted accessibility standard.
- Status is not communicated by color alone.
- Touch controls meet the adopted minimum target size.
- Validation errors identify the field and corrective action.
- Motion respects reduced-motion preferences where supported.
- Assessment limitation and privacy copy is readable before the teacher starts a session.

## 13. Security and privacy tests

- No plaintext teacher PIN appears in storage, source fixtures, logs, crash output, or reports.
- PIN verification is rate-limited and lockout state survives the intended restart boundary.
- Report viewing, settings, ending, and deletion enforce the approved teacher-control policy.
- Browser-local PIN limitations are disclosed.
- No Accessibility Service, usage-history, browser-history, call-log, microphone, camera, screen-recording, or other-app identity permission is requested.
- Reports contain only approved student/session identifiers and focus/visibility evidence.
- Debug diagnostics are disabled or redacted in release builds.
- Storage deletion removes data according to the documented retention policy.
- Exported or future-synced reports use authenticated encrypted transport.
- Local tampering or cleared storage produces an integrity/storage warning, not fabricated continuity.

Firebase-specific authorization, rules, emulator, retry, conflict, retention, and deletion tests remain deferred until Firebase synchronization is approved and implemented.

## 14. Performance checks

- Measure cold and warm launch separately on an agreed low-end Android device, representative iPhone/iPad, and throttled desktop browser.
- Target usable initial UI in under three seconds under the documented network/cache conditions.
- Profile converter input, search, scrolling grids, navigation, and long report lists.
- Target smooth 60 FPS interaction on 60 Hz devices; investigate repeatable frame misses.
- Ensure assessment observation performs no polling and negligible work while no session is active.
- Ensure report writes do not block animation frames.
- Record release Web asset sizes and compare them with the previous accepted build.

Performance claims are accepted only with a named device, build mode, test data size, cache state, and measurement method.

## 15. Defect severity

- **Severity 1:** Data loss across multiple sessions, security/privacy breach, unusable release, or materially incorrect conversions.
- **Severity 2:** Incorrect incident classification/count, duplicate events, broken teacher authorization, major supported-platform failure, or inaccessible primary task.
- **Severity 3:** Recoverable workflow defect, isolated responsive issue, incorrect secondary formatting, or degraded performance.
- **Severity 4:** Cosmetic issue with no functional or accessibility impact.

Severity 1 and 2 defects block release. Severity 3 defects require explicit triage and owner before release.

## 16. Test evidence template

Each manual or integration run records:

- Build identifier and commit
- Date and tester
- Device, OS, browser, and install mode
- Viewport, orientation, zoom, and text scale where relevant
- Preconditions and session threshold configuration
- Exact actions and observed lifecycle evidence
- Expected and actual duration band/disposition
- Screenshot or log attachment without sensitive student data
- Pass, fail, blocked, or not applicable
- Defect identifier and retest result
