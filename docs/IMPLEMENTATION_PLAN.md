# Calculator Module Implementation Plan

**Plan date:** 2026-09-01
**Status:** Phases 1 and 2 complete and verified; awaiting approval for Phase 3
**Source specification:** `Unit_Converter_Calculator_PWA_GitHub_Vercel_Plan.md` at the repository root

> The requested source path, `docs/Unit_Converter_Calculator_PWA_GitHub_Vercel_Plan.md`, does not currently exist. The same-named, untracked document at the repository root was used for this assessment. It will not be moved or committed without approval.

Phase 1 was approved on 2026-09-01. The pure calculator models, parser/evaluator, typed errors, deterministic number formatter, and 21 focused tests are implemented.

The subsequently approved Phase 2 scope combines calculator application state, responsive presentation, local history UX, and minimal adaptive-shell access. It is complete with 12 additional controller/widget tests. The Phase 1 engine was not modified. Assessment tool-policy enforcement, report changes, GitHub work, and deployment remain outside this checkpoint.

## 1. Objective and non-regression boundaries

Add a basic, scientific, and engineering calculator to Unit Converter Classroom while preserving all existing behavior:

- The nine-category unit converter and all conversion formulas.
- The single root-scoped `AssessmentMonitor` above `MaterialApp`, navigation, and feature pages.
- `InterruptionPolicy` thresholds and return-time duration calculation.
- Immediate persistence of a pending absence on hidden/paused transitions.
- Local-only assessment reports and the future Firebase repository seam.
- The PWA install bridge, app-owned service worker, manifest, icons, and SPA fallback.
- Compact, medium, and expanded responsive behavior.
- Teacher authorization boundaries and all 95 currently passing tests.

The calculator will be an internal feature. Opening it, entering expressions, using history or memory, opening calculator-owned UI, showing the keyboard, and navigating between calculator and converter screens must not emit lifecycle events or create assessment incidents.

## 2. Current project assessment

### 2.1 Repository and platform baseline

- Flutter/Dart project with Android, iOS, and Web runners.
- Desktop support currently means responsive Web/PWA on Windows and macOS; native Windows and macOS runners do not exist.
- Git is initialized on `main` with two commits and a clean tracked worktree.
- No Git remote is configured, so no GitHub repository URL or push target is available.
- The calculator specification is currently an untracked root file.
- Baseline verification on 2026-09-01:
  - `flutter analyze`: passed with no issues.
  - `flutter test --reporter compact`: all 95 tests passed.

### 2.2 Existing application architecture

The application is composed as follows:

```text
main.dart
└── UnitConverterApp (root lifecycle ownership)
    ├── AppLifecycleListener
    ├── SystemPresenceBridge subscription
    ├── MaterialApp and Material 3 themes
    └── UnitConverterShell
        ├── AdaptiveScaffold
        ├── Converter
        ├── Assessment
        └── Teacher-gated Reports
```

`UnitConverterShell` uses an `IndexedStack`, which is suitable for adding a calculator without destroying feature state during internal navigation. The current shell uses numeric destination indices; adding a destination without first removing that implicit coupling could send report authorization or assessment actions to the wrong page.

### 2.3 Already completed requirements

| Requirement area | Current evidence |
|---|---|
| Unit conversion | Pure affine/linear conversion domain, nine categories, search, swap, validation, formatting, and unit/widget tests |
| Material 3 and dark theme | Shared light/dark `ThemeData` generated from the existing brand seed |
| Responsive layout | Compact `<600`, medium `600–1023`, expanded `1024+`; bottom navigation changes to rail/sidebar |
| Assessment monitor placement | One lifecycle listener and system-signal subscription in `UnitConverterApp`, above `MaterialApp` and the shell |
| Interruption classification | Less than 2 seconds ignored, 2–9.999 seconds review, 10 seconds or more extended |
| Pending absence | Saved before suspension on hidden/paused and cleared only after resolution |
| Return-time duration | Calculated from persisted timestamps on resume, not from background timers |
| False-positive controls | Internal navigation creates no incident; inactive-only mobile transitions are ignored; trusted install prompts are explicitly suppressed |
| Reports | SharedPreferences-backed local reports, neutral terminology, teacher PIN gate, and deletion |
| PWA | Early install bridge, iOS instructions, standalone detection, valid manifest/icons, one app-owned `sw.js`, offline shell policy |
| Static deployment | `vercel.json`, `.vercelignore`, SPA fallback, security/cache headers, and a verified HTTPS preview |
| Tests | 95 passing tests covering converter, assessment, reports repository, responsive shell, PIN, and PWA install service |

