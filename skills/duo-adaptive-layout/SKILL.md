---
name: duo-adaptive-layout
description: Use when an iPhone Duo screen must work on both displays — one column on the outer display and more on the inner one — when the app loses its place, selection, scroll position or input on closing or opening the device, when content sits under the side bar, or when the app looks stretched or wrong in Split View. Covers size classes, split views, two columns, a tab sidebar, asymmetric safe areas and continuity. Layout around the fold itself is in duo-fold-and-poses.
---

# Layout across the two displays of iPhone Duo

The same app runs on a narrow outer display and a wide inner one, and people switch between them mid-task. This skill covers the layout that grows from one to the other and keeps its state.

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

## The model

Design two layouts, chosen by horizontal size class:

| Size class | Where | Layout |
|---|---|---|
| Compact | Outer display; either half of Split View | The iPhone layout: one column, navigation by push |
| Regular | Inner display, full screen | The same content with more of the hierarchy visible |

The regular layout is an extension of the compact one. Apple's own wording for the inner display is that it should look like a natural extension of the app's iPad layout; what differs from an iPad is everything around it: bars on the side, the fold, no free resizing, and a compact layout that is one fold away.

Never choose by device, idiom or orientation. The inner display ignores the app's supported orientations, and a Split View half on the inner display is compact.

## Runbook

1. **Find what the screen can show next to itself.** A parent list beside its detail, a second column of the same content, or navigation as a sidebar.
2. **Pick the container** from the table below. Prefer a system container; it handles both displays, the side bar and the fold.
3. **Make state independent of layout.** Selection, navigation path, scroll position and draft input live in the model or in scene storage, not in the view that happens to be on screen.
4. **Inset each side on its own.** The side bar makes one horizontal inset larger; in Split View it changes sides.
5. **Check the compact layout in Split View**, not only on the outer display.
6. **Verify** the open-and-close round trip with `duo-pose-testing`.

## Containers

| The screen is | Compact | Regular | Use |
|---|---|---|---|
| A list and its detail | Push | List and detail side by side | `NavigationSplitView` / `UISplitViewController` |
| Top-level sections | Tab bar on the side | Optional sidebar, for information-dense apps | `TabView` with the sidebar-adaptable style |
| A page of content | One column | Two pages or two columns | `duo-book-layout`, or a column count from the available width |
| Content plus a companion (player and queue, map and results) | One, with the other reachable | Both | `ArrangementView`; see `duo-fold-and-poses` |
| One visual surface (map, canvas, video) | Full | Full, with controls clear of the fold | Span, with the reason stated |

Most apps keep the tab bar on the inner display. Offer the sidebar where there are many destinations.

```swift
import SwiftUI

// Sections: a tab bar outside, an optional sidebar inside.
struct RootView: View {
    var body: some View {
        TabView {
            Tab("Library", systemImage: "books.vertical") { LibraryView() }
            Tab("Search", systemImage: "magnifyingglass") { Text("Search") }
        }
        .tabViewStyle(.sidebarAdaptable)
        .defaultTabBarPlacement(.sidebar)
    }
}

// List and detail: push when compact, side by side when regular.
struct LibraryView: View {
    // Selection lives outside the columns, so it survives the change of layout.
    @SceneStorage("library.selection") private var selection: String?
    private let items = ["Notes", "Drafts", "Archive"]

    var body: some View {
        NavigationSplitView {
            List(items, id: \.self, selection: $selection) { Text($0) }
                .navigationTitle("Library")
        } detail: {
            if let selection {
                DetailView(title: selection)
            } else {
                ContentUnavailableView("Nothing selected", systemImage: "doc")
            }
        }
    }
}

// Custom content: decide from the size class and the space offered, never from the device.
struct DetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let title: String

    var body: some View {
        ScrollView {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 16),
                                count: horizontalSizeClass == .regular ? 2 : 1)
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.quaternary)
                        .frame(height: 120)
                        .overlay { Text("Card \(index + 1)") }
                }
            }
            .padding()   // stays inside the safe area, so it clears the side bar on its own
        }
        .navigationTitle(title)
    }
}
```

## Safe areas are asymmetric

Measured on the simulator with a build against the 27.1 SDK: closed, the trailing inset was 84 pt and the leading inset 0; open in landscape, the same; open in portrait, both were 0 and the bars were horizontal. Closed in landscape with the device turned the other way, the 84 pt were on the leading side. The numbers are an illustration, not constants.

- SwiftUI keeps content inside the safe area by default. Let only backgrounds ignore it.
- Do not center on the display or compute `width - inset * 2`. Use the area the view is given.
- In UIKit, constrain to `safeAreaLayoutGuide` or `layoutMarginsGuide`, each edge separately, or use `bounds.inset(by: safeAreaInsets)`.
- The bar stays on the hardware side in right-to-left languages, so the larger inset is not always the trailing one. In Split View it is on the app's outer edge.
- Full-width content suits only visual, non-scrolling screens whose controls the bar does not cover. A full-width background under inset content is fine.

## Continuity

People open the device to see more and close it to keep going on the move.

- Opening: the item on screen stays selected and the new column shows its context.
- Closing: the outer display shows the detail the person was in, at the same scroll position, not the root.
- Keep drafts, selection and the navigation path in scene storage or the model.
- A sheet, alert or menu that is open should survive the change. Standard ones do.
- Do not present different features on the two displays. Show more of the same hierarchy inside.

## Other things the inner display changes

- **Split View.** Two apps share the inner display 50/50. Each half is compact width with the bar on that app's outer edge. Test both halves.
- **Corners.** Display corners differ between the two displays. Shapes that hug the screen edge should take their radius from the container rather than a constant.
- **Games and fixed-orientation apps.** An orientation lock applies on the outer display only. Fill the inner display in every pose; change the aspect ratio rather than letterboxing.
- **A second window** is possible on the inner display only. See `duo-scenes-and-camera`.

## Checklist

- [ ] Layout is chosen by size class and available space only.
- [ ] The regular layout shows more of the same hierarchy, not a stretched phone screen.
- [ ] Left and right insets are handled separately; verified in both Split View halves.
- [ ] Open → close → open keeps the item, the scroll position and the input.
- [ ] Both displays offer the same functions.
