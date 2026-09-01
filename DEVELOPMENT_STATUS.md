# Development Status

**Status date:** 2026-09-02
**Overall state:** Core converter, calculator, assessment, local-report, responsive-shell, and install-flow implementation exists. Phase 3 stabilization passed local regression, release-build, Chrome install-signal, and offline-shell gates. Physical mobile installation/lifecycle testing and installed standalone acceptance remain open, so the product is not release-ready.

This is the live delivery checklist. A checked item means the implementation exists in the repository and has appropriate verification evidence. Architecture approval alone does not make an implementation item complete.

## Status legend

- **Done:** Implemented and verified.
- **In progress:** Actively planned or being implemented, but not yet accepted.
- **Not started:** No verified product implementation.
- **Deferred:** Intentionally outside the current release.

## Current verified baseline

| Area | Status | Current evidence |
|---|---|---|
| Flutter project scaffold | Done | Android, iOS, and Web runners are present |
| Dependency baseline | Done | Flutter, Cupertino icons, shared preferences, and cryptographic verifier dependencies are locked |
| Application UI | In progress | Product app shell, converter, assessment, reports, theme, and install affordances are implemented; physical-device acceptance remains open |
| Automated tests | Done | `flutter analyze` is clean and all 241 VM/widget tests pass; 18 Chrome-specific install-service/action tests also pass |
| Converter domain | Done | Nine-category catalog, conversion engine, affine temperature handling, search, and number formatting are implemented with unit coverage |
| Calculator domain | Done | Feature-isolated immutable state/history models, angle modes, tokenizer/parser, scientific evaluation, typed failures, and deterministic number formatting are covered by 21 tests |
| Calculator UI | Done | Material 3 basic/scientific keypads, expression/result/error display, memory, angle mode, session-local history, compact history sheet, tablet dialog, desktop history panel, and 320–2560 px widget coverage are implemented |
| AMT 111 Module 2 — Whole Numbers | Done | Five lessons, aviation worked examples, guided lab, seven-question practice/Quiz, calculator launch, versioned local progress, responsive UI, and 20 focused tests are complete |
| AMT 111 Module 3 — Fractions | Done | Six lessons, exact fraction engine, corrected LCD 64, fraction lab, nine-question Seat Work 2, calculator launch, versioned attempts/progress, responsive UI, and 26 focused tests are complete |
| AMT 111 Module 4 — Mixed Numbers | Done | Five lessons, Module 3 fraction-service reuse, mixed-number lab, eight-question Seat Work 3 preparation, calculator launch, versioned local progress, responsive UI, and 28 focused tests are complete |
| AMT 111 Module 5 — Decimal Number System | Done | Six lessons, BigInt coefficient/scale decimal engine, half-up rounding, exact/repeating fraction conversion, shop 64ths, thirteen-question Seat Work 3, calculator launch, versioned local progress, responsive UI, and 27 focused tests are complete; Modules 6–13 remain unstarted |
| Modules 2–5 controlled practice input | Done | Graded answers use a shared in-app numeric keypad with structured fraction, mixed-number, decimal, and unit controls; no graded practice card contains an editable text field |
| Assessment monitoring | In progress | Root lifecycle monitor, exact threshold policy, pending persistence/recovery, Android lock hints, internal tool/overlay no-incident integration, and neutral reports are verified; physical platform matrix remains open |
| Local reports | In progress | SharedPreferences repository, report UI, teacher-PIN verifier, throttling, and deletion are implemented; migration/failure and physical persistence acceptance remain open |
| Responsive UI | In progress | Compact, medium, and expanded navigation/layouts pass logical-width tests from 320 through 2560 px; physical browser/device, zoom, and accessibility matrices remain open |
| PWA shell | In progress | ACATECH manifest/branding, distinct safe-zone-tested icons, install signal, app-owned worker, release shell inventory, Chrome online load, and controlled offline reload pass; physical installation and standalone relaunch remain open |
| Firebase synchronization | Deferred | Static Hosting rules exist, but report sync remains a future seam; Firebase CLI authentication and a project ID are unavailable |
| Native desktop runners | Deferred | Desktop delivery currently means Web/PWA |

## Approved decisions

