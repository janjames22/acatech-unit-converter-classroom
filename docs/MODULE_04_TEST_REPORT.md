# Module 4 — Mixed Numbers Test Report

Date: 2026-09-02  
Scope: AMT 111 Phase A, Module 4 only  
Result: **Passed — automated implementation gate complete**

## 1. Implementation under test

The tested Module 4 vertical slice includes:

- A module introduction, learning objectives, five lessons, explanations, and worked solutions.
- Aviation examples involving steel-rule and drawing measurements, cargo length, bolt grip, spacer stacks, cable pieces, and cut remainders.
- A mixed-number domain layer that reuses Module 3's public `ExactFraction`, `FractionEngine`, and fraction-answer parser.
- Proper, improper, whole, and mixed representation; bidirectional conversion; simplification; addition, subtraction, multiplication, and division.
- Explicit carry and borrow evidence, exact piece totals, cut planning, and formula-given/distracter selection.
- A responsive mixed-number lab with whole, numerator, and denominator inputs.
- Eight retryable practice questions with separate feedback for exact value, lowest terms, required mixed form, units, and selected givens.
- Existing calculator access through the application shell.
- Versioned local progress for lesson views, per-question attempts, mastered questions, score, and completion.
- Module 4 access through the existing responsive Aviation Mathematics hub.

Modules 5–13 were not implemented or scaffolded.

## 2. Automated test environment

| Item | Value |
|---|---|
| Project | Flutter ACATECH Aviation Tools PWA |
| Test host | macOS development host |
| Flutter target | Flutter VM/widget test environment |
| Local storage adapters | `SharedPreferences` mock and in-memory repository |
| Assessment repository | In-memory assessment repository |
| Network/Firebase | Not used |

## 3. Domain and validation results

| Area | Evidence | Result |
|---|---|---|
| Mixed normalization | `1 6/8 = 1 3/4`; `2 9/4 = 4 1/4`; zero fraction becomes a whole | Pass |
| Proper fraction | `0 3/4` is represented as `3/4` | Pass |
| Improper conversion | `5 7/16 = 87/16` with multiply-add evidence | Pass |
| Mixed conversion | `87/32 = 2 23/32` with quotient/remainder evidence | Pass |
| Invalid denominator | Zero denominator rejected | Pass |
| Signed-number boundary | Negative construction/results deferred to Module 9 | Pass |
| Addition with carry | `4 3/4 + 2 1/3 = 7 1/12` | Pass |
| Addition without carry | `1 1/8 + 2 1/8 = 3 1/4` | Pass |
| Subtraction with borrow | `3 1/8 − 1 5/16 = 1 13/16` | Pass |
| Subtraction without borrow | `5 3/4 − 2 3/4 = 3` | Pass |
| Multiplication | `2 1/2 × 1 3/4 = 4 3/8` | Pass |
| Spacer stack | `12 × 1 3/8 inch = 16 1/2 inches` | Pass |
| Exact division | `7 1/2 ÷ 1 1/4 = 6` | Pass |
| Cut remainder | `8 ft ÷ 1 1/2 ft` gives five pieces and `1/2 ft` remaining | Pass |
| Distracter selection | Shank and threaded length required; overall length rejected | Pass |
| Answer validation | Invalid, incorrect, unreduced, wrong-form, wrong-givens, missing-unit, and correct outcomes | Pass |

All Module 4 calculations remain exact integer-rational operations. The Module 3 service implementation is reused and was not modified.

## 4. Lesson, practice, and widget results

| Feature | Verification | Result |
|---|---|---|
| Module screen | Title, introduction, objectives, lessons, progress, lab, and practice render | Pass |
| Lesson navigation | Internal route opens, records the lesson as viewed, and returns normally | Pass |
| Worked method | `Given → Formula → Substitute → Solve` appears in aviation examples | Pass |
| Curriculum correction | Authoritative `1 13/16 inch` bolt result and distracter note are visible | Pass |
| Mixed-number lab | Default bolt subtraction displays improper conversions and borrow evidence | Pass |
| Retry | An unfinished answer remains editable and can be resubmitted | Pass |
| Reduction feedback | An equivalent unreduced answer receives reduction-specific feedback | Pass |
| Correct response | Mastery and score update locally | Pass |
| Attempts | Incorrect and correct submissions increment the local attempt count | Pass |
| Calculator launcher | Uses the supplied shell callback and existing calculator screen | Pass |
| Accessibility baseline | Labeled fields, semantic feedback, and at least 48-pixel calculator launcher target | Pass |

