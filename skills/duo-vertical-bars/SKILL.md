---
name: duo-vertical-bars
description: Use when toolbar, navigation bar or tab bar items on iPhone Duo should sit on the side of the screen, when a toolbar button or action disappears, goes missing or ends up in a menu when the device is closed or in another pose, when a custom bar stays horizontal, or when deciding which items stay visible. Covers which bars go vertical, item order, titles and symbols, overflow priority, per-item axis, compression and when to turn vertical bars off.
---

# Vertical bars on iPhone Duo

On iPhone Duo the system moves navigation, toolbar and tab bar items into one vertical bar along the side. Apps get this by using standard bars; the work is making items ready for it and deciding what survives when space runs out.

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

## When bars are vertical

Needs a build against the iOS 27.1 SDK. Earlier builds never show a vertical bar.

In the iOS 27.2 SDK the APIs come from two releases. `topBarPinnedTrailing`, `visibilityPriority` and `ToolbarOverflowMenu` are available from iOS 27.0. `axisBehavior`, `toolbarVerticalCompressionBehavior`, `toolbarVerticalBehavior` and `toolbarVerticalEdge` need iOS 27.1. An app with a lower deployment target wraps each in an availability check and keeps its horizontal bars on older systems.

| Context | Bars |
|---|---|
| Outer display, any orientation | Vertical |
| Inner display, landscape | Vertical for the trailing content |
| Inner display, portrait | Horizontal |
| Split view with several columns | Horizontal for sidebar and content columns, vertical for the detail column |
| Inspector | Horizontal |
| Sheet on the outer display | Vertical by default |
| Sheet on the inner display | Horizontal when centered or leading, vertical when trailing |
| Split View multitasking | Each app's bar on its own outer edge |

The bar stays on the hardware side: it does not flip for right-to-left languages. The status bar and the Dynamic Island share that edge.

A vertical bar does not replace the top bar. In every vertical pose run on the simulator, a horizontal bar stayed at the top with the title and the items that cannot go vertical.

## Runbook

1. **Confirm the bar is system-managed.** Items join the vertical bar only from `.toolbar` inside `NavigationStack`, `NavigationSplitView` or `TabView`, or from items set on a view controller inside `UINavigationController` or `UITabBarController`. A hand-made `UIToolbar`, `UINavigationBar`, `UITabBar` or a row of buttons stays where it is.
2. **Give every item a title and a symbol.** The vertical bar shows the symbol; the overflow menu shows both. An item with a title only, or with a custom view, is not presented vertically.
3. **Order the items.** Top of the bar: Back or Close. Then the prominent action, such as Done. Then everything else in its groups. Use semantic placements rather than position.
4. **Give each action a role** from the table in "What stays visible": one pinned action per screen at most, the frequent ones high, the occasional ones low, the rare ones in the overflow menu. Marking everything high is the same as marking nothing.
5. **Decide what compresses first** when both a toolbar and a tab bar compete: navigation-focused screens keep the tabs (the default); task-focused screens keep the toolbar items.
6. **Fix the exceptions** with a per-item axis, or turn vertical bars off for one flow.
7. **Verify** closed in both orientations, open in landscape, and in both Split View halves with `duo-pose-testing`. In each, open the overflow menu and read it, then repeat with search active, with the keyboard up and at a larger text size.

## What stays visible

| Role of the action | API | What the system does |
|---|---|---|
| The screen's main action: Save, Done, Share | `placement: .topBarPinnedTrailing` | Keeps it in the bar. It moves to the overflow menu only while search is active and there is no room |
| Used all the time | `.visibilityPriority(.high)` | Moves it last |
| Everything else | automatic | Moves the last declared item first |
| Occasional: archive, delete | `.visibilityPriority(.low)` | Moves it first; it still shows when there is room |
| Rare | `ToolbarOverflowMenu` | Always in the overflow menu, in every pose |