- [x] Use one Flutter codebase for Android, iOS/iPadOS, and Web/PWA.
- [x] Treat laptop and desktop delivery as responsive Web/PWA for the current scope.
- [x] Keep conversion logic independent of Flutter widgets.
- [x] Own assessment observation in one root-scoped monitor above navigation.
- [x] Report focus/visibility absence neutrally; never claim proof of cheating or another app’s identity.
- [x] Use exact thresholds: less than 2 seconds ignored, 2 to less than 10 seconds review, and 10 seconds or more extended.
- [x] Keep assessment reports local-only for the current release.
- [x] Preserve a repository seam for optional future Firebase synchronization.
- [x] Use compact 320–599, medium 600–1023, and expanded 1024+ responsive tiers.
- [x] Keep unsupported lock, call, and system-interruption causes unknown rather than inventing certainty.

## Calculator module plan

### Phase 1 — Pure calculator domain

**Status: Done**

- [x] Add a feature-based `lib/features/calculator/` boundary without changing converter code.
- [x] Add immutable angle-mode, calculator-state, history-entry, and bounded-history models.
- [x] Implement a pure Dart tokenizer and recursive-descent expression parser.
- [x] Support arithmetic precedence, unary signs, parentheses, decimals, scientific literals, fractions through division, postfix percentage, and right-associative powers.
- [x] Support `sqrt`, `sin`, `cos`, `tan`, `log`, `ln`, `exp`, `recip`, `pi`, and `e` with degree/radian trigonometry.
- [x] Return typed syntax, division-by-zero, domain, and non-finite failures.
- [x] Add deterministic finite-number formatting.
- [x] Add 21 focused model, engine, error, and formatter tests.
- [x] Re-run the full regression gate: `flutter analyze` clean and all 116 tests passing.

### Phase 2 — Calculator application state and responsive UI

**Status: Done**

- [x] Add the calculator controller and tested input/evaluation state transitions without changing `CalculatorEngine`.
- [x] Add clear, backspace, percentage, parentheses, constants, scientific functions, degree/radian selection, and recoverable error behavior.
- [x] Add MC, MR, M+, and M− operations and bounded session-local history actions.
- [x] Build a Material 3 display, 4-column basic keypad, scientific controls, angle selector, memory controls, and accessible calculator buttons.
- [x] Use the shared theme, typography, card style, and color scheme in light and dark modes.
- [x] Add compact history bottom sheet, tablet history dialog, and desktop two-panel history layout with reusable entries.
- [x] Add Calculator to the existing adaptive navigation and `IndexedStack`; preserve the teacher-gated Reports destination.
- [x] Verify 360, 390, 430, 768, 1024, 1366, and 1920 logical-pixel widths without layout exceptions.
- [x] Verify calculator navigation and button input during an active assessment create no interruption incident and do not replace the root monitor.
- [x] Add 12 Phase 2 controller/widget tests and re-run the complete 128-test regression suite.

### Phase 3 — Stabilization and integration testing

**Status: Done (local/automated); physical device gates remain open**

- [x] Run clean static analysis and the complete 129-test VM/widget regression suite.
- [x] Run 18 Chrome-specific PWA installation-state and install-action tests.
- [x] Verify converter categories, formulas, search, input, unit selection, and results.
- [x] Verify calculator basic/scientific operations, history, memory, and degree/radian modes.
- [x] Verify teacher-PIN-protected assessment start, report access, and session end.
- [x] Verify calculator, history, converter, keyboard, dropdown, PIN dialog, and theme interactions create zero incidents during an active assessment.
- [x] Verify hidden/paused persistence and return-time duration classification remain correct.
- [x] Build the release Web application and validate manifest, icons, JavaScript, bootstrap ordering, service-worker ownership, and complete shell inventory.
- [x] Verify Chrome desktop captures the install eligibility signal and renders the cached release shell after the local server is stopped.
- [x] Verify responsive logical widths at 320, 360, 390, 430, 768, 1024, 1366, 1920, and 2560 px.
- [ ] Complete desktop installed standalone, Android Chrome, and iOS/iPadOS Safari acceptance on physical platforms.
- [x] Record results, issues, and recommended fixes in `docs/PHASE3_TEST_REPORT.md`.

## Phase 0 — Requirements and architecture

**Status: Done**

