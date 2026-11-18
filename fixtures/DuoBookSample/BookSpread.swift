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
