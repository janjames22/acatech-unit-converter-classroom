# Unit Converter Architecture

**Status:** Approved target architecture
**Last reviewed:** 2026-08-28

This document describes the intended structure of the Unit Converter application. It distinguishes the target design from the current implementation; see [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) for what is actually complete.

## 1. Scope

The product uses one Flutter codebase for:

- Android applications
- iPhone and iPad applications
- Web and installable PWA experiences
- Laptop and desktop use through supported web browsers

The repository currently contains Android, iOS, and Web runners. Native Windows, macOS, and Linux runners are not part of the current scaffold. Adding native desktop targets requires a separate scope decision; until then, “desktop” means the responsive web/PWA experience.

The product has two primary domains:

1. Unit conversion, search, settings, and responsive presentation.
2. Assessment sessions, focus/visibility observation, local incident reports, and teacher controls.

## 2. Architectural principles

- **Domain logic stays independent of widgets.** Conversion math and assessment classification must be testable without rendering Flutter UI.
- **Monitoring has one root owner.** One root-scoped monitor observes lifecycle signals for the whole application and survives route changes.
- **Reports are local-first.** The current product boundary is on-device report storage. A repository interface preserves a future Firebase synchronization seam without adding Firebase to the present build.
- **Monitoring language stays neutral.** A signal means that focus or visibility changed. It does not prove cheating, identify another app, or determine why the signal occurred.
- **Platform differences are explicit.** Android, iOS, and Web adapters translate platform events into common domain signals but do not pretend that all platforms expose the same facts.
- **Layouts respond to constraints.** Breakpoints are based on available width, not device names or fixed screen assumptions.
- **Dependencies point inward.** Presentation and platform adapters depend on domain contracts; domain code does not import Flutter UI, browser, database, or Firebase APIs.

## 3. Logical component map

    App bootstrap
      └── Root application scope
          ├── App theme and responsive shell
          ├── PWA installation service
          │   └── Conditional browser/native bridge
          ├── Converter controller
          │   ├── Conversion catalog
          │   └── Conversion engine
          └── Assessment controller
              ├── Root AssessmentMonitor
              │   ├── FocusSignalSource
              │   ├── Assessment state machine
              │   └── Clock
              ├── AssessmentReportRepository
              │   └── Local report store
              └── Teacher controls and report UI

    Future extension
      └── SyncingAssessmentReportRepository
          └── Firebase data source

The future Firebase data source sits behind the report repository contract. Converter logic, assessment classification, and UI must not depend directly on Firebase.

## 4. Target source organization

The exact filenames may evolve, but implementation should preserve these boundaries:

    lib/
      app/
        app.dart
        app_scope.dart
        navigation/
        theme/
      core/
        clock/
        errors/
        responsive/
      features/
        pwa_install/
          domain/
          application/
          infrastructure/
        converter/
          domain/
          application/
          presentation/
        assessment/
          domain/
          application/
          data/
          platform/
          presentation/
      shared/
        widgets/

- **domain** contains immutable models, conversion formulas, assessment rules, and repository contracts.
- **application** coordinates use cases and exposes UI-ready state.
- **data** implements local serialization and repositories.
- **platform** adapts Flutter lifecycle, Web visibility, and supported native hints.
- **presentation** contains screens and widgets only.

## 5. Converter domain

### Responsibilities

- Define conversion categories and units.
- Normalize a source value to a category base unit and convert it to the target unit.
- Support both multiplicative conversions and affine conversions such as temperature.
- Validate input without embedding validation rules in widgets.
- Provide deterministic formatting rules while preserving an unrounded numeric result for further conversion.
- Expose searchable category and unit metadata.

### Boundaries

Conversion formulas must not read UI state, local storage, or platform APIs. Search operates on catalog metadata and remains case-insensitive. Settings may affect formatting and theme, but must not alter the underlying conversion result.

## 6. Assessment domain

### 6.1 Root monitor lifetime

AssessmentMonitor is created once in the root application scope, above navigation and responsive shells. It is not created inside the Assessment screen.

The monitor:

- Owns the single platform signal subscription.
- Is armed only while a session is active.
- Continues observing when the user navigates between internal application screens.
- Coalesces noisy lifecycle callbacks into one absence candidate.
- Persists an open candidate before execution may be suspended.
- Is disposed only when the root application scope is disposed.

This placement prevents duplicate observers, double-counted events, and lost sessions during internal navigation.

### 6.2 Common focus signals

Platform adapters emit a small common vocabulary:

- focused
- focusLost
- visible
- hidden
- paused
- resumed
- pageHide
- pageShow
- knownSystemExclusionStarted
- knownSystemExclusionEnded
- processRestarted

Signals carry their source and timestamp. Adapters report only what the platform exposed; they must not infer another app’s identity.

### 6.3 State machine

    disabled
       │ start session
       ▼
    foreground
       │ first focus/visibility loss
       ▼
    candidateAbsence
       │ additional lifecycle signals are coalesced
       │ known exclusion evidence may be attached
       │
       └── focused and visible again
                ▼
             resolve
                │ persist one result
                ▼
            foreground

Ending a session disarms the monitor. If a session ends with an open candidate, the candidate is resolved using the evidence available at that time and is never labeled a confirmed app switch.

An unfinished persisted candidate found after process restart becomes an unknown process gap. Flutter and browsers do not guarantee that every termination callback will run.

### 6.4 Exact duration thresholds

Threshold boundaries are intentionally complete and non-overlapping:

| Measured absence | Duration band | Default report treatment |
|---|---|---|
| Less than 2 seconds | transient | Ignore |
| At least 2 seconds and less than 10 seconds | review | Store as a review event |
| At least 10 seconds | extended | Store as an extended focus/visibility absence |

Classification occurs when focus and visibility return. Background timers are not used to decide when ten seconds has elapsed because browsers throttle timers and mobile operating systems suspend processes.

Duration band and disposition are separate fields:

- **durationBand:** transient, review, or extended
- **disposition:** recorded, excluded, or unknown

A known screen-lock hint, for example, can produce an extended duration band with an excluded disposition. Duration alone never changes an unknown cause into a confirmed app switch.

### 6.5 Platform policy

#### Android and iOS native

- resumed means the Flutter view is visible and has input focus.
- inactive alone is weak evidence and must not become a counted absence on mobile.
- hidden or paused upgrades the candidate to evidence that the app was not visible.
- notification UI, calls, authentication UI, app switchers, system dialogs, and split-screen can share lifecycle states with ordinary app switching.
- Android may add best-effort screen/keyguard hints through a narrow native adapter. Unsupported or missing hints remain unknown.
- iOS does not provide a general, reliable reason for a transition to the background.

#### Web and PWA

- Document visibility and window focus are retained as separate evidence.
- A hidden document may mean a background tab, minimized window, covered window, screen-off state, or operating-system lock.
- Window blur may represent Alt+Tab, browser chrome, a file picker, or other system UI.
- Installed standalone mode does not grant monitoring privileges beyond normal Web APIs.
- pageHide is persisted immediately where possible. A browser or process can still terminate before a callback runs.

#### Desktop browser

Desktop behavior uses the Web policy. Alt+Tab is observable as focus loss, but the application cannot identify the foreground program or prove why focus moved.

### 6.6 False-positive controls

- Flutter dialogs, dropdowns, keyboard display, and internal navigation are app-owned UI and must not create monitor events.
- Mobile inactive-only sequences are ignored for counted absence purposes.
- App-initiated external flows use explicit, short-lived exemption tokens with a flow identifier.
- Prefer disabling file pickers, external links, and permission prompts during an assessment instead of creating broad exemptions that can be exploited.
- Repeated inactive, hidden, and paused callbacks belong to one candidate until the application is focused and visible again.
- Split-screen focus loss is retained as review evidence rather than described as leaving the device.

No cross-platform implementation can guarantee both “count every real app switch” and “never count screen lock, calls, or system UI.” Unsupported causes remain neutral and visible as unknown or review events.

### 6.7 Assessment models

An assessment session should contain:

- session identifier
- assessment title
- optional student display identifier
- start and end timestamps in UTC
- threshold snapshot used for that session
- session status
- report schema version

An assessment event should contain:

- event identifier and session identifier
- first loss and return timestamps in UTC
- measured duration
- duration band
- disposition
- source signal set
- neutral reason code
- optional exclusion reason
- platform and application version
- confidence or evidence level

Reason codes describe observations such as documentHidden, windowFocusLost, appNotVisible, knownScreenLock, expectedExternalFlow, or processGap. They must never use labels such as cheated.

## 7. Local reports and future synchronization

### Current boundary

Assessment reports are local-only. The local repository is responsible for:

- Atomic session and event writes.
- Restoring an active session and open candidate.
- Schema versioning and migrations.
- Listing, viewing, and deleting reports after teacher authorization.
- Handling unavailable, corrupt, full, or cleared storage without fabricating events.