### 2.4 Missing calculator requirements

No calculator feature directory or calculator implementation currently exists. All items below are missing:

- Expression parsing and evaluation.
- Addition, subtraction, multiplication, division, decimals, unary negatives, percentages, and parentheses.
- Square root, powers, exponential function, reciprocal, trigonometry, logarithms, π, and Euler's constant.
- Degree/radian mode.
- Fraction expressions.
- MC, MR, M+, and M− memory operations.
- Calculator state and calculation history.
- Responsive calculator display, keypad, scientific controls, memory controls, and history UI.
- Calculator-specific unit, controller, widget, responsive, and assessment-compatibility tests.
- Calculator navigation and active-assessment allowed-tool enforcement.

### 2.5 Missing assessment-tool requirements

The specification shows an assessment tool policy with Unit Converter and Calculator allowed and Settings disallowed. The existing session model stores no allowed-tool snapshot and the setup screen has no tool controls.

Required additions:

- A backward-compatible `AssessmentToolPolicy` stored with each session.
- Teacher-selectable Unit Converter and Calculator controls during assessment setup.
- Settings represented as unavailable during an active assessment.
- Navigation enforcement that blocks a disallowed tool without generating an interruption.
- Active-session UI and teacher reports showing the session's allowed tools.
- Existing sessions without the new JSON field must load with safe defaults.

## 3. Requirement decisions for implementation

Approval of this plan accepts these deterministic interpretations of ambiguous calculator requirements:

1. The calculator will use a pure Dart parser; it will never execute user text as Dart or JavaScript.
2. `^` is a right-associative power operator. `exp(x)` means `e^x`.
3. Postfix `%` means divide the preceding value by 100. Percentage-of calculations use multiplication, for example `200 × 10% = 20`; contextual commercial-calculator behavior such as `200 + 10% = 220` is not implied.
4. Fractions use ordinary division expressions such as `1/2 + 1/4`. Results are numeric rather than symbolic rational reductions.
5. History and memory are local to the running application session. They are not assessment evidence and are not persisted or synchronized.
6. History is bounded to prevent unbounded memory growth; the proposed limit is 50 successful calculations.
7. Division by zero, invalid syntax, square root of a negative value, logarithm of a non-positive value, undefined tangent points, overflow, and non-finite results produce visible recoverable errors.
8. Unit Converter and Calculator default to allowed for new and legacy assessment sessions. Settings remains unavailable during an active session.
9. Native Windows/macOS runners are outside this implementation. Windows and macOS acceptance uses the responsive Web/PWA, consistent with the existing architecture.

## 4. Target calculator architecture

```text
CalculatorPage and widgets
↓ user intents
CalculatorController
↓ pure evaluation
CalculatorEngine
↓ immutable output
CalculatorState + CalculatorHistory
```

Responsibilities:

- `CalculatorEngine`: tokenization, parsing, operator precedence, functions, constants, domain validation, and numeric evaluation.
- `CalculatorState`: immutable expression, display result, error, angle mode, memory value, and history snapshot.
- `CalculatorHistory`: immutable successful expression/result entries with timestamps and a bounded collection.
- `CalculatorController`: input editing, clear/backspace, evaluation, degree/radian mode, memory commands, history commands, and UI notification.
- Presentation widgets: render state and dispatch intent only; no mathematical logic.

The shell will own one `CalculatorController` for its lifetime and dispose it with the shell. This preserves calculator state across `IndexedStack` navigation without adding calculator responsibilities to `main.dart` or the assessment monitor.

## 5. Implementation phases

### Phase 0 — Protect the baseline

1. Preserve the current untracked specification file.
2. Reconfirm the clean tracked worktree before editing.
3. Run the existing converter, assessment, PWA, and responsive tests before each high-risk integration phase.
4. Do not modify conversion formulas, `AssessmentMonitor`, `InterruptionPolicy`, the PWA bridge, or `sw.js` unless a failing acceptance test proves a change is necessary.

### Phase 1 — Pure calculator domain

1. Add immutable angle-mode, result/error, state, and history models.
2. Implement a tokenizer and recursive-descent or Pratt-style parser in pure Dart.
3. Support:
   - Binary `+`, `−`, `×`, `÷`, and `^`.
   - Unary positive/negative operators.
   - Decimal and scientific numeric literals.
   - Parentheses and postfix percentage.
   - `sqrt`, `sin`, `cos`, `tan`, `log`, `ln`, and `exp`.
   - `pi` and `e` constants.