- [x] Capture initial PWA, responsive UI, converter, and assessment goals.
- [x] Review monitoring feasibility across Android, iOS, Web, and desktop browsers.
- [x] Replace “confirmed app switch” assumptions with observable focus/visibility evidence.
- [x] Define root monitor ownership and state-machine boundaries.
- [x] Define local-first report storage with a future Firebase seam.
- [x] Define exact responsive tiers and monitoring thresholds.
- [x] Create architecture, status, and test-plan documents.
- [ ] Reconcile the original planning document with the approved neutral terminology.

## Phase 1 — Application foundation

**Status: In progress**

- [x] Generate Flutter Android, iOS, and Web scaffolds.
- [x] Establish baseline pubspec and lint configuration.
- [x] Replace the generated counter application with the root application shell.
- [x] Add application theme and branded color tokens.
- [x] Add navigation that adapts between bottom navigation, rail, and sidebar.
- [x] Add the root application scope and dependency wiring.
- [x] Add clock and storage abstractions required by assessment logic.
- [x] Replace the generated widget test with product smoke tests.
- [ ] Confirm the supported Flutter/Dart version in CI and release documentation.

## Phase 2 — Converter domain

**Status: Done**

- [x] Define conversion category and unit models.
- [x] Implement the pure conversion engine.
- [x] Support affine conversions such as temperature.
- [x] Define input validation, precision, and display formatting.
- [x] Create the searchable unit/category catalog.
- [x] Add unit tests across conversion pairs and boundary classes.
- [x] Verify reciprocal conversions within the documented tolerance.
- [x] Implement the initial nine-category supported inventory.

## Phase 3 — Converter and shared UI

**Status: In progress**

- [x] Build the responsive home/category grid.
- [x] Build compact and expanded converter layouts.
- [x] Implement unit selection, swap, input, and result interactions.
- [x] Implement case-insensitive search, clear action, and empty state.
- [x] Implement settings and theme behavior.
- [ ] Add loading, empty, invalid-input, and storage-error states.
- [ ] Meet keyboard, text scaling, touch-target, focus-order, and contrast requirements.
- [ ] Verify no clipping, overflow, or horizontal page scrolling from 320 to 2560 logical pixels.

## Phase 4 — Assessment monitoring

**Status: In progress**

- [x] Define AssessmentSession and AssessmentEvent domain models.
- [x] Implement the pure assessment state machine with an injected clock.
- [x] Create one root-scoped AssessmentMonitor above navigation.
- [x] Add the Flutter lifecycle signal adapter.
- [ ] Add Web visibility, focus, page-hide, and page-show evidence where required.
- [x] Coalesce inactive, hidden, and paused callbacks into one candidate.
- [x] Ensure mobile inactive-only sequences do not become counted absences.
- [x] Implement exact transient, review, and extended duration bands.
- [x] Add known-system and app-initiated exemption evidence without broad exemptions.
- [x] Persist an open candidate before background suspension.
- [x] Recover unfinished candidates as unknown process gaps.
- [x] Verify internal navigation, keyboard, dropdowns, and Flutter dialogs do not create events.
- [x] Add platform capability copy to the active-assessment and report screens.

## Phase 5 — Teacher controls and local reports

**Status: In progress**

- [x] Define AssessmentRepository.
- [x] Implement local storage with SharedPreferences behind the repository contract.
- [ ] Replace separate preference writes with transactional storage if atomic multi-record commits become a release requirement.
- [x] Implement report list, report detail, totals, and neutral event labels.
- [x] Separate review events, extended absences, exclusions, and unknown gaps.
- [x] Implement start, end, settings, view, and delete authorization boundaries.
- [x] Store a salted PIN verifier rather than plaintext.
- [x] Add PIN attempt throttling and lockout behavior.
- [ ] Document browser-local PIN and local-data tamper limitations.
- [ ] Add schema versioning, corruption handling, and migration tests.
- [ ] Define and implement local report retention/deletion behavior.

## Phase 6 — PWA, branding, and production UX

**Status: In progress**

