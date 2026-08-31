# Unit Converter Classroom

A responsive Flutter unit-conversion PWA with classroom Assessment Mode.

## Features

- Responsive unit converter with nine conversion categories.
- Mobile, tablet, and desktop layouts.
- PWA installation support for eligible Chromium browsers.
- Android, iOS/iPadOS, and browser delivery from one Flutter project.
- Assessment Mode with neutral foreground/visibility interruption reporting.
- Teacher-gated, local-only assessment reports.
- Immediate persistence and recovery of pending assessment absences.
- Local-first student testing; Firebase report synchronization remains future architecture.

## Supported Platforms

- Android browsers and installed PWAs.
- iPhone and iPad Safari with Add to Home Screen installation.
- Windows desktop browsers.
- macOS desktop browsers.
- Linux desktop browsers.
- Phones and tablets across compact, medium, and expanded layouts.

Native Android and iOS runners are included. Current Windows, macOS, and Linux delivery uses the responsive Web/PWA build rather than native desktop runners.

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

The production service worker is disabled on localhost unless explicitly enabled, so it does not interfere with Flutter hot reload.

## Production Build

```bash
flutter build web --release
```

The deployable static website is generated in `build/web`. It includes Flutter assets, the manifest, branded icons, the PWA installation bridge, and the app-owned service worker.

## Deployment

Vercel is used for public student-testing previews. The current workflow builds Flutter locally and deploys only the verified `build/web` output; Vercel is configured as an Other/Static project with SPA fallback routing. Vercel does not need to install Flutter for this workflow.

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for preview deployment, GitHub, routing verification, student installation, and bug-fix procedures.

## Assessment Privacy

The app records when the assessment application loses foreground focus during an active assessment. The resulting report is neutral visibility evidence, not proof of why focus changed.

It does **not** inspect:

- Browser history.
- Messages or notifications.
- Microphone input.
- Camera input.
- Screen contents.
- Which external app the student opened.

Platform lifecycle APIs cannot always distinguish application switching from screen lock, calls, browser UI, or other system interruptions. Unsupported causes remain unknown and are documented in [ARCHITECTURE.md](ARCHITECTURE.md).

## Project Documentation

- [Architecture](ARCHITECTURE.md)
- [Development status](DEVELOPMENT_STATUS.md)
- [Test plan](TEST_PLAN.md)
- [Deployment workflow](docs/DEPLOYMENT.md)
