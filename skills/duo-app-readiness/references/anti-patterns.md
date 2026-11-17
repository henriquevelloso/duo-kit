# Assumptions that break on iPhone Duo

Search the app sources for each pattern. A hit is a lead, not a verdict: read the surrounding code and decide whether it drives layout.

| Search for | Why it breaks on iPhone Duo | Use instead |
|---|---|---|
| `UIScreen.main` | Ambiguous on a device with two displays, and deprecated. | The view's or scene's geometry: `GeometryReader`, the environment, `window?.windowScene?.screen`, `traitCollection.displayScale`. |
| `userInterfaceIdiom`, `UIDevice.current.model`, model identifiers such as `iPhone19,` | The Duo is an iPhone with regular width inside. Idiom and model say nothing about the space a view has, and fail in Split View and iPhone Mirroring. | Size classes and the space actually proposed to the view. |
| `UIInterfaceOrientation`, `UIDevice.current.orientation`, `supportedInterfaceOrientations`, `verticalSizeClass == .compact` used as "landscape" | The inner display does not honor supported orientations, and landscape does not imply compact height there. | Size classes for layout; aspect ratio of the available space when shape matters. |
| `safeAreaInsets.left * 2`, `.leading` and `.trailing` insets assumed equal, content centered on `bounds.midX` | A vertical bar makes the two sides differ, and the larger inset switches sides in Split View. | `bounds.inset(by: safeAreaInsets)`, `safeAreaLayoutGuide`, each side handled alone. |
| `UIToolbar(`, `UINavigationBar(`, `UITabBar(` created by hand; a hand-built `HStack` of buttons pinned to the bottom | Only system-managed bars move to the side and avoid the fold. | `.toolbar` inside `NavigationStack`, `NavigationSplitView` or `TabView`; items set on a view controller inside `UINavigationController` or `UITabBarController`. |
| `.frame(width:` with a literal that matches an iPhone width; `UIScreen.main.bounds.width` | Fixed widths tied to one display. | Sizes relative to the container. |
| `openWindow(`, `requestSceneSessionActivation`, `activateSceneSession` | Only the inner display can create a second window. | Gate the affordance and handle the failure; see `duo-scenes-and-camera`. |
| `UIRequiresFullScreen`, missing launch screen configuration | The app still resizes when the device opens or closes, and uploads built with the iOS 27 SDK need a launch screen. | Confirm the current App Store requirements before changing these keys. |
| `onHingeChange`, `UIHingeInteraction` feeding sizes or stack axes | The hinge is for effects and interactions. | Reserved regions and arrangement views; see `duo-fold-and-poses`. |

Also read by eye, because no search finds them:

- Screens that only stretch the phone layout on the inner display.
- Different features or a different hierarchy between the two displays.
- Controls that disappear in one pose.
- Toolbar items with a symbol but no title, or with text only.

## Report format

```text
SDK: iOS <version> (vertical bars and fold APIs: available / not available)

Hits
  path/File.swift:42  UIScreen.main.bounds   breaks on Duo   width drives a grid
  path/Other.swift:10 userInterfaceIdiom     fine            analytics only

Screens
  Library       duo-adaptive-layout, duo-vertical-bars
  Reader        duo-book-layout
  Player        duo-fold-and-poses

To verify on the simulator: <poses and screens>
```
