# AMT 111 Module Implementation Roadmap

Status: **Architecture approved; application implementation not started**  
Scope: **Modules 2–13 only**  
Source plan: [`MODULE_2_13_IMPLEMENTATION_PLAN.md`](MODULE_2_13_IMPLEMENTATION_PLAN.md)

## 1. Purpose and delivery rules

This roadmap converts the approved curriculum plan into an executable Flutter development sequence. It does not authorize changes to the existing converter engine, calculator engine, presence-monitoring policy, PWA installation system, or report semantics.

Every module is delivered as a small vertical slice:

1. Versioned curriculum content.
2. Pure Dart mathematical logic.
3. Lesson and worked-example UI.
4. Practice and answer validation.
5. Curriculum assessment support.
6. Local progress persistence.
7. Unit, widget, integration, and regression tests.

Implementation proceeds only when the preceding module and phase exit gates pass. Shared abstractions are extracted only after their behavior is proven in at least two modules. Existing converter and calculator functionality is consumed through adapters and is not rewritten.

The following curriculum rules apply throughout:

- Use the PowerPoint-derived curriculum plan as the authoritative scope.
- Show `Given → Formula → Substitute → Solve` for worked calculations.
- Preserve units through every applicable step.
- Keep exact values during working and round only at the declared final step.
- Preserve all documented curriculum corrections and source references.
- Treat calculations as educational examples, never as maintenance or airworthiness authority.
- Keep all Module 2–13 lessons, practice, results, and assets available offline.

## 2. Implementation phases

### Foundation gate — shared contracts and baseline protection

This gate creates only the minimum framework required for the first Module 2 vertical slice.

Deliverables:

- Record the current converter, calculator, assessment, reports, navigation, branding, and PWA regression baseline.
- Define stable curriculum, lesson, problem, formula, source, assessment, and progress identifiers.
- Add a versioned bundled-content manifest and loader contract.
- Add repository interfaces for curriculum content, progress, practice attempts, and learning results.
- Add a module registry that can expose one `Aviation Math` or `Tools` destination without adding twelve root destinations.
- Define an adapter boundary for launching the existing calculator without coupling curriculum code to its engine internals.
- Define assessment allowed-tool identifiers without changing current presence behavior.
- Add shared serialization, schema validation, and repository contract tests.

Exit criteria:

- Existing tests remain at or above their current baseline.
- The application still starts and all existing root destinations behave unchanged.
- Empty/loading/error states for the future curriculum hub are specified and testable.
- No presence, interruption, or incident model has been changed.

### Phase A — Modules 2–5: number systems foundation

Purpose: establish exact arithmetic and the reusable learning flow on which later modules depend.

#### A1 — Module 2: Whole Numbers

- Implement whole-number operations, factors, multiples, prime factors, divisibility, greatest common divisor, and least common multiple.
- Establish the first complete module screen, lesson reader, four-line worked example, practice flow, progress recording, and Module 2 Quiz.
- Validate the content schema and screen pattern before copying it to other modules.

Gate: Module 2 domain, content, widget, storage, responsive, accessibility, and active-assessment compatibility tests pass.

#### A2 — Module 3: Fractions

- Introduce normalized `ExactFraction` arithmetic and reuse Module 2 GCD/LCM behavior.
- Implement equivalent fractions, LCD methods, cancellation, operations, improper/proper conversion, and lowest terms.
- Add Seat Work 2 and lock the corrected LCD result of 64 with a curriculum regression test.

Gate: all fraction operations remain exact and serialize without loss.

#### A3 — Module 4: Mixed Numbers

- Build mixed-number parsing, normalization, borrowing, and operations on top of `ExactFraction`.
- Add compound-form worked examples and preserve the corrected bolt result `1 13/16`.
- Reuse fraction validation rather than duplicating arithmetic.

Gate: mixed-number input, output, reduction, and four-line steps pass across phone, tablet, and desktop layouts.

#### A4 — Module 5: Decimal Number System

- Introduce coefficient-and-scale decimal arithmetic to avoid binary floating-point artifacts.
- Implement decimal place value, operations, rounding, fraction/decimal conversion, repeating notation, and sixty-fourths.
- Add Seat Work 3 covering Modules 4–5.

Phase A exit criteria:

