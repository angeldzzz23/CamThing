//
//  CameraConfigurationManager.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.

import Foundation
import AVKit
import SwiftUI
import Photos

// MARK: - Configuration Management
class CameraConfigurationManager {
    
    private weak var cameraManager: CameraManager?
    
    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
    }
    
    func handleAttributeChanges(oldValue: CameraManagerAttributes, newValue: CameraManagerAttributes) {
        
        if oldValue.cameraPosition != newValue.cameraPosition {
            cameraManager?.deviceManager.switchCamera(to: newValue.cameraPosition)
        }
        
        if oldValue.resolution != newValue.resolution {
            cameraManager?.sessionManager.updateResolution(newValue.resolution)
        }
        
        if oldValue.zoomFactor != newValue.zoomFactor {
            cameraManager?.deviceManager.updateZoom(newValue.zoomFactor)
        }
        
        if oldValue.frameRate != newValue.frameRate {
            cameraManager?.deviceManager.updateFrameRate(newValue.frameRate)
        }
    }
    
}
