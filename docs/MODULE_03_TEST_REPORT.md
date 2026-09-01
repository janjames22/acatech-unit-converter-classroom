# Module 3 — Fractions Test Report

Date: 2026-09-01  
Scope: AMT 111 Phase A, Module 3 only  
Result: **Passed — automated implementation gate complete**

## 1. Implementation under test

The tested Module 3 vertical slice includes:

- Module introduction, six lessons, objectives, explanations, and worked solutions.
- Aviation examples for panel thickness, aileron tolerance, hole-center layout, and jackscrew travel.
- `Given → Formula → Substitute → Solve` presentation with units and educational-use notices.
- An exact normalized fraction value type and learning engine.
- Equivalent fractions and least common denominators using least-shared-multiple and denominator-product methods.
- Fraction comparison, addition, subtraction, multiplication, division, cancellation, reduction, tolerance ranges, and improper-to-mixed display.
- A responsive fraction lab with explicit numerator/denominator controls and zero-denominator feedback.
- Nine retryable practice/Seat Work 2 questions with separate arithmetic, reduction, and unit feedback.
- Existing calculator access through the application shell.
- Versioned local progress recording lesson views, attempts, mastered questions, score, and completion.
- A responsive Aviation Mathematics hub for the already approved Modules 2 and 3.

Modules 4–13 were not implemented or scaffolded.

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
| Normalization | `6/8 = 3/4`; denominator signs normalized; zero becomes `0/1` | Pass |
| Denominator boundary | Zero denominator rejected | Pass |
| Classification | Proper, improper, and whole results | Pass |
| Equivalent fractions | Unsimplified instructional forms such as `1/5 = 2/10` are preserved | Pass |
| LCD methods | Least-shared-multiple and product-of-denominators methods | Pass |
| Curriculum correction | Panel LCD is 64; `3/32 = 6/64` | Pass |
| Addition | `1/5 + 1/10 = 3/10` | Pass |
| Multi-term addition | `2/3 + 3/5 + 4/7 = 193/105 = 1 88/105` | Pass |
| Panel thickness | `3/32 + 1/64 = 7/64 inch` | Pass |
| Tolerance range | Minimum `27/40`; maximum `43/40 = 1 3/40` | Pass |
| Multiplication | `3/5 × 7/8 × 1/2 = 21/80` | Pass |
| Cancellation | `14/15 × 3/2 = 7/5`; two cancellation steps | Pass |
| Division | `7/8 ÷ 4/3 = 21/32` | Pass |
| Zero divisor | Division by a zero fraction rejected | Pass |
| Hole centers | `87/32 = 2 23/32`; `29/16 = 1 13/16` | Pass |
| Jackscrew travel | `13/16 − 7/16 = 3/8` | Pass |
| Reduction | Already-reduced values and a common factor of 500,000 | Pass |
| Comparison | Positive, equal, and negative exact comparisons | Pass |
| Validation | Invalid, incorrect, unreduced, missing-unit, and correct outcomes | Pass |

All calculations remain integer-rational and exact. No decimal approximation is used by the fraction engine.

## 4. Lesson, practice, and widget results

| Feature | Verification | Result |
|---|---|---|
| Module screen | Title, introduction, objectives, lessons, progress, lab, and Seat Work render | Pass |
| Lesson navigation | Internal route opens and returns normally | Pass |
| Worked content | Four-line method, aviation label, correction badge, and safety notice render | Pass |
| Corrected curriculum | LCD 64 correction is visible in the lesson UI | Pass |
| Lesson progress | Opening a lesson records its stable ID as viewed | Pass |
| Unreduced response | Correct numerical value receives reduction-specific feedback | Pass |
| Retry | Answer remains editable and can be resubmitted | Pass |
| Correct response | Question becomes mastered and score increments once | Pass |
| Attempts | Unfinished and correct submissions increment the local attempt count | Pass |
| Units | Required unit is evaluated separately from numeric correctness | Pass |
| Fraction lab | Exact result, common denominator, and equivalent steps render | Pass |
| Calculator launcher | Uses the supplied shell callback and existing calculator screen | Pass |
| Accessibility baseline | Semantic fraction grouping, labeled fields/buttons, and 48-pixel launcher target | Pass |

