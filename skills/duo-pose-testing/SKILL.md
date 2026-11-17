---
name: duo-pose-testing
description: Use to run, fold and screenshot an app on the iPhone Duo simulator in every pose, or when a layout must be verified closed, open, partially folded and in Split View. Covers simulator setup, the pose matrix, capturing the outer and inner displays, and hinge control in UI tests.
argument-hint: "[app path or scheme] [screens to cover]"
---

# Pose-by-pose testing on iPhone Duo

A build that compiles says nothing about poses. This runbook runs the app on the iPhone Duo simulator, moves it through every pose, and captures both displays so the result can be judged.

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

## 1. Check the tools

```bash
xcodebuild -version                                   # Xcode 27.1 or later
xcrun simctl list devicetypes | grep -i "iPhone Duo"   # the device type must exist
xcrun simctl list runtimes | grep iOS
```

iPhone Duo needs a runtime made for it. A general iOS runtime refuses with `Incompatible device`. Do not guess the identifier: try each iOS 27.1-or-later runtime until one accepts.

```bash
for RUNTIME in $(xcrun simctl list runtimes | grep -o 'com.apple.CoreSimulator.SimRuntime.iOS-27[^ ]*'); do
  UDID=$(xcrun simctl create "Duo pose test" com.apple.CoreSimulator.SimDeviceType.iPhone-Duo "$RUNTIME" 2>/dev/null) && break
done
echo "$UDID"
xcrun simctl boot "$UDID" && xcrun simctl bootstatus "$UDID"
```

Use a simulator made for the test. Leave other people's simulators alone, and delete yours when done: `xcrun simctl delete "$UDID"`.

## 2. Install and launch

Build for the simulator with the project's own tooling, then:

```bash
xcrun simctl install "$UDID" /path/to/App.app
xcrun simctl launch "$UDID" com.example.app
```

## 3. Change the pose

There is no `simctl` command for opening, closing or folding. Use the first option that exists:

1. **A simulator tool in your environment that can set the pose.** If one is available, use it, and take a screenshot after every change.
2. **Xcode's Device Hub.** Ask the person to use the open, close, rotate and fold controls there, and to say when each pose is set.
3. **A UI test** (Xcode 27.3 or later). `XCUIDevice.shared.hinge` is `nil` on devices without a hinge. Its `angle` is in radians and settable; `0` is closed and `.pi` is fully open. On a physical device, opening a closed device this way fails the test.

```swift
// fragment — Xcode 27.3 or later
@MainActor
func testBookPose() throws {
    let app = XCUIApplication()
    app.launch()
    let hinge = try XCTUnwrap(XCUIDevice.shared.hinge)
    hinge.angle = .pi * 0.7        // partially folded
    XCTAssertTrue(app.staticTexts["Page 2"].waitForExistence(timeout: 2))
}
```

After any pose change, wait for the transition to finish before capturing. A capture taken mid-animation shows a blank or half-drawn window.

## 4. The pose matrix

Cover every row for each screen under test. Skip a row only with a stated reason.

| # | Pose | Display | What to look for |
|---|---|---|---|
| 1 | Closed, portrait | outer | Compact layout; bars on the side; nothing under the camera corner |
| 2 | Closed, landscape (also standing like a tent) | outer | Compact width and height; bar overflow |
| 3 | Open flat, landscape | inner | Regular layout; bars on the side; asymmetric safe area |
| 4 | Partially folded like a book | inner | Nothing straddles the fold; layout matches row 3 or shifts only slightly |
| 5 | Open flat, portrait | inner | Horizontal bars; regular layout |
| 6 | Partially folded like a laptop | inner | Content above the fold, controls below; nothing in the fold |
| 7 | Split View, left half | inner | Compact layout; bar on the app's left edge |
| 8 | Split View, right half | inner | Compact layout; bar on the app's right edge; the larger inset has changed sides |

Also go from row 1 to row 3 and back in the middle of a task: the screen, scroll position and unsaved input must survive.

## 5. Capture both displays

With two displays, a plain `simctl io screenshot` fails with "Cannot choose between 2 displays". Pass a display id. The bundled script finds the ids and captures both:

```bash
scripts/capture_displays.sh "$UDID" 03-open-landscape ./duo-shots
```

It writes `03-open-landscape-inner.png` and `03-open-landscape-outer.png`. The display that is not lit comes out dark; keep the lit one. Name files `<row>-<pose>-<screen>` so a review can read them in order. If every capture is dark shortly after boot, wait and retry before debugging the app.

## 6. Report

```text
Simulator: iPhone Duo, <runtime>, Xcode <version>
Screen: <name>
  1 closed portrait       pass / issue: <what>   <file>
  2 closed landscape      …
  …
Continuity (1 → 3 → 1): pass / issue
Not covered: <rows and why>
```

Hand the captures to `duo-design-review` for judgment. Say plainly which rows were not run. Simulator results do not cover the camera, real hinge feel or performance; those need a device.

## Notes

Checked on Xcode 27.2 (27B52) with an iPhone Duo simulator: the general iOS 27.2 runtime rejected the device type and a Duo-specific 27.2 runtime accepted it; the default screenshot failed until a display id was passed; the hinge property was absent from that Xcode's UI testing headers and present in Xcode 27.3 beta.
