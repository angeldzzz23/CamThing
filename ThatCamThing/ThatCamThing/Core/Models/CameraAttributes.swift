//
//  CameraError.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//

import Foundation
import AVKit

// MARK: - Core Models and Enums

public enum CameraError: Error {
    case cameraPermissionsNotGranted
    case cannotSetupInput, cannotSetupOutput
}

public enum CameraOutputType: CaseIterable {
    case photo
}

public enum CameraPosition: CaseIterable {
    case back
    case front
}

public enum CameraFlashMode: CaseIterable {
    case off
    case on
    case auto
}

public enum CameraHDRMode: CaseIterable {
    case off
    case on
    case auto
}

struct CameraMedia {
    let image: UIImage
    let metadata: [String: Any]?
    let timestamp: Date
}

struct CameraManagerAttributes {
    var capturedMedia: CameraMedia? = nil
    var error: CameraError? = nil
    var outputType: CameraOutputType = .photo
    var cameraPosition: CameraPosition = .back
    var zoomFactor: CGFloat = 1.0
    var frameRate: Int32 = 30
    var flashMode: CameraFlashMode = .off
    var resolution: AVCaptureSession.Preset = .hd1920x1080
    var mirrorOutput: Bool = false
    var orientationLocked: Bool = false
    var userBlockedScreenRotation: Bool = false
    var frameOrientation: CGImagePropertyOrientation = .right
}