Priority goes on the `ToolbarItem` or `ToolbarItemGroup`, not on the button inside. `ToolbarItemVisibilityPriority(higherThan:)` and `(lowerThan:)` make steps between the three levels.

When a toolbar and a tab bar share the vertical bar, one of them gives up space first. The value names what is kept:

| `toolbarVerticalCompressionBehavior` | Keeps | Gives up first |
|---|---|---|
| `.automatic` (on iOS, the same as `.prefersTabBar`) | The tabs | Toolbar items move to the overflow menu |
| `.prefersToolbarItems` | The toolbar items | The tab bar collapses to one button that opens the list of tabs |

It is a preference for one screen, not a promise that everything fits.

Measured on the iPhone Duo simulator, iOS 27.2, with one pinned action, five symbol items (one high, one low), one text-only item and four tabs:

| Pose | Automatic | `.prefersToolbarItems` |
|---|---|---|
| Closed, portrait | Pinned and 2 items; 3 in overflow; all tabs | not run |
| Closed, landscape | Pinned only; 5 in overflow; all tabs | Pinned and 3 items; 2 in overflow; tabs in one button |
| Open, landscape | Pinned and 3 items; 2 in overflow; all tabs | not run |
| Open, portrait | Horizontal bars, every item visible, the inline title cut to an ellipsis | not run |

The high item was the last to move and the low one the first. With every priority automatic, the items declared last moved first. The counts change with the number of tabs and items: they show the mechanism, not a budget.

## Items that stay horizontal

- By default a symbol item can go in either bar. A text-only item or a custom view stays in the horizontal bar.
- `.axisBehavior(.horizontalOnly)` holds a symbol item in the horizontal bar. The SDK documents that such an item is not shown where no horizontal bar is present, so confirm the action is reachable in every pose the app supports.
- `.axisBehavior(.verticalPreferred)` lets a custom view into the vertical bar. It states a preference; the view itself must fit the bar's width.

## Turning vertical bars off

`.toolbarVerticalBehavior(.disabled)` sends bar content back to the top and bottom bars. Measured closed in landscape: the content area went from 594 × 350 pt to 678 × 319 pt, and `toolbarVerticalEdge` read `nil`.

- Treat it as a stable choice. Do not switch it as people navigate or from a view's state; the bars and the safe area animate across the screen each time.
- To hide bars on one screen, use `toolbarVisibility(_:for:)` instead.
- The container decides whose value counts: a navigation stack uses its top view, a tab view its selected tab, a navigation split view its trailing-most column. A sheet resolves its own.

## SwiftUI

```swift
import SwiftUI

@available(iOS 27.1, *)
struct DocumentScreen: View {
    // .leading or .trailing where the system prefers a vertical bar; nil where it never uses one.
    @Environment(\.toolbarVerticalEdge) private var barEdge

    var body: some View {
        NavigationStack {
            Text(barEdge == nil ? "Horizontal bars" : "Bar on the side")
                .navigationTitle("Document")
                .toolbar {
                    // A custom Close replaces Back at the top of the bar.
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", systemImage: "xmark") { }
                    }
                    // The screen's main action: pinned right after navigation.
                    ToolbarItem(placement: .topBarPinnedTrailing) {
                        Button("Done", systemImage: "checkmark") { }
                    }
                    // Kept visible longer when space runs out.
                    ToolbarItem {
                        Button("Share", systemImage: "square.and.arrow.up") { }
                    }
                    .visibilityPriority(.high)
                    // A step below high, still above the automatic items.
                    ToolbarItem {
                        Button("Search", systemImage: "magnifyingglass") { }
                    }
                    .visibilityPriority(ToolbarItemVisibilityPriority(lowerThan: .high))
                    // First to go to the overflow menu; shown when there is room.
                    ToolbarItem {
                        Button("Archive", systemImage: "archivebox") { }
                    }
                    .visibilityPriority(.low)
                    // Grouped items get their spacing from the system.
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("Highlight", systemImage: "highlighter") { }
                        Button("Note", systemImage: "note.text") { }
                    }
                    // An item that swaps between a word and a symbol stays horizontal.
                    ToolbarItem {
                        Button("Select") { }
                    }
                    .axisBehavior(.horizontalOnly)
                    // Rarely used actions go straight to the system overflow menu.
                    ToolbarOverflowMenu {
                        Button("Print", systemImage: "printer") { }
                    }
                }
                // This screen is about a task: keep the toolbar, compress the tab bar.
                .toolbarVerticalCompressionBehavior(.prefersToolbarItems)
        }
    }
}

@available(iOS 27.1, *)
struct KeypadScreen: View {
    var body: some View {
        NavigationStack {
            Text("A bottom-heavy, single-page layout")
                // The overflow menu can also be filled from a view modifier.
                .toolbarOverflowMenu {
                    Button("History", systemImage: "clock") { }
                }
                // Horizontal bars for this flow. Set once; never toggled from state.
                .toolbarVerticalBehavior(.disabled)
        }
    }
}
```

