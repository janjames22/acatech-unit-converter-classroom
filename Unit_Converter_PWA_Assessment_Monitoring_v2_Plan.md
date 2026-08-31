# Unit Converter PWA + Assessment Monitoring v2 Development Plan

## Project Objective

Create a Progressive Web App (PWA) version of the Unit Converter
application that can be accessed by students using:

-   Android phones
-   iPhones
-   iPads
-   Android tablets
-   Windows laptops
-   MacBooks
-   Desktop computers

The PWA must provide the same professional experience as the mobile
application while improving:

-   Responsive UI/UX
-   Student Assessment Monitoring
-   False interruption detection
-   Cross-platform compatibility
-   Deployment readiness

------------------------------------------------------------------------

# Final Product Architecture

Maintain one Flutter codebase:

    Unit_converter_A

    ├── Android Application
    ├── iOS Application
    └── Progressive Web App

Shared features:

-   Unit conversion engine
-   Search
-   Settings
-   Theme
-   Assessment Mode
-   User interface components

------------------------------------------------------------------------

# Phase 1 --- Progressive Web App Conversion

## Enable Flutter Web

Verify:

``` bash
flutter devices
```

Enable:

``` bash
flutter config --enable-web
```

Run:

``` bash
flutter run -d chrome
```

------------------------------------------------------------------------

# Phase 2 --- Web Compatibility Audit

Inspect all dependencies.

Check:

``` bash
flutter pub outdated
```

Identify packages that do not support:

-   Flutter Web
-   Safari
-   Chrome
-   Desktop browsers

Replace mobile-only implementations when necessary.

Examples:

Avoid:

-   Android-only storage APIs
-   Device-only permissions
-   Native-only plugins

Use:

-   Shared preferences
-   Web-compatible storage
-   Flutter-supported cross-platform solutions

------------------------------------------------------------------------

# Phase 3 --- Responsive UI/UX Requirements

The application must behave like a true responsive application.

Supported sizes:

## Mobile

320px - 430px width

Examples:

-   iPhone SE
-   iPhone Pro
-   Android phones

------------------------------------------------------------------------

## Tablet

600px - 1024px width

Examples:

-   iPad
-   Android tablets

------------------------------------------------------------------------

## Laptop/Desktop

1024px - 2560px width

Examples:

-   Windows laptops
-   MacBooks
-   Desktop monitors

------------------------------------------------------------------------

# Responsive Layout Rules

Do NOT use fixed dimensions that cause overflow.

Avoid:

    height: 200
    width: 300

Prefer:

-   LayoutBuilder
-   Flexible
-   Expanded
-   ConstrainedBox
-   AspectRatio
-   Responsive Grid

------------------------------------------------------------------------

# Home Screen Improvements

The category grid must automatically adjust.

Mobile:

    [Length]
    [Area]
    [Mass]
    [Temperature]

Tablet:

    [Length] [Area]
    [Mass]   [Temperature]

Desktop:

    [Length] [Area] [Mass]
    [Temp]   [Speed] [Volume]
    [Time]   [Storage] [Pressure]

Use:

    GridView.builder
    SliverGridDelegateWithMaxCrossAxisExtent

Requirements:

-   No overflow
-   No clipped text
-   Consistent spacing
-   Better icons
-   Modern cards
-   Smooth animations
-   Touch-friendly buttons

------------------------------------------------------------------------

# Navigation Improvements

## Mobile

Use:

Bottom Navigation:

    Home
    Assessment
    Tools

## Tablet/Desktop

Use:

-   NavigationRail
-   Sidebar navigation

Do not force mobile navigation on large screens.

------------------------------------------------------------------------

# Converter Screen UX Improvements

Improve:

-   Input field
-   Unit selection
-   Swap button
-   Result display
-   Keyboard behavior

Requirements:

-   No keyboard overflow
-   Large touch targets
-   Clear result card
-   Responsive layout

Mobile:

    Input

    From Unit

    Swap

    To Unit

    Result

Desktop:

    Input | From Unit | Swap | To Unit

    Result

------------------------------------------------------------------------

# Search Improvements

Search must support:

Categories:

-   Length
-   Area
-   Mass
-   Temperature

Units:

-   Meter
-   Kilometer
-   Celsius
-   Fahrenheit
-   Kilogram

Requirements:

-   Case insensitive
-   Fast filtering
-   Clear button
-   Empty result state

------------------------------------------------------------------------

# Assessment Mode v2

## Purpose

Assessment Mode allows teachers to know if students leave the Unit
Converter application during an exam.

The feature must NOT:

-   Spy on other applications
-   Read browser history
-   Monitor messages
-   Record screens
-   Record microphone
-   Record camera
-   Use Accessibility Service

The system only records application focus changes.

------------------------------------------------------------------------

# Important Monitoring Rule

## DO NOT COUNT:

The following events are NOT interruptions:

-   Screen turned off
-   Device locked
-   Phone idle
-   Incoming call
-   Notification popup
-   Temporary system dialog
-   Keyboard opening
-   Flutter dialogs
-   Dropdown menus
-   Internal app navigation

------------------------------------------------------------------------

