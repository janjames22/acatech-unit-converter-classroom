# Module 2 — Whole Numbers Test Report

Date: 2026-09-01  
Scope: AMT 111 Phase A, Module 2 only  
Result: **Passed — automated implementation gate complete**

## 1. Implementation under test

The tested Module 2 vertical slice includes:

- Module introduction and five lessons.
- Learning objectives, explanations, operation vocabulary, and worked examples.
- Aviation examples for stores inventory, flight-hour differences, boxed fasteners, technician allocation, and repeating cycles.
- `Given → Formula → Substitute → Solve` presentation.
- A guided whole-number lab for place value, four operations, quotient/remainder, factors, prime factors, and divisibility evidence.
- A seven-question retryable practice/Module 2 Quiz with correct, incorrect, invalid, explanation, retry, and next-question states.
- Calculator access through the existing application calculator destination.
- Versioned local progress for viewed lessons, mastered questions, score, practice completion, and overall completion status.
- Internal lesson navigation and adaptive `Learn` navigation.

Modules 3–13 were not implemented or scaffolded.

## 2. Automated test environment

| Item | Value |
|---|---|
| Project | Flutter ACATECH Aviation Tools PWA |
| Test host | macOS development host |
| Flutter target | Flutter VM/widget test environment |
| Local storage test adapter | `SharedPreferences` mock and in-memory repository |
| Assessment repository test adapter | In-memory assessment repository |
| Network/Firebase | Not used |

## 3. Domain and validation results

| Area | Evidence | Result |
|---|---|---|
| Addition | `4,314 + 122 + 93,132 + 10 = 97,578` | Pass |
| Subtraction | `97,564 − 3,461 = 94,103` | Pass |
| Multiplication | `35 × 18 = 630` | Pass |
| Division | `218 ÷ 7 = 31 remainder 1`; exact division also tested | Pass |
| Whole-number boundary | Negative inputs and negative subtraction results rejected with a Module 9 boundary message | Pass |
| Division boundary | Division by zero rejected | Pass |
| Factors | Complete ordered factors of 48 and 60 | Pass |
| Prime factors | `48 = 2⁴ × 3`; `60 = 2² × 3 × 5` | Pass |
| Special values | Zero place value, one, prime numbers, repeated factors | Pass |
| Multiples/GCD/LCM | First-N multiples, `GCD(48, 60) = 12`, `LCM(16, 24) = 48` | Pass |
| Place value | `93,132 = 90,000 + 3,000 + 100 + 30 + 2` | Pass |
| Divisibility | Rules for 2, 3, 4, 5, 6, 8, 9, and 10; 3,816 explanations for 3, 4, 8, and 9 | Pass |
| Answer validation | Blank, incorrect, correct, comma formatting, quotient/remainder, and exponent notation variants | Pass |

## 4. Lesson and practice widget results

| Feature | Verification | Result |
|---|---|---|
| Module screen | Title, introduction, objectives, lessons, progress, lab, and Quiz render | Pass |
| Lesson navigation | Lesson opens on an internal Flutter route and returns normally | Pass |
| Lesson content | Objectives, explanations, worked examples, aviation label, and four-line method render | Pass |
| Lesson progress | Opening an identified lesson records it as viewed | Pass |
| Incorrect response | Incorrect feedback and the worked explanation appear | Pass |
| Retry | Retry clears the feedback state and enables another answer | Pass |
| Correct response | Correct feedback appears and the question is mastered once | Pass |
| Score | Local progress updates from `0/7` to `1/7` in interaction testing | Pass |
| Guided lab | Division result, factors/prime factors, place value, and divisibility explanations render | Pass |
| Calculator launcher | Invokes the shell-provided existing calculator destination | Pass |
| Accessibility baseline | Labeled Material controls and at least 48-logical-pixel calculator launcher target | Pass |

## 5. Local storage results

Storage key: `curriculum.module_02.v1.progress`

| Behavior | Result |
|---|---|
| New student receives empty progress | Pass |
| Viewed lesson IDs round-trip | Pass |
| Mastered question IDs and score round-trip | Pass |
| Practice and completion status are represented in serialized data | Pass |
| UTC update timestamp round-trips | Pass |
| Schema and module identifiers are recorded | Pass |
| Unsupported/corrupt schema falls back to fresh progress with a visible local-storage notice | Pass |
| Presence incidents remain in their existing separate repository/keyspace | Pass |

No Firebase package, account, API, network request, or synchronization state was added.

## 6. Assessment compatibility results

An active assessment session was created in the integration test, then the following internal actions were exercised:

1. Navigate to `Learn`.
2. Open Module 2.
3. Open and close a lesson route.
4. Launch the existing calculator from Module 2.

Results:

- The same root-owned `AssessmentMonitor` instance remained active.
- No pending absence was created.
- Zero incidents were recorded.
- `AssessmentMonitor`, `InterruptionPolicy`, platform presence tracking, pending-absence persistence, and incident recording code were not modified.
- Existing regression tests still verify that a real hidden/paused lifecycle signal persists a pending absence immediately and that duration/classification occur only after return.

## 7. Responsive results

Automated widget testing used a device-pixel ratio of 1 and a 1,000 logical-pixel test height for the module viewport.

| Logical width | Layout tier | Overflow/layout exception | Core content present | Result |
|---:|---|---|---|---|
| 320 | Compact | None | Yes | Pass |
| 360 | Compact | None | Yes | Pass |
| 390 | Compact | None | Yes | Pass |
| 430 | Compact | None | Yes | Pass |
| 768 | Medium | None | Yes | Pass |
| 1024 | Expanded | None | Yes | Pass |
| 1366 | Expanded | None | Yes | Pass |
| 1920 | Expanded | None | Yes | Pass |

Lessons use a single column below 760 logical pixels and a two-column wrapping layout above that threshold. The whole-number lab stacks its fields below 620 logical pixels and uses a constrained three-column row at larger widths.

## 8. Command results

### Static analysis

```text
flutter analyze
No issues found! (ran in 1.5s)
```

Result: **Pass**

### Focused Module 2 tests

The focused suite covers 20 new tests across domain services, validation, storage, widgets, responsive layouts, navigation, and assessment compatibility.

Result: **Pass**

### Full regression suite

```text
flutter test --reporter compact
00:09 +155: All tests passed!
```

Result: **Pass**

Existing converter, calculator, assessment, reports, navigation, branding, and PWA tests remained enabled and passed.

## 9. Known limitations and deferred work

- Progress is browser/device-local and can be cleared by the browser or user; there is no account backup.
- The local progress record is a single bounded Module 2 record. A larger durable database must be selected only when later approved modules create demonstrated query/volume needs.
- The Quiz is deterministic local practice with mastery scoring; teacher rubric workflows and teacher-gated learning-result reports are not part of this Module 2 slice.
- Calculator availability currently follows the existing app navigation contract; a generalized per-session allowed-tools snapshot remains a separately reviewed future change.
- Automated responsive tests do not replace physical Android, iOS/iPadOS, installed-PWA, browser zoom, screen-reader, and external-keyboard acceptance.
- Curriculum content is represented in Dart for this first vertical slice. Migration to versioned bundled JSON should occur only with a tested content-schema loader and without changing the validated domain behavior.
- Modules 3–13, Major Quiz 1, Midterm, Final, Firebase synchronization, and cloud reports remain unimplemented.

## 10. Gate decision

Module 2 meets the automated Phase A vertical-slice gate. Work must stop here until Module 3 receives separate approval.
