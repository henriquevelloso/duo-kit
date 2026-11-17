---
name: duo-scenes-and-camera
description: Use when an iPhone Duo app should open a second window, show content on the outer display while the camera runs on the inner display (a teleprompter, a preview for the person being photographed), or present supplementary content on another display. Covers multiple scenes on the inner display, scene accessories and the camera capture accessory. Layout is in the other duo- skills.
---

# Windows, displays and the camera on iPhone Duo

Three things iPhone Duo adds that are not layout: a second window of the same app, content the system presents on another display, and an outer display that faces the same way as the camera.

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

## A second window

iPhone Duo is the first iPhone that can show two windows of one app. Only the inner display can create one.

1. Declare support: `UIApplicationSupportsMultipleScenes` set to `YES` in the scene manifest, and in SwiftUI a `WindowGroup(id:for:)` that matches what you open.
2. Offer "Open in New Window" only as an addition. The same content must be reachable in the current window.
3. Gate the affordance and handle refusal. On the outer display the request fails. It has been reported that `supportsMultipleWindows` can read `true` there too, so do not treat the value as a guarantee: keep a fallback that shows the content in place.
4. Each window is a compact-width Split View half or a full regular-width scene, like any other app. Keep per-window state in scene storage.

```swift
import SwiftUI

struct ItemRow: View {
    let itemID: String
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        NavigationLink(itemID, value: itemID)      // always available: opens in place
            .contextMenu {
                if supportsMultipleWindows {
                    Button("Open in New Window", systemImage: "macwindow.badge.plus") {
                        openWindow(id: "detail", value: itemID)
                    }
                }
            }
    }
}
```

In UIKit, `UIWindowScene.ActivationAction` with an alternate action falls back by itself where a new window is not available, and `UIApplication.activateSceneSession(for:errorHandler:)` reports the failure so you can show the content in the current window.

## Scene accessories

A scene accessory is supplementary content that the system presents for your scene when a capability is available. The system decides when and where it appears. The app must be complete without it.

Two rules follow from that:

- Availability and your own on/off switch are separate. The system reports whether it can present; you decide whether to offer.
- Essential controls never live in the accessory.

### Content on the outer display during capture

While the camera interface runs full screen on the inner display, the outer display faces the subject. A camera capture accessory puts content there: a script to read, a countdown, a mirror of the shot.

```swift
import SwiftUI

@available(iOS 27.1, *)
struct RecordingScreen: View {
    @State private var showsScript = true
    @State private var canShowScript = false

    var body: some View {
        Text("Camera preview")
            .toolbar {
                ToolbarItem {
                    Toggle("Script on outer display", systemImage: "text.bubble", isOn: $showsScript)
                        .disabled(!canShowScript)     // only offer it when the system can present it
                }
            }
            .sceneAccessory {
                CameraCaptureAccessory(isEnabled: $showsScript) {
                    Text("Your script, large and high-contrast")
                }
                .onAvailabilityChange { canShowScript = $0 }
            }
    }
}
```

- It is presented only while the app is in the foreground, capturing, and on the inner display. It goes away when capture stops, the app leaves the foreground, or the device closes.
- Register it on the view that shows the capture interface, so its visibility follows that view.
- The simulator has no camera. Test this on a device, and say so in any report.
- The same mechanism, with a different accessory type, presents non-interactive content on an external display.
- Apple's article "Registering a camera capture accessory on iPhone Duo" and the camera tech talk cover capture setup and the Duo's front cameras; links are in `duo-app-readiness`.

## Checklist

- [ ] The app is fully usable with one window and with no accessory.
- [ ] "New window" appears only where it can work, and a refused request falls back to the current window.
- [ ] Accessory content is supplementary, readable from a distance, and its toggle is disabled when unavailable.
- [ ] Camera features were tested on a device, or reported as untested.