- Modules 2–5 are usable offline from a single responsive catalog.
- Shared exact fraction and decimal primitives pass boundary and serialization tests.
- Module 2 Quiz, Seat Work 2, and Seat Work 3 are locally recoverable after reload.
- Major Quiz 1 remains disabled because Module 1 is outside the approved scope.
- Full existing regression, analysis, web build, and offline checks pass.

### Phase B — Modules 6–8: applied mathematics

Purpose: apply the Phase A number system to relationships, statistical summaries, and percentage problems.

#### B1 — Module 6: Ratio

- Implement ratio reduction, equivalent ratios, proportion solving, unit-rate reasoning, and cross multiplication.
- Reuse exact fractions and scaled decimals for deterministic results.
- Add aviation ratio examples with explicit units and distracter selection.

#### B2 — Module 7: Average Value

- Implement arithmetic mean, total/count validation, missing-value cases, and appropriate rounding.
- Separate deterministic numerical scoring from teacher-reviewed outlier interpretation.
- Add a rubric state for answers that require manual review.

#### B3 — Module 8: Percentage

- Implement percent/decimal/fraction conversions and the three problem forms: percentage, rate, and base.
- Reuse ratio, exact fraction, and decimal behavior.
- Preserve units and defer rounding until the final answer.

Phase B exit criteria:

- The Modules 6–8 Long Quiz is complete and locally persisted.
- Teacher-reviewed Module 7 responses cannot be falsely marked fully correct by automatic scoring.
- Phase A results and progress remain readable after any storage migration.
- Full assessment-compatibility and application regression gates pass.

### Phase C — Modules 9–10: signed and denominated numbers

Purpose: add direction-sensitive arithmetic and compound-unit operations without changing the general converter.

#### C1 — Module 9: Positive and Negative Numbers

- Implement signed arithmetic, comparison, absolute value, sign rules, and physical sign semantics.
- Distinguish a numerical sign from an aviation direction or reference convention in lesson content and validation.

#### C2 — Module 10: Denominated Numbers

- Implement `CompoundQuantity` arithmetic and normalization for major/minor unit systems.
- Add time, length, weight, and temperature examples through a curriculum-specific conversion profile.
- Keep the existing Unit Converter catalog and formulas unchanged, including when curriculum approximations differ.
- Lock the temperature formulas `C = (5/9)(F − 32)` and `F = (9/5)C + 32` with tests.

Phase C exit criteria:

- Seat Work 5 and Major Quiz 2 are complete and locally persisted.
- The existing converter gives exactly the same results as before this phase.
- The curriculum conversion profile is clearly labeled and cannot leak into the general converter.
- The Midterm remains disabled because Module 1 is outside the approved scope.
- Full assessment-compatibility and application regression gates pass.

### Phase D — Modules 11–13: advanced numerical representation

Purpose: complete the approved curriculum with powers, roots, and scientific notation.

#### D1 — Module 11: Powers and Indices

- Implement powers, exponent laws, powers of ten, negative bases, and expression-order exercises.
- Enforce equal precedence with left-to-right evaluation for multiplication/division and addition/subtraction.
- Keep the existing calculator parser unchanged; use it only through an optional verification adapter.

#### D2 — Module 12: Roots

- Implement exact perfect-root detection, approximate roots, root estimation, and fractional-index relationships.
- Use declared tolerances only for irrational results and preserve final-step rounding rules.
- Lock the corrected `N = 62` circle-area result `3019.07` with a regression test.

#### D3 — Module 13: Scientific Notation

- Implement normalization, standard/scientific conversion, powers-of-ten arithmetic, and metric-prefix movement.
- Validate coefficients, exponent alignment, significant digits, division by zero, and prefix symbol case.
- Add the combined Modules 12–13 Seat Work.

Phase D exit criteria:

- Seat Work 6 and the Modules 12–13 Seat Work are complete and locally persisted.
- All Modules 2–13 work offline and restore progress after reload.
- The Final remains disabled because Modules 1 and 14 are outside the approved scope.
- Full analysis, tests, release build, installed-PWA, responsive, accessibility, and physical-device acceptance pass.

### Release stabilization gate

- Run cumulative converter, calculator, assessment, report, PWA installation, branding, offline, curriculum, and migration regression suites.
- Verify route restoration and persisted practice/assessment recovery after refresh and installed-PWA restart.
- Profile curriculum asset size, first module load, module-to-module navigation, and low-end device behavior.
- Perform manual acceptance on Chrome desktop, Chrome Android, Safari iOS/iPadOS, and at least one installed desktop PWA.
- Confirm teacher-gated learning reports remain separate from presence reports.
- Document deferred Major Quiz 1, Midterm, and Final scope.

