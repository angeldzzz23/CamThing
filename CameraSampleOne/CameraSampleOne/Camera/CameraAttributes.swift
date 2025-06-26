//
//  CameraAttributes.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//

import Foundation
import AVKit


struct CameraManagerAttributes {
    var capturedMedia: CameraMedia? = nil
    var error: CameraError? = nil
    var outputType: CameraOutputType = .photo
    var cameraPosition: CameraPosition = .back
    var zoomFactor: CGFloat = 1.0
    var flashMode: CameraFlashMode = .off
    var resolution: AVCaptureSession.Preset = .hd1920x1080
}


public enum CameraError: Error {
    case cameraPermissionsNotGranted
    case cannotSetupInput, cannotSetupOutput
}


// MARK: Camera Output Type
public enum CameraOutputType: CaseIterable {
    case photo
    case video
}

// MARK: Camera Position
public enum CameraPosition: CaseIterable {
    case back
    case front
}

// MARK: Camera Flash Mode
public enum CameraFlashMode: CaseIterable {
    case off
    case on
    case auto
}

// MARK: Camera Light Mode
public enum CameraLightMode: CaseIterable {
    case off
    case on
}

// MARK: Camera HDR Mode
public enum CameraHDRMode: CaseIterable {
    case off
    case on
    case auto
}
