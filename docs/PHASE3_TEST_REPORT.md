# Phase 3 Stabilization and Integration Test Report

**Test date:** 2026-09-01 (Asia/Manila)  
**Scope:** Unit Converter, Calculator, Assessment Monitor, local Reports, responsive shell, and PWA installation/offline behavior  
**Outcome:** Automated and local Chrome release gates passed. Physical mobile installation and real-device lifecycle checks remain open.

No Module 2–13 features were implemented during this phase. Product source was reviewed but not changed; Phase 3 changed only automated tests and documentation.

## Test environment

| Device | OS | Browser/runtime | Result | Issues |
|---|---|---|---|---|
| Apple Silicon Mac (`arm64`) | macOS 26.4.1, build 25E253 | Google Chrome 152.0.7977.65 | Available and tested | Physical touch/mobile behavior is not represented |
| Local Flutter test runner | macOS 26.4.1 | Flutter 3.44.9 stable, Dart 3.12.2 | Available and tested | Widget tests model logical viewports rather than physical displays |
| Android device | Not available | Chrome Android | Not run | Manual install, launcher crop, rotation, keyboard, offline, and lifecycle checks required |
| iPhone/iPad | Not available | Safari iOS/iPadOS | Not run | Manual Add to Home Screen, safe areas, standalone mode, multitasking, and lifecycle checks required |

## Execution summary

| Gate | Result | Evidence/issues |
|---|---|---|
| `flutter analyze` | Pass | No issues found |
| Complete VM/widget regression | Pass | 129 tests passed after adding one end-to-end assessment/PIN/report stabilization scenario |
| Chrome-specific PWA tests | Pass | 18 tests passed: install states, captured prompt, one-shot prompt behavior, installed state, and iOS guidance UI |
| `flutter build web --release` | Pass | Release built at `build/web`; WebAssembly dry run also succeeded |
| Manifest/config JSON parsing | Pass | Source/build manifest, Firebase, and Vercel JSON parse successfully |
| JavaScript syntax | Pass | `flutter_bootstrap.js`, `pwa_install_bridge.js`, and `sw.js` pass `node --check` |
| Release shell inventory | Pass | Every path declared by `APP_SHELL` exists in `build/web` |
| Chrome release load | Pass | Release rendered in Chrome 152 at 1440 × 900 with the Install App action available |
| Chrome offline shell | Pass | After an online controlled load and server shutdown, the service-worker-cached shell rendered again; online/offline screenshots had the same SHA-256 |
| Physical installation | Not run | Desktop OS installation, Android installation, and iOS Add to Home Screen remain manual gates |

## Feature regression results

| Feature | Verification | Result | Issues |
|---|---|---|---|
| Converter categories | Catalog/model tests cover all nine categories and their unit inventories | Pass | None found |
| Converter formulas | Pair, reciprocal, affine temperature, boundary, validation, and formatting tests | Pass | None found |
| Converter search | Category, unit name, symbol, alias, empty, and unmatched query coverage | Pass | None found |
| Converter UI | Input, result, unit swap, search selection, compact layout, keyboard entry, and dropdown integration | Pass | No functional regression; physical browser accessibility review remains open |
| Calculator basic operations | Controller, engine, and UI tests for arithmetic, decimals, signs, parentheses, percentage, clear, backspace, and equals | Pass | None found |
| Calculator scientific operations | Root, powers, reciprocal, trigonometry, logarithms, exponent, π, and e | Pass | None found |
| Calculator angle mode | Degree and radian controller/UI behavior | Pass | None found |
| Calculator history | Add, bound, clear, open sheet/panel, and reuse | Pass | Session-local only as designed |
| Calculator memory | MC, MR, M+, and M− controller coverage | Pass | Session-local only as designed |
| Assessment session | Start and end through the UI with teacher authorization | Pass | No dedicated page-level progress indicator during asynchronous operations |
| Teacher PIN | Setup, verification, throttling, report gate, and session-end gate | Pass | Browser-local PIN remains a convenience lock, not tamper-proof security |
| Reports | Local repository persistence, active/ended session display, incident classifications, empty state, and protected access | Pass | No explicit loading state while reports refresh |
| Interruption policy | Ignore/review/extended thresholds and negative-duration rejection | Pass | Platform APIs still cannot identify the other app or every interruption cause |

## Assessment monitoring results

The root monitor remains above `MaterialApp`, navigation, and feature pages. The integration test retained the same monitor object for the entire active session.

### Must not count

| Interaction during active assessment | Result | Evidence |
|---|---|---|
| Navigate to Calculator | Pass: zero incidents | Adaptive-shell integration test |
| Enter calculator expression and calculate | Pass: zero incidents | Calculator key interaction in active-session shell |
| Open/close calculation history | Pass: zero incidents | Modal history sheet interaction |
| Navigate to Converter | Pass: zero incidents | Adaptive-shell integration test |
| Focus converter input and show keyboard | Pass: zero incidents | Widget keyboard interaction |
| Open/select converter dropdown | Pass: zero incidents | Unit picker interaction |
| Open/cancel teacher PIN dialog | Pass: zero incidents | Reports authorization dialog interaction |
| Toggle theme/settings control | Pass: zero incidents | Internal theme action interaction |
| Trusted PWA install prompt lifecycle | Pass: zero incidents | Explicit suppression test through matching resume |
| Mobile inactive-only sequence | Pass: zero incidents | Assessment state-machine test |