## 3. Feature architecture

The requested feature layout is organized into shared capabilities, a module registry, and twelve independently testable numbered features.

```text
lib/features/
├── curriculum/
│   ├── domain/
│   │   ├── models/
│   │   └── repositories/
│   ├── application/
│   └── data/
├── lessons/
│   ├── application/
│   └── presentation/widgets/
├── practice/
│   ├── domain/
│   ├── application/
│   └── presentation/widgets/
├── assessments/
│   ├── domain/
│   ├── application/
│   └── data/
├── progress/
│   ├── domain/
│   │   ├── models/
│   │   └── repositories/
│   ├── application/
│   └── data/
├── modules/
│   ├── domain/
│   ├── application/
│   └── presentation/
├── module_02/
├── module_03/
├── module_04/
├── module_05/
├── module_06/
├── module_07/
├── module_08/
├── module_09/
├── module_10/
├── module_11/
├── module_12/
└── module_13/
```

### Shared feature ownership

| Feature | Responsibility | Must not own |
|---|---|---|
| `curriculum` | Versioned module/lesson/formula/problem/source definitions, asset loading, schema validation | Student state, presence incidents, UI navigation |
| `lessons` | Lesson sequencing and reusable learning presentation | Mathematical truth or persistence implementation |
| `practice` | Question sessions, input capture, feedback timing, answer-validation orchestration | Assessment presence signals or teacher PIN |
| `assessments` | Curriculum blueprints, item responses, scoring, submission, rubric status | Existing assessment presence sessions/incidents |
| `progress` | Lesson completion and attempt repositories/controllers | Curriculum source content or interruption classification |
| `modules` | Module descriptors, dependency/availability registry, catalog and module route shell | Module-specific arithmetic |
| `module_02` … `module_13` | Module-specific engines, content adapters, screens, widgets, and tests | Root navigation, presence monitoring, unrelated module logic |

Each numbered module uses the same internal shape only where needed:

```text
module_XX/
├── domain/
│   ├── models/
│   └── services/
├── application/
├── presentation/
│   ├── module_XX_screen.dart
│   └── widgets/
└── module_XX.dart
```

Tests mirror production ownership:

```text
test/features/
├── curriculum/
├── lessons/
├── practice/
├── assessments/
├── progress/
├── modules/
├── module_02/
├── ...
└── module_13/
```

Curriculum content is bundled separately from Dart UI code:

```text
assets/curriculum/amt111/
├── curriculum_manifest.json
├── module_02.json
├── ...
└── module_13.json
```

The raw PowerPoint is not shipped in the application bundle. Stable source IDs and curriculum-version metadata preserve traceability.

### Navigation boundary

- Add one future `Aviation Math` or `Tools` entry using the current adaptive-navigation pattern.
- Display Modules 2–13 in an internal responsive catalog, not as twelve root destinations.
- Use internal Flutter navigation for catalog, lesson, practice, and assessment routes.
- Keep `AssessmentMonitor` above the navigation/root level.
- Use stable route and module IDs so progress restoration is independent of display titles.
- Do not duplicate mobile and desktop destination logic.

## 4. Shared components

| Component | Layer and responsibility | Reuse rule |
|---|---|---|
| `LessonCard` | Presentation widget showing module/lesson title, objective, availability, completion state, and navigation action | Receives immutable view data; never writes progress directly |
| `ExampleViewer` | Presentation widget for stepwise `Given → Formula → Substitute → Solve`, units, answer, and optional explanation | Read-only in lessons; reveal timing is controlled by practice/assessment state |
| `FormulaCard` | Presentation widget for formula, variable definitions, unit constraints, source, and curriculum correction badge | Formula data comes from the curriculum model, not hardcoded widget text |
| `PracticeQuestion` | Presentation widget selecting the appropriate numeric/text/unit input and rendering distracters, hints, submit, and feedback states | Delegates evaluation to `AnswerValidator` and has no presence-monitor behavior |
| `AnswerValidator` | Pure Dart domain service comparing exact, normalized, tolerance-based, step-based, and unit-bearing responses | Module policies configure it; widgets and repositories do not duplicate validation rules |
| `ProgressTracker` | Application service/controller that updates and observes lesson completion and attempt summaries through repository interfaces | Does not infer completion merely from opening a page and does not store incidents |
| `AviationExampleCard` | Presentation widget for scenario, givens, cautions, educational-use notice, and source traceability | Never labels a classroom result as airworthy or maintenance-approved |
| `CalculatorLauncher` | Presentation/application adapter that opens the existing calculator through the existing navigation contract when allowed | Does not import or rewrite calculator internals; internal use creates no incident |

