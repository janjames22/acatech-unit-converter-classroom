# Module 5 — The Decimal Number System Test Report

Date: 2026-09-02  
Scope: AMT 111 Phase A, Module 5 only  
Result: **Passed — automated implementation gate complete**

## 1. Implementation under test

The tested Module 5 vertical slice includes:

- A module introduction, learning objectives, six lessons, explanations, and worked solutions.
- Aviation examples for electrical resistance and power, measurements, wing dimensions, drilling, reaming, and decimal-equivalent references.
- An exact `DecimalQuantity` represented by a `BigInt` coefficient plus integer decimal scale.
- Decimal place-value rows, reading support, safe comparison, exact addition, subtraction, multiplication, and division.
- Curriculum half-up rounding with retained and inspection digits.
- Exact decimal-to-fraction conversion and fraction-to-decimal long division with terminating/repeating classification.
- Explicit overline rendering for repeating digits and parenthesized plain notation for input/accessibility.
- Shop 64ths conversion and the `1/64 in` undersize drill/ream planner.
- A responsive exact-decimal lab covering all Module 5 learning tools.
- Thirteen retryable Seat Work 3 questions with separate value, precision, reduction, repeating-notation, and unit feedback.
- Existing calculator access through the application shell.
- Versioned local progress for lesson views, per-question attempts, mastered questions, score, and completion.

Modules 6–13 were not implemented or scaffolded.

## 2. Automated test environment

| Item | Value |
|---|---|
| Project | Flutter ACATECH Aviation Tools PWA |
| Test host | macOS development host |
| Flutter target | Flutter VM/widget test environment |
| Decimal storage | `BigInt` coefficient plus integer scale |
| Local progress adapters | `SharedPreferences` mock and in-memory repository |
| Assessment repository | In-memory assessment repository |
| Network/Firebase | Not used |

## 3. Decimal engine and validation results

| Area | Evidence | Result |
|---|---|---|
| Normalization | `0002.3400 = 2.34`; `0.50 = 0.5`; zero normalizes safely | Pass |
| Long exact input | 30 whole digits plus 18 fractional digits round-trip exactly | Pass |
| Negative policy | Negative decimal input/results defer to Module 9 | Pass |
| Place value | Tens through thousandths identified for `37.205` | Pass |
| Decimal reading | `37.005` reads as 37 and 5 thousandths | Pass |
| Comparison | `0.763 > 0.736`; `0.50 = 0.5`; `0.099 < 0.1` | Pass |
| Binary-float avoidance | `0.1 + 0.2 = 0.3` exactly | Pass |
| Series resistance | `2.34 + 37.5 + 0.09 = 39.93 Ω` | Pass |
| Subtraction | `37.272 − 14.88 = 22.392` | Pass |
| Multiplication | `9.45 × 120 = 1,134 W` | Pass |
| Division | `262.6 ÷ 40.4 = 13/2 = 6.5 ft` | Pass |
| Zero divisor | Division by zero rejected | Pass |
| Half-up rounding | `2.1938 → 2.2`; `3.1648 → 3.16`; `3.7487 → 3.749` | Pass |
| Exact midpoint | `2.150` to tenths rounds upward to `2.2` | Pass |
| Fixed precision | Whole value rounded/displayed to thousandths becomes `2.000` | Pass |
| Decimal to fraction | `0.3125 = 5/16` exactly | Pass |
| Terminating conversion | `1/2 = 0.5`; `3/8 = 0.375` | Pass |
| Repeating conversion | `1/3 = 0.(3)`; `1/6 = 0.1(6)` | Pass |
| Cycle bound | A repeating expansion exceeding the configured learning limit is rejected | Pass |
| Shop 64ths | `0.3123 × 64 = 19.9872 → 20/64 → 5/16` | Pass |
| Drill and ream | `0.763 → 49/64`; subtract `1/64 → 3/4` drill | Pass |
| Precision validation | Numerically equal output with the wrong written scale receives precision feedback | Pass |
| Fraction validation | Equivalent unreduced shop result receives reduction feedback | Pass |
| Repeating validation | Truncated `0.333` is rejected in favor of explicit `0.(3)` | Pass |

