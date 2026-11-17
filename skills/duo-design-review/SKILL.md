---
name: duo-design-review
description: Use to review a design, mock-up, prototype or set of screenshots for iPhone Duo pose by pose — closed, open in portrait and landscape, partially folded like a book or a laptop, standing, and Split View — against Apple's design guidance and this plugin's book-layout convention. Produces a findings table with severity. It judges; it does not capture screenshots or write code.
argument-hint: "[screen or flow] [images or design link]"
---

# Design review for iPhone Duo

Judge one screen or flow in every pose it can appear in. The usual failure is a design drawn for one state: a phone screen stretched across the inner display, or a tablet layout that ignores the fold and the side bars.

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

## Before reviewing

1. Get the material for as many poses as exist: mock-ups, or captures from `duo-pose-testing`. List which poses you were given. A pose with no material is reported as "not reviewed", never assumed fine.
2. Ask what the screen is for and which one or two actions matter most. Overflow and displacement decisions depend on it.
3. Check which SDK the app builds with. Side bars exist only with the iOS 27.1 SDK.

## Principles to judge against

Paraphrased from Apple's "Designing for iPhone Duo" and the September 2026 design tech talk; links are in `duo-app-readiness`.

1. **One app, two widths.** A compact-width layout for the outer display and a regular-width layout for the inner one. The regular layout extends the compact one: more of the hierarchy, a second column, a sidebar. It is not a different app.
2. **Same functions everywhere.** Controls may move, shrink or go into the overflow menu. No function disappears because of a pose.
3. **Continuity.** Opening or closing mid-task keeps the place, the selection and the input.
4. **Controls on the side.** Navigation, toolbar and tab bar items sit in a vertical bar, except on the inner display in portrait. Keep their order and relative position stable between poses. Do not override the placement without a reason.
5. **Asymmetric space.** Content is offset from the side bar, not centered on the display. Full-width layouts are for visual, non-scrolling screens whose controls are not covered.
6. **The fold divides.** Partially folded, nothing interactive and no continuous image or line of text crosses the fold. Scrolling content is exempt. Make small moves; do not rearrange the screen.
7. **Purpose picks the side.** Like a book: transient elements go to the trailing side, where they will be when the device closes. Like a laptop: what is watched goes above the fold, what is touched goes below.
8. **System first.** Standard split views, sheets, alerts, menus and bars already adapt. Custom versions must do the same work.
9. **House convention.** Open in landscape, content screens use two pages either side of the fold (`duo-book-layout`). A screen that spans instead needs a stated reason.

## Pose checklist

Detailed questions per pose are in [references/pose-checklist.md](references/pose-checklist.md). The poses:

| # | Pose | Width | Key question |
|---|---|---|---|
| 1 | Closed, portrait | compact | Does the compact layout work with a bar on the side and a camera in the corner? |
| 2 | Closed, landscape or standing | compact, short | Does it survive very little height? What overflows? |
| 3 | Open, landscape | regular | Is the extra width used, and split at the fold where content allows? |
| 4 | Partially folded, like a book | regular | Is anything on the fold? Did anything jump compared with pose 3? |
| 5 | Open, portrait | regular | Does it work with horizontal bars and a tall canvas? |
| 6 | Partially folded, like a laptop | regular | Is content above the fold and control below? |
| 7 | Split View, either half | compact | Does the compact layout hold with the bar on either side? |
| 8 | Transitions | — | Is anything lost going 1 → 3 → 1? |

## Severity

- **Blocker:** a function is unreachable in a pose; interactive content sits on the active fold or under the camera; state is lost on open or close.
- **Major:** the inner display only stretches the phone layout; controls change order between poses; a custom bar does not move to the side; the layout jumps when folding.
- **Minor:** uneven columns across the fold; poor overflow priority; spare space badly placed; a span without a stated reason.
- **Note:** a taste point or an improvement that the guidance does not require.

## Output

```text
Screen: <name>     Material: <poses provided>     Not reviewed: <poses>

| Pose | Finding | Severity | Principle | Suggested change |
|---|---|---|---|---|

Summary: <two sentences>
Must fix before shipping: <blockers>
To verify on a simulator or device: <items a still image cannot show>
```

Separate what you saw from what you infer. If a judgment depends on behavior a still cannot show (transitions, overflow menus, fold avoidance by system components), say so and send it to `duo-pose-testing`. For supporting examples from shipped apps, use `duo-design-references`.