4. Reject malformed and non-finite expressions with typed calculator errors.
5. Add exhaustive engine tests before creating UI.

### Phase 2 — Calculator application state

1. Add `CalculatorController` as a `ChangeNotifier`.
2. Implement digit/operator/function entry, clear, backspace, evaluate, and error recovery.
3. Implement degree/radian mode and apply it only to trigonometric functions.
4. Implement MC, MR, M+, and M− against the last valid result.
5. Add bounded history and a clear-history action.
6. Test every state transition independently of widgets.

### Phase 3 — Responsive calculator UI

1. Build a Material 3 calculator page using shared theme tokens.
2. Add:
   - Expression/result display with accessible live-region semantics.
   - Basic keypad with large touch targets.
   - Scientific and engineering controls.
   - Degree/radian segmented control.
   - Memory status and controls.
   - History panel on expanded layouts and a modal sheet/dialog on compact layouts.
3. Use `LayoutBuilder`, `Flexible`, `Expanded`, scrolling containers, and responsive grids.
4. Avoid fixed page dimensions; only minimum touch constraints and bounded content widths are allowed.
5. Verify 320, 360, 390, 600, 768, 1024, 1366, and 1920 logical-pixel widths in light and dark themes.

### Phase 4 — Shell and navigation integration

1. Replace fragile numeric-section assumptions with a stable app-section identifier or an explicit index mapping.
2. Add Calculator as an internal destination while preserving Home/Converter, Assessment, and teacher-gated Reports.
3. Place `CalculatorPage` in the existing `IndexedStack` so internal navigation does not recreate the root monitor or calculator controller.
4. Preserve the install action, theme behavior outside assessments, active-assessment banner, converter selections, and report authorization.
5. Extend responsive shell tests for four destinations and small-width navigation.

### Phase 5 — Assessment allowed tools

1. Add an immutable `AssessmentToolPolicy` model with Unit Converter and Calculator flags; Settings remains false.
2. Extend `AssessmentSession` serialization, `end`, equality, and hash behavior.
3. Read missing policy data as the backward-compatible default of Converter + Calculator allowed.
4. Add teacher-controlled tool choices to the assessment setup form and require at least one student tool.
5. Pass the policy through `AssessmentAppController.startSession`.
6. During an active session:
   - Permit only the selected student tools.
   - Block disallowed internal destinations with neutral in-app feedback.
   - Disable the theme/settings action.
   - Preserve teacher-gated report access and session-ending controls.
7. Show the policy on the active assessment and report UI.
8. Confirm calculator input, history, memory, sheets/dialogs, keyboard use, and internal navigation create no incidents.
9. Reconfirm a real hidden/paused and resumed sequence still produces exactly one duration-based incident.

### Phase 6 — Documentation and PWA regression

1. Update architecture documentation to add the calculator boundary and assessment tool policy.
2. Update development status and test plan with evidence rather than aspirational checkmarks.
3. Update README features and local usage documentation.
4. Keep calculator assets inside compiled Flutter output where possible; no new service-worker path should be necessary.
5. Verify manifest validity, bridge-before-bootstrap ordering, `sw.js` ownership, generated asset availability, and offline shell behavior.
6. Preserve the existing app identity unless separate branding approval is given.

### Phase 7 — Release verification and preview

1. Run formatting, static analysis, all tests, and a clean Web release build.
2. Inspect generated JavaScript, manifest, icons, service-worker registration, and release file inventory.
3. Re-run converter, assessment, PWA installation, responsive, and teacher-authorization regression suites.
4. Create a Vercel preview explicitly with `--target preview`; do not promote to production.
5. Verify `/`, `/calculator`, `/assessment`, `/reports`, `/converter`, manifest, bridge, worker, icons, JavaScript, and WASM over public HTTPS.
6. Perform manual install checks on Android Chrome, iOS/iPadOS Safari, and Chrome/Edge desktop before student acceptance.

## 6. Required files

### 6.1 New calculator files

```text
lib/features/calculator/
├── calculator.dart
├── application/
│   └── calculator_controller.dart
├── models/
│   ├── calculator_angle_mode.dart
│   ├── calculator_history.dart
│   └── calculator_state.dart
├── services/
│   └── calculator_engine.dart
├── presentation/
│   └── calculator_page.dart
└── widgets/
    ├── calculator_display.dart
    ├── calculator_history_view.dart
    └── calculator_keypad.dart
```

