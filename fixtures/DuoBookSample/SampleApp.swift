import SwiftUI

@main
struct DuoBookSampleApp: App {
    var body: some Scene {
        WindowGroup {
            switch UserDefaults.standard.string(forKey: "mode") {
            case "arrangement": ArrangementScreen()
            case "reader": ReaderDemo()
            case "naive": NaiveDemo()
            case "toolbar": ToolbarLab()
            case "split": SplitLab()
            case "overlay": OverlayLab()
            default: BookScreen()
            }
        }
    }
}

// `-matched YES` gives both pages the width of the narrower side.
struct BookScreen: View {
    var body: some View {
        NavigationStack {
            BookSpread(matchesPageWidths: UserDefaults.standard.bool(forKey: "matched")) {
                PageView(number: 1, tint: .orange)
            } second: {
                PageView(number: 2, tint: .teal)
            }
            .overlay { Probe() }
            .navigationTitle("Book")
            .toolbar {
                ToolbarItem { Button("Bookmark", systemImage: "bookmark") {} }
                ToolbarItem { Button("Search", systemImage: "magnifyingglass") {} }
            }
        }
    }
}

struct ArrangementScreen: View {
    var body: some View {
        NavigationStack {
            ArrangementView {
                PageView(number: 1, tint: .orange)
            } secondary: {
                PageView(number: 2, tint: .teal)
            }
            .arrangementViewStyle(.split.axes(.horizontal))
            .overlay { Probe() }
            .navigationTitle("Arrangement")
            .toolbar {
                ToolbarItem { Button("Bookmark", systemImage: "bookmark") {} }
            }
        }
    }
}

struct PageView: View {
    let number: Int
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 8) {
                Text("Page \(number)").font(.title.bold())
                Text("\(Int(proxy.size.width)) × \(Int(proxy.size.height)) pt")
                    .font(.footnote.monospaced())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(tint.opacity(0.25))
            .border(tint, width: 2)
        }
    }
}

/// Prints what the layout system reports, so screenshots double as measurements.
struct Probe: View {
    @Environment(\.horizontalSizeClass) private var horizontal
    @Environment(\.verticalSizeClass) private var vertical
    @Environment(\.toolbarVerticalEdge) private var barEdge
    @Environment(\.layoutDirection) private var direction
    @State private var hinge = "hinge: –"

    var body: some View {
        GeometryReader { proxy in
            let all = proxy.reservedRegions(kind: .division, options: .includeInactive)
            let active = proxy.reservedRegions(kind: .division)
            let insets = proxy.safeAreaInsets
            // `.fixed` reports the fold from the left edge; the default mirrors it for right-to-left.
            let unmirrored = proxy.reservedRegions(kind: .division, options: .includeInactive, layoutDirectionBehavior: .fixed)
            VStack(alignment: .leading, spacing: 2) {
                Text("direction:\(direction == .rightToLeft ? "RTL" : "LTR")  fold from the left: " + unmirrored.map { "x\(Int($0.frame.minX))" }.joined(separator: ","))
                Text("size \(Int(proxy.size.width))×\(Int(proxy.size.height))  h:\(name(horizontal)) v:\(name(vertical))")
                Text("insets L\(Int(insets.leading)) T\(Int(insets.top)) R\(Int(insets.trailing)) B\(Int(insets.bottom))  bar:\(barEdge.map { $0 == .leading ? "leading" : "trailing" } ?? "none")")
                Text("division all:\(all.count) active:\(active.count)  " + all.map { "x\(Int($0.frame.minX)) y\(Int($0.frame.minY)) w\(Int($0.frame.width)) h\(Int($0.frame.height)) \($0.isActive ? "ACTIVE" : "inactive")" }.joined(separator: "; "))
                Text(hinge)
            }
            .font(.caption2.monospaced())
            .padding(6)
            .background(.black.opacity(0.75))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .allowsHitTesting(false)
        .onHingeChange { _, new in
            if let value = new.hinge {
                hinge = "hinge: \(value.status) \(Int(value.angle.degrees))°"
            } else {
                hinge = "hinge: none"
            }
        }
    }

    private func name(_ sizeClass: UserInterfaceSizeClass?) -> String {
        switch sizeClass {
        case .compact: "compact"
        case .regular: "regular"
        default: "nil"
        }
    }
}
