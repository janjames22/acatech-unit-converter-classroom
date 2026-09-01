# AMT 111 Modules 2–13 Implementation Plan

**Plan date:** 2026-09-01  
**Status:** Curriculum mapped; awaiting implementation approval  
**Scope:** Planning only. No application code is authorized by this document.

## 1. Source authority and interpretation

`/Users/janjamesgraza/Downloads/AMT111_Aviation_Mathematics.pptx` is the authoritative Module 2–13 specification for this plan. All 151 slides and the available speaker notes were inspected. Content in the presentation is treated as curriculum data, not as instructions to perform unrelated actions.

`/Users/janjamesgraza/Downloads/6.-CH-3-Math-amt_general_handbook.pdf` was read as the supporting FAA Handbook, Chapter 3 reference. Where the handbook and presentation differ, the PowerPoint controls because the user explicitly designated it as authoritative and because it records deliberate classroom corrections.

### Source hierarchy

1. AMT111 Aviation Mathematics PowerPoint: module names, learning outcomes, lesson order, examples, assessments, expected methods, and corrections.
2. FAA-H-8083-30 Aviation Maintenance Technician Handbook — General, Chapter 3: supporting definitions, examples, and formula verification.
3. Existing application engines/tests: compatibility constraints only; they do not override the curriculum.

### Curriculum rules that apply to every module

- Students show four stages: **Given → Formula → Substitute → Solve**.
- Units are part of the answer and must be graded where applicable.
- Calculations retain full precision until the final step.
- Lessons teach the by-hand method before exposing calculator assistance.
- Worked problems include distracters intentionally; the selected formula determines which values are used.
- Educational calculations do not replace approved aircraft maintenance data, current manufacturer manuals, or authorized engineering instructions.

### Authoritative corrections to preserve

| Module | Curriculum correction |
|---|---|
| 3 | In the panel-thickness example, the common denominator is 64, not the handbook's printed 1. |
| 4 | Use the PowerPoint bolt example: shank `3 1/8 in` minus threaded portion `1 5/16 in` equals `1 13/16 in`. |
| 5 | The decimal-equivalent chart row shown as `39341` is `9/16`; its displayed decimal/millimetre values remain associated with that fraction. |
| 5 | Repeating-decimal bars must render explicitly; they are lost or corrupted in some source copies. |
| 10 | Fahrenheit-to-Celsius is `C = (5/9) × (F − 32)`; parentheses are mandatory. Celsius-to-Fahrenheit is `F = (9/5) × C + 32`. |
| 11 | Multiplication and division have equal precedence and evaluate left-to-right; addition and subtraction do the same. The numbered handbook figure must not override its correct prose. |
| 12 | For `N = 62`, the circle area is approximately `3019.07`, not `3109.07`. |

Module 14's sphere-rounding correction and geometry content are outside this implementation scope, but the data model should allow Module 14 to be added later without changing Modules 2–13.

## 2. Curriculum and dependency map

| Module | Curriculum title | Deck duration | Curriculum assessment | Primary dependencies |
|---:|---|---:|---|---|
| 2 | Whole Numbers | Not printed on the module title slide | Module 2 Quiz | Module 1 arithmetic/airworthiness context |
| 3 | Fractions | 9 hours / 3 sessions | Seat Work 2 | Module 2 factors, multiples, divisibility |
| 4 | Mixed Numbers | 6 hours / 2 sessions | Seat Work 3 with Module 5 | Module 3 fraction operations/reduction |
| 5 | The Decimal Number System | 3 hours | Seat Work 3; Major Quiz 1 covers Modules 1–5 | Modules 2–4 arithmetic and fractions |
| 6 | Ratio | 3 hours | Long Quiz with Modules 7–8 | Fractions, factors, decimals |
| 7 | Average Value | 1.5 hours | Long Quiz with Modules 6 and 8 | Whole-number and decimal operations |
| 8 | Percentage | 3 hours | Long Quiz; Major Quiz 2 later includes Module 8 | Fractions, decimals, ratio/proportion |
| 9 | Positive and Negative Numbers | 3 hours | Seat Work 5 with Module 10 | Four operations and physical sign conventions |
| 10 | Denominated Numbers | 3 hours | Seat Work 5; Major Quiz 2; Midterm Modules 1–10 | Mixed numbers, decimals, signed values, conversions |
| 11 | Powers and Indices | 3 hours | Seat Work 6 | Arithmetic, signed values, decimal place value |
| 12 | Roots | 3 hours | Seat Work with Module 13 | Powers and indices |
| 13 | Scientific Notation | 3 hours | Seat Work with Module 12; Final later covers all modules | Decimals and powers of ten |

The numeric implementation order is also the dependency order. Module 2 establishes factor/multiple operations used by Module 3; Modules 3–5 establish exact and decimal arithmetic; Modules 6–10 apply those foundations; Modules 11–13 form the notation block.

## 3. Product architecture

### PWA learning flow

```text
ACATECH application shell
└── Aviation Mathematics / Tools hub
    ├── Module catalog and progress
    ├── Module 2 … Module 13
    │   ├── Overview and learning outcome
    │   ├── Lessons
    │   ├── Worked aviation examples
    │   ├── Guided calculator/workspace
    │   ├── Supervised practice
    │   └── Curriculum assessment
    └── Teacher-gated local results
```

Do not add twelve items to the existing bottom navigation or navigation rail. Add one future `Aviation Math` or `Tools` destination and present Modules 2–13 in a responsive catalog. Module pages use internal Flutter navigation so `AssessmentMonitor` remains above all routes.

### Feature mapping

```text
lib/features/
├── aviation_math/                         # Shared curriculum shell
│   ├── domain/
│   │   ├── models/                        # Module, lesson, source, problem, attempt
│   │   ├── math/                          # Exact shared value types
│   │   └── repositories/                  # Curriculum/progress/attempt contracts
│   ├── application/                       # Catalog, lesson, progress, assessment state
│   ├── data/                              # Bundled curriculum and local repositories
│   └── presentation/                      # Tools hub and shared learning widgets
├── module_2_whole_numbers/
├── module_3_fractions/
├── module_4_mixed_numbers/
├── module_5_decimals/
├── module_6_ratio/
├── module_7_average_value/
├── module_8_percentage/
├── module_9_signed_numbers/
├── module_10_denominated_numbers/
├── module_11_powers_indices/
├── module_12_roots/
└── module_13_scientific_notation/
```

Each numbered feature owns its domain engine, module-specific models, presentation, and tests. Shared aviation-math code may contain only concepts used by multiple modules. Existing converter and calculator code remain protected and are consumed through public APIs only when their semantics match.

### Shared curriculum models