The exact private parser helpers may remain inside `calculator_engine.dart` unless separation materially improves testability.

### 6.2 New assessment file

```text
lib/features/assessment/domain/models/assessment_tool_policy.dart
```

### 6.3 Existing files expected to change

| File | Planned change |
|---|---|
| `lib/app/app.dart` | Calculator controller ownership, stable destination mapping, Calculator page, assessment policy enforcement, settings lock |
| `lib/features/assessment/domain/models/assessment_session.dart` | Backward-compatible tool-policy snapshot and serialization |
| `lib/features/assessment/presentation/assessment_app_controller.dart` | Accept policy when starting a session |
| `lib/features/assessment/presentation/assessment_page.dart` | Allowed-tools setup and active-session tool actions |
| `lib/features/reports/presentation/reports_page.dart` | Display the session's allowed-tool snapshot |
| `test/app/responsive_shell_test.dart` | Calculator navigation, four-destination layouts, monitor identity, and no-incident integration |
| `test/features/assessment/domain/assessment_models_test.dart` | Policy invariants and legacy/new JSON round trips |
| `README.md` | Calculator feature and testing instructions |
| `ARCHITECTURE.md` | Calculator boundaries and assessment tool-policy flow |
| `DEVELOPMENT_STATUS.md` | Phase progress and verified evidence |
| `TEST_PLAN.md` | Calculator, responsive, accessibility, and assessment compatibility matrices |
| `docs/DEPLOYMENT.md` | Calculator route and student acceptance checks |

`lib/main.dart`, converter source, `AssessmentMonitor`, `InterruptionPolicy`, PWA bridge files, `web/flutter_bootstrap.js`, `web/sw.js`, `vercel.json`, and `.vercelignore` are verification-only by default and should not change.

### 6.4 New tests

```text
test/features/calculator/services/calculator_engine_test.dart
test/features/calculator/application/calculator_controller_test.dart
test/features/calculator/presentation/calculator_page_test.dart
```

## 7. Testing strategy

### 7.1 Calculator engine

- `2+2`, `10/2`, decimal arithmetic, unary negatives, nested parentheses, and precedence.
- Fraction expressions and postfix percentage.
- Right-associative powers, square root, reciprocal, and exponential function.
- Degree/radian trigonometry with representative exact or tolerance-based cases.
- Base-10 and natural logarithms, π, and e.
- Division by zero, invalid tokens, incomplete parentheses, domain violations, and non-finite results.
- Whitespace and repeated-evaluation behavior.

### 7.2 Controller and models

- Immutable state transitions and error recovery.
- Clear and backspace at empty/non-empty boundaries.
- Memory clear, recall, add, and subtract.
- History creation only for successful calculations, deterministic ordering, limit enforcement, recall, and deletion.
- Angle-mode changes without corrupting the current expression.
- Controller disposal and listener behavior.

### 7.3 Widget and responsive tests

- Basic and scientific calculations through visible controls.
- Error messages and recovery.
- Degree/radian control, memory actions, and history UI.
- Large control semantics and keyboard reachability.
- No overflow at the representative compact, medium, and expanded widths.
- Dark-theme rendering and text scaling checks.

### 7.4 Assessment compatibility

- Starting a session stores its allowed-tool policy.
- Legacy stored sessions receive safe defaults.
- Calculator and converter navigation preserve the same monitor instance.
- Calculator entry, memory, history, dropdown/sheet/dialog, keyboard, and internal navigation produce zero incidents.
- A disallowed tool remains inaccessible without lifecycle side effects.
- Settings/theme changes are unavailable during an active session.
- Hidden/paused persists a pending absence immediately.
- No duration is calculated before return.
- Resume calculates duration and stores exactly one policy-classified incident.
- Existing screen-off/device-lock exclusions and trusted PWA prompt handling remain intact.