- [x] Replace the interim Unit Converter identity with the supplied official ACATECH Aviation College logo and application naming.
- [x] Add the full ACATECH logo to the web loading surface, Material shell, and in-app About page.
- [x] Validate manifest name, short name, theme, background, start URL, scope, and standalone display.
- [x] Verify PNG inventory dimensions: favicon 32 × 32, regular icons 192 × 192 and 512 × 512, and maskable icons 192 × 192 and 512 × 512.
- [x] Declare regular icons for any purpose and dedicated maskable entries for maskable purpose.
- [x] Load the install bridge before Flutter bootstrap so Chromium install events can be captured early.
- [x] Use one app-owned service worker without Flutter deprecated-worker registration.
- [x] Version the service-worker cache from the Flutter build token and limit cache cleanup to this application.
- [x] Exclude Firebase reserved /__/ routes from service-worker fallback and caching.
- [x] Add static Firebase Hosting configuration for build/web, SPA fallback, security headers, and shell revalidation.
- [x] Add static Vercel configuration for the locally built `build/web` release, SPA fallback, security headers, and source-only upload exclusions.
- [x] Build the current release with local renderer resources and verify every APP_SHELL path exists.
- [ ] Select a real Firebase project and create .firebaserc with firebase use --add.
- [ ] Confirm install flow on Android Chrome and iOS/iPadOS Safari.
- [ ] Confirm installed and browser modes use the same monitoring limitations.
- [x] Define the intended network-first, cached-shell offline behavior in TEST_PLAN.md.
- [x] Verify offline shell behavior after service-worker activation and one controlled online reload in Chrome 152.
- [ ] Verify service-worker/update behavior for the supported Flutter release.
- [x] Separate regular and maskable icon artwork and verify all visible maskable pixels remain inside the central 80% safe-zone circle.
- [ ] Visually validate the safe-zone-tested artwork on physical Android launchers.
- [ ] Measure cold and warm start against the agreed under-three-second baseline.
- [ ] Profile scrolling and interaction performance on representative low-end hardware.

## PWA Installation

Checked items below have source, static-build, or automated-test evidence. Device/browser installation and hosted HTTPS evidence remain open.

- [x] Manifest valid
- [x] 192 icon
- [x] 512 icon
- [x] Chromium install event detected
- [ ] Desktop install tested
- [ ] Android install tested
- [x] iOS instructions implemented
- [x] Standalone detection tested
- [x] Already-installed state tested
- [x] HTTPS preview deployed

The Vercel preview is publicly reachable over HTTPS. The application shell and direct `/assessment`, `/reports`, and `/converter` paths return HTTP 200; the deployed manifest, install bridge, app-owned service worker, and 192 px icon match the locally verified release artifacts. Physical browser installation remains an acceptance item.

Vercel automatically promoted the project's first deployment despite the CLI call omitting `--prod`. A separate explicit preview was then created and verified; deletion of the unintended first deployment remains pending explicit cloud-delete approval.

Firebase Hosting remains configuration-ready through firebase.json as an undeployed alternative. Firebase CLI 15.28.2 is available through `npx`, but it is not authenticated, no Firebase project ID has been supplied, and .firebaserc is intentionally absent. Firebase report synchronization remains deferred.

The Chromium bridge and its one-shot prompt contract are covered in VM and Chrome Web tests. A local Chrome 152 release load captured the eligibility event and displayed Install App. Accepting the operating-system install prompt and relaunching standalone remain manual gates.

The regular and maskable PNGs are now separate ACATECH assets. Automated pixel validation confirms that all visible maskable artwork, including both wing tips, remains inside the central 80% safe-zone circle. Physical launcher-mask acceptance remains open.

## AMT 111 Phase A — Module 2: Whole Numbers

**Status: Done**

- [x] Add a feature-isolated `lib/features/module_02/` boundary with models, presentation, services, and widgets.
- [x] Add five curriculum lessons covering place value, operation vocabulary, four operations, remainders, factors, multiples, primes, GCD/LCM, and divisibility.
- [x] Add curriculum worked examples and aviation inventory, flight-hour, fastener, technician-allocation, and cycle examples.
- [x] Implement exact non-negative integer operations, `divmod`, factors, prime factorization, multiples, GCD, LCM, place-value rows, and divisibility explanations for 2, 3, 4, 5, 6, 8, 9, and 10.
- [x] Keep subtraction with a negative result outside Module 2 and direct the learner to Module 9.
- [x] Add a guided whole-number lab and seven-question retryable Module 2 practice/Quiz with explanations.
- [x] Add one `Learn` destination to the existing adaptive shell and launch the existing calculator through the shell callback without duplicating its engine.
- [x] Add versioned local-first SharedPreferences storage for viewed lessons, mastered questions, score, practice completion, and module completion status.
- [x] Keep curriculum progress separate from assessment presence sessions and incidents; Firebase remains deferred.
- [x] Verify internal module navigation, lesson routes, and calculator launch create zero incidents during an active assessment.
- [x] Verify Module 2 layouts at 320, 360, 390, 430, 768, 1024, 1366, and 1920 logical pixels without layout exceptions.
- [x] Add 20 focused domain, validation, persistence, widget, responsive, navigation, and assessment-compatibility tests.
- [x] Run `flutter analyze` clean and the complete 155-test suite successfully.
- [ ] Complete physical-device accessibility, installed-PWA, and browser acceptance for Module 2.
- [x] Integrate the separately approved Module 3 through one responsive Aviation Mathematics hub without changing Module 2 internals.

