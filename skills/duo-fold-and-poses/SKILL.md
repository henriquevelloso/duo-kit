---
name: duo-fold-and-poses
description: Use when content or controls on iPhone Duo land in the fold or under the inner camera, when an app should adapt to being partially folded like a book or a laptop or standing like a tent, or when choosing between reserved regions, arrangement views and the hinge. Covers displacement rules, ReservedRegion, ArrangementView split and overlay, grids across the fold, and hinge-driven effects. Not for toolbar items that go missing (duo-vertical-bars) or state lost when the device opens or closes (duo-adaptive-layout).
---

# The fold and the poses of iPhone Duo

When iPhone Duo is partially folded, the inner display bends through the middle and becomes two usable areas. This skill covers keeping an interface usable there: what the system does for you, and what custom views must do.

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

## Reserved regions

A reserved region is part of the display that content should stay out of. A view asks which ones overlap it.

| Kind | What it is | Active when |
|---|---|---|
| Division | The fold | Only while the device is partially folded. Flat or closed, it is inactive and a default query does not return it. |
| Occlusion | The inner front camera | Only while that camera is in use |

The outer display's camera is always there; the system accounts for it together with the side bar.

A region gives a `frame` in the view's own coordinates, `margins` that are already included in that frame, and `isActive`. On the simulator the fold's frame was about 40 pt across, flat or folded. Never hard-code that or the middle of the screen.

## Poses and what they ask for

| Pose | The fold runs | Layout |
|---|---|---|
| Open flat | — (inactive) | Regular-width layout; see `duo-adaptive-layout`. Content screens: `duo-book-layout`. |
| Partially folded, like a book | top to bottom | Two sides. Keep each view on one side. Transient elements go to the trailing side, where they will be when the device closes. |
| Partially folded, like a laptop | side to side | Top and bottom. What is watched goes on top; what is touched goes on the bottom, which rests on the table. |
| Standing like a tent, closed | — | The outer display in landscape: compact width and height. Glanceable content. |

There is no pose value to read. Layout comes from size classes and regions. The hinge is for effects only.

## Displacement rules

- Move, resize or reorganize. Never hide a function because of a pose.
- Move elements that work together as a group; move independent elements alone.
- Move as little and as short a distance as possible. Large jumps are hard to follow.
- Continuously scrolling content does not move: it already adapts by scrolling.
- Let purpose choose the destination, as in the pose table.
- Keep things in context: a search field stays with the view it searches.

## What already adapts

Sheets, alerts, action sheets, menus, popovers and toolbar buttons move off the fold by themselves, and standard split views rebalance their columns to the two sides. Use them. Custom containers are the ones that need the code below.

## Choosing the tool

| Need | Use |
|---|---|
| Navigation, lists and detail, modals | Standard containers |
| Two views that share the screen and follow the fold | `ArrangementView`, split style |
| Controls layered over content that should separate when folded | `ArrangementView`, overlay style |
| A custom view that must dodge the fold or the camera | `reservedRegions` |
| Two pages that must not move between flat and folded | `duo-book-layout` |
| An effect that follows the fold angle | `onHingeChange` |

## Arrangement views

An arrangement holds a primary and a secondary view and places them by size, shape and active regions.

- **Split.** Side by side when wider than tall, stacked when taller than wide, adjusted to the fold. Replaces a layout you would have built with `HStack` or `VStack`.
- **Overlay.** The primary is the foreground: over the secondary while closed or flat. Partially folded, the primary moves to the trailing or bottom area and the secondary to the leading or top. Replaces a `ZStack` of controls over content.
- Limit the axes to control when the secondary appears. A split that cannot use an allowed axis shows the primary only. The default split did the same closed in landscape, so nothing essential may live only in the secondary.
- `splitArrangementLayoutRatio` on a child asks for a share of the split: one ratio, or a minimum, ideal and maximum per axis. It is a preference; the fold still decides.
- A child reads `splitArrangementAxis` or `overlayArrangementZIndex` to change its own presentation, such as a compact card while overlaid and full detail once separated. Keep the same functions in both.
- Put navigation around an arrangement, not inside it. Do not place an arrangement inside a list, a scroll view or a navigation split view.

Measured on the simulator (iOS 27.2): flat, a horizontal split divided the content area into two equal halves; partially folded, the boundary moved onto the fold. Expect that small shift. Closed in portrait the split stacked into two equal halves; closed in landscape only the primary showed. In an overlay the primary's index was 1 while laid over the secondary and 0 once the fold separated them; the secondary's stayed 0.

