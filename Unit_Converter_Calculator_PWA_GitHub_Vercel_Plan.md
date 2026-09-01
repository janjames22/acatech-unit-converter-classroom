# Unit Converter Classroom PWA + Calculator Module + GitHub + Vercel Deployment Plan

## Project Objective

Upgrade the Unit Converter Classroom application by adding a
professional calculator module while preserving:

-   Unit conversion features
-   Progressive Web App functionality
-   Assessment Monitoring Mode
-   Responsive UI
-   Student testing workflow

The final application becomes an educational mathematics platform:

    Unit Converter Classroom

    ├── Unit Converter
    ├── Scientific Calculator
    ├── Assessment Mode
    ├── Student Monitoring
    ├── Tools
    └── PWA Installation

# Calculator Module Requirements

## Purpose

The calculator supports:

-   Engineering mathematics
-   Aviation mathematics
-   Classroom exercises
-   Student practice
-   Conversion assistance

## Basic Calculator

Include:

-   Addition
-   Subtraction
-   Multiplication
-   Division
-   Decimal values
-   Negative numbers
-   Percentage
-   Parentheses
-   Clear
-   Backspace
-   Calculation history

## Scientific Calculator

Include:

-   Square root
-   Power
-   Exponent
-   Reciprocal
-   sin
-   cos
-   tan
-   Degree/radian mode
-   log
-   ln
-   Pi
-   Euler constant

## Engineering Functions

Include:

-   Fraction calculations
-   Percentage calculations
-   Memory buttons:
    -   MC
    -   MR
    -   M+
    -   M-

## UI/UX Requirements

Follow the existing Unit Converter design.

Requirements:

-   Material 3
-   Dark theme support
-   Responsive layout
-   Large touch buttons
-   Clear result display
-   Smooth interaction

Avoid:

-   fixed dimensions
-   overflow
-   RenderFlex errors

Use:

-   LayoutBuilder
-   Flexible
-   Expanded
-   Responsive GridView

# Assessment Integration

Calculator usage inside the app must NOT trigger interruptions.

These must NOT count:

-   opening calculator
-   switching converter pages
-   keyboard opening
-   dialogs
-   dropdowns
-   internal navigation

Only actual application leaving should be monitored.

Assessment settings should allow:

    Allowed Tools

    ✓ Unit Converter
    ✓ Calculator
    ✗ Settings

# Code Structure

Do not place calculator logic directly in UI.

Recommended:

    lib/features/calculator/

    ├── models/
    ├── services/
    ├── presentation/
    └── widgets/

Create:

-   CalculatorEngine
-   CalculatorState
-   CalculatorHistory

# Testing

Test:

Basic:

-   2+2
-   10/2
-   decimals
-   negative values

Scientific:

-   sqrt
-   powers
-   trigonometry
-   logarithms

Error handling:

-   division by zero
-   invalid expressions

Assessment:

Calculator activity: NO interruption

External app switching: YES interruption

# Git Manual Deployment Workflow

## Initialize

From project folder:

    git init

Check:

    git status

Add:

    git add .

Commit:

    git commit -m "Add calculator module and prepare PWA deployment"

# GitHub Setup

Create an empty GitHub repository:

Example:

    unit-converter-classroom

Do not initialize it with README or .gitignore.

Connect:

    git remote add origin YOUR_GITHUB_URL

Push:

    git branch -M main

    git push -u origin main

Verify:

    git remote -v

# Future Bug Fix Workflow

After changes:

    flutter analyze

    flutter test

    flutter build web --release

Then:

    git add .

    git commit -m "Fix calculator bugs"

    git push

# Vercel Deployment

Use GitHub as the source.

Steps:

1.  Login to Vercel
2.  Import GitHub repository
3.  Select unit-converter-classroom

Configuration:

Framework:

    Other

Build command:

    flutter build web --release

Output:

    build/web

Enable SPA fallback:

    /index.html

so Flutter routes work after refresh.

# Student Testing

After deployment Vercel provides:

    https://your-app.vercel.app

Students can:

Android: - Open URL - Install PWA - Test converter/calculator

iOS: - Safari - Share - Add to Home Screen

Laptop: - Install from Chrome/Edge

# Acceptance Criteria

Complete when:

✓ Calculator works

✓ Scientific functions work

✓ Unit converter still works

✓ Responsive design works

✓ Assessment monitoring works

✓ No false interruptions

✓ GitHub repository exists

✓ Vercel HTTPS URL works

✓ PWA installs correctly

✓ Students can test the application

# Final Goal

Create:

Unit Converter

-   

Scientific Calculator

-   

Classroom Assessment System

-   

Progressive Web App

for Android, iOS, Windows, macOS, and browsers.