## AMT 111 Phase A — Module 3: Fractions

**Status: Done**

- [x] Add a feature-isolated `lib/features/module_03/` boundary with models, presentation, services, and widgets.
- [x] Add six curriculum lessons covering fraction anatomy, equivalent fractions, both common-denominator methods, four operations, cancellation, tolerance ranges, mixed numbers, and lowest terms.
- [x] Add aviation examples for panel thickness, aileron tolerance, hole-center layout, and jackscrew travel.
- [x] Implement normalized `ExactFraction` values with a positive nonzero denominator, exact arithmetic, comparison, classification, and mixed-number formatting.
- [x] Reuse Module 2's tested GCD/LCM service without modifying Module 2.
- [x] Preserve unsimplified equivalent-fraction steps for instruction while normalizing final arithmetic results.
- [x] Lock the authoritative corrected panel LCD of 64 and every specified worked result with tests.
- [x] Add the responsive exact-fraction lab with fraction-bar semantics, LCD method selection, operation/comparison controls, equivalent steps, and reduction output.
- [x] Add nine retryable Seat Work 2 questions that separately validate arithmetic, lowest terms, and required units.
- [x] Add versioned local-first SharedPreferences storage for lesson views, practice-attempt counts, mastered questions, score, and completion status.
- [x] Add one responsive Aviation Mathematics hub under the existing `Learn` destination; Modules 2 and 3 use internal Flutter routes.
- [x] Launch the existing calculator through the shell callback without modifying or duplicating the calculator engine.
- [x] Keep curriculum results separate from assessment presence sessions and incidents; Firebase remains deferred.
- [x] Verify hub, module, lesson, practice, and calculator navigation create zero incidents during an active assessment.
- [x] Verify Module 3 layouts at 320, 360, 390, 430, 768, 1024, 1366, and 1920 logical pixels without layout exceptions.
- [x] Add 26 focused domain, validation, persistence, widget, responsive, navigation, and assessment-compatibility tests.
- [x] Run `flutter analyze` clean and the complete 181-test suite successfully.
- [ ] Complete physical-device accessibility, installed-PWA, and browser acceptance for Module 3.
- [x] Integrate the separately approved Module 4 without changing Module 3 internals.

## AMT 111 Phase A — Module 4: Mixed Numbers

**Status: Done**

- [x] Add a feature-isolated `lib/features/module_04/` boundary with models, presentation, services, and widgets.
- [x] Add five curriculum lessons covering mixed/improper conversion, addition with carrying, subtraction with borrowing, formula-given selection and distracters, multiplication, division, and cut planning.
- [x] Add aviation examples for steel-rule and drawing dimensions, cargo length, authoritative bolt grip, spacer stacks, and control-cable cuts.
- [x] Reuse Module 3's public `ExactFraction`, `FractionEngine`, and fraction parser without changing Module 3 or duplicating exact fraction arithmetic.
- [x] Implement normalized non-negative mixed values, bidirectional conversion steps, carry/borrow evidence, exact four-operation results, piece totals, cut plans, and distracter selection.
- [x] Preserve the authoritative bolt-grip result `3 1/8 − 1 5/16 = 1 13/16 inch` and reject overall length as a distracter.
- [x] Add a responsive mixed-number lab with whole/numerator/denominator controls and explicit improper, carry, borrow, and reduced-result evidence.
- [x] Add eight retryable Seat Work 3 preparation questions that separately validate exact value, mixed form, lowest terms, units, and selected givens.
- [x] Add versioned local-first SharedPreferences storage for lesson views, practice-attempt counts, mastered questions, score, and completion status.
- [x] Add Module 4 to the existing responsive Aviation Mathematics hub and launch the existing calculator through the shell callback.
- [x] Keep curriculum results separate from assessment presence sessions and incidents; Firebase remains deferred.
- [x] Verify hub, module, lesson, practice, and calculator navigation create zero incidents during an active assessment.
- [x] Verify Module 4 layouts at 320, 360, 390, 430, 768, 1024, 1366, and 1920 logical pixels without layout exceptions.
- [x] Add 28 focused domain, validation, persistence, widget, responsive, navigation, and assessment-compatibility tests.
- [x] Run `flutter analyze` clean and the complete 209-test suite successfully.
- [ ] Complete physical-device accessibility, installed-PWA, and browser acceptance for Module 4.
- [x] Integrate the separately approved Module 5 without changing Module 4 internals.