UIKit names for the same things: `UINavigationItem.pinnedTrailingGroup` and `leadingItemGroups`, `UIBarButtonItem.axisBehavior` and `visibilityPriority`, `UINavigationItem.additionalOverflowItems` and `verticalBarCompressionBehavior`, `UIViewController.preferredVerticalBarBehavior`, and the read-only trait `verticalBarEdge`. Confirm each in the installed SDK.

## Design rules

- Do not override the default placement without a reason. The side bar is one of the defining patterns of the device.
- Keep items in the same order and relative position in every pose so people do not relearn where actions are.
- Prefer symbols. Text buttons stay in a horizontal bar and cost vertical space; keep text only where it carries information, such as a total.
- Use a badge instead of an inline count.
- Group related items with `ToolbarItemGroup` or `UIBarButtonItemGroup` and add no spacing of your own.
- Controls that belong to another content area stay with that area. In a list-and-detail screen, the list's controls stay above the list rather than moving to the side.
- Merge a custom "more" menu into the system overflow menu, and keep the ellipsis symbol for overflow only. A second menu in the same bar gets a different symbol.
- Use a label with a title and a symbol even where only the symbol shows: the overflow menu and VoiceOver read the title.
- A screen that is one visual, non-scrolling page with heavy bottom controls, or a sheet whose only item is Close, can be better with horizontal bars. A calculator is the standard example.
- If a hero or background image should run under the bar, extend the background and keep the content inset.

## Common problems

| Symptom | Cause | Fix |
|---|---|---|
| Items stay in a horizontal row | Bar is not system-managed, or the build uses an older SDK | Host items in a navigation container; build with iOS 27.1 or later |
| One item never goes vertical | Title only, or a custom view | Add a symbol, or opt the custom view in with `.axisBehavior(.verticalPreferred)` and make it fit the bar's fixed width |
| Important action lands in the overflow menu | Default order: last declared goes first | Pin the screen's one main action; raise the `visibilityPriority` of frequent ones and lower the rest |
| The pinned action goes to the overflow menu | Search is active and the bar is out of room | Expected. Keep few items on screens with search |
| An item is missing in one pose, and not in the overflow menu either | `.horizontalOnly` where no horizontal bar is present | Give it a symbol and let it go vertical |
| The title is cut to an ellipsis with the device open in portrait | Every item fits the horizontal bar and squeezes the title | Move rare actions into `ToolbarOverflowMenu` |
| Bars jump between the side and the top while navigating | Vertical behavior set per view or from state | Choose once per flow; hide bars with `toolbarVisibility(_:for:)` |
| Tab bar disappears on a task screen, or actions disappear on a navigation screen | Compression preference | Set the compression behavior for that screen |
| Content hidden under the bar, or a gap on one side | Symmetric inset math | Inset each side on its own from the safe area |
| A system toggle ignores custom tint or opacity in the bar | System items are drawn by the bar | Use a custom view opted into the vertical axis when state must be shown your way |
