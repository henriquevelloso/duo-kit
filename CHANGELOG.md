# Changelog

## 0.1.0 — 2026-11-17

First version. Nine skills: `duo-app-readiness`, `duo-adaptive-layout`, `duo-fold-and-poses`, `duo-book-layout`, `duo-vertical-bars`, `duo-scenes-and-camera`, `duo-design-references`, `duo-design-review`, `duo-pose-testing`. Two optional Claude Code agents. Code checked against Xcode 27.2 (27B52), iOS 27.2 SDK; the book layout was run on an iPhone Duo simulator.

Verification for this release:

- Trigger prompts: the expected skill loaded for 15 of 15 prompts in Codex and in Claude Code, after one round of description fixes for prompts 8 and 10.
- Baseline: seven prompts in a clean Codex session without plugins. Two misread the device, four were generic, one found Apple's page by web search.
- Documentation images in `docs/images`, captured from the sample app on the iPhone Duo simulator.
- Not verified: a physical device, the camera accessory, Split View halves, UIKit equivalents.

