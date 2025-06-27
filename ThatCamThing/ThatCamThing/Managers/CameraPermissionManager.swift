//
//  CameraPermissionManager.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//

import SwiftUI
import AVKit
import Photos

// MARK: - Permission Management
class CameraPermissionManager {
    private weak var cameraManager: CameraManager?
    
    init(cameraManager: CameraManager) {
        self.cameraManager = cameraManager
    }
    
    func requestPermissions() {
        requestCameraPermission()
        requestPhotoLibraryPermission()
    }
    
    private func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.global().async {
                self.cameraManager?.sessionManager.startSession()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.global().async {
                        self.cameraManager?.sessionManager.startSession()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.cameraManager?.attributes.error = .cameraPermissionsNotGranted
                    }
                }
            }
        case .denied, .restricted:
            cameraManager?.attributes.error = .cameraPermissionsNotGranted
            cameraManager?.showAlert(message: "Camera access is required to use this app")
        @unknown default:
            break
        }
    }
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                DispatchQueue.main.async {
                    self.cameraManager?.showAlert(message: "Photo library access is required to save photos")
                }
            }
        }
    }
}