The current implementation uses a JSON-backed SharedPreferences repository. UI and application controllers depend only on AssessmentRepository, so a different local store or future synchronizing decorator can replace it without changing monitoring policy or presentation code.

### Future Firebase seam

Firebase is deferred. No current feature may require network access to convert units or complete a local assessment.

A future sync implementation may:

- Reuse stable client-generated identifiers.
- Upload idempotently and track pending, synced, and failed states.
- Preserve local timestamps while adding trusted server receipt timestamps.
- Resolve retries without duplicating events.
- Enforce authenticated teacher access and server-side retention policy.

Network loss or a missed heartbeat must never be classified as an app switch. Synchronization state is separate from monitoring state.

## 8. Teacher authorization and privacy

- Teacher PINs are never stored as plaintext.
- The current local implementation stores a randomly salted PBKDF2 verifier, never a plaintext PIN, and rate-limits attempts. Native secure storage is a future hardening option rather than a claim of the present implementation.
- A browser-local PIN is a convenience barrier, not strong security against a device owner with developer tools.
- Strong multi-device teacher authorization belongs in the future authenticated backend.
- Monitoring must not request Accessibility Service, usage-history, browser-history, microphone, camera, screen-recording, or other-app identity access.
- Reports retain only the minimum student identifier and focus/visibility evidence needed for the classroom purpose.
- Logs must not contain PINs, raw student secrets, or unrelated device activity.
- The UI explains what is observed, what cannot be determined, and how reports are retained or deleted.

## 9. PWA installation architecture

PWA installation uses progressive enhancement and is independent of converter, reporting, and assessment-domain logic:

    Root application scope
      └── PwaInstallService
          └── PwaInstallBridge
              ├── Web JavaScript bridge
              └── Native/unsupported unavailable stub

The JavaScript bridge loads synchronously before Flutter bootstrap so it cannot miss an early Chromium `beforeinstallprompt` event. It calls `preventDefault()`, retains the deferred event, and publishes availability to Flutter. The deferred event is consumed only after the user activates Install App and is cleared before awaiting the browser result, enforcing the browser's one-shot contract.

The service exposes unavailable, available, installing, installed, and iOS-manual states. It also observes `appinstalled`, `display-mode: standalone`, and practical iOS standalone detection. Unsupported browsers and already-installed/standalone launches do not display an inert install control. iPhone and iPad browser mode displays manual Share → Add to Home Screen instructions because WebKit does not expose the Chromium prompt.

Browser-specific code stays behind a conditional import, so Android and iOS Flutter builds receive an unavailable stub and never import JavaScript interop libraries. The install service does not own offline policy: the explicit app service worker and its network-first cache remain a separate production concern.

An intentional Chromium installation prompt runs inside a narrow lifecycle-suppression scope owned by the root assessment controller. Any hidden/paused callback produced by that one trusted prompt and its matching resume is ignored before it reaches AssessmentMonitor. The suppression is not armed for ordinary navigation or while no install action is executing.

## 10. Responsive architecture

Breakpoints have exact, non-overlapping boundaries:

| Tier | Available width | Primary navigation |
|---|---:|---|
| Compact | 320–599 logical pixels | Bottom navigation |
| Medium | 600–1023 logical pixels | Navigation rail or adaptive two-pane layout |
| Expanded | 1024 logical pixels and above | Navigation rail or sidebar |

The supported verification range is 320 through 2560 logical pixels. Width below 320 should fail gracefully but is outside the primary acceptance matrix.

Layouts use constraints and content needs through LayoutBuilder, Flexible, Expanded, ConstrainedBox, and max-extent grids. The converter changes from a vertical compact layout to a horizontal or multi-column expanded layout. Tier changes must not recreate the root assessment monitor or active session.

## 11. Error handling and observability

- Domain operations return typed failures that presentation code can explain.
- Storage errors are visible to the teacher and do not silently discard reports.
- Monitoring diagnostics may log state names and anonymous session/event identifiers in debug builds.
- Production logs avoid student names, PIN attempts, and raw report content.
- Clock changes, missing callbacks, and recovered process gaps are marked explicitly.
- No error path may transform an unknown observation into a confirmed incident.

## 12. Explicit non-goals

- Identifying which application, tab, or website gained focus.
- Reading messages, notifications, history, or other application content.
- Recording camera, microphone, or screen content.
- Declaring that a student cheated.
- Preventing application switching or providing kiosk/exam lockdown.
- Treating local PWA data as tamper-proof audit evidence.
- Requiring Firebase for the first local-only release.
