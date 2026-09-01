# ACATECH Application Branding

## Official identity source

The supplied ACATECH Aviation College logo is the sole identity source for the application. The production assets preserve the complete emblem, both wings, gear, globe, aircraft, orbit stroke, `ACATECH` wordmark, and `AVIATION COLLEGE` subtitle. No logo elements were redrawn, recolored, removed, or replaced.

The full-logo asset was produced with deterministic center cropping and proportional downsampling from the supplied 1392 × 1130 PNG. The crop removes excess white canvas only and preserves the complete visible logo.

## Asset inventory

| Purpose | Path | Size | Treatment |
|---|---|---:|---|
| Flutter About/branding master | `assets/branding/acatech_logo_full.png` | 1200 × 689 | Complete logo on white |
| Web loading/splash logo | `web/branding/acatech-logo-full.png` | 1200 × 689 | Exact copy of the Flutter full-logo asset |
| Regular app-icon master | `assets/branding/app_icon_master.png` | 1024 × 1024 | Complete logo at 85.9% canvas width |
| Maskable app-icon master | `assets/branding/app_icon_maskable_master.png` | 1024 × 1024 | Complete logo at 68.0% canvas width |
| Regular PWA icons | `web/icons/Icon-192.png`, `web/icons/Icon-512.png` | 192, 512 square | Derived from regular master |
| Maskable PWA icons | `web/icons/Icon-maskable-192.png`, `web/icons/Icon-maskable-512.png` | 192, 512 square | Derived from maskable master |
| Android launcher icons | `android/app/src/main/res/mipmap-*/ic_launcher.png` | 48–192 square | Derived from maskable master |
| Browser favicon | `web/favicon.png` | 32 × 32 | Derived from regular master |

All square assets use a solid white background. This matches the logo artwork, prevents visible rectangular seams, and supplies the opaque background expected by launcher masks.

## Maskable safe zone

Maskable artwork uses additional padding instead of sharing the regular icon file. At 512 pixels, the complete logo occupies a 348 × 200 pixel centered rectangle. At 192 pixels it occupies approximately 131 × 75 pixels. Both rectangles fit inside the standard centered circle with a radius equal to 40% of the icon width.

Automated pixel validation scans both maskable files and fails if any visible logo pixel lies outside that circle. This protects both wing tips under circle, rounded-square, squircle, and other compliant launcher masks. Physical Android launcher review remains the final device-level acceptance step.

## Application integration

- The app and PWA identity is `ACATECH Aviation Tools`, with `ACATECH Tools` as the short install name.
- The Material app shell uses the ACATECH logo as its brand mark.
- The About page displays the complete official logo and describes the existing tools.
- The web loading surface displays the full logo until Flutter emits its first-frame event.
- The full web loading logo and Flutter logo asset are included in the application-owned offline shell.
- The manifest retains the existing `#176B5B` theme color and uses `#FFFFFF` as its splash/background color to match the official logo canvas.

## Validation

Automated checks cover:

- PNG dimensions for full-logo, master, favicon, PWA, and Android density assets.
- Distinct regular and maskable files.
- Pixel-level maskable safe-zone containment.
- Manifest identity, theme/background colors, standalone display, icon paths, sizes, and purposes.
- Loading-surface logo presence, first-frame dismissal, and service-worker cache inventory.
- About-page navigation during an active assessment without an interruption incident.

Manual release acceptance should still confirm the icon under several Android launcher masks, the installed Chrome desktop icon, iOS Add to Home Screen, and light/dark system splash transitions.