### Must count or persist

| Presence sequence | Result | Evidence |
|---|---|---|
| Hidden/paused departure | Pass | Pending absence is saved immediately before suspension handling completes |
| Duplicate hidden/paused callbacks | Pass | One stable pending candidate is retained |
| Resume after 1.999999 seconds | Pass | Candidate ignored and cleared |
| Resume at 2 seconds | Pass | One review incident |
| Resume below 10 seconds | Pass | One review incident |
| Resume at 10 seconds | Pass | One extended-absence incident |
| Resume after hidden → inactive sequence | Pass | Original departure time retained; duration calculated on return |
| Process restart with pending candidate | Pass | Recovered as an unresolved neutral gap |
| Real tab switch/app switch on physical device | Not run | Must be verified manually per browser/OS; browser signals cannot prove another app's identity |

## PWA artifact and browser status

| PWA check | Result | Issues |
|---|---|---|
| Manifest identity and parsing | Pass | Description still mentions converter/assessment but not the calculator |
| `display: standalone`, start URL, and scope | Pass (static declaration) | Actual installed standalone launch not performed |
| Regular icons 192/512 | Pass | Correct PNG dimensions |
| Maskable icons 192/512 | Pass (file/declaration) | Maskable files are byte-identical to regular icons; safe-zone cropping is not proven |
| Install bridge ordering | Pass | `pwa_install_bridge.js` loads before async Flutter bootstrap |
| Chromium install eligibility signal | Pass on local Chrome release load | Install App action was visible; accepting the OS install prompt was not performed |
| iOS instructions | Pass in automated UI tests | Physical Safari Add to Home Screen not performed |
| Service-worker ownership | Pass | Custom bootstrap registers `sw.js`; generated `flutter_service_worker.js` exists but is not registered |
| Offline shell | Pass in Chrome 152 | Functional converter interaction while offline was not manually exercised; the complete cached shell rendered |
| Standalone detection | Pass in service-state tests | Physical installed-window verification remains open |

The online and offline desktop screenshots were both 1440 × 900 and had SHA-256 `b074fb6d566dcb205f6db25cc3b4509186356d9c1f3ba913e5a10728ffdb8b80`. Screenshots are temporary test evidence under `/private/tmp` and are not product assets.

## Responsive and UI quality audit

Automated logical-width checks pass at 320, 360, 390, 430, 768, 1024, 1366, 1920, and 2560 pixels without Flutter layout exceptions. Material 3, dark theme, and minimum calculator touch targets are also covered.

| Screen | Result | Observations/issues |
|---|---|---|
| Home | Pass | Desktop Chrome screenshot shows consistent typography, cards, spacing, icons, dark theme, rail, and install action |
| Converter | Pass | Consistent shared card/input styling; invalid input and unavailable-result states exist; no asynchronous loading state is needed |
| Calculator | Pass | Shared theme, responsive keypad, error state, empty history, modal/persistent history, and dark mode verified |
| Assessment | Pass with minor issue | Setup/active states and responsive wrapping are consistent; busy actions disable but have no visible page-level progress indicator |
| Reports | Pass with minor issue | Empty state and report cards are present; refresh has no explicit loading presentation |
| Application shell | Pass with minor consistency issue | App bar title and ruler icon remain “Unit Converter” on Calculator, Assessment, and Reports screens |

A 320-pixel headless Chrome capture appeared horizontally cropped because that headless configuration rendered a wider minimum CSS viewport into a 320-pixel bitmap. The Flutter widget suite passes a true 320 logical-pixel constraint, but a real 320–360 pixel browser/device visual check is still recommended.

## Bugs and risks discovered

No critical or high-severity functional regression was found.

| ID | Severity | Finding |
|---|---|---|
| P3-01 | Release gate | Android Chrome and iOS/iPadOS Safari installation/lifecycle testing was not possible without devices |
| P3-02 | Release gate | Desktop install acceptance and actual standalone relaunch were not performed |
| P3-03 | Medium | Maskable icons are byte-identical to regular icons, so launcher safe-zone cropping is unverified |
| P3-04 | Low | Shell title/icon stay converter-specific on every destination |
| P3-05 | Low | Assessment/report asynchronous work lacks explicit page-level loading feedback |
| P3-06 | Low | Manifest and HTML descriptions do not mention the calculator module |
| P3-07 | Coverage | Real browser visual review of Converter, Calculator, Assessment, and Reports remains manual; widget tests cover their layout and behavior |

## Recommended fixes and next actions

1. Complete desktop Chrome/Edge installation and standalone relaunch using an HTTPS preview.
2. Run Android Chrome and iPhone/iPad Safari install, offline, keyboard, rotation, and lifecycle matrices on physical devices.
3. Validate or redesign dedicated maskable icon artwork inside the launcher safe zone.
4. Perform a real 320–360 pixel browser visual review and keyboard/accessibility pass.
5. In a later approved UI phase, consider destination-aware shell title/icon and visible assessment/report loading feedback.
6. Update PWA descriptions to mention the calculator when branding/content changes are approved.
7. Keep Module 2–13 implementation blocked until the user approves proceeding after reviewing this report.
