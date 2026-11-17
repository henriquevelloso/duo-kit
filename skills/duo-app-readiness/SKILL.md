---
name: duo-app-readiness
description: Use for any request to prepare, adapt, audit or plan an app for iPhone Duo, Apple's two-display folding iPhone, or when a question about iPhone Duo is vague. Explains how the device differs from an iPad, scans code for assumptions that break on it, and says which duo- skill handles each screen. Generic resizing and multiwindow readiness for other devices is out of scope.
argument-hint: "[project path or screen name]"
---

# iPhone Duo app readiness

Start here when someone asks to "get the app ready for iPhone Duo" or asks about the device in general. This skill gives the model of the device, finds the code that will break, and routes each screen to the skill that fixes it. It reports; it does not edit unless asked.

<!-- duo-kit:card:start -->
> **iPhone Duo is not an iPad.** Read this before answering.
>
> - It is a real, shipped device (September 2026): an outer display and a larger inner display that folds on a hinge. Its APIs are in the iOS 27.1 SDK. Never describe it or its APIs as hypothetical.
> - It is an iPhone. There is no Duo idiom, no Stage Manager and no free-form window resizing. An app's size comes from the pose and from 50/50 Split View on the inner display.
> - Outer display: compact width. Inner display: regular width and regular height. One half of Split View: compact width again.
> - The inner display does not honor an app's supported orientations.
> - Built with the 27.1 SDK, toolbars and tab bars move to the side as vertical bars in every pose except the inner display in portrait. Safe areas become asymmetric.
> - The fold is a reserved region of kind "division". It is active only while the device is partially folded. Content and controls must not straddle it.
> - Never branch on device model, idiom or orientation. Decide layout from size classes, safe areas and reserved regions.
> - Before writing code, confirm each API name in the installed SDK. The SDK's spelling wins over this text.
<!-- duo-kit:card:end -->

## The device in one table

| Where the app is | Horizontal size class | Vertical size class | Bars |
|---|---|---|---|
| Outer display, portrait (closed) | compact | regular | vertical, on the side |
| Outer display, landscape (closed, or standing like a tent) | compact | compact | vertical, on the side |
| Inner display, landscape (open) | regular | regular | vertical, on the side |
| Inner display, portrait (open) | regular | regular | horizontal, as on other iPhones |
| One half of Split View (inner display) | compact | regular | vertical, on the app's outer edge |

Vertical bars need a build against the iOS 27.1 SDK. Size classes above are for a full-screen app; always read them from the environment rather than assuming them from the display.

People also hold the open device partially folded: like a book (the fold runs vertically) or like a laptop on a table (the fold runs horizontally). There is no API that returns a pose. Layout follows size classes and reserved regions; the hinge reports a status and an angle for effects only.

## What the SDK you build with changes

| Built against | On iPhone Duo |
|---|---|
| iOS 26 SDK or earlier | The app runs without recompiling but does not extend under the status bar and camera. |
| iOS 27.0 SDK | The app resizes like any iOS 27 iPhone app and extends beside the status bar on the inner display. |
| iOS 27.1 SDK or later | The app reaches the screen edges, and standard navigation bars, toolbars and tab bars lay out vertically. Fold, arrangement and hinge APIs become available. |

Check before promising anything: `xcrun --sdk iphoneos --show-sdk-version`. Gate 27.1 APIs with `@available(iOS 27.1, *)` and keep the older path compiling.

## Runbook

1. **Establish scope.** Which targets, which screens, SwiftUI or UIKit, deployment target, and the SDK version above. Ask only if the project does not show it.
2. **Scan for assumptions.** Run the searches in [references/anti-patterns.md](references/anti-patterns.md). Record each hit as breaks on Duo, fine, or needs a look, with file and line.
3. **Classify each screen** with the table below. One screen can need more than one skill.
4. **Report.** Give the SDK status, the hit list, the per-screen plan and what must be checked on a simulator. Do not edit files in an audit.
5. **Verify on the simulator** with `duo-pose-testing` once changes are made. A clean build proves nothing about poses.

## Which skill for which screen

| The screen or problem | Use |
|---|---|
| Goes from one column outside to more content inside; state lost on open or close; Split View halves | `duo-adaptive-layout` |
| Reading, document, article detail, or a master–detail pair on the open inner display | `duo-book-layout` |
| Content or controls land in the fold or under the inner camera; partially folded use | `duo-fold-and-poses` |
| Toolbar, tab bar or navigation items should sit on the side, overflow, or stay horizontal | `duo-vertical-bars` |
| A second window, content on the outer display during camera capture, hinge-driven effects | `duo-scenes-and-camera` |
| "How do good apps do this?" | `duo-design-references` |
| A design, mock-up or screenshots need judging pose by pose | `duo-design-review` |
| Run, fold and screenshot the app in every pose | `duo-pose-testing` |

## Rules that hold everywhere

- Design two layouts, not one per pose: compact width for the outer display and regular width for the inner one. Let the regular layout extend the compact one instead of reinventing it.
- Keep the same functions and the same information hierarchy on both displays. People open and close the device in the middle of a task.
- Prefer system containers (`NavigationSplitView`, `TabView`, `NavigationStack`, sheets, alerts). They already adapt to both displays, the vertical bars and the fold.
- Inset each safe-area side on its own. A vertical bar on one side makes left and right different, and in Split View the larger inset changes sides.
- Move, resize or reorganize content that meets the fold. Never hide a function because of a pose.

## Sources

Apple's guidance, the measurements used here and what was verified against which SDK are listed in [references/sources.md](references/sources.md).