## 5. Local storage results

Storage key: `curriculum.module_04.v1.progress`

| Behavior | Result |
|---|---|
| New learner receives empty progress | Pass |
| Viewed lesson IDs round-trip | Pass |
| Mastered question IDs and score round-trip | Pass |
| Per-question and total attempts round-trip | Pass |
| Completion status is serialized | Pass |
| UTC update timestamp round-trips | Pass |
| Schema version and module ID are recorded | Pass |
| Unsupported schema falls back with a visible local-storage notice | Pass |
| Module 2 and Module 3 storage remain independent | Pass |
| Assessment incidents remain in the existing assessment repository | Pass |

No Firebase package, network request, cloud report, or synchronization state was added.

## 6. Assessment compatibility results

With an assessment session active, the integration test exercised:

1. Internal navigation to `Learn`.
2. Module 4 selection from the Aviation Mathematics hub.
3. Opening and closing a Module 4 lesson route.
4. Launching the existing calculator from Module 4.

Results:

- The same root-owned `AssessmentMonitor` instance remained active.
- No pending absence was created or persisted.
- Zero incidents were recorded.
- `AssessmentMonitor`, `InterruptionPolicy`, presence tracking, pending-absence persistence, and incident recording source were not modified.
- Existing regression tests still verify that a real hidden/paused departure is persisted immediately and classified only on return.

## 7. Responsive results

Automated widget testing used a device-pixel ratio of 1 and a 1,000 logical-pixel module viewport height.

| Logical width | Layout tier | Overflow/layout exception | Title and calculator action | Result |
|---:|---|---|---|---|
| 320 | Compact | None | Present | Pass |
| 360 | Compact | None | Present | Pass |
| 390 | Compact | None | Present | Pass |
| 430 | Compact | None | Present | Pass |
| 768 | Medium | None | Present | Pass |
| 1024 | Expanded | None | Present | Pass |
| 1366 | Expanded | None | Present | Pass |
| 1920 | Expanded | None | Present | Pass |

Lesson cards use one column below 760 logical pixels and two columns at wider sizes. Mixed-value field groups and practice answer/unit controls stack on compact widths and use bounded rows when space allows.

## 8. Command results

### Static analysis

```text
flutter analyze
No issues found! (ran in 1.4s)
```

Result: **Pass**

### Focused Module 4 tests

```text
flutter test test/features/module_04 test/app/module_04_integration_test.dart
00:02 +28: All tests passed!
```

Result: **Pass**

### Full regression suite

```text
flutter test
00:11 +209: All tests passed!
```

Result: **Pass**

Existing converter, calculator, Modules 2–3, assessment, reports, navigation, branding, and PWA tests remained enabled and passed.

## 9. Known limitations and deferred work

- Progress is local to the current browser/device and can be cleared by the browser or user.
- Module practice is deterministic local mastery practice; teacher-gated curriculum result reporting is not included.
- Negative mixed numbers intentionally remain outside this module and are deferred to Module 9.
- Cut planning reports mathematically complete pieces and exact remainder; real maintenance work must account for approved data, tolerances, and cutting loss.
- Automated responsive checks do not replace physical Android, iOS/iPadOS, installed-PWA, zoom, screen-reader, or external-keyboard acceptance.
- Curriculum content remains bundled in Dart for this vertical slice; migration to versioned content data requires a separately tested schema and loader.
- Modules 5–13, Major Quiz 1, Firebase synchronization, and cloud reports remain unimplemented.

## 10. Gate decision

Module 4 meets the automated Phase A vertical-slice gate. Work must stop here until Module 5 receives separate approval.