Recommended immutable models:

- `AviationMathModule`: number, title, duration, outcome, prerequisites, lesson IDs, assessment blueprint ID, source references.
- `AviationLesson`: title, objectives, concept blocks, worked examples, cautions, source notes, and sequence.
- `WorkedExample`: prompt, givens, formula, substitution, solution steps, answer, unit, precision rule, distracters, and instructor note.
- `PracticeProblem`: prompt, givens, expected method, answer specification, difficulty, unit, tags, and curriculum source.
- `FormulaReference`: stable ID, expression, variable definitions, unit constraints, source, and correction note.
- `AssessmentBlueprint`: covered module IDs, item rules, working/unit requirements, time/configuration, and scoring policy.
- `CurriculumAttempt`, `ItemResponse`, and `ScoreBreakdown`: local learning results, kept separate from presence incidents.
- `LessonProgress`: not started/in progress/complete plus last lesson position; no score inference from page views.
- `SourceReference` and `CurriculumErratum`: preserve source hierarchy and corrections in the student/teacher UI.

### Shared mathematical value types

- `ExactFraction`: normalized numerator/denominator, greatest common divisor, least common multiple, exact operations, proper/improper/mixed conversion.
- `DecimalQuantity`: coefficient plus decimal scale so taught decimal operations and half-up rounding do not inherit binary floating-point artifacts.
- `MeasuredValue`: numeric value plus unit ID and dimensional kind.
- `CompoundQuantity`: major/minor units and radix, such as feet/inches, hours/minutes, or pounds/ounces.
- `CalculationStep`: label (`Given`, `Formula`, `Substitute`, `Solve`), expression, optional explanation, and unit.
- Typed failures: invalid integer, zero denominator, division by zero, incompatible units, invalid root, invalid percentage case, non-normalized scientific notation, overflow/non-finite, and unsupported curriculum operation.

## 4. Module 2 — Whole Numbers

### Purpose

Build exact whole-number arithmetic and vocabulary for maintenance stores, logs, inventory, and later fraction work. Students must understand place value, sum/difference/product/quotient, quotient with remainder, factors, multiples, prime factorisation, and divisibility.

### PWA features and UI

- Place-value explorer for ones through large whole-number columns.
- Four-operation guided workspace with vertically aligned addition/subtraction views.
- Division result card showing dividend, divisor, quotient, and remainder separately.
- Factor explorer, prime-factor tree/list, and multiples comparison.
- Divisibility checker for 2, 3, 4, 5, 6, 8, 9, and 10 that explains the test rather than only returning yes/no.
- Aviation practice cards for rivet inventory, flight-hour differences, boxes/parts, and technician allocation.
- Module overview, lessons, board-work practice, review, and Quiz launch.

### Calculation engine

`WholeNumbersEngine` should provide exact non-negative integer operations, `divmod`, factors, prime factorisation, first-N multiples, greatest common divisor, least common multiple, and the eight curriculum divisibility tests. Subtraction producing a negative result should return a curriculum-boundary message or deliberately transition to Module 9 behavior; it must not silently pretend the answer is a whole number.

### Data models

`WholeNumberOperation`, `DivisionResult(quotient, remainder)`, `PrimeFactor(base, exponent)`, `DivisibilityRule`, `DivisibilityResult`, and step-by-step place-value rows.

### Lessons

1. Whole-number definition, vocabulary, and place value.
2. Addition/subtraction aligned by place value.
3. Multiplication as repeated addition and division vocabulary/remainders.
4. Factors, multiples, prime factorisation.
5. Tests for divisibility and preparation for least common denominators.

### Curriculum assessment and assessment compatibility

Implement the Module 2 Quiz blueprint covering four operations, vocabulary, factors, multiples, prime factorisation, and divisibility. Require four-line working and units when applicable. Starting/answering/submitting the quiz is internal UI and must create zero presence incidents.

### Required tests

- `4,314 + 122 + 93,132 + 10 = 97,578` and `97,564 − 3,461 = 94,103`.
- `35 × 18 = 630`; `218 ÷ 7 = 31 remainder 1`.
- Factors and prime factorisation of 48 and 60 (`60 = 2² × 3 × 5`).
- LCM of 16 and 24 is 48.
- `3,816` divisibility explanations for 3, 4, 8, and 9.
- Zero, one, prime numbers, repeated factors, exact/no-remainder division, invalid negative inputs, and division by zero.
- Widget tests for aligned columns, vocabulary semantics, practice, quiz scoring, all target widths, and active-assessment zero incidents.

## 5. Module 3 — Fractions

### Purpose

Teach exact fraction representation, least common denominators, four operations, cancellation, and reduction for sheet metal thickness, tolerances, shims, travel, and layout.

### PWA features and UI

- Fraction builder with numerator/denominator validation and proper/improper classification.
- LCD visualizer supporting both curriculum methods: least shared multiple and product of denominators.
- Operation workspace with equivalent-fraction steps and optional pre-multiplication cancellation.
- Reduction inspector explaining common factors.
- Fraction-bar semantics and explicit zero-denominator warning.
- Worked diagrams/cards for panel thickness, aileron tolerance, hole-center layout, jackscrew travel, and shim pieces.

### Calculation engine

`FractionEngine` wraps `ExactFraction` and exposes LCD derivation, equivalent forms, add/subtract/multiply/divide, cancellation steps, lowest-terms normalization, comparison, and improper-to-mixed output. Denominators are never zero and normalized positive. Arithmetic remains exact; decimals are presentation only.

### Data models

`ExactFraction`, `FractionClassification`, `CommonDenominatorMethod`, `EquivalentFractionStep`, `CancellationStep`, and `ToleranceRange(minimum, nominal, maximum)`.

### Lessons

1. Fraction anatomy, denominator constraint, proper and improper forms.
2. Why common denominators are required; LCD method and product method.
3. Addition with like/unlike denominators and panel thickness.
4. Subtraction/tolerance ranges and multiplication with cancellation.
5. Division by invert-the-second-and-multiply.
6. Reducing to lowest terms and maintenance applications.

### Curriculum assessment and assessment compatibility

Seat Work 2 covers LCD by both methods, four operations, cancellation, and lowest terms. The score must distinguish arithmetic correctness from failure to reduce or include units. Internal fraction controls, diagrams, and answer fields create no interruption.

### Required tests