Additional candidates should be introduced only when repeated behavior is confirmed:

- `ModuleScaffold` for a common responsive module header and section layout.
- `FourLineWorkspace` for guided entry of the required calculation method.
- `UnitAnswerField` for value-and-unit responses.
- `CurriculumSourceBadge` for traceability and corrections.
- `AssessmentStatusBanner` for allowed-tool and submission status.

Reusable components must support Material 3, light/dark themes, keyboard navigation, semantic labels, text scaling, and touch targets of at least 48 logical pixels.

## 5. Local database and storage design

### Storage principles

- Local-only is the first implementation; there is no Firebase dependency or network requirement.
- Repository interfaces isolate domain/application code from the browser persistence mechanism.
- All records use stable client-generated IDs, UTC timestamps, an explicit `schemaVersion`, and the relevant `curriculumVersion`.
- Stored values use lossless string/integer representations for fractions, scaled decimals, and large exponents.
- Data is namespaced by feature and schema version and migrated transactionally where the selected local store supports it.
- Recovery from malformed or partially written records is tested; corruption in one attempt must not erase all progress.
- Browser storage can be cleared by the user or platform, so the UI must describe local-only retention honestly.
- Presence data and learning data remain in separate repositories and storage namespaces.

Use the existing lightweight local approach only for small bounded preferences or summaries. Before storing a large question bank or unbounded item-response history, select a durable web-compatible local database behind the same repository contracts and document its licensing, migration, quota, and browser-support behavior.

### Core local models

#### `StudentProgress`

```text
id
studentId                 # local opaque identifier; no cloud account required
curriculumId
curriculumVersion
moduleSummaries           # derived/bounded progress summaries by stable module ID
lastLocation              # optional module/lesson route for restoration
createdAtUtc
updatedAtUtc
schemaVersion
```

`StudentProgress` is an aggregate summary. Detailed lesson and attempt records remain normalized so an update does not rewrite the entire learning history.

#### `LessonCompletion`

```text
id
studentId
moduleId
lessonId
status                    # notStarted, inProgress, complete
lastContentPosition
startedAtUtc
completedAtUtc
updatedAtUtc
curriculumVersion
schemaVersion
```

Opening a lesson may set `inProgress`; only the defined completion rule can set `complete`.

#### `PracticeAttempt`

```text
id
studentId
moduleId
lessonId
questionId
attemptNumber
responsePayload           # versioned typed response, including unit and steps
validationSummary
scoreAwarded
scorePossible
hintsUsed
startedAtUtc
submittedAtUtc
curriculumVersion
schemaVersion
```

Exact values are serialized canonically. Irrational-result tolerances and the validation-policy version are stored with the result so a later rule change does not silently reinterpret an old attempt.

#### `AssessmentResult`

```text
id
studentId
assessmentBlueprintId
assessmentBlueprintVersion
moduleIds
itemResponses             # or references to normalized item-response records
scoreAwarded
scorePossible
rubricStatus              # notRequired, pendingTeacherReview, reviewed
status                    # inProgress, submitted, finalized
startedAtUtc
submittedAtUtc
curriculumVersion
schemaVersion
assessmentSessionId       # optional reference only; never an embedded incident
```

`AssessmentResult` represents learning performance. It is not the same object as the existing presence assessment session, pending absence, or incident.

### Repository contracts

- `CurriculumRepository`: read-only access to bundled, versioned module content.
- `ProgressRepository`: lesson completions and bounded student progress summaries.
- `PracticeAttemptRepository`: local practice recovery, submission history, and retention.
- `CurriculumAssessmentRepository`: curriculum attempts, item responses, scores, and rubric status.

All repositories expose typed domain objects, not storage-library records. Serialization and migrations remain in `data/`.

### Future Firebase compatibility

