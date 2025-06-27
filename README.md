# Camthing — A Minimal, Camera App

**Camthing** is a lightweight, SwiftUI-friendly camera interface designed to be **clean**, **reusable**, and **production-ready** for iOS apps.  
Built using **SwiftUI + UIKit**, it’s simple to customize and extend — perfect for both prototypes and real-world camera tools.


- Live camera preview using `AVCaptureSession`
- Pause / resume support
- Capture and save photos to photo library
- Modular architecture (`CameraManager`, `CameraContainerView`)
- Easily toggle:
  - Camera position (front/back)
  - Resolution (`.hd1920x1080`, `.hd1280x720`, etc.)
  - Flash mode (`on`, `off`, `auto`)
  - Frame rate (24, 30, 60, 120 fps)
  - Zoom level
  - Mirror output (for selfies)
- Built with SwiftUI + UIKit for full hardware access + modern UI

## Why I Built This

At **Answers**, we were running into serious **CPU usage issues** with our in-app camera — leading to performance drops and (more than a few) crashes.

Looking for a better foundation, I explored Apple’s official camera demo app — but most of its APIs are **iOS 18+ only**, making it impractical for real-world apps.

> For a camera-based app, requiring iOS 18+ is a non-starter.


<img width="1113" alt="Screenshot 2025-06-25 at 5 17 39 PM" src="https://github.com/user-attachments/assets/caa8bd71-34e2-461d-b2c1-bf85142c24ce" />


So I built my own:

- 💡 A **clean, modular** camera UI
- 💡 SwiftUI-compatible
- 💡 iOS **16+** support
- 💡 Easy to drop into future projects

Sid, if you're reading this — the README is kinda fire. My goal: a minimal but powerful camera base I could trust and iterate on across projects.


**Example Usage:**

CameraContainerView { manager in
    CameraOverlay(manager: manager)
}