### 7.5 Regression and release commands

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --reporter compact
flutter build web --release
```

Additional static checks:

```bash
python3 -m json.tool web/manifest.json
python3 -m json.tool vercel.json
node --check build/web/flutter_bootstrap.js
node --check build/web/pwa_install_bridge.js
node --check build/web/sw.js
```

The existing 95 tests are the regression floor. Implementation is not complete if any current test is deleted, weakened, or left failing merely to accommodate the calculator.

## 8. Deployment plan

### 8.1 Git and GitHub

- Do not run `git init`; the repository already exists on `main`.
- Preserve the untracked source specification until its intended location is confirmed.
- Stage only audited source and documentation; `build/`, `.dart_tool/`, `.vercel/`, environment files, credentials, signing files, and local report data remain excluded.
- Use focused commits after the complete test gate, for example:
  - `Add calculator domain and application state`
  - `Integrate responsive calculator with assessment tools`
  - `Document and verify calculator PWA preview`
- No GitHub push is possible until the user supplies or creates a real remote URL. Never invent one or overwrite a remote.

### 8.2 Vercel

The new specification's GitHub-import instruction conflicts with the current verified deployment model: Vercel's default static build environment is not configured with Flutter. Retain the existing safer workflow unless a Flutter-capable CI pipeline is separately approved:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build web --release
npx --yes vercel@latest deploy --target preview --yes
```

- `.vercelignore` continues to upload only `build/web` and `vercel.json`.
- Never use `--prod` during implementation acceptance.
- Confirm Vercel Authentication settings permit the intended student testers.
- Verify the returned deployment is explicitly `target: preview` and `Ready`.
- Verify direct route fallbacks and static content types rather than claiming success from CLI output alone.
- The previously recorded unintended first production deployment remains a separate cleanup item requiring explicit deletion approval.

### 8.3 PWA/device acceptance

- Desktop Chrome/Edge: install, standalone launch, calculator/converter use, offline reload.
- Android Chrome: install, launcher icon, standalone launch, rotation, keyboard, calculator, converter, and assessment checks.
- iPhone/iPad Safari: manual Add to Home Screen, safe areas, rotation, calculator, converter, and local-data behavior.
- Windows/macOS: test the responsive Web/PWA. Native desktop binaries are not part of the current project.

## 9. Conflicts and risks

| Risk or conflict | Mitigation |
|---|---|
| Requested specification path is missing | Use the root file for planning only; do not move it without approval |
| Calculator terminology is ambiguous | Adopt the explicit semantics in section 3 and cover them with tests |
| A custom parser can mishandle precedence or domains | Keep it pure, small, typed, and exhaustively unit tested; never evaluate code dynamically |
| IEEE-754 results may surprise users | Reuse deterministic display principles, test tolerances, and expose errors for non-finite values |
| Adding a fourth destination can break numeric index assumptions | Introduce stable section mapping before adding the page |
| Four compact navigation items may overflow or truncate | Test from 320 px and shorten accessible visual labels only if necessary |
| Allowed tools modify stored session schema | Add an optional backward-compatible field and legacy round-trip tests |
| Disabling Settings could accidentally disable unrelated PWA behavior | Treat the theme action as Settings; retain the independently tested install flow and trusted-prompt suppression |
| Calculator dialogs/history could be mistaken for departures | Keep them entirely inside Flutter and add no-incident integration tests |
| Monitor changes could double-count or lose absences | Do not relocate or rewrite `AssessmentMonitor`; retain immediate pending writes and resume-only resolution |
| New main bundle could break offline PWA updates | Rely on the generated build token, verify the active worker and cache transition, and test release A → B |
| GitHub/Vercel instructions conflict with current setup | Do not reinitialize Git; require a real remote; continue local Flutter builds and explicit preview deployments |
| First Vercel deployment was auto-promoted previously | Keep production cleanup separate and require explicit destructive-action approval |
| Specification names native Windows/macOS but runners are absent | Deliver and test Web/PWA there unless native runners receive separate approval |
| Physical installation and lifecycle behavior cannot be proven by widget tests | Keep Android, iOS/iPadOS, and desktop manual acceptance as release gates |

## 10. Approval gate and definition of done

No implementation begins until this plan is approved.

After approval, the calculator increment is complete only when:

- All specified calculator operations, history, memory, and angle modes work.
- Mathematical domain errors are recoverable and never crash the UI.
- Converter behavior and its existing tests remain unchanged and passing.
- Calculator UI passes compact, medium, expanded, light, and dark checks.
- Allowed-tool settings are stored and enforced backward-compatibly.
- Calculator and internal navigation create no assessment incidents.
- Actual hidden/paused and resumed behavior still produces one correct incident.
- PWA install assets, service worker ownership, offline shell, and SPA routes pass regression checks.
- `flutter analyze`, the full test suite, and `flutter build web --release` pass.
- A public HTTPS preview is verified on real routes and static assets.
- Physical PWA installation remains explicitly pending until tested on the named target devices.