```swift
import SwiftUI

// Split: two views that share the screen and follow the fold.
@available(iOS 27.1, *)
struct LessonScreen: View {
    var body: some View {
        NavigationStack {
            ArrangementView {
                Text("Video")          // primary; asks for about 60% of the split
                    .splitArrangementLayoutRatio(0.6)
            } secondary: {
                Transcript()           // secondary
            }
            .arrangementViewStyle(.split.axes(.horizontal))
            .navigationTitle("Lesson")
        }
    }
}

@available(iOS 27.1, *)
struct Transcript: View {
    @Environment(\.splitArrangementAxis) private var axis   // nil outside a split arrangement

    var body: some View {
        Text(axis == .vertical ? "Transcript, short" : "Transcript, with timestamps")
    }
}

// Overlay: controls over content, separated when partially folded.
@available(iOS 27.1, *)
struct ReaderScreen: View {
    var body: some View {
        NavigationStack {
            ArrangementView {
                PlaybackControls()     // primary: on top, or on the trailing/bottom side when folded
            } secondary: {
                Text("Article")        // secondary: behind, or on the leading/top side when folded
            }
            .arrangementViewStyle(.overlay)
        }
    }
}

@available(iOS 27.1, *)
struct PlaybackControls: View {
    // Above 0 while this view is laid over the other; 0 once the fold separates them.
    @Environment(\.overlayArrangementZIndex) private var zIndex

    var body: some View {
        Label(zIndex > 0 ? "Play" : "Play, with the queue", systemImage: "play.fill")
            .padding()
    }
}
```

## Reserved regions in a custom view

```swift
import SwiftUI

// A floating control that leaves the fold and the camera alone.
@available(iOS 27.1, *)
struct FloatingActionLayer: View {
    var body: some View {
        GeometryReader { proxy in
            let blocked = proxy.reservedRegions(kind: .division).map(\.frame)
                + proxy.reservedRegions(kind: .occlusion).map(\.frame)
            let size = CGSize(width: 64, height: 64)
            // Preferred spot: bottom center. If a region covers it, slide to the trailing side of that region.
            let preferred = CGRect(x: proxy.size.width / 2 - size.width / 2,
                                   y: proxy.size.height - size.height - 16,
                                   width: size.width, height: size.height)
            let obstacle = blocked.first { $0.intersects(preferred) }
            let origin = obstacle.map { CGPoint(x: $0.maxX + 16, y: preferred.minY) } ?? preferred.origin

            Button("Add", systemImage: "plus") { }
                .labelStyle(.iconOnly)
                .frame(width: size.width, height: size.height)
                .background(.tint, in: .circle)
                .foregroundStyle(.white)
                .position(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
                .animation(.smooth, value: origin)
        }
    }
}
```

Notes for custom views:

- Query during layout; regions arrive after the first layout pass and change with the pose. Do not cache them.
- A view only receives regions that overlap it. A small view away from the fold gets none.
- Pass `.includeInactive` only when a layout decision must be the same flat and folded, such as a column count.
- UIKit: `view.reservedRegions(kind:options:)` returns `UIView.ReservedRegion` values with the same properties.

## Grids across the fold

- Keep every item on one side while folded: keep the outer margins and widen the spacing at the fold.
- Prefer an even number of columns whenever a fold exists, active or not, so the gap can sit on it.
- Place the gap from the region's frame. An adaptive grid may choose an odd count; set the count yourself where the fold matters.

## The hinge

The hinge reports a status (closed, partially open, fully open) and an angle. Use it for an effect or an interaction that follows the fold, such as a page that lifts as the device opens. Never size or place views from it.

```swift
import SwiftUI

@available(iOS 27.1, *)
struct CoverView: View {
    @State private var lift = Angle.zero

    var body: some View {
        Image(systemName: "book.closed.fill")
            .font(.system(size: 80))
            .rotation3DEffect(lift, axis: (x: 0, y: 1, z: 0))
            .onHingeChange { _, context in
                if let hinge = context.hinge, hinge.status == .partiallyOpen {
                    lift = .degrees(180 - hinge.angle.degrees)   // an effect, not a layout input
                } else {
                    lift = .zero                                 // no hinge, closed or flat: reset
                }
            }
    }
}
```

`context.hinge` is `nil` where there is no hinge. Reset anything hinge-driven whenever the device is not partially open. UIKit delivers the same state through `UIHingeInteraction`.

## Checklist

- [ ] Nothing interactive, and no text or image that must be read as one piece, crosses the active fold.
- [ ] Every function is reachable in every pose.
- [ ] Custom containers read regions; nothing uses the midpoint of the screen or a device check.
- [ ] Laptop pose puts content above and controls below.
- [ ] The hinge drives effects only, and its state resets.
- [ ] Verified flat, like a book and like a laptop with `duo-pose-testing`.