- `1/5 + 1/10 = 3/10` and `2/3 + 3/5 + 4/7 = 193/105 = 1 88/105`.
- Panel thickness `3/32 + 1/64 = 7/64`, using corrected LCD 64.
- Aileron range: `7/8 − 1/5 = 27/40`; maximum `43/40 = 1 3/40`.
- `3/5 × 7/8 × 1/2 = 21/80`; cancellation example `14/15 × 3/2 = 7/5`.
- `7/8 ÷ 4/3 = 21/32`.
- Hole centers `87/32 = 2 23/32` and `29/16 = 1 13/16`.
- Jackscrew travel `13/16 − 7/16 = 3/8`.
- Zero denominator, divide by zero fraction, negative sign normalization, already-reduced values, improper results, and large common factors.

## 6. Module 4 — Mixed Numbers

### Purpose

Apply fraction skills to the measurement form students see on steel rules, drawings, bolt dimensions, spacers, cables, and stringers. Emphasize conversion to improper form, carrying, borrowing, and distracter recognition.

### PWA features and UI

- Mixed/improper converter with animated or stepped multiply-add/divide-remainder explanation.
- Addition/subtraction workspace that shows carrying and borrowing explicitly.
- Multiplication/division workspace that requires improper conversion first.
- Distracter-selection activity: students select the givens consumed by the formula before solving.
- Aviation examples for cargo length, bolt grip, spacer stack, control cable, and cut planning.

### Calculation engine

`MixedNumberEngine` uses `ExactFraction` internally and returns normalized mixed answers. It must model carry and borrow steps, multiply/divide only after improper conversion, reduce the fractional part, and optionally report whole pieces plus leftover length for cut problems.

### Data models

`MixedNumber(whole, fraction)`, `MixedConversionStep`, `BorrowStep`, `CarryStep`, `CutPlan(pieceCount, remainder)`, and `DistracterSelection`.

### Lessons

1. Mixed versus improper form and conversions both directions.
2. Addition and carrying an improper fraction into the whole.
3. Subtraction by borrowing one whole as denominator/denominator.
4. Distracters and formula-driven value selection.
5. Multiplication/division after improper conversion and final reduction.

### Curriculum assessment and assessment compatibility

Module 4 contributes to Seat Work 3 with Module 5 and Major Quiz 1. Grade conversion method, carrying/borrowing, reduction, and units. Distracter exercises remain internal and do not trigger monitoring.

### Required tests

- `5 7/16 ↔ 87/16`; `87/32 ↔ 2 23/32`.
- Cargo length `4 3/4 + 2 1/3 = 7 1/12`.
- Authoritative bolt grip `3 1/8 − 1 5/16 = 1 13/16`; ignore overall-length distracter.
- `2 1/2 × 1 3/4 = 4 3/8` and reject the parts-separately shortcut result.
- Twelve spacers at `1 3/8 in = 16 1/2 in` total.
- `7 1/2 ÷ 1 1/4 = 6` pieces.
- Borrow/no-borrow, carry/no-carry, zero fractional part, exact division, remainder, invalid denominator, and reduction cases.

## 7. Module 5 — The Decimal Number System

### Purpose

Teach decimal place value, exact decimal operations, final-step rounding, fraction conversion, repeating decimals, and the practical shop 64ths method used for sockets, drills, reamers, measurements, circuits, and wing dimensions.

### PWA features and UI

- Decimal place-value explorer on both sides of the point.
- Aligned add/subtract view and multiply/divide point-placement walkthrough.
- Rounding selector for tenth/hundredth/thousandth and explicit retained/inspection digits.
- Exact decimal-to-fraction and fraction-to-decimal converter with repeating cycle display.
- Shop 64ths tool: multiply by 64, round half-up to whole numerator, place over 64, reduce.
- Drill-and-ream planner subtracting the curriculum `1/64 in` undersize.
- Corrected decimal-equivalent reference card with `9/16` erratum notice.

### Calculation engine

`DecimalEngine` should use `DecimalQuantity` or another decimal-safe representation for taught operations. Rounding is half-up because the deck says 5 or greater rounds upward. `FractionDecimalEngine` detects terminating/repeating expansions and retains exact fractions. `ShopSixtyFourthsEngine` returns every method step and never rounds before the specified numerator step.

### Data models

`DecimalQuantity(coefficient, scale)`, `DecimalPlace`, `RoundingRequest`, `RepeatingDecimal(nonRepeating, repeating)`, `ShopFractionResult`, and `DrillReamResult`.

### Lessons

1. Base ten, definition, and decimal place value.
2. Add/subtract by aligning points.
3. Multiply by counting decimal places; divide by clearing the divisor's point.
4. Final-step rounding.
5. Decimal-to-fraction shop 64ths and drill/ream application.
6. Fraction-to-decimal and repeating notation; corrected reference chart.

### Curriculum assessment and assessment compatibility

Seat Work 3 combines Modules 4–5; Major Quiz 1 covers Modules 1–5. Assess four operations, rounding, both conversion directions, mixed numbers, and distracters. The lesson may offer an optional calculator check after the by-hand steps, controlled by the assessment tool policy.

### Required tests

- Series resistance `2.34 + 37.5 + 0.09 = 39.93 Ω`; `37.272 − 14.88 = 22.392 Ω`.
- `9.45 × 120 = 1,134 W`; `262.6 ÷ 40.4 = 6.5 ft`.
- Half-up rounding examples `2.1938 → 2.2`, `3.1648 → 3.16`, `3.7487 → 3.749`.
- `0.3123 × 64 → 20/64 → 5/16`.
- Reamed `0.763 in → 49/64`; subtract `1/64 → 3/4` drill.
- `1/2 = 0.5`, `3/8 = 0.375`, and `1/3` repeating.
- Trailing zeros, leading zeros, negative decimal policy, exact midpoint rounding, very long input, zero divisor, and repeating-cycle bounds.

## 8. Module 6 — Ratio

### Purpose

Teach ratios in fraction, colon, and word forms; reduction and rebasing; gear/speed relationships; proportions; and solving an unknown in fuel, glide, air-fuel, aspect, and compression applications.

### PWA features and UI

- Three-notation ratio builder and reducer.
- “To 1” rebasing tool.
- Gear pair visualizer showing tooth ratio, inverse speed ratio, direction/sanity prediction, and unknown RPM.
- Proportion workspace labeling quantities before substitution and identifying extremes/means.
- Fuel-required and glide-ratio aviation calculators with assumption notes.

### Calculation engine

`RatioEngine` stores ratios as exact fractions, reduces by GCD, rebases to 1 with controlled decimal output, inverts gear/speed ratio, and validates compatible quantities. `ProportionEngine` solves any one missing term by cross-products with nonzero denominators and produces extremes/means steps.

### Data models

`Ratio`, `RatioNotation`, `RebasedRatio`, `GearRatioInput`, `GearSpeedResult`, `Proportion<T>`, `ProportionTerm`, and `GlideRatioResult`.

### Lessons