Firebase synchronization remains future architecture, implemented later as a repository decorator or synchronization service rather than a replacement for domain models.

Preparation rules:

- Generate IDs locally to support offline creation and idempotent upload.
- Keep `createdAtUtc` immutable and track `updatedAtUtc` explicitly.
- Add sync metadata in a separate envelope (`localOnly`, `pending`, `synced`, `failed`) only when synchronization exists.
- Define conflict behavior per record type before enabling upload; never use silent last-write-wins for finalized assessment results.
- Keep personal identity/authentication outside curriculum record models.
- Never synchronize presence incidents through the curriculum-result repository.
- Do not block lessons, practice, results, or app startup on network availability.

## 6. Assessment integration

The existing monitoring path remains authoritative and unchanged:

```text
Platform presence signals
↓
AssessmentMonitor at application root
↓
InterruptionPolicy
↓
Existing local session/incident repository
↓
Teacher-gated presence reports
```

Module integration follows these rules:

- `AssessmentMonitor` remains above the root navigator and all module routes.
- Module, lesson, practice, and curriculum-assessment code does not import, instantiate, call, or suppress `AssessmentMonitor`.
- `InterruptionPolicy`, platform presence tracking, pending-absence persistence, and incident recording are not modified by module implementation.
- Internal routes, calculator launches, converter launches, answer entry, keyboard appearance, dialogs, dropdowns, sheets, history panels, theme UI, and formula cards emit no presence events.
- Only root-level application absence starts a pending absence; it is persisted immediately on leaving and its duration is calculated only on return.
- A stable allowed-tools snapshot is owned by the existing assessment session/controller and passed down as read-only state.
- A disallowed curriculum tool is blocked inside the app with neutral feedback; blocking it does not create an incident.
- External reference links are disabled during an active assessment unless a separately approved root-level policy exists. Modules cannot grant themselves suppression tokens.
- Curriculum learning results may hold an optional assessment-session ID for reporting context, but presence and learning records remain separate.
- Teacher-gated reports may later show distinct `Presence` and `Learning Results` sections; no module phase changes current incident language or teacher-PIN protection.

Required compatibility contract for every module:

1. Start an active assessment.
2. Open the module and navigate among lessons, examples, practice, and its local assessment.
3. Use permitted internal tools and interact with all input surfaces.
4. Assert that zero new incidents were recorded.
5. Hide or pause the real application and assert pending absence was saved immediately.
6. Resume and assert one absence duration was computed and classified by the unchanged policy.

## 7. Test strategy

### Test layers used by every module

Unit tests:

- Every authoritative formula and worked example.
- Exact calculations, normalization, reduction, units, final-step rounding, and correction cases.
- Invalid input, division by zero, incompatible units, overflow/non-finite values, and module-specific boundaries.
- Answer-validation policies for numeric value, method steps, units, distracters, tolerances, and manual-review outcomes.
- Curriculum JSON schema, stable IDs, source IDs, dependency references, and version migrations.

Widget tests:

- Catalog/module screen opening and internal navigation.
- Lesson, formula, example, practice, feedback, empty, loading, error, locked, and submitted states.
- Progress restoration and local assessment recovery.
- Material 3 light/dark behavior, semantics, focus order, keyboard operation, text scaling, and 48-pixel touch targets.
- Responsive layouts at 320, 360, 390, 430, 768, 1024, 1366, 1920, and 2560 logical pixels with no overflow or clipped controls.

Integration tests:

- The assessment compatibility contract above for each module.
- Allowed and disallowed calculator/converter launch behavior.
- Offline lesson, practice, and in-progress attempt recovery.
- Existing converter, calculator, navigation, reports, PWA installation, branding, and local assessment flows.

### Module-specific verification matrix