## AMT 111 Phase A — Module 5: The Decimal Number System

**Status: Done**

- [x] Add a feature-isolated `lib/features/module_05/` boundary with models, presentation, services, and widgets.
- [x] Add six curriculum lessons covering place value and reading, comparison, aligned addition/subtraction, multiplication/division, final-step half-up rounding, shop 64ths, drill/ream planning, and terminating/repeating fraction conversion.
- [x] Add aviation examples for series resistance, material dimensions, electrical power, wing dimensions, socket/drill/ream sizes, and the corrected decimal-equivalent reference row.
- [x] Implement `DecimalQuantity` with a `BigInt` coefficient and integer scale so arithmetic and comparison do not use binary floating point.
- [x] Normalize leading/trailing zeros while preserving exact value and support very long inputs without an early precision conversion.
- [x] Implement exact addition, subtraction, multiplication, comparison, division as a reduced fraction plus decimal expansion, and explicit zero-divisor/negative-policy failures.
- [x] Implement curriculum half-up rounding with retained digit, inspection digit, requested fixed-place output, and no early rounding.
- [x] Implement exact decimal-to-fraction conversion and bounded long-division detection for terminating and repeating expansions.
- [x] Render repeating digits with an explicit overline and preserve plain parenthesized notation for validation and accessibility.
- [x] Preserve the curriculum correction that the corrupted `39341` chart row is `9/16`, with `0.5625 in` and `14.2875 mm` associated with that fraction.
- [x] Implement the shop method `0.3123 × 64 → 20/64 → 5/16` and drill/ream method `0.763 in → 49/64 − 1/64 = 3/4` without early rounding.
- [x] Add a responsive exact-decimal lab covering operations, place value, rounding, fraction conversions, repeating cycles, shop 64ths, and drill/ream planning.
- [x] Add thirteen retryable Seat Work 3 questions that separately validate exact value, requested precision, lowest terms, repeating notation, and units.
- [x] Add versioned local-first SharedPreferences storage for lesson views, practice-attempt counts, mastered questions, score, and completion status.
- [x] Add Module 5 to the existing responsive Aviation Mathematics hub and launch the existing calculator through the shell callback.
- [x] Keep curriculum progress separate from assessment presence sessions and incidents; Firebase remains deferred.
- [x] Verify hub, module, lesson, practice, and calculator navigation create zero incidents during an active assessment.
- [x] Verify Module 5 layouts at 320, 360, 390, 430, 768, 1024, 1366, and 1920 logical pixels without layout exceptions.
- [x] Add 27 focused domain, validation, persistence, widget, responsive, navigation, and assessment-compatibility tests.
- [x] Run `flutter analyze` clean and the complete 236-test suite successfully.
- [ ] Complete physical-device accessibility, installed-PWA, and browser acceptance for Module 5.
- [ ] Start Module 6 only after separate approval.

## Modules 2–5 beta input UX

**Status: Done (local/automated); physical device gates remain open**

- [x] Add reusable `NumericKeypad`, `NumericInput`, `FractionInput`, `MixedNumberInput`, `DecimalInput`, and controlled unit-choice components under `lib/features/practice/widgets/`.
- [x] Replace every graded practice `TextField` in Modules 2–5 with controlled application-owned input without changing the calculation engines or validators.
- [x] Restrict entry to digits, decimal point, clear, backspace, structured fraction/mixed-number parts, problem-specific symbols, and declared units.
- [x] Verify every Module 2–5 practice card contains no `EditableText`, while retry, validation, explanation, scoring, and progress behavior remain intact.
- [x] Verify keypad opening, input, submission, and calculator launch during an active assessment create zero incidents and do not replace the root monitor.
- [x] Verify complete Module 2–5 layouts at 320, 360, 390, 430, 768, 1024, 1366, and 1920 logical pixels without layout exceptions.
- [x] Run 106 focused beta tests, clean static analysis, and the complete 241-test regression suite.
- [x] Produce a successful release Web build and verify generated manifest, service worker, and regular/maskable icon inventory.
- [x] Record the results and remaining physical-device limitations in `docs/BETA_TEST_REPORT.md`.
- [ ] Confirm system-keyboard suppression, orientation, text scaling, screen-reader output, and tap ergonomics on physical Android and iOS devices.
- [ ] Start Module 6 only after separate approval.