1. Definition, three notations, and π as a ratio.
2. Compression, aspect, air-fuel, glide, and gear applications.
3. Gear ratio versus inverse speed ratio.
4. Reduction and rebasing to 1.
5. Proportion, extremes/means, unknown solving, and labeled units.

### Curriculum assessment and assessment compatibility

Module 6 contributes to the Long Quiz with Modules 7–8, Major Quiz 2, and Midterm. Assess notation, reduction, rebase, gear/speed ratios, extremes/means, and unknowns. Module navigation and gear diagrams remain internal.

### Required tests

- `8:28 = 2:7`; gear `2:9` produces speed ratio `9:2`.
- Pinion 10 teeth/spur 40 teeth/spur 160 rpm gives pinion 640 rpm.
- `200:250 = 4:5`; `9:5 = 1.8:1`.
- `65/80 = X/100` gives `81.25`.
- 300 miles/24 gallons to 750 miles gives 60 gallons under constant-burn assumption.
- 2 miles/1,000 ft gives `10.56:1` after converting miles to feet.
- Zero terms where denominators would be zero, incompatible labels, reversed gear sanity, exact and repeating rebases.

## 9. Module 7 — Average Value

### Purpose

Teach mean, median, mode, and introductory weighted average while emphasizing that averages can conceal unsafe outliers in compression, tyre pressure, micrometer, and fuel-burn measurements.

### PWA features and UI

- Measurement-set editor with reorder-independent statistics.
- Mean walkthrough, sorted median visualization, and mode frequency display supporting none/one/multiple modes.
- Weighted-average builder with visible weights and validation.
- Raw-reading panel that remains visible beside summaries so a mean cannot hide an individual value.
- Reflective questions requiring students to comment on outliers; do not automatically declare components airworthy/unairworthy.

### Calculation engine

`AverageValueEngine` computes exact/rational or decimal-safe mean, median, all modes, and weighted mean. Weights must be explicit and normally total 100%/1.0. The engine can report range and candidate outliers for teaching, but maintenance-limit decisions require approved limits and are outside this module.

### Data models

`MeasurementSet`, `AverageSummary(mean, median, modes)`, `WeightedObservation`, `WeightedAverageResult`, and `InterpretationPrompt`.

### Lessons

1. Why repeated measurements are averaged.
2. Arithmetic mean and cylinder compression example.
3. Median and mode, including even counts and no/multiple modes.
4. Mean chord and other aviation averages.
5. Weighted average and what a summary conceals.

### Curriculum assessment and assessment compatibility

Module 7 is part of the Modules 6–8 Long Quiz. Numeric scoring covers mean/median/mode/weighted average; interpretation of concealed outliers should be teacher-reviewed or rubric-based rather than guessed by an automatic scorer.

### Required tests

- Compression readings total 452, mean `75.333…`, median `75.5`, no mode.
- Repeated 75 produces mode 75; support no mode and multiple modes.
- Grade weights 30/30/40 with 85, 78, 90 produce `84.9`.
- Micrometer and fuel-burn practice data at curriculum precision.
- Tyres `180, 178, 145, 182`: mean `171.25`, median `179`; preserve 145 in raw display.
- Empty set, one value, odd/even counts, duplicate values, decimal measurements, invalid/negative weights, and weights not totaling the required amount.

## 10. Module 8 — Percentage

### Purpose

Teach decimal/fraction/percentage conversion and the three complete percentage problem types: find the part, find the rate, and find the whole.

### PWA features and UI

- Three-way fraction/decimal/percentage converter.
- Case classifier showing what is given and what is missing.
- Dual-method solution view: algebraic and proportion.
- “Of” denominator cue and bigger/smaller sanity-check prompt.
- Aviation examples for defects, engine/pump efficiency, resistance, rejects, and useful load.

### Calculation engine

`PercentageEngine` implements:

1. `part = whole × rate`.
2. `rate = part ÷ whole`, displayed as percent.
3. `whole = part ÷ rate`.

It also converts exact fractions, decimals, and percentages in both directions and returns both algebraic and proportion steps. Whole cannot be zero for Case 2; rate cannot be zero for Case 3 unless the problem is explicitly indeterminate.

### Data models

`PercentageRate`, `PercentageProblemType`, `PercentageProblem`, `PercentageResult`, `SanityPrediction`, and dual `SolutionMethod` steps.

### Lessons

1. Per hundred and conversions in every direction.
2. Case 1: whole and rate given, find part.
3. Case 2: part and whole given, find rate.
4. Case 3: part and rate given, find whole.
5. Three-case classification card and aviation practice.

### Curriculum assessment and assessment compatibility

The Long Quiz covers Modules 6–8 using both percentage methods and all conversion directions. Require students to select the case before calculation. Internal case selectors, proportion views, and calculator checks create no incidents.

### Required tests

- `0.90 = 90%`, `1.25 = 125%`, `5% = 0.05`, `5/8 = 62.5%`.
- Case 1: 15% of 80 is 12.
- Case 2: 10.75 of 12 horsepower is approximately 89.58%.
- Case 3: 80 Ω at 52% gives approximately 153.846 Ω whole.
- Practice: 6% of 240 produces the raw value 14.4; because rivets are discrete, the curriculum must define whether the scenario data or whole-item rounding is corrected before it becomes an auto-graded item. Also verify 12.6/15 is 84% and 47 Ω at 25% gives 188 Ω.
- 0%, 100%, over 100%, sub-1%, negative-value policy, zero whole/rate, exact fraction output, and final-step rounding.

## 11. Module 9 — Positive and Negative Numbers

### Purpose

Teach signed arithmetic and the physical meaning of signs in weight and balance changes, fore/aft arms, altitude deviations, and temperature deviations.

### PWA features and UI

- Interactive number line and debt/change visualization.
- Signed add/subtract workspace that rewrites subtraction as addition of the opposite.
- Multiplication/division same-sign versus different-sign rule table.
- Weight-added/removed scenario builder and temperature-deviation practice.
- Mandatory sign display in givens, steps, and answers.

### Calculation engine

`SignedNumbersEngine` supports signed integers and curriculum decimals, additive inverses, four operations, and step narration. `WeightChangeEngine` maps removed to negative and installed/added to positive without claiming to perform a complete certified weight-and-balance analysis.

### Data models

`SignedOperation`, `SignedTerm(value, physicalMeaning)`, `WeightChange`, `WeightChangeResult`, and `TemperatureDeviation`.

### Lessons

1. Integers and the number line.
2. Adding signed values using direction/debt.
3. Subtraction by changing the operation and second sign.
4. Multiplication/division: same signs positive, different signs negative.
5. Physical sign conventions in aviation maintenance.

