# Modules 2–5 Beta Test Report

**Date:** 2026-09-02  
**Scope:** Modules 2–5 controlled practice input, curriculum regression, responsive layout, assessment compatibility, and application regression  
**Result:** Passed local automated and build gates; physical mobile/browser acceptance remains open

## Summary

The graded practice flows in Modules 2–5 no longer contain editable text fields. Students compose answers through reusable, application-owned math controls, so the practice cards do not request the Android or iOS system keyboard and do not expose native selection, paste, or unrestricted text entry.

The existing calculator engine, converter formulas, `AssessmentMonitor`, `InterruptionPolicy`, module calculation engines, and module progress repositories were not changed. All 241 project tests pass, `flutter analyze` reports no issues, and `flutter build web --release` succeeds.

## Input UX implemented

| Component | Controlled input | Module use |
|---|---|---|
| `NumericKeypad` | Digits 0–9, decimal point, clear, backspace, and problem-scoped math symbols | Shared foundation |
| `NumericInput` | Whole-number display with no editable text surface | Module 2 |
| `FractionInput` | Independently selected numerator and denominator | Modules 3 and 5 |
| `MixedNumberInput` | Independently selected whole number, numerator, and denominator | Modules 3 and 4 |
| `DecimalInput` | Decimal entry plus optional controlled repeating-cycle parentheses | Module 5 |
| `ControlledUnitInput` | Problem-specific unit choice chips | Modules 3–5 |

Every keypad control has a semantic label and a 48 logical-pixel height. Practice answers remain strings at the presentation boundary, so the existing validators continue to own correctness, reduction, precision, unit, and feedback rules.

## Issues found and fixes applied

| Issue | Impact | Fix | Result |
|---|---|---|---|
| Graded practice used `TextField` controls | Opened the system keyboard and allowed paste/free-form entry | Replaced practice fields with application-owned displays and keypad controls | Fixed |
| Fractions and mixed numbers required learners to type syntax such as `/` and spaces | Increased entry mistakes unrelated to the mathematics | Added separately selectable fraction and mixed-number parts | Fixed |
| Units were unrestricted text | Accepted arbitrary text before validator feedback | Replaced unit entry with question-specific choice chips | Fixed |
| Decimal repeating notation required punctuation through the system keyboard | Inconsistent mobile entry | Added controlled decimal and parentheses keys only where required | Fixed |
| Widget tests entered answers through `enterText` | Did not represent the intended learner interaction | Updated Module 2–5 practice tests to tap the in-app controls | Fixed |

## Module beta results

| Module | Feature | Evidence | Result |
|---|---|---|---|
| 2 — Whole Numbers | Addition, subtraction, multiplication, quotient/remainder | Engine and answer-validation tests; controlled practice submit | Pass |
| 2 — Whole Numbers | Factors, prime factorization, GCD/LCM | `WholeNumbersEngine` factor/multiple tests | Pass |
| 2 — Whole Numbers | Divisibility rules for 2, 3, 4, 5, 6, 8, 9, and 10 | Complete divisibility-rule test group | Pass |
| 3 — Fractions | LCD, equivalent fractions, four operations, comparison | Exact fraction-engine tests | Pass |
| 3 — Fractions | Simplification and retry feedback | Validator and controlled practice widget tests | Pass |
| 4 — Mixed Numbers | Proper/improper/mixed conversion and simplification | Mixed-number engine and validator tests | Pass |
| 4 — Mixed Numbers | Carrying, borrowing, multiplication, division | Exact engine tests and controlled practice retry | Pass |
| 5 — Decimals | Exact operations and comparison without binary floating point | `BigInt` coefficient/scale engine tests | Pass |
| 5 — Decimals | Half-up rounding and written precision | Engine and validator tests | Pass |
| 5 — Decimals | Fraction/decimal and repeating conversion | Exact conversion and controlled-input tests | Pass |

## Responsive results

Module screen tests render the complete page—including the controlled practice pad—at each required logical width. No `RenderFlex` overflow or layout exception was reported.

| Logical width | Classification | Result |
|---:|---|---|
| 320 | Compact mobile | Pass |
| 360 | Compact mobile | Pass |
| 390 | Compact mobile | Pass |
| 430 | Compact mobile | Pass |
| 768 | Tablet | Pass |
| 1024 | Desktop boundary | Pass |
| 1366 | Desktop | Pass |
| 1920 | Wide desktop | Pass |

These are automated Flutter logical-size tests. Physical Android/iOS keyboard suppression, touch ergonomics, text scaling, screen readers, browser zoom, and orientation changes still require device acceptance.

## Assessment compatibility

An active-assessment integration test now opens Module 2 practice, uses the controlled keypad, submits a correct answer, and then opens the existing calculator. Throughout that sequence:

- the root `AssessmentMonitor` instance is unchanged;
- `pendingAbsence` remains `null`;
- the session repository contains zero incidents.

Existing Module 3–5 integration tests also continue to verify that hub, lesson, internal navigation, and calculator actions produce zero incidents. No assessment-monitoring or interruption-policy source was modified.

## Regression and PWA results

| Gate | Result |
|---|---|
| `flutter analyze` | Pass — no issues found |
| Focused Modules 2–5 beta suite | Pass — 106 tests |
| `flutter test` | Pass — 241 tests |
| Calculator regression | Pass — controller, engine, scientific, memory, history, responsive UI tests |
| Converter regression | Pass — catalog, formulas, search, swap, responsive UI tests |
| Assessment regression | Pass — lifecycle/policy/repository/PIN/report and integration tests |
| `flutter build web --release` | Pass — `build/web` produced; WebAssembly dry run succeeded |
| Generated manifest | Present; standalone identity, theme, regular icons, and maskable icons retained |
| Generated service worker | Present |
| Generated 192/512 regular and maskable icons | Present |

No hosted deployment was changed during this beta phase.

## Remaining limitations

1. Module learning labs still use editable exploratory operands. They are not graded answer fields and were intentionally left unchanged; converting them should be a separately scoped UX decision.
2. Physical Android and iOS verification is still required to confirm keyboard suppression, tap comfort, orientation behavior, and assistive-technology output on real devices.
3. The keypad restricts the UI entry path; it is not a secure exam-lock mechanism and does not attempt to block browser developer tools or external automation.
4. Units are limited to each current question’s declared choices. Future modules may require a shared unit catalog or signed/scientific input controls.
5. Installed-PWA relaunch and service-worker update behavior remain physical/browser acceptance gates already tracked in `DEVELOPMENT_STATUS.md`.

## Approval gate

Modules 2–5 are ready for review of this beta phase. Module 6 has not been started.
