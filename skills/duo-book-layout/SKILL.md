---
name: duo-book-layout
description: Use when a reading, document, article-detail or master–detail screen should show two pages either side of the fold on the open inner display of iPhone Duo, like an open book. Gives the split-or-span decision, a SwiftUI recipe that finds the fold even when the device is flat, and the behavior in every other pose.
argument-hint: "[screen name]"
---

# Two-page book layout on iPhone Duo

A layout convention for the open inner display: content sits on two pages, one each side of the fold, the way an open book does. The pages do not move when the device goes from flat to partially folded.

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

## What is Apple's rule and what is this plugin's rule

- **Apple's rule.** Content and controls must not straddle the fold while the device is partially folded. Flat, the fold is inactive and a layout may cross it. Continuously scrolling content does not have to avoid the fold at all.
- **This plugin's rule (a house convention).** On the open inner display in landscape, two pages either side of the fold is the default for content screens, flat or folded. It goes further than Apple requires, so say so when recommending it.

## Split or span

| Screen | Default | Why |
|---|---|---|
| Reading: book, article, document, long-form detail | Two pages | Line length stays readable; nothing crosses the spine. |
| Master–detail pair: list and its detail, form and its preview, player and its transcript | Two pages, one role per side | Each side keeps one job; closing the device keeps the detail. |
| Dashboard or grid of cards | Two pages, with an even number of columns | Cards divide cleanly at the fold. |
| One continuously scrolling list or feed | May span | Apple exempts scrolling content. State the reason in the design notes. |
| Map, canvas, photo or video viewer, game | May span | The content is one image. Keep controls off the fold. State the reason. |
| Any screen on the outer display, in a Split View half, or flat in portrait | One page | Compact width, or no top-to-bottom fold to split at. |

A screen that spans must still move its controls off the fold while partially folded. See `duo-fold-and-poses`.

## Runbook

1. **Confirm the SDK.** The recipe needs the iOS 27.1 SDK: `xcrun --sdk iphoneos --show-sdk-version`.
2. **Decide split or span** with the table. Write the reason for any span.
3. **Name the two pages.** First page is what the outer display shows alone; the second is what the inner display adds. For reading, they are consecutive pages. For master–detail, the detail is the first page, because that is what remains when the device closes.
4. **Use the recipe** in [references/book-spread.md](references/book-spread.md). Do not compute the middle of the screen: a side bar makes the content area off-center from the fold.
5. **Keep position across poses.** Store the reading position as a page or content anchor, never as a spread index. Closing the device shows the first page of the current spread; opening it shows that page on the leading side.
6. **Page two at a time** while split, one at a time while single. Page-turn controls sit at the outer edges of the spread, not at the fold.
7. **Test** closed, open flat, partially folded like a book, partially folded like a laptop, flat in portrait, and both Split View halves, with `duo-pose-testing`.

## Using the recipe

```swift
// fragment
NavigationStack {
    BookSpread {
        ChapterPage(index: currentPage)
    } second: {
        ChapterPage(index: currentPage + 1)
    }
    .toolbar { /* system-managed bar: it moves to the side by itself */ }
}
```

## What the recipe does in each pose

Measured on the iPhone Duo simulator (iOS 27.2 runtime, Xcode 27.2). Numbers are observations, not constants; the recipe reads them at run time.

| Pose | Fold region reported | Result |
|---|---|---|
| Closed, outer display | none | One page |
| Open flat, landscape | one, inactive, running top to bottom, about 40 pt wide | Two pages side by side |
| Partially folded like a book | the same region, now active | Two pages, unchanged |
| Partially folded like a laptop | one, active, running side to side | Two pages stacked above and below |
| Open flat, portrait | one, inactive, running side to side | One page |
| Split View half | compact width | One page |

With a vertical bar on the trailing side, the content area was 867 pt wide and the fold sat at 455–495 pt, so the leading side had 455 pt and the trailing side 372 pt. The recipe gives both pages the narrower width and keeps them against the fold, leaving the spare space at the outer edge.

## Why not `ArrangementView` for this

`ArrangementView` with `.split.axes(.horizontal)` is the system's two-view container and the right tool when two views should simply share the space. For a book layout it has one drawback, measured on the same simulator: flat, it divides the content area into two equal halves (433 and 433 pt), which puts the boundary about 42 pt away from the fold; partially folded, it jumps to the fold (455 and 371 pt). The layout shifts as the device folds, and when flat the second view crosses the fold line. Use it when that shift is acceptable; use the recipe when the pages must stay put.

## Checklist

- [ ] The fold comes from the division reserved region with `.includeInactive`, not from the screen's midpoint.
- [ ] Nothing interactive and no line of text crosses the fold in any pose.
- [ ] Both pages have the same width; spare space is at the outer edge.
- [ ] The outer display and Split View halves show one page with the same content reachable.
- [ ] Position survives closing and opening.
- [ ] Any spanning screen has its reason written down.