No taught operation converts through `double`, and no approximate binary floating-point comparison is used.

## 4. Curriculum correction and UI results

| Feature | Verification | Result |
|---|---|---|
| Module content | Introduction, objectives, six lessons, lab, progress, and practice render | Pass |
| Lesson navigation | Internal lesson route opens, records a view, and returns normally | Pass |
| Four-line method | `Given → Formula → Substitute → Solve` renders in worked examples | Pass |
| Repeating bar | Repeating digits render with an explicit overline and semantic label | Pass |
| Corrected chart | Corrupted row label `39341` is identified as `9/16` | Pass |
| Corrected values | `9/16 = 0.5625 in = 14.2875 mm` remains associated with the corrected row | Pass |
| Decimal lab | Default aligned subtraction displays exact `22.392` result and place evidence | Pass |
| Retry flow | Incorrect answer remains editable and can be resubmitted | Pass |
| Correct response | Mastery and score update locally | Pass |
| Calculator launcher | Uses the supplied shell callback and existing calculator screen | Pass |
| Accessibility baseline | Labeled fields, semantic live feedback, repeating label, and 48-pixel calculator target | Pass |

## 5. Local storage results

Storage key: `curriculum.module_05.v1.progress`

| Behavior | Result |
|---|---|
| New learner receives empty progress | Pass |
| Viewed lesson IDs round-trip | Pass |
| Mastered question IDs and score round-trip | Pass |
| Per-question and total attempts round-trip | Pass |
| Completion status is serialized | Pass |
| UTC update timestamp round-trips | Pass |
| Schema version and module ID are recorded | Pass |
| Unsupported schema falls back with a visible storage notice | Pass |
| Modules 2–4 storage remain independent | Pass |
| Assessment incidents remain in the existing assessment repository | Pass |

No Firebase package, cloud report, network request, or synchronization state was added.

## 6. Assessment compatibility results

With an assessment session active, the integration test exercised:

1. Internal navigation to `Learn`.
2. Module 5 selection from the Aviation Mathematics hub.
3. Opening and closing a Module 5 lesson route.
4. Launching the existing calculator from Module 5.

Results:

- The same root-owned `AssessmentMonitor` instance remained active.
- No pending absence was created or persisted.
- Zero incidents were recorded.
- `AssessmentMonitor`, `InterruptionPolicy`, platform presence tracking, pending-absence persistence, and incident recording source were not modified.
- Existing regression coverage still verifies real departure persistence and return-time duration calculation.

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

Lesson cards use one column below 760 logical pixels and two columns on wider layouts. Decimal lab inputs and practice answer/unit fields stack on compact widths and use bounded rows when space allows.

## 8. Command results

### Static analysis

```text
flutter analyze
No issues found! (ran in 1.4s)
```

Result: **Pass**

### Focused Module 5 tests

```text
flutter test test/features/module_05 test/app/module_05_integration_test.dart
00:02 +27: All tests passed!
```

Result: **Pass**

### Full regression suite

```text
flutter test
00:12 +236: All tests passed!
```

Result: **Pass**

Existing converter, calculator, Modules 2–4, assessment, reports, navigation, branding, and PWA tests remained enabled and passed.

## 9. Known limitations and deferred work

- Progress remains local to the current browser/device and can be cleared by the browser or user.
- Seat Work 3 is local mastery practice; teacher-gated curriculum result reporting is not included.
- Negative decimals and negative decimal results intentionally remain deferred to Module 9.
- Repeating expansion is bounded to 256 digits by default to prevent unbounded learning-tool work; the exact fraction remains authoritative.
- The shop 64ths method is a curriculum approximation and must not replace approved maintenance dimensions, tolerances, or tooling data.
- Very large `BigInt` inputs remain exact but can consume increasing time and memory; no arbitrary unbounded UI workload is promised.
- Automated responsive coverage does not replace physical Android, iOS/iPadOS, installed-PWA, browser zoom, screen-reader, or external-keyboard acceptance.
- Modules 6–13, Major Quiz 1, Firebase synchronization, and cloud reports remain unimplemented.

## 10. Gate decision

Module 5 meets the automated Phase A vertical-slice gate. Work must stop here until Module 6 receives separate approval.
