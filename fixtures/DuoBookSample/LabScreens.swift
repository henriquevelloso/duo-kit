import SwiftUI

// Screens for checking system behavior on the simulator, pose by pose.
//
//   -mode toolbar   a tab view with a crowded toolbar
//       -compress toolbar|tabs    compression preference (default: automatic)
//       -vbar off                 vertical bars disabled
//       -priorities off           every item at the automatic priority
//       -textItem horizontalOnly|plain|none   the text-only "Select" item (default: horizontalOnly)
//   -mode split     a split arrangement that prints its axis (add -axes horizontal to limit it)
//   -mode overlay   an overlay arrangement that prints each view's z-index

struct ToolbarLab: View {
    var body: some View {
        TabView {
            Tab("Notes", systemImage: "note.text") { ToolbarLabScreen(title: "Notes") }
            Tab("Tasks", systemImage: "checklist") { ToolbarLabScreen(title: "Tasks") }
            Tab("Files", systemImage: "folder") { ToolbarLabScreen(title: "Files") }
            Tab("Settings", systemImage: "gear") { ToolbarLabScreen(title: "Settings") }
        }
    }
}

private struct ToolbarLabScreen: View {
    let title: String
    @Environment(\.toolbarVerticalEdge) private var barEdge
    @Environment(\.horizontalSizeClass) private var horizontal
    @Environment(\.verticalSizeClass) private var vertical
    @State private var lastTap = "–"

    private var options: UserDefaults { .standard }
    private var usePriorities: Bool { options.string(forKey: "priorities") != "off" }
    private var textItem: String { options.string(forKey: "textItem") ?? "horizontalOnly" }

    private var compression: ToolbarVerticalCompressionBehavior {
        switch options.string(forKey: "compress") {
        case "toolbar": .prefersToolbarItems
        case "tabs": .prefersTabBar
        default: .automatic
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let insets = proxy.safeAreaInsets
                VStack(alignment: .leading, spacing: 4) {
                    Text("size \(Int(proxy.size.width))×\(Int(proxy.size.height))  h:\(name(horizontal)) v:\(name(vertical))")
                    Text("insets L\(Int(insets.leading)) T\(Int(insets.top)) R\(Int(insets.trailing)) B\(Int(insets.bottom))")
                    Text("bar edge: \(barEdge.map { $0 == .leading ? "leading" : "trailing" } ?? "none")")
                    Text("compress:\(options.string(forKey: "compress") ?? "auto") vbar:\(options.string(forKey: "vbar") ?? "auto") prio:\(usePriorities ? "on" : "off") text:\(textItem)")
                    Text("last tap: \(lastTap)")
                }
                .font(.caption.monospaced())
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.yellow.opacity(0.15))
                .border(.orange, width: 1)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarPinnedTrailing) {
                    Button("Done", systemImage: "checkmark") { lastTap = "Done" }
                }
                ToolbarItem {
                    Button("Bookmark", systemImage: "bookmark") { lastTap = "Bookmark" }
                }
                ToolbarItem {
                    Button("Archive", systemImage: "archivebox") { lastTap = "Archive" }
                }
                .visibilityPriority(usePriorities ? .low : .automatic)
                ToolbarItem {
                    Button("Search", systemImage: "magnifyingglass") { lastTap = "Search" }
                }
                ToolbarItem {
                    Button("Text Size", systemImage: "textformat.size") { lastTap = "Text Size" }
                }
                ToolbarItem {
                    Button("Share", systemImage: "square.and.arrow.up") { lastTap = "Share" }
                }
                .visibilityPriority(usePriorities ? .high : .automatic)
                if textItem != "none" {
                    ToolbarItem {
                        Button("Select") { lastTap = "Select" }
                    }
                    .axisBehavior(textItem == "plain" ? .automatic : .horizontalOnly)
                }
                ToolbarOverflowMenu {
                    Button("Print", systemImage: "printer") { lastTap = "Print" }
                }
            }
            .toolbarVerticalCompressionBehavior(compression)
            .toolbarVerticalBehavior(options.string(forKey: "vbar") == "off" ? .disabled : .automatic)
        }
    }
}

struct SplitLab: View {
    var body: some View {
        let style: SplitArrangementViewStyle = UserDefaults.standard.string(forKey: "axes") == "horizontal"
            ? .split.axes(.horizontal) : .split
        NavigationStack {
            ArrangementView {
                SplitLabPane(name: "PRIMARY", tint: .orange)
            } secondary: {
                SplitLabPane(name: "SECONDARY", tint: .teal)
            }
            .arrangementViewStyle(style)
            .navigationTitle("Split")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SplitLabPane: View {
    let name: String
    let tint: Color
    @Environment(\.splitArrangementAxis) private var axis

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 6) {
                Text(name).font(.headline)
                Text("axis: \(axis.map { $0 == .horizontal ? "horizontal" : "vertical" } ?? "nil")")
                Text("\(Int(proxy.size.width))×\(Int(proxy.size.height))")
            }
            .font(.caption.monospaced())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(tint.opacity(0.25))
            .border(tint, width: 2)
        }
    }
}

struct OverlayLab: View {
    var body: some View {
        NavigationStack {
            ArrangementView {
                OverlayLabPane(name: "PRIMARY", tint: .orange)
                    .frame(maxWidth: 220, maxHeight: 120)
            } secondary: {
                OverlayLabPane(name: "SECONDARY", tint: .teal)
            }
            .arrangementViewStyle(.overlay)
            .navigationTitle("Overlay")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct OverlayLabPane: View {
    let name: String
    let tint: Color
    @Environment(\.overlayArrangementZIndex) private var zIndex

    var body: some View {
        VStack(spacing: 6) {
            Text(name).font(.headline)
            Text("zIndex: \(zIndex)")
        }
        .font(.caption.monospaced())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(tint.opacity(0.35))
        .border(tint, width: 2)
    }
}

private func name(_ sizeClass: UserInterfaceSizeClass?) -> String {
    switch sizeClass {
    case .compact: "compact"
    case .regular: "regular"
    default: "nil"
    }
}
