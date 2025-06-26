# Camthing — A Minimal, Customizable Camera App


-  **Live camera preview** using `AVCaptureSession`
-  **Pause / resume** functionality
-  **Capture photos** and save to library
-  **Modular architecture** (`CameraManager`, `CameraContainerView`)

- Built using SwiftUI + UIKit interoperability

**Purpose of Building this:**

I wanted a clean, modular camera UI in SwiftUI that I could use in future projects — something simple enough to understand and customize, but powerful enough to build on


**Example Usage:**

CameraContainerView { manager in
    CameraOverlay(manager: manager)
}