### Curriculum assessment and assessment compatibility

Module 9 combines with Module 10 in Seat Work 5 and appears in Major Quiz 2/Midterm. Assessment items must retain sign semantics, not grade only absolute values.

### Required tests

- Aircraft `2,000 + (−3) + (−10) = 1,987 lb`.
- Temperature `−6 − 20 = −26 °C`.
- All four sign combinations for multiplication and division.
- Practice aircraft `3,250 − 22 − 8 + 35 = 3,255 lb`.
- Surface `−3 °C`, 24° colder gives `−27 °C`.
- Zero, negative zero normalization, subtracting negatives, mixed added/removed sequences, division by zero, and required sign/unit presentation.

## 12. Module 10 — Denominated Numbers

### Purpose

Make units first-class in arithmetic. Teach carrying/borrowing in mixed bases, multiplication/division of compound measurements, conventional/metric conversions, area/volume factor scaling, and chained aviation quantities.

### PWA features and UI

- Compound measurement editor for feet/inches, hours/minutes, and pounds/ounces.
- Carry/borrow visualizer parameterized by radix 12, 60, or 16.
- Safe general method: convert to smallest unit, calculate, convert back.
- Curriculum conversion table for length, area, volume, weight, and temperature.
- Conversion-chain workspace that visibly cancels units.
- Aviation tools for tank cubic volume → gallons → fuel weight, square-unit conversion, and temperature.

### Calculation engine

`DenominatedNumberEngine` performs compatible-unit arithmetic and compound-unit normalization. `CurriculumConversionEngine` uses the factors stated by the deck, including approximations where the curriculum expects them:

- `1 in = 2.54 cm = 25.4 mm`; `1 ft = 12 in`; `1 yd = 3 ft`; `1 mile = 5,280 ft`.
- `1 ft² = 144 in²`; `1 yd² = 9 ft²`; `1 acre = 43,560 ft²`; `1 mi² = 640 acres ≈ 2.59 km²`.
- `1 gal = 4 qt = 8 pt = 3.785 L = 231 in³`; `1 ft³ = 1,728 in³ ≈ 7.5 gal`; `1 yd³ = 27 ft³`.
- `1 lb = 16 oz = 453.592 g`; `1 kg = 1,000 g ≈ 2.2 lb`; `1 oz = 28.350 g`.
- `C = (5/9)(F − 32)` and `F = (9/5)C + 32`.

These curriculum factors must not replace the more precise existing Unit Converter catalog. The module engine and general converter need separate profiles so instructional answers remain stable and working converter logic is untouched.

### Data models

`UnitDefinition`, `CompoundUnitDefinition(radix)`, `CompoundQuantity`, `ConversionFactor(source, target, factor, exactness)`, `ConversionChain`, `DimensionalKind`, and `FuelQuantityResult`.

### Lessons

1. Denominated numbers and like-unit rule.
2. Addition/carrying in base 12/60/16.
3. Subtraction/borrowing.
4. Multiplication/division and smallest-unit method.
5. Length/area conversions and the 144 square-unit trap.
6. Volume/weight/temperature factors and chained conversions.

### Curriculum assessment and assessment compatibility

Seat Work 5 covers Modules 9–10; Major Quiz 2 covers Modules 6–10; Midterm covers Modules 1–10. Every scored line must carry a unit. The module must not navigate into the existing converter during graded work unless the session's allowed-tools snapshot permits it.

### Required tests

- `5 ft 9 in + 3 ft 8 in = 9 ft 5 in`.
- `4:45 + 3:50 + 2:35 = 11 hr 10 min`.
- `12 ft 3 in − 4 ft 9 in = 7 ft 6 in`.
- `3 ft 7 in × 4 = 14 ft 4 in`; `15 ft 6 in ÷ 3 = 5 ft 2 in`.
- `10 ft 4 in ÷ 3 = 41.333… in = 3 ft 5.333… in` with controlled final display.
- `20 in = 508 mm`; `12 oz = 340.2 g`; `30 ft³ = 225 gal`; at 6.7 lb/gal gives 1,507.5 lb, displayed approximately 1,508 lb when requested.
- `4,620 in³ = 20 gal`; `6 ft² = 864 in²`; `95 °F = 35 °C`.
- Incompatible units, invalid radix, negative compound values, carry/borrow boundaries, exact/approximate factor labels, chain cancellation, and no early rounding.

## 13. Module 11 — Powers and Indices

### Purpose

Teach base/exponent vocabulary, squared/cubed dimensions, zero and negative powers, exponent laws, powers of ten, negative-base parentheses, and correct PEMDAS order.

### PWA features and UI

- Base/exponent builder with repeated-multiplication expansion.
- Squared/cubed dimensional explanation.
- Zero/negative exponent reciprocal visualizer.
- Same-base exponent-law simplifier with counterexamples for different bases.
- Negative-base calculator trap comparison: `(-3)²` versus `-3²`.
- Powers-of-ten place-movement tool.
- Stepwise PEMDAS expression reducer; calculator available only as a final check.

### Calculation engine

`PowersIndicesEngine` supports integer exponents, exact reciprocal results for negative integer powers, zero-exponent rules for nonzero bases, same-base multiply/divide simplification, and powers of ten. `OrderOfOperationsEngine` may reuse the tested `CalculatorEngine` for final numeric evaluation, but it needs its own curriculum step reducer and must preserve multiplication/division and addition/subtraction left-to-right behavior.

### Data models

`PowerExpression(base, exponent)`, `ExactPowerResult`, `ExponentLawOperation`, `PowerOfTen`, `PemdasStage`, and `NegativeBaseComparison`.

### Lessons

1. Base, exponent, expanded form.
2. Squared/cubed and dimensional meaning.
3. Power zero, negative powers, and reciprocals.
4. Parentheses around negative bases.
5. Same-base multiplication/division laws.
6. Powers of ten.
7. Correct PEMDAS and full expression chain.

### Curriculum assessment and assessment compatibility

Seat Work 6 covers Module 11. Require expansion/simplification steps and distinguish a correct value from a correctly interpreted expression. Calculator evaluation inside the app remains an allowed-tool policy decision and cannot create an incident.

### Required tests

- `3⁴ = 81`, `2³ = 8`, `10⁵ = 100,000`, `7⁰ = 1`, `2⁻³ = 1/8`.
- `(-3)² = 9` versus `-3² = -9` under standard precedence.
- `3² × 3⁴ = 3⁶`; `10⁴ ÷ 10² = 10²`; reject combining different bases.
- Powers of ten from `10⁶` through representative negative powers.
- Curriculum PEMDAS chain evaluates to `161.75 = 161 3/4`.
- `2 × [(12 ÷ 4) + (2 + 3)²] = 56`.
- `0⁰` undefined policy, zero to negative power, negative exponents, large exponents/non-finite limits, left-to-right tie handling, and nested parentheses.