## Phase 7 — Verification and release

**Status: In progress**

- [x] Make flutter analyze pass with no unresolved findings.
- [x] Make the full automated test suite pass (241 tests).
- [x] Produce a release Web build.
- [x] Document and verify the local-build Vercel static preview workflow.
- [x] Produce an Android debug compatibility APK after the conditional Web implementation.
- [ ] Produce Android and iOS release candidates.
- [ ] Complete the device, browser, viewport, accessibility, lifecycle, and interruption matrices in TEST_PLAN.md.
- [ ] Confirm no sensitive permissions or unrelated activity collection.
- [ ] Complete teacher-facing privacy, retention, and limitation copy.
- [ ] Run final regression after branding and deployment configuration.
- [ ] Document deployment target, rollback procedure, and release owner.

## Phase 8 — Optional Firebase synchronization

**Status: Deferred**

- [ ] Confirm that remote sync is approved for a later release.
- [ ] Define teacher identity and authorization.
- [ ] Implement Firebase only behind AssessmentReportRepository.
- [ ] Add idempotent uploads and stable local identifiers.
- [ ] Keep local monitoring and conversion usable without network access.
- [ ] Distinguish monitoring, connectivity, and synchronization state.
- [ ] Add server-side access, retention, deletion, and audit controls.
- [ ] Add privacy and security review before enabling production data.

## Known limitations and risks

1. Lifecycle and browser APIs expose focus or visibility, not the identity of another app or the reason focus changed.
2. Web visibility can represent a tab switch, minimized window, screen-off state, or operating-system lock.
3. iOS background transitions do not provide a general reliable distinction between app switching, lock, and some full-screen interruptions.
4. Android screen/keyguard hints can improve classification but remain best-effort and require device/version verification.
5. Flutter and operating systems may skip callbacks when a process is killed; recovered gaps must remain unknown.
6. Browser timers are throttled while hidden, so classification must occur from persisted timestamps on return.
7. Local PWA data and a browser-local PIN are not tamper-proof against the device owner.
8. Broad “system dialog” exemptions could be exploited; expected external flows must be explicit and time-bounded.
9. Automated and local Chrome offline coverage exists, but physical interruption, installation, standalone, accessibility, and full device/browser matrices remain open.
10. Module learning labs retain editable exploratory operands; only graded practice-answer entry is controlled in this beta phase.

## Immediate integration order

1. Review `docs/PHASE3_TEST_REPORT.md` and approve or defer its recommended fixes.
2. Validate desktop, Android, and iOS/iPadOS installation on real browsers and devices.
3. Complete the assessment interruption and Android lock-exclusion device matrix.
4. Complete responsive, accessibility, performance, and local-persistence validation.
5. Run the service-worker update procedure with two distinct release builds.
6. Keep Modules 2–5 complete and start Module 6 only after separate explicit approval.

## Checklist maintenance

When updating this file:

- Change the status date.
- Check an item only after code and proportionate tests exist.
- Add a short evidence link or note for high-risk platform behavior.
- Keep deferred work visibly separate from the current release.
- Record limitations rather than silently weakening acceptance criteria.

## Change log

### 2026-09-02