## 5. Local storage results

Storage key: `curriculum.module_03.v1.progress`

| Behavior | Result |
|---|---|
| New student receives empty progress | Pass |
| Viewed lesson IDs round-trip | Pass |
| Mastered question IDs and score round-trip | Pass |
| Per-question and total attempts round-trip | Pass |
| Practice and completion status are represented in serialized data | Pass |
| UTC update timestamp round-trips | Pass |
| Schema and module identifiers are recorded | Pass |
| Unsupported schema falls back to fresh progress with a visible storage notice | Pass |
| Module 2 storage remains independent | Pass |
| Presence incidents remain in the existing separate repository/keyspace | Pass |

No Firebase package, account, API, network request, or synchronization state was added.

## 6. Assessment compatibility results

An active assessment session was created, then the integration test exercised:

1. Navigate to the internal `Learn` destination.
2. Scroll and open Module 3 from the Aviation Mathematics hub.
3. Open and close a lesson route.
4. Launch the existing calculator from Module 3.

Results:

- The same root-owned `AssessmentMonitor` instance remained active.
- No pending absence was created.
- Zero incidents were recorded.
- `AssessmentMonitor`, `InterruptionPolicy`, platform presence tracking, pending-absence persistence, and incident recording code were not modified.
- Existing regression tests continue to verify real departure persistence and return-time duration classification.

## 7. Responsive results

Automated widget testing used a device-pixel ratio of 1 and a 1,000 logical-pixel module viewport height.

| Logical width | Layout tier | Overflow/layout exception | Lesson content present | Result |
|---:|---|---|---|---|
| 320 | Compact | None | Yes | Pass |
| 360 | Compact | None | Yes | Pass |
| 390 | Compact | None | Yes | Pass |
| 430 | Compact | None | Yes | Pass |
| 768 | Medium | None | Yes | Pass |
| 1024 | Expanded | None | Yes | Pass |
| 1366 | Expanded | None | Yes | Pass |
| 1920 | Expanded | None | Yes | Pass |

Lessons use one column below 760 logical pixels and two columns above. Fraction groups and lab controls stack at compact widths and use bounded rows on larger viewports. The hub remains scrollable when cards extend below compact navigation.

## 8. Command results

### Static analysis

```text
flutter analyze
No issues found! (ran in 1.7s)
```

Result: **Pass**

### Focused Module 3 tests

The focused suite adds 26 tests across fraction logic, validation, storage, widgets, responsive layouts, navigation, and assessment compatibility.

Result: **Pass**

### Full regression suite

```text
flutter test --reporter compact
00:11 +181: All tests passed!
```

Result: **Pass**

Existing converter, calculator, Module 2, assessment, reports, navigation, branding, and PWA tests remained enabled and passed.

## 9. Known limitations and deferred work

- Progress and attempts are local to the current browser/device and can be cleared by the browser or user.
- Seat Work 2 is deterministic local mastery practice; teacher review and teacher-gated curriculum result reporting are not included.
- The calculator launcher follows the existing navigation contract. A generalized session-level allowed-tools snapshot remains separately reviewed future work.
- Exact integer arithmetic is bounded by the practical integer behavior of the Dart Web runtime; extreme values outside curriculum scope are not a big-integer subsystem.
- Automated responsive coverage does not replace physical Android, iOS/iPadOS, installed-PWA, browser zoom, screen-reader, or external-keyboard acceptance.
- Curriculum content remains in Dart for this vertical slice. Migration to bundled versioned JSON requires a separately tested loader and content schema.
- Modules 4–13, Major Quiz 1, Midterm, Final, Firebase synchronization, and cloud reports remain unimplemented.

## 10. Gate decision

Module 3 meets the automated Phase A vertical-slice gate. Work must stop here until Module 4 receives separate approval.