## 14. Module 12 — Roots

### Purpose

Teach roots as inverse powers, perfect squares, estimation, square/cube roots, the cube-versus-cube-root distinction, and roots as fractional indices.

### PWA features and UI

- Perfect-square memory drill and reference.
- Root estimator that brackets a value between neighboring perfect powers before showing a calculated approximation.
- Square/cube/fourth/nth-root calculator with fractional-index equivalence.
- Cube versus cube-root comparison card.
- Calculator-entry coach that enforces parentheses around fractional exponents.
- Corrected Functions of Numbers reference entry for `N = 62`.

### Calculation engine

`RootsEngine` finds exact integer roots where possible, brackets/estimates non-perfect roots, computes controlled approximations, and represents roots as fractional indices. Even roots of negative inputs are invalid in real numbers; odd roots may support negative inputs as an explicit domain rule. It must distinguish `x³` from `∛x` structurally.

### Data models

`RootExpression(radicand, degree)`, `RootResult(exact, approximation)`, `RootEstimate(lowerPerfectPower, upperPerfectPower)`, `FractionalIndex`, and `PerfectPowerEntry`.

### Lessons

1. Roots undo powers; radical sign and first perfect squares.
2. Estimating square roots as an error check.
3. Cube roots and cube/cube-root distinction.
4. Fractional indices and calculator parentheses.
5. Corrected functions chart and dimension-from-area application.

### Curriculum assessment and assessment compatibility

Module 12 shares a Seat Work with Module 13. Where required, students enter an estimate before revealing the calculator result. This pedagogical sequence must remain available in assessment mode without external tools.

### Required tests

- Perfect roots: `√25 = 5`, `√49 = 7`, `∛125 = 5`, `∛27 = 3`, `∛1000 = 10`.
- `√31` brackets between 5 and 6 and approximates `5.568…`.
- `27³ = 19,683` versus `∛27 = 3`.
- `125^(1/3) = 5`; `16^(1/4) = 2`.
- Corrected circle area for diameter 62: `π × 31² ≈ 3019.07` under curriculum display precision.
- Area 196 in² gives side 14 in.
- Zero, one, non-perfect roots, negative even/odd domains, fractional-index parentheses, exact-versus-approximate flag, and final rounding.

## 15. Module 13 — Scientific Notation

### Purpose

Teach normalized scientific notation, conversion in both directions, exponent sign/direction, four operations using the handbook method, optional exponent shortcuts, and metric prefixes.

### PWA features and UI

- Standard/scientific notation converter that animates decimal movement.
- Format validator requiring coefficient `1 ≤ |c| < 10` for nonzero values.
- Direction/sign reference card for large and small numbers.
- Arithmetic workspace with the handbook method as default: convert to standard, calculate, normalize.
- Enrichment switch for exponent rules: multiply/add exponents, divide/subtract exponents, align exponents before addition/subtraction.
- Metric-prefix explorer for giga, mega, kilo, hecto, deca, unit, deci, centi, milli, micro, nano, and pico.

### Calculation engine

`ScientificNotationEngine` uses a normalized coefficient plus integer exponent and string/decimal-safe conversion to avoid losing significant digits. Zero receives a defined canonical form. Addition/subtraction aligns magnitudes; multiplication/division normalizes the coefficient after exponent arithmetic. The engine records whether a result is a valid value but non-normalized notation.

### Data models

`ScientificNumber(coefficient, exponent)`, `ScientificFormatValidation`, `DecimalMovement`, `ScientificOperation`, `ScientificSolutionMethod`, and `MetricPrefix(symbol, exponent)`.

### Lessons

1. Motivation using very large/small aviation/scientific values.
2. Normalized format and coefficient range.
3. Standard-to-scientific and scientific-to-standard conversion.
4. Direction/sign reference table.
5. Four operations using the handbook method; exponent method as enrichment.
6. Metric prefixes and aviation-electronics connections.

### Curriculum assessment and assessment compatibility

Module 13 shares a Seat Work with Module 12. The primary grading method follows the handbook conversion method; the faster exponent method is enrichment and should not be required unless the teacher enables it. All notation entry stays inside the app.

### Required tests

- `2,350,000 = 2.35 × 10⁶`; `23.5 × 10⁵` is equal in value but invalid normalized form.
- `1,244,000,000,000 = 1.244 × 10¹²`.
- `0.000000457 = 4.57 × 10⁻⁷`.
- `3.68 × 10⁷ = 36,800,000`; `7.1543 × 10⁻¹⁰ = 0.00000000071543`.
- `(2 × 10³)(3 × 10⁴) = 6 × 10⁷`; `(8 × 10⁶)/(2 × 10²) = 4 × 10⁴`.
- Practice: `93,000,000`, `0.00042`, `5,280`; reject `38 × 10²` as non-normalized.
- Metric conversions `4.5 km = 4,500 m`, `250 mm = 0.25 m`, `18 cm = 0.18 m`.
- Zero, negative coefficients, coefficient boundaries 1/10, very large exponents, significant-digit preservation, exponent-alignment addition, division by zero, and prefix symbol case sensitivity (`M` versus `m`).

## 16. Lessons and content delivery

### Bundled curriculum

Store lessons and problem metadata as versioned local assets, for example:

```text
assets/curriculum/amt111/
├── curriculum_manifest.json
├── module_02.json
├── module_03.json
├── ...
└── module_13.json
```

Do not ship the raw PowerPoint inside the PWA. Translate its curriculum into structured content and include only optimized diagrams/assets that are required and authorized for distribution. Preserve source slide IDs such as `M6-S05` in metadata so each lesson and expected result is traceable.

Before a public deployment reproduces substantial ACATECH-authored slide text or artwork, confirm the institution's distribution approval. FAA material and ACATECH curriculum should retain visible source attribution in the About/Curriculum Sources screen.

### Shared lesson UI

- Module header: number, title, duration, learning outcome, prerequisites, progress.
- Lesson reader: concept, formula, variable/unit definitions, aviation relevance, source/correction badge.
- Worked-example panel: four required lines plus final answer and no-early-rounding reminder.
- Guided workspace: student fills each step; hints are optional and recorded only for learning feedback.
- Mistake cards: common incorrect method and why it fails.
- Practice mode: immediate feedback, retry, complete solution after submission.
- Assessment mode: no answer reveal until submission/teacher review; tool availability comes from the session snapshot.
- Formula/reference cards available offline, with teacher control during graded work.

