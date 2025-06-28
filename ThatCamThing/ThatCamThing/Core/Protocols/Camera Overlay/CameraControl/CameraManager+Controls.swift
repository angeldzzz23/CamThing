//
//  CameraManager+Controls.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/27/25.
//

import Foundation
import AVKit

extension CameraManager: CameraControl {

    func updateZoomFactor2(_ factor: Float) {
        updateZoomFactor(CGFloat(factor))
    }
    
    var cameraPosition: CameraPosition { attributes.cameraPosition }
    var flashMode: CameraFlashMode { attributes.flashMode }
    var resolution: AVCaptureSession.Preset { attributes.resolution }
    var frameRate: Int32 { attributes.frameRate }
    var mirrorOutput: Bool { attributes.mirrorOutput }
    
    var zoomFactor: Float {
        get {
            Float(attributes.zoomFactor)
            
        }
        set {
            updateZoomFactor2(Float(newValue))
        }
    }
    
    func switchCamera() {
        updateCameraPosition(attributes.cameraPosition == .back ? .front : .back)
    }
    
    func toggleFlashMode() {
        let nextMode = nextFlashModeValue(attributes.flashMode)
        updateFlashMode(nextMode)
    }
    
    func cycleResolution() {
        let nextResolution = nextResolutionValue(attributes.resolution)
        updateResolution(nextResolution)
    }
    
    func cycleFrameRate() {
        let nextFrameRate = nextFrameRateValue(attributes.frameRate)
        updateFrameRate(nextFrameRate)
    }
    
    func toggleMirrorOutput() {
        updateMirrorOutput(!attributes.mirrorOutput)
    }
    
    private func nextFlashModeValue(_ current: CameraFlashMode) -> CameraFlashMode {
        switch current {
        case .off: return .on
        case .on: return .auto
        case .auto: return .off
        }
    }
    
    private func nextResolutionValue(_ current: AVCaptureSession.Preset) -> AVCaptureSession.Preset {
        switch current {
        case .hd1920x1080: return .hd1280x720
        case .hd1280x720: return .vga640x480
        case .vga640x480: return .high
        default: return .hd1920x1080
        }
    }
    
    private func nextFrameRateValue(_ current: Int32) -> Int32 {
        switch current {
        case 24: return 30
        case 30: return 60
        case 60: return 120
        case 120: return 24
        default: return 30
        }
    }
}
