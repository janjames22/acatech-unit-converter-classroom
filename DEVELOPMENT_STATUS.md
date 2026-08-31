# Development Status

**Status date:** 2026-08-31
**Overall state:** Core converter, assessment, local-report, responsive-shell, and install-flow implementation exists; cross-platform verification is in progress and the product is not release-ready.

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
| Automated tests | Done | `flutter analyze` is clean and all 95 VM/widget tests pass; the 14-test install-service suite also passes through Chrome's Web interop branch |
| Converter domain | Done | Nine-category catalog, conversion engine, affine temperature handling, search, and number formatting are implemented with unit coverage |
| Assessment monitoring | In progress | Root lifecycle monitor, exact threshold policy, pending-candidate persistence/recovery, Android lock hints, and neutral reports are implemented; platform matrix remains open |
| Local reports | In progress | SharedPreferences repository, report UI, teacher-PIN verifier, throttling, and deletion are implemented; migration/failure and physical persistence acceptance remain open |
| Responsive UI | In progress | Compact, medium, and expanded navigation/layouts plus widget coverage exist; full browser/device/viewport matrix remains open |
| PWA shell | In progress | Manifest metadata, icon declarations, install bridge loading, app-owned service worker, and Firebase Hosting rules are configured; physical installation/offline acceptance remains open |
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

- [x] Replace generated Flutter title, description, favicon, and icons with Unit Converter branding.
- [x] Validate manifest name, short name, theme, background, start URL, scope, and standalone display.
- [x] Verify PNG inventory dimensions: favicon 32 × 32, regular icons 192 × 192 and 512 × 512, and maskable icons 192 × 192 and 512 × 512.
- [x] Declare regular icons for any purpose and dedicated maskable entries for maskable purpose.
- [x] Load the install bridge before Flutter bootstrap so Chromium install events can be captured early.
- [x] Use one app-owned service worker without Flutter deprecated-worker registration.
- [x] Version the service-worker cache from the Flutter build token and limit cache cleanup to this application.
- [x] Exclude Firebase reserved /__/ routes from service-worker fallback and caching.
- [x] Add static Firebase Hosting configuration for build/web, SPA fallback, security headers, and shell revalidation.
- [x] Build the current release with local renderer resources and verify every APP_SHELL path exists.
- [ ] Select a real Firebase project and create .firebaserc with firebase use --add.
- [ ] Confirm install flow on Android Chrome and iOS/iPadOS Safari.
- [ ] Confirm installed and browser modes use the same monitoring limitations.
- [x] Define the intended network-first, cached-shell offline behavior in TEST_PLAN.md.
- [ ] Verify offline behavior after service-worker activation and one controlled online reload.
- [ ] Verify service-worker/update behavior for the supported Flutter release.
- [ ] Visually validate maskable safe-zone cropping on Android launchers; matching dimensions alone do not prove safe artwork.
- [ ] Measure cold and warm start against the agreed under-three-second baseline.
- [ ] Profile scrolling and interaction performance on representative low-end hardware.

## PWA Installation

Checked items below have source, static-build, or automated-test evidence. Device/browser installation and hosted HTTPS evidence remain open.

- [x] Manifest valid
- [x] 192 icon
- [x] 512 icon
- [ ] Chromium install event detected
- [ ] Desktop install tested
- [ ] Android install tested
- [x] iOS instructions implemented
- [x] Standalone detection tested
- [x] Already-installed state tested
- [ ] HTTPS preview deployed

Firebase Hosting is configuration-ready through firebase.json. Firebase CLI 15.28.2 is available through `npx`, but it is not authenticated, no Firebase project ID has been supplied, and .firebaserc is intentionally absent. No deployment has been performed.

The Chromium bridge and its one-shot prompt contract are covered in VM and Chrome Web tests. The real browser eligibility event remains unchecked until an installable HTTPS preview is available.

The maskable PNGs currently match the regular PNGs byte-for-byte. Their files and manifest purposes are valid, but safe-zone cropping remains a manual Android launcher acceptance item.

## Phase 7 — Verification and release

**Status: In progress**

- [x] Make flutter analyze pass with no unresolved findings.
- [x] Make the full automated test suite pass (95 tests).
- [x] Produce a release Web build.
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
9. Automated coverage exists, but physical interruption, installation, offline, HTTPS, accessibility, and full viewport matrices remain open.

## Immediate integration order

1. Restore a clean flutter analyze and full automated-test gate.
2. Run the documented local PWA service-worker, offline, and update procedures.
3. Validate desktop, Android, and iOS/iPadOS installation on real browsers and devices.
4. Complete the assessment interruption and Android lock-exclusion device matrix.
5. Complete responsive, accessibility, performance, and local-persistence validation.
6. Select and authenticate a Firebase project only when an HTTPS preview is authorized.

## Checklist maintenance

When updating this file:

- Change the status date.
- Check an item only after code and proportionate tests exist.
- Add a short evidence link or note for high-risk platform behavior.
- Keep deferred work visibly separate from the current release.
- Record limitations rather than silently weakening acceptance criteria.

## Change log

### 2026-08-31

- Reconciled the checklist with the implemented converter, assessment monitor, local reports, responsive shell, install bridge, and automated-test inventory.
- Added the exact PWA Installation readiness checklist.
- Recorded successful static PWA validation and release Web build while leaving physical install, offline/update, and HTTPS deployment checks open.
- Added static Firebase Hosting configuration without selecting or deploying to a project.
- Recorded clean analysis, 95 passing tests, 14 passing Chrome-interoperability tests, and a successful Android debug build.

### 2026-08-28

- Recorded the generated Flutter scaffold as the verified implementation baseline.
- Added the approved root-monitor, neutral evidence, exact threshold, responsive tier, local-report, and future Firebase decisions.
- Established the initial live delivery checklist.