## 17. Curriculum assessments and local reporting

### Assessment map

| Assessment | Modules | PWA implementation |
|---|---|---|
| Module 2 Quiz | 2 | Whole-number operations, vocabulary, factors/multiples, prime factors, divisibility |
| Seat Work 2 | 3 | LCD methods, fraction operations, cancellation, lowest terms |
| Seat Work 3 | 4–5 | Mixed-number operations/borrowing and decimal operations/rounding/conversion |
| Major Quiz 1 | 1–5 | Existing/future Module 1 plus Modules 2–5; do not activate until Module 1 content is defined |
| Long Quiz | 6–8 | Ratio/proportion, average value, percentage conversions/all three cases |
| Seat Work 5 | 9–10 | Signed arithmetic and denominated arithmetic/conversions |
| Major Quiz 2 | 6–10 | Modules 6–10 cumulative |
| Midterm | 1–10 | Do not activate until Module 1 content is defined |
| Seat Work 6 | 11 | Powers, laws, powers of ten, negative bases, PEMDAS |
| Seat Work | 12–13 | Roots/fractional indices plus scientific notation/arithmetic/prefixes |
| Final examination | 1–14 | Outside this phase because Modules 1 and 14 are not included |

### Scoring model

Each automatically gradable item can award separate points for:

- Correctly selected givens and rejection of distracters.
- Correct formula/method.
- Correct substitution including signs and units.
- Correct calculation.
- Required reduction/normalization.
- Correct unit and final-step rounding.

Free-response interpretation—especially Module 7 outlier reasoning—requires a teacher rubric or manual review. The system must never manufacture an “airworthy” decision from a classroom calculation.

### Storage boundary

Create a `CurriculumAttemptRepository` separate from the existing `AssessmentRepository`:

- Assessment repository: sessions, pending absences, and neutral presence incidents.
- Curriculum repository: lesson progress, answers, scores, rubric status, and assessment attempts.

Both are local-only in the first release. Teacher-gated Reports may present separate **Presence** and **Learning Results** sections, but their records must not be merged. Firebase/server synchronization remains future architecture behind repository decorators.

## 18. AssessmentMonitor integration

The monitor architecture does not change:

```text
Platform presence signals
↓
Root AssessmentMonitor
↓
InterruptionPolicy
↓
Local session/incident repository
↓
Teacher-gated presence reports
```

Modules, lessons, calculators, practice, quizzes, keyboards, dialogs, dropdowns, sheets, formula cards, and internal navigation never emit presence events. They must create zero incidents during an active session.

A versioned allowed-tools snapshot should use stable tool IDs rather than twelve Boolean fields. Examples:

```text
converter
calculator
aviation_math.module_2
...
aviation_math.module_13
aviation_math.formula_reference
```

Teacher selection is frozen when a graded session starts and displayed in the report. Disallowed tools show neutral in-app feedback; they do not navigate externally. The theme/settings restriction and teacher PIN remain independent.

Any future external link to a reference should be disabled during active assessment by default. If an external flow is explicitly approved, only the root assessment controller may issue a narrow, one-shot suppression token. Modules cannot suppress monitoring themselves.

## 19. Dependency and reuse analysis

### Reuse without rewriting

- Keep the current converter formulas/catalog unchanged. Module 10 owns a curriculum conversion profile because its expected approximations differ from a general precision converter.
- Keep the calculator engine unchanged. Modules 11–12 may use it as a final-answer verifier through an adapter, while their own engines produce pedagogical steps.
- Reuse Material 3 themes, cards, breakpoints, accessibility patterns, teacher-PIN dialog, and root monitor ownership.
- Extract shared lesson widgets or math types only after at least two modules require the same behavior.

### Dependency graph

```text
Module 2
  └── factors, GCD, LCM, divisibility
      ↓
Module 3 exact fractions
      ↓
Module 4 mixed numbers
      ↓
Module 5 exact decimals / fraction conversion
      ├── Module 6 ratio and proportion
      │     └── Module 8 percentage
      ├── Module 7 average value
      ├── Module 9 signed numbers
      │     └── Module 10 denominated numbers
      └── Module 11 powers and indices
            └── Module 12 roots
            └── Module 13 scientific notation
```

Module 10 also consumes Module 4 compound-form thinking and Module 3 fractions. Module 13 consumes Module 5 decimal place value and Module 11 powers of ten.

### Package/dependency policy

- Prefer pure Dart value types and existing Flutter dependencies.
- Do not add a math-expression package merely to duplicate the tested calculator parser.
- Evaluate a decimal/rational dependency only if the in-house exact types cannot meet web precision, serialization, and explanation requirements; require license and cross-platform review first.
- No database dependency is approved until local attempt volume and query needs are measured.
- No Firebase, analytics, ads, remote question bank, or mandatory API dependency in the local-first phase.

## 20. Implementation sequence

Each phase is a complete vertical slice with domain tests before UI tests. Run the full regression gate before starting the next module.

### Phase A — Module 2 and minimal shared foundation

1. Add shared curriculum/source/problem/step models and local content loader.
2. Add one Tools/Aviation Mathematics hub without overloading root navigation.
3. Implement Module 2 engine, lessons, practice, Quiz, and tests.
4. Validate the architecture pattern and accessibility before expanding it.

### Phase B — Modules 3–5 foundation arithmetic

1. Module 3 exact fractions and Seat Work 2.
2. Module 4 mixed numbers.
3. Module 5 decimal-safe math, 64ths, repeating decimals.
4. Add Seat Work 3; leave Major Quiz 1 inactive until Module 1 content is available.

### Phase C — Modules 6–8 relationships

1. Module 6 ratio/proportion.
2. Module 7 statistics/interpretation.
3. Module 8 percentage cases.
4. Add the Modules 6–8 Long Quiz.

### Phase D — Modules 9–10 signed and denominated values

1. Module 9 signed arithmetic and physical sign semantics.
2. Module 10 compound units and curriculum conversion profile.
3. Add Seat Work 5 and Major Quiz 2.
4. Leave the Midterm inactive until Module 1 exists.

### Phase E — Modules 11–13 notation

1. Module 11 exponents and corrected PEMDAS.
2. Module 12 roots/estimation/fractional indices.
3. Module 13 scientific notation/metric prefixes.
4. Add Seat Work 6 and combined Modules 12–13 Seat Work.

### Phase F — Stabilization

1. Add generalized allowed-tools snapshots and learning-result repository only after their schemas are separately reviewed.
2. Run cumulative curriculum, converter, calculator, assessment, reports, responsive, branding, PWA, and offline tests.
3. Profile bundle size, curriculum loading, route restoration, and low-end device performance.
4. Perform physical Chrome Android, Safari iOS/iPadOS, and desktop installed-PWA acceptance.
5. Do not enable Major Quiz 1, Midterm, or Final until their missing Module 1/14 scope is supplied.

