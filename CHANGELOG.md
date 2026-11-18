# Changelog

## 0.1.2 — 2026-11-18

Book layout: the two pages are no longer forced to one width.

- `duo-book-layout`: each page fills its own side of the fold. The side bar takes room from one side, so the page beside it is narrower (measured: 455 and 371 pt). Before, both pages took the narrower width and an empty band was left at the outer edge. New "Page widths" section, runbook step and checklist items.
- `BookSpread`: pages fill their sides by default. `matchesPageWidths` keeps equal pages for fixed-size pages or panels that must line up, with the reason stated.
- Right-to-left, run on the simulator in Arabic and with right-to-left forced: the bar stayed on the right, the page order mirrored, and the first page became the narrower one. The reserved-region query mirrors by default, so the recipe needs no branch on layout direction.
- `duo-vertical-bars` and the review checklist: do not assume the bar is on the trailing edge; check the narrow page on either side.
- Documentation image `book-layout.png` captured again. The sample's probe prints the layout direction; `-matched YES` shows equal pages.

Not reproduced: a side bar on the left of the open inner display. No setting that moves it was found in Apple's two pages or in the simulator's Settings search. The SDK's documentation comment says the system chooses the edge from the locale and the device. Skill descriptions did not change, so the trigger prompts were not run again.

## 0.1.1 — 2026-11-17

Toolbars and arrangements, re-checked and measured.

- `duo-vertical-bars`: a table of roles for actions (pinned, high, automatic, low, always in overflow), the compression table, which APIs are iOS 27.0 and which are 27.1, when a pinned action can still overflow, when a horizontal-only item is not shown, how to turn vertical bars off as a stable choice, and five new rows of common problems. Adds measurements from the simulator for four poses.
- `duo-fold-and-poses`: split ratio, reading the split axis and the overlay index from a child view, and measured behavior: the default split shows only the primary closed in landscape; the primary's overlay index is 1 while overlaid and 0 once separated.
- `duo-pose-testing` and the review checklist: check the overflow menu, search, the keyboard and larger text.
- Sample app: lab screens for toolbars and arrangements (`-mode toolbar`, `-mode split`, `-mode overlay`). Two new documentation images.
- Sources: two Bitrig guides by Sean Allen prompted this pass. They are linked; nothing is copied, and each statement taken up was checked against the SDK's documentation comments or run on the simulator.

Not run: compression with `.prefersToolbarItems` outside the closed landscape pose, search-active overflow, Split View halves, a physical device. Skill descriptions did not change, so the trigger prompts were not run again.

## 0.1.0 — 2026-11-17

First version. Nine skills: `duo-app-readiness`, `duo-adaptive-layout`, `duo-fold-and-poses`, `duo-book-layout`, `duo-vertical-bars`, `duo-scenes-and-camera`, `duo-design-references`, `duo-design-review`, `duo-pose-testing`. Two optional Claude Code agents. Code checked against Xcode 27.2 (27B52), iOS 27.2 SDK; the book layout was run on an iPhone Duo simulator.

Verification for this release:

- Trigger prompts: the expected skill loaded for 15 of 15 prompts in Codex and in Claude Code, after one round of description fixes for prompts 8 and 10.
- Baseline: seven prompts in a clean Codex session without plugins. Two misread the device, four were generic, one found Apple's page by web search.
- Documentation images in `docs/images`, captured from the sample app on the iPhone Duo simulator.
- Not verified: a physical device, the camera accessory, Split View halves, UIKit equivalents.

