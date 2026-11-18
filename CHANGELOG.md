# Changelog

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