## 21. Test strategy

### Per-module quality gate

- Pure domain tests for every formula and worked example listed above.
- Typed validation/error tests and boundary tests.
- Step-generation tests for Given/Formula/Substitute/Solve.
- Unit, precision, no-early-rounding, and correction tests.
- Content-schema validation: stable IDs, source slide IDs, nonempty outcome, valid lesson order, valid formula/problem references.
- Controller tests for lesson navigation, practice retries, assessment submission, and local recovery.
- Repository round-trip, corruption, schema-version, bounded-retention, and migration tests when storage is added.
- Widget tests for lessons, calculators, mistakes, empty/error/loading states, assessment locks, and teacher review.
- Responsive tests at 320, 360, 390, 430, 768, 1024, 1366, 1920, and 2560 logical pixels.
- Light/dark mode, text scaling, keyboard navigation, focus order, semantic labels, and 48-pixel touch targets.

### Assessment compatibility gate

For every module during an active assessment:

- Open/close module: zero incidents.
- Navigate lessons/practice/quiz: zero incidents.
- Enter answers/show keyboard: zero incidents.
- Open dropdown/dialog/sheet/formula card: zero incidents.
- Use allowed calculator/converter: zero incidents.
- Attempt disallowed tool: blocked internally, zero incidents.
- Hide/pause app: pending absence saved immediately.
- Resume: one duration calculated and classified by unchanged `InterruptionPolicy`.

### Regression commands

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --reporter compact
flutter test --platform chrome \
  test/features/pwa_install/pwa_install_service_test.dart \
  test/app/install_app_action_test.dart
flutter build web --release
```

The current floor is 135 VM/widget tests and 18 Chrome PWA tests. No existing converter, calculator, assessment, PWA, branding, responsive, or reports test may be deleted or weakened.

## 22. Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Curriculum/reference conflict | Wrong taught result or method | PowerPoint controls; encode source/correction metadata and lock every correction with tests |
| Early rounding | Chained aviation answers drift | Exact fraction/decimal types; retain full value; round only at the declared final step |
| Binary floating-point behavior on Web | Decimal/fraction displays can surprise students | Coefficient/scale decimals and exact fractions for taught arithmetic; tolerance only for irrational results |
| Educational result treated as maintenance authority | Safety risk | Prominent educational-use notice; never label airworthiness; require approved manuals/engineering data |
| Existing converter constant mismatch | Curriculum assessment answers may differ | Separate curriculum conversion profile; do not alter converter engine/catalog |
| Calculator reuse changes pedagogy | Correct answer without required method | Use calculator only as optional verifier; module engines generate required steps |
| Assessment versus curriculum report confusion | Presence event could be misread as answer activity | Separate repositories, models, and report sections; neutral presence language remains unchanged |
| False interruption from internal learning UI | Assessment integrity regression | Root-only presence inputs and no-incident integration tests for every interaction type |
| Navigation overload | Twelve modules cannot fit adaptive navigation | One Tools/Aviation Math hub with internal routes and stable IDs |
| Large raw curriculum assets | Slow PWA install/cache failure | Structured text, optimized required diagrams, lazy module loading, bundle/cache size budgets |
| Content distribution rights | Public deployment may redistribute institutional material | Confirm ACATECH approval before reproducing substantial slide text/artwork publicly |
| Auto-grading subjective answers | Misleading scores, especially outlier interpretation | Teacher rubric/manual review for free response; automatic scoring only for deterministic components |
| Unit omission | Numerically correct but curriculum-wrong answers | Make unit a scored field and retain it at every step |
| Distracter handling | App may accidentally reveal the needed values | Require student selection before formula feedback; delay hints during graded assessment |
| Shared type overengineering | Early abstractions constrain later modules | Build Module 2 vertical slice; extract only proven cross-module patterns |
| Storage schema growth | Attempts/progress become corrupt or incompatible | Namespaced, versioned local repository with migrations and bounded retention |
| Module 1/14 missing | Cumulative exams would be incomplete | Keep Major Quiz 1, Midterm, and Final disabled until those module specifications are supplied |

## 23. Expected files by implementation completion

This is a forecast, not authorization to create the files now.

```text
lib/features/aviation_math/
├── aviation_math.dart
├── domain/
│   ├── math/
│   ├── models/
│   └── repositories/
├── application/
├── data/
└── presentation/

lib/features/module_2_whole_numbers/
...
lib/features/module_13_scientific_notation/

assets/curriculum/amt111/
├── curriculum_manifest.json
└── module_02.json ... module_13.json

test/features/aviation_math/
test/features/module_2_whole_numbers/
...
test/features/module_13_scientific_notation/
```

Existing files likely to require carefully scoped integration changes after approval:

- `lib/app/app.dart`: one stable Tools/Aviation Math destination and route ownership.
- `lib/app/layout/adaptive_scaffold.dart`: only if stable destination IDs are introduced.
- Assessment session/models/controller/pages: generalized allowed-tools snapshot, after separate schema review.
- Reports presentation: optional teacher-gated Learning Results section, without changing incident semantics.
- `pubspec.yaml`: versioned local curriculum assets and only approved dependencies.
- `ARCHITECTURE.md`, `TEST_PLAN.md`, `DEVELOPMENT_STATUS.md`, `README.md`, and deployment acceptance documentation.

Protected by default: converter engine/catalog, calculator engine, `AssessmentMonitor`, `InterruptionPolicy`, PWA install bridge, branding identity, manifest icons, and service-worker ownership.

## 24. Approval gate and definition of done

No Module 2–13 implementation begins until this curriculum-derived plan is approved.

Each module is complete only when:

- Its authoritative lessons, formulas, examples, cautions, and assessment blueprint are represented and source-traceable.
- Domain logic is independent of Flutter and all specified examples/edge cases pass.
- Four-line working, units, final-step rounding, and curriculum corrections are enforced.
- Responsive and accessible UI passes the complete width/theme/input matrix.
- Internal activity creates zero assessment incidents and real absence behavior remains unchanged.
- Local persistence is versioned and independent from presence incidents.
- Converter, calculator, assessment, reports, PWA installation, offline shell, and branding continue to pass regression.
- `flutter analyze`, all Flutter/Chrome tests, and `flutter build web --release` pass.

Cross-module completion additionally requires the Long Quiz, Seat Works, Major Quiz 2, module progress, teacher-gated local learning results, installed-PWA acceptance, and a documented list of deferred Module 1/14 cumulative assessments.
