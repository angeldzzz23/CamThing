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
    var capturedMedia: CameraMedia?
    var error: CameraError?
    var outputType: CameraOutputType
    var cameraPosition: CameraPosition
    var zoomFactor: CGFloat
    var frameRate: Int32
    var flashMode: CameraFlashMode
    var resolution: AVCaptureSession.Preset
    var mirrorOutput: Bool
    var orientationLocked: Bool
    var userBlockedScreenRotation: Bool
    var frameOrientation: CGImagePropertyOrientation
    
    // Explicit initializer with default values
    init(
        capturedMedia: CameraMedia? = nil,
        error: CameraError? = nil,
        outputType: CameraOutputType = .photo,
        cameraPosition: CameraPosition = .back,
        zoomFactor: CGFloat = 1.0,
        frameRate: Int32 = 30,
        flashMode: CameraFlashMode = .off,
        resolution: AVCaptureSession.Preset = .hd1920x1080,
        mirrorOutput: Bool = false,
        orientationLocked: Bool = false,
        userBlockedScreenRotation: Bool = false,
        frameOrientation: CGImagePropertyOrientation = .right
    ) {
        self.capturedMedia = capturedMedia
        self.error = error
        self.outputType = outputType
        self.cameraPosition = cameraPosition
        self.zoomFactor = zoomFactor
        self.frameRate = frameRate
        self.flashMode = flashMode
        self.resolution = resolution
        self.mirrorOutput = mirrorOutput
        self.orientationLocked = orientationLocked
        self.userBlockedScreenRotation = userBlockedScreenRotation
        self.frameOrientation = frameOrientation
    }
    
    init(
        capturedMedia: CameraMedia,
        error: CameraError,
        outputType: CameraOutputType ,
        cameraPosition: CameraPosition ,
        zoomFactor: CGFloat,
        frameRate: Int32,
        flashMode: CameraFlashMode ,
        resolution: AVCaptureSession.Preset,
        mirrorOutput: Bool ,
        orientationLocked: Bool ,
        userBlockedScreenRotation: Bool,
        frameOrientation: CGImagePropertyOrientation
    ) {
        self.capturedMedia = capturedMedia
        self.error = error
        self.outputType = outputType
        self.cameraPosition = cameraPosition
        self.zoomFactor = zoomFactor
        self.frameRate = frameRate
        self.flashMode = flashMode
        self.resolution = resolution
        self.mirrorOutput = mirrorOutput
        self.orientationLocked = orientationLocked
        self.userBlockedScreenRotation = userBlockedScreenRotation
        self.frameOrientation = frameOrientation
    }
    
}