| Module | Unit-test focus | Widget-test focus | Curriculum assessment | Integration focus |
|---|---|---|---|---|
| 2 | Whole operations, factors, multiples, primes, divisibility, GCD/LCM | Number input, factor trees, worked steps | Module 2 Quiz | First vertical slice, module registry, progress persistence |
| 3 | Exact fraction operations, LCD, reduction, cancellation | Fraction editor, equivalent-fraction and solution views | Seat Work 2 | Reuse Module 2 GCD/LCM; corrected LCD 64 |
| 4 | Mixed/improper conversion, borrowing, operations | Mixed-number fields and compound-form steps | Seat Work 3 portion | Reuse Module 3 engine; corrected `1 13/16` result |
| 5 | Scaled decimals, place value, rounding, fraction conversion, 64ths | Decimal/repeating notation and precision feedback | Seat Work 3 portion | Exact storage round trip and no early rounding |
| 6 | Ratio reduction, proportion, unit rate | Ratio/proportion editors and aviation scenarios | Long Quiz portion | Exact fraction/decimal reuse |
| 7 | Mean, count validation, missing values, rounding | Data-set entry and teacher-review status | Long Quiz portion | Manual-review responses remain pending |
| 8 | Percent conversions and percentage/rate/base cases | Case selector, percent input, result explanation | Long Quiz portion | Ratio/fraction/decimal reuse |
| 9 | Signed operations, comparison, absolute value, sign semantics | Number line and direction/context labels | Seat Work 5 portion | No sign loss through persistence |
| 10 | Compound quantities, radix normalization, curriculum conversions | Major/minor unit fields and conversion steps | Seat Work 5 and Major Quiz 2 portions | Existing converter unchanged; temperature formulas locked |
| 11 | Powers, exponent laws, powers of ten, corrected PEMDAS | Exponent entry and ordered expression steps | Seat Work 6 | Existing calculator unchanged and optional verifier isolated |
| 12 | Perfect roots, approximation, estimation, fractional indices | Radical input, estimate/exact state, tolerance feedback | Modules 12–13 Seat Work portion | Corrected circle-area result and tolerance serialization |
| 13 | Scientific normalization, conversions, arithmetic, metric prefixes | Coefficient/exponent editor and prefix movement | Modules 12–13 Seat Work portion | Large exponent persistence and prefix case sensitivity |

### Phase quality gate

After every module, run focused tests first and then the full regression suite. At every phase exit, run:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --reporter compact
flutter test --platform chrome \
  test/features/pwa_install/pwa_install_service_test.dart \
  test/app/install_app_action_test.dart
flutter build web --release
```

Do not delete, skip, loosen, or rewrite an existing test merely to make a new module pass. Browser/device checks that cannot be automated are recorded with device, OS, browser, build, result, and issue references.

## 8. Safest implementation order

The safest order follows mathematical dependencies and validates the architecture with one complete module before scaling it.

1. Freeze and record the current application/test baseline.
2. Define stable curriculum IDs, source/correction metadata, content schema, and repository contracts.
3. Add the module registry and an initially empty Aviation Math catalog through the existing adaptive-navigation pattern.
4. Deliver Module 2 as the first full vertical slice, including local progress, Quiz, and assessment-compatibility tests.
5. Review the Module 2 architecture; extract only the shared widgets and services proven by the slice.
6. Deliver Module 3 and establish `ExactFraction` as a shared mathematical primitive.
7. Deliver Module 4 on top of Module 3 fraction behavior.
8. Deliver Module 5 and establish the exact scaled-decimal primitive.
9. Deliver Phase A assessments and run the complete Phase A gate.
10. Deliver Modules 6, 7, and 8 in order, then the Long Quiz and Phase B gate.
11. Deliver Module 9 before Module 10 so signed behavior is stable before compound conversions.
12. Deliver Module 10 with a separate curriculum conversion profile, then Seat Work 5, Major Quiz 2, and the Phase C gate.
13. Deliver Module 11 before Modules 12–13 so exponent behavior and expression order are stable.
14. Deliver Module 12, then Module 13, followed by their Seat Works and the Phase D gate.
15. Add teacher-gated learning-result presentation only after the local learning schemas are stable; retain separate presence and learning sections.
16. Run release stabilization, installed-PWA acceptance, offline recovery, migrations, accessibility, and physical-device testing.
17. Update architecture, development status, test plan, deployment acceptance, and curriculum-source documentation.

No phase activates Major Quiz 1, the Midterm, or the Final until authoritative Modules 1 and 14 specifications are supplied. Firebase/server synchronization remains deferred architecture after local-only behavior and conflict policies are proven.

## 9. Approval boundary

This file is a roadmap only. No application code, navigation, assets, storage dependency, assessment policy, or deployment configuration is changed by its creation.

Before coding begins, approval should identify the first authorized scope as the Foundation gate plus Module 2 only. Completion of that scope must produce a file-change report, test evidence, responsive preview status, and an explicit pause before Module 3.