- Completed the Modules 2–5 beta input UX phase without starting Module 6 or modifying calculator, converter, assessment-monitoring, interruption-policy, or curriculum-engine logic.
- Replaced graded practice text entry with reusable controlled numeric, fraction, mixed-number, decimal, repeating-notation, and unit-choice components.
- Updated Module 2–5 practice and active-assessment integration coverage to use the in-app keypad; keypad entry and submission produce zero assessment incidents.
- Verified all required 320–1920 logical widths, clean static analysis, 106 focused beta tests, all 241 project tests, and a successful release Web/PWA build.
- Recorded fixes and physical-device limitations in `docs/BETA_TEST_REPORT.md`.
- Completed the separately approved Module 5 Decimal Number System vertical slice without modifying the calculator engine, converter formulas, assessment monitoring, interruption policy, or Modules 2–4.
- Added BigInt coefficient/scale exact decimals, safe comparison and operations, half-up rounding, exact and repeating fraction conversion, shop 64ths, and drill/ream planning.
- Added six curriculum lessons, aviation worked examples, explicit repeating overlines, the corrected `9/16` chart row, a responsive decimal lab, thirteen retryable questions, and versioned local progress.
- Added Module 5 to the existing Aviation Mathematics hub and verified internal lesson/calculator navigation produces zero assessment incidents.
- Added 27 focused tests; verified clean static analysis and all 236 project tests passing.
- Completed the separately approved Module 4 Mixed Numbers vertical slice without modifying the calculator engine, converter formulas, assessment monitoring, interruption policy, or Modules 2–3.
- Reused Module 3 exact-fraction services for normalized conversions, carry/borrow operations, multiplication, division, spacer totals, cut planning, and answer parsing.
- Added five curriculum lessons, aviation worked examples, the authoritative bolt-grip correction, a responsive mixed-number lab, eight retryable practice questions, and versioned local progress.
- Added Module 4 to the existing Aviation Mathematics hub and verified internal lesson/calculator navigation produces zero assessment incidents.
- Added 28 focused tests; verified clean static analysis and all 209 project tests passing.

### 2026-09-01

- Applied the supplied ACATECH Aviation College identity without redrawing or replacing the logo.
- Added full-logo loading/About branding, separate 192/512 regular and maskable PWA icons, branded Android launcher densities, and a branded favicon.
- Added pixel-level maskable safe-zone, branding inventory, manifest, loading-surface, and active-assessment About-navigation tests.
- Documented source treatment, asset inventory, safe-zone geometry, application integration, and remaining physical-device acceptance in `docs/BRANDING.md`.
- Completed calculator Phase 1 as a feature-isolated pure Dart domain module.
- Added immutable calculator state/history models, degree/radian modes, expression parsing, scientific functions, typed errors, and deterministic formatting.
- Completed the approved calculator Phase 2 controller and responsive presentation layer without changing the Phase 1 engine.
- Added the calculator to the existing adaptive shell, with state retained by the existing `IndexedStack` and no changes to root assessment-monitor ownership.
- Added 12 controller/UI tests and active-assessment no-incident integration coverage.
- Completed Phase 3 stabilization without adding product features.
- Expanded responsive checks to the 320 and 2560 px boundaries and added a teacher-PIN-protected assessment start/report/end integration test.
- Verified clean analysis, all 129 VM/widget tests, 18 Chrome tests, and a release Web build.
- Verified manifest/icons/scripts, install eligibility, service-worker shell acquisition, and a byte-identical offline Chrome render after server shutdown.
- Recorded physical mobile/standalone gates, maskable-icon risk, and minor UI consistency/loading observations in `docs/PHASE3_TEST_REPORT.md`.
- Completed the approved Module 2 Whole Numbers vertical slice; Modules 3–13 remain unstarted pending separate approval.
- Completed the separately approved Module 3 Fractions vertical slice and responsive Aviation Mathematics hub; Modules 4–13 remain unstarted.

### 2026-08-31

- Reconciled the checklist with the implemented converter, assessment monitor, local reports, responsive shell, install bridge, and automated-test inventory.
- Added the exact PWA Installation readiness checklist.
- Recorded successful static PWA validation and release Web build while leaving physical install, offline/update, and HTTPS deployment checks open.
- Added static Firebase Hosting configuration without selecting or deploying to a project.
- Recorded clean analysis, 95 passing tests, 14 passing Chrome-interoperability tests, and a successful Android debug build.
- Added a Vercel static deployment configuration and local-build deployment guide.
- Verified a public HTTPS preview, direct SPA fallbacks, static content types, security headers, and release-artifact hashes.
- Recorded the remaining Vercel first-deployment cleanup gate without weakening the preview-only release policy.

### 2026-08-28

- Recorded the generated Flutter scaffold as the verified implementation baseline.
- Added the approved root-monitor, neutral evidence, exact threshold, responsive tier, local-report, and future Firebase decisions.
- Established the initial live delivery checklist.
