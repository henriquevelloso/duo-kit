# Sources and verification

API names in this plugin were checked against Xcode 27.2 (build 27B52), iOS 27.2 SDK, on 2026-11-17. The SDK you have installed is the authority; if a name differs, trust the SDK.

## Apple

- Human Interface Guidelines, "Designing for iPhone Duo": https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo
- "Preparing your app for iPhone Duo": https://developer.apple.com/documentation/technologyoverviews/preparing-your-app-for-iphone-duo
- Get ready for iPhone Duo: https://developer.apple.com/iphone-duo/
- `ReservedRegion`: https://developer.apple.com/documentation/swiftui/reservedregion
- `ArrangementView`: https://developer.apple.com/documentation/swiftui/arrangementview
- `UIArrangementViewController`: https://developer.apple.com/documentation/uikit/uiarrangementviewcontroller
- Tech talks (September 2026):
  - Prepare your app for iPhone Duo: https://developer.apple.com/videos/play/tech-talks/111461
  - Raise the bar with iPhone Duo: https://developer.apple.com/videos/play/tech-talks/111462
  - Strike a pose with adaptive layouts on iPhone Duo: https://developer.apple.com/videos/play/tech-talks/111463
  - Leverage multiple displays and scenes on iPhone Duo: https://developer.apple.com/videos/play/tech-talks/111464
  - Build a great camera experience for iPhone Duo: https://developer.apple.com/videos/play/tech-talks/111465
  - Design for iPhone Duo: https://developer.apple.com/videos/play/tech-talks/111466
- "A Summary of the iPhone Duo Group Lab" (Apple Developer Forums): https://developer.apple.com/forums/thread/847644

## Community

- iPhone Duo by Examples, one SwiftUI file per API: https://github.com/artemnovichkov/iPhone-Duo-by-Examples
- Duo Gallery, screenshots of shipped apps in three states: https://duogallery.io/
- Bitrig guides by Sean Allen, read 2026-11-17. Linked for reading; each statement taken up in this plugin was checked against the SDK's documentation comments or run on the simulator:
  - iPhone Duo Toolbars: A SwiftUI Guide: https://bitrig.com/blog/iphone-duo-toolbars
  - SwiftUI ArrangementView for iPhone Duo Layouts: https://bitrig.com/blog/swiftui-arrangementview

## What is measured rather than documented

Apple publishes no point dimensions for the two displays. Community measurements on the simulator put the outer display near 466 × 678 pt and the inner display near 951 × 669 pt. Treat these as orientation for design discussion only. Never write them into code.

## What was run on the simulator

On an iPhone Duo simulator with the iOS 27.2 runtime, using `fixtures/DuoBookSample`: the book layout and reserved regions in four poses; the open pose again in Arabic, with right-to-left layout forced and in the other landscape rotation, for page widths and the side of the bar; toolbar overflow, priorities, compression and the vertical-bar opt-out closed in both orientations and open in both; split and overlay arrangements closed, flat and partially folded. Numbers quoted from those runs are labelled as measured where they appear.

## Statements that rest on one source

- "No Stage Manager, no free-form resizing, no Duo idiom" comes from the Group Lab summary on the Apple Developer Forums.
- The size-class table for Split View halves comes from simulator observation, not from Apple's documentation.
