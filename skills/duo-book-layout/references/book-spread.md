# `BookSpread`: the two-page recipe

Copy this view into the app. It needs the iOS 27.1 SDK. The same file is built and run in `fixtures/DuoBookSample`.

```swift
import SwiftUI

/// Two pages either side of the fold on the open inner display; one page everywhere else.
///
/// - A fold that runs top to bottom (open in landscape, flat or folded like a book)
///   gives a leading and a trailing page.
/// - A fold that runs side to side gives a top and a bottom page only while it is
///   active (partially folded like a laptop). Flat in portrait stays a single page.
///
/// The fold comes from the division reserved region, asked for with `.includeInactive`
/// so the layout is the same whether the device is flat or partially folded.
///
/// Each page fills its own side of the fold. A vertical bar takes room from one side,
/// so the page next to the bar is the narrower one. Set `matchesPageWidths` only when
/// the content needs two pages of the same width.
@available(iOS 27.1, *)
struct BookSpread<First: View, Second: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var minimumPageWidth: CGFloat = 300
    var minimumPageHeight: CGFloat = 240
    var minimumGutter: CGFloat = 24
    var matchesPageWidths = false
    @ViewBuilder var first: First
    @ViewBuilder var second: Second

    var body: some View {
        GeometryReader { proxy in
            switch arrangement(in: proxy) {
            case .sideBySide(let leading, let gutter, let trailing):
                // Matched pages stay against the fold; the spare room goes to the outer edge.
                let matched = matchesPageWidths ? min(leading, trailing) : nil
                HStack(spacing: 0) {
                    first
                        .frame(width: matched ?? leading)
                        .frame(width: leading, alignment: .trailing)
                    Color.clear.frame(width: gutter)
                    second
                        .frame(width: matched ?? trailing)
                        .frame(width: trailing, alignment: .leading)
                }
            case .stacked(let top, let gutter, let bottom):
                VStack(spacing: 0) {
                    first.frame(height: top)
                    Color.clear.frame(height: gutter)
                    second.frame(height: bottom)
                }
            case .single:
                // Outer display, a Split View half, the inner display flat in portrait.
                // The second page is reached by paging or scrolling.
                first
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private enum Arrangement {
        case sideBySide(leading: CGFloat, gutter: CGFloat, trailing: CGFloat)
        case stacked(top: CGFloat, gutter: CGFloat, bottom: CGFloat)
        case single
    }

    private func arrangement(in proxy: GeometryProxy) -> Arrangement {
        guard horizontalSizeClass == .regular,
              let fold = proxy.reservedRegions(kind: .division, options: .includeInactive).first
        else { return .single }
        let frame = fold.frame

        if frame.height > frame.width {
            // The fold runs top to bottom: pages sit side by side, flat or folded.
            let gutter = max(frame.width, minimumGutter)
            let leading = frame.midX - gutter / 2
            let trailing = proxy.size.width - frame.midX - gutter / 2
            // A side bar makes the two sides differ: the side next to the bar is narrower.
            guard min(leading, trailing) >= minimumPageWidth else { return .single }
            return .sideBySide(leading: leading, gutter: gutter, trailing: trailing)
        }

        // The fold runs side to side: split only while it is active.
        guard fold.isActive else { return .single }
        let top = frame.minY
        let bottom = proxy.size.height - frame.maxY
        guard min(top, bottom) >= minimumPageHeight else { return .single }
        return .stacked(top: top, gutter: frame.height, bottom: bottom)
    }
}
```

## How it decides

1. Regular horizontal size class is required. The outer display and a Split View half are compact, so they get one page.
2. It asks for the division region with `.includeInactive`. Without that option the region disappears when the device is flat and the layout would change as the device folds.
3. A region taller than it is wide is a fold that runs top to bottom: pages go side by side, flat or folded.
4. A region wider than it is tall is a fold that runs side to side. Pages stack above and below it only while it is active, which is the laptop pose. Flat in portrait stays one page.
5. Each page fills its own side of the fold. A side bar makes the sides unequal, so the page beside the bar is narrower. With `matchesPageWidths` set, both pages take the narrower width and stay against the fold.
6. If a page would be narrower than `minimumPageWidth` or shorter than `minimumPageHeight`, it falls back to one page.

## Adapting it

- **Deployment target below iOS 27.1.** Wrap the call site: `if #available(iOS 27.1, *) { BookSpread { … } second: { … } } else { singlePage }`. An iPhone Duo always runs iOS 27.1 or later, so the fallback only serves other devices.
- **Other devices.** Where there is no division region, such as an iPad, the view shows one page. The book layout is specific to the fold. Use a split view or columns for wide displays without one.
- **Backgrounds.** Give each page its own background and let it extend under the bars with `.ignoresSafeArea()` on the background only. Keep text and controls inside the safe area.
- **The gutter.** The region already includes margins around the physical fold. Do not draw text, dividers that need to be read, or controls inside it. A soft shadow is fine.
- **UIKit.** `UIView.reservedRegions(kind:options:)` returns the same regions for a view. Lay out two child views from the region's frame in `viewDidLayoutSubviews`, with the same rules as above.
- **Right-to-left.** `reservedRegions(kind:options:layoutDirectionBehavior:)` mirrors by default (iOS 27.2 SDK), so the fold's frame is measured from the leading edge and the recipe needs no branch on layout direction. Run in Arabic on the simulator, the first page was on the right at 371 pt, beside the bar, and the second on the left at 455 pt. Pass `.fixed` only when a frame from the left edge is needed.
- **Regions arrive after the first layout pass.** Read them during layout, as the recipe does. Do not cache a frame.