# COUNT ONLY:

A real application switch.

Examples:

Mobile:

    Unit Converter
          ↓
    Android Recent Apps
          ↓
    Chrome / Another App
          ↓
    Return to Unit Converter

Computer:

    Unit Converter Browser Tab
          ↓
    Alt + Tab
          ↓
    Another Application
          ↓
    Return

------------------------------------------------------------------------

# Improved Interruption Detection Logic

Do not count every lifecycle event.

Avoid:

    inactive = interruption

because it creates false positives.

Use a state machine.

Example:

    APP ACTIVE

          |
          |
    User leaves application

          |
          |
    Verify background duration

          |
          |
    If another app/window replaced it

          |
          |
    Record interruption

------------------------------------------------------------------------

# Interruption Rules

Recommended logic:

## Ignore

Less than 2 seconds:

    Brief system event

Do not count.

------------------------------------------------------------------------

## Review

3-10 seconds:

    Possible application switch

------------------------------------------------------------------------

## Count

More than 10 seconds:

    Confirmed application absence

------------------------------------------------------------------------

# Incident Data Model

Store:

    AssessmentIncident

    id

    sessionId

    leftAt

    returnedAt

    durationSeconds

    classification

    reason

Reason examples:

    Application left foreground

Never:

    Student cheated

------------------------------------------------------------------------

# Assessment Report

Example:

    Assessment Report

    Student:
    Juan Dela Cruz

    Assessment:
    Physics Quiz

    Duration:
    60 minutes

    Interruptions:
    2

    Total Outside Time:
    25 seconds


    Incident 1

    Left:
    1:15 PM

    Returned:
    1:15:08 PM

    Duration:
    8 seconds


    Incident 2

    Left:
    1:30 PM

    Returned:
    1:30:17 PM

    Duration:
    17 seconds

------------------------------------------------------------------------

# Assessment UI Improvements

Create professional classroom UI.

Active screen:

    ASSESSMENT ACTIVE

    Physics Quiz

    Time Remaining

    45:22

    Recorded Events

    0


    Leaving this application
    will be recorded.

------------------------------------------------------------------------

# Teacher Controls

Require teacher PIN for:

-   Start assessment
-   End assessment
-   Change settings
-   View reports
-   Delete history

PIN requirements:

-   4-6 digits
-   Secure storage
-   No plaintext storage

------------------------------------------------------------------------

# PWA Features

Add:

## Manifest

    manifest.json

Include:

-   App name
-   Theme color
-   Icons
-   Standalone display mode

------------------------------------------------------------------------

## Install Support

Android:

    Chrome
    ↓
    Install App

iOS:

    Safari
    ↓
    Add to Home Screen

------------------------------------------------------------------------

# Branding

Replace Flutter default branding.

Use:

-   Unit Converter logo
-   Custom favicon
-   192x192 icon
-   512x512 icon

------------------------------------------------------------------------

# Performance Requirements

Target:

Loading:

\< 3 seconds

Smooth scrolling:

60 FPS

No:

-   overflow
-   broken layout
-   horizontal scrolling
-   frozen UI

------------------------------------------------------------------------

# GitHub Deployment

## Initialize

``` bash
git init
```

Add:

``` bash
git add .
```

Commit:

``` bash
git commit -m "Unit Converter PWA initial release"
```

Connect:

``` bash
git remote add origin YOUR_GITHUB_URL
```

Push:

``` bash
git branch -M main
git push -u origin main
```

------------------------------------------------------------------------

# Production Build

Before deployment:

Run:

``` bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

Build:

``` bash
flutter build web --release
```

Output:

    build/web

------------------------------------------------------------------------

# Deployment Options

Recommended:

## GitHub Pages

Good for:

-   student testing
-   free hosting
-   simple updates

------------------------------------------------------------------------

Alternative:

## Firebase Hosting

Good for:

-   professional deployment
-   custom domain
-   scalability

------------------------------------------------------------------------

# Testing Matrix

Test:

## Android

Chrome:

-   Xiaomi
-   Samsung
-   Pixel

## iOS

Safari:

-   iPhone
-   iPad

## Desktop

Browsers:

-   Chrome
-   Edge
-   Safari
-   Firefox

------------------------------------------------------------------------

# Acceptance Criteria

The project is complete only when:

## PWA

✓ Works on mobile browsers

✓ Works on tablets

✓ Works on laptops

✓ Installable

✓ Responsive

✓ Logo applied

------------------------------------------------------------------------

## UI/UX

✓ No overflow errors

✓ Professional design

✓ Fast navigation

✓ Good accessibility

------------------------------------------------------------------------

## Assessment

✓ Teacher PIN works

✓ Assessment starts

✓ Assessment ends

✓ Reports generate

✓ Screen off does NOT count

✓ System interruptions do NOT count

✓ Only real app switching counts

✓ False positives minimized

------------------------------------------------------------------------

# Final Goal

Create a professional educational Unit Converter ecosystem:

Mobile App

Progressive Web App

Classroom Assessment Monitoring

Teacher-Friendly Reports

that students can use anywhere while providing teachers with reliable
exam activity monitoring.
