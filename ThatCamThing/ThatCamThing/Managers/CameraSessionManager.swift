//
//  CameraSessionManager.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//

import AVKit
import SwiftUI

// MARK: - Session Management
@MainActor
class CameraSessionManager {
    
    private let session: AVCaptureSession
    private weak var cameraManager: CameraManager?
    
    init(session: AVCaptureSession, cameraManager: CameraManager) {
        self.session = session
        self.cameraManager = cameraManager
    }
    
    func setupSessionObservers() {
        let startNotification: NSNotification.Name
        let stopNotification: NSNotification.Name
        
        if #available(iOS 18.0, *) {
            startNotification = AVCaptureSession.didStartRunningNotification
            stopNotification = AVCaptureSession.didStopRunningNotification
        } else {
            startNotification = .AVCaptureSessionDidStartRunning
            stopNotification = .AVCaptureSessionDidStopRunning
        }
        
        NotificationCenter.default.addObserver(
            forName: startNotification,
            object: session,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.cameraManager?.isSessionRunning = true
            }
           
        }
        
        NotificationCenter.default.addObserver(
            forName: stopNotification,
            object: session,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.cameraManager?.isSessionRunning = false
            }
           
        }
    }
    
    func updateResolution(_ resolution: AVCaptureSession.Preset) {
        Task { @MainActor in
            self.session.beginConfiguration()
            self.session.sessionPreset = resolution
            self.session.commitConfiguration()
        }
    }
    
    func startSession() {
        guard !session.isRunning else { return }

        let session = self.session // ✅ capture outside the closure

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning() // ✅ no longer accessing actor-isolated property
            Task { @MainActor in
                self.cameraManager?.isPaused = false
            }
        }
    }
    
    func pauseSession() {
        guard let cameraManager = cameraManager,
              cameraManager.isSessionRunning && !cameraManager.isPaused else { return }
        
        Task { @MainActor in
            self.session.beginConfiguration()
            
            if let videoInput = cameraManager.deviceManager.videoDeviceInput {
                self.session.removeInput(videoInput)
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                cameraManager.isPaused = true
            }
        }
    }
    
    func resumeSession() {
        guard let cameraManager = cameraManager,
              cameraManager.isPaused else { return }
        
        Task { @MainActor in
            self.session.beginConfiguration()
            
            if let videoInput = cameraManager.deviceManager.videoDeviceInput {
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                }
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                cameraManager.isPaused = false
            }
        }
    }
}
