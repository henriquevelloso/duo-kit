// Draws the plugin icon: an open book of two pages with the fold between them.
// Usage: swift scripts/make_icon.swift .claude-plugin/icon.png
import AppKit

let side = 1024
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: side, pixelsHigh: side, bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

let canvas = NSRect(x: 0, y: 0, width: side, height: side)
NSColor(red: 0.10, green: 0.11, blue: 0.14, alpha: 1).setFill()
NSBezierPath(roundedRect: canvas, xRadius: 228, yRadius: 228).fill()

let paper = NSColor(red: 0.98, green: 0.96, blue: 0.91, alpha: 1)
let ink = NSColor(red: 0.16, green: 0.14, blue: 0.12, alpha: 0.55)
let pageWidth: CGFloat = 330, pageHeight: CGFloat = 520, gutter: CGFloat = 44
let originY = (CGFloat(side) - pageHeight) / 2
let leftX = CGFloat(side) / 2 - gutter / 2 - pageWidth
let rightX = CGFloat(side) / 2 + gutter / 2

for (index, x) in [leftX, rightX].enumerated() {
    let page = NSRect(x: x, y: originY, width: pageWidth, height: pageHeight)
    paper.setFill()
    NSBezierPath(roundedRect: page, xRadius: 40, yRadius: 40).fill()
    ink.setFill()
    let lines = index == 0 ? 7 : 5
    for line in 0..<lines {
        let width = pageWidth - 96 - (line == lines - 1 ? 90 : 0)
        let y = originY + pageHeight - 96 - CGFloat(line) * 56
        NSBezierPath(roundedRect: NSRect(x: x + 48, y: y, width: width, height: 20), xRadius: 10, yRadius: 10).fill()
    }
}

// The fold: a dashed line down the gutter.
let fold = NSBezierPath()
fold.move(to: NSPoint(x: CGFloat(side) / 2, y: originY - 40))
fold.line(to: NSPoint(x: CGFloat(side) / 2, y: originY + pageHeight + 40))
fold.lineWidth = 10
fold.lineCapStyle = .round
fold.setLineDash([26, 26], count: 2, phase: 0)
NSColor(red: 1.0, green: 0.42, blue: 0.36, alpha: 1).setStroke()
fold.stroke()

NSGraphicsContext.restoreGraphicsState()
let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
print("wrote", path)
