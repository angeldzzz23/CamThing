//
//  CameraActions.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/27/25.
//

import AVKit
import SwiftUI

// MARK: - Camera Actions Interface
protocol CameraActions {
    func switchCamera()
    func toggleFlashMode()
    func cycleResolution()
    func cycleFrameRate()
    func toggleMirrorOutput()
    func updateZoomFactor2(_ factor: Float)
    func capturePhoto()
}

// MARK: - Camera State Interface
protocol CameraState: ObservableObject {
    var cameraPosition: CameraPosition { get }
    var flashMode: CameraFlashMode { get }
    var resolution: AVCaptureSession.Preset { get }
    var frameRate: Int32 { get }
    var mirrorOutput: Bool { get }
    var zoomFactor: Float { get set }
}

// MARK: - Combined Interface
protocol CameraControl: CameraActions, CameraState {}
