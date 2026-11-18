import SwiftUI

// Screens used for the documentation images. Launch with `-mode reader` or `-mode naive`,
// and add `-showFold YES` to draw where the fold is. The measurement screens are in LabScreens.swift.

private let chapter: [String] = [
    "The ferry left at six, before the cafés on the quay had put their chairs out. From the upper deck the town looked like something folded and put away for the night.",
    "I had brought one book and a notebook, which is the right amount for a crossing of four hours. A book alone and you only read. A notebook alone and you only look at the water and write nothing.",
    "By the second hour the coast had thinned to a line. A man beside me unfolded a paper map and traced the route in pencil, lifting it at each crease.",
    "That crease is the oldest interface problem there is. Printers solved it centuries ago by leaving a gutter: nothing that must be read as one thing is allowed to cross the middle of the book.",
    "It is a small courtesy and it costs almost nothing. The page ends before the spine and the next one begins after it, and the reader never has to think about how the object is made.",
    "When we came into port the map was folded again along the same lines, and went back into the same pocket, smaller than a hand."
]

struct ReaderDemo: View {
    var body: some View {
        NavigationStack {
            BookSpread {
                ReaderPage(number: 12, title: "Crossing", paragraphs: Array(chapter[0..<3]))
            } second: {
                ReaderPage(number: 13, title: nil, paragraphs: Array(chapter[3..<6]))
            }
            .background(Color(red: 0.98, green: 0.96, blue: 0.91).ignoresSafeArea())
            .navigationTitle("Field Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ReaderToolbar() }
        }
        .overlay { FoldMarker() }
    }
}

/// What a layout that knows nothing about the fold does: one column across everything.
struct NaiveDemo: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Crossing").font(.system(.largeTitle, design: .serif).bold())
                    ForEach(chapter, id: \.self) { paragraph in
                        Text(paragraph).font(.system(.title3, design: .serif)).lineSpacing(6)
                    }
                }
                .padding(28)
            }
            .background(Color(red: 0.98, green: 0.96, blue: 0.91).ignoresSafeArea())
            .navigationTitle("Field Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ReaderToolbar() }
        }
        .overlay { FoldMarker() }
    }
}

private struct ReaderToolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem { Button("Bookmark", systemImage: "bookmark") { } }
        ToolbarItem { Button("Search", systemImage: "magnifyingglass") { } }
        ToolbarItem { Button("Text Size", systemImage: "textformat.size") { } }
    }
}

private struct ReaderPage: View {
    let number: Int
    let title: String?
    let paragraphs: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title {
                Text(title).font(.system(.largeTitle, design: .serif).bold())
            }
            ForEach(paragraphs, id: \.self) { paragraph in
                Text(paragraph)
                    .font(.system(.body, design: .serif))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Text("\(number)")
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.12))
        .clipped()
    }
}

/// Draws the fold's reserved region so a flat screenshot can show where it is.
struct FoldMarker: View {
    var body: some View {
        if UserDefaults.standard.bool(forKey: "showFold") {
            GeometryReader { proxy in
                ForEach(proxy.reservedRegions(kind: .division, options: .includeInactive)) { region in
                    let vertical = region.frame.height > region.frame.width
                    Rectangle()
                        .fill(Color.red.opacity(0.10))
                        .overlay {
                            Rectangle().strokeBorder(Color.red.opacity(0.55),
                                                     style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
                        }
                        .overlay(alignment: vertical ? .bottom : .trailing) {
                            Text("fold")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.red)
                                .rotationEffect(vertical ? .degrees(-90) : .zero)
                                .fixedSize()
                                .padding(vertical ? .bottom : .trailing, 26)
                        }
                        .frame(width: region.frame.width, height: region.frame.height)
                        .position(x: region.frame.midX, y: region.frame.midY)
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}
