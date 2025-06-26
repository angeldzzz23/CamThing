//
//  CameraManager.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//

import AVFoundation
import Photos
import UIKit
import SwiftUI

// MARK: Capture ed photo
// MARK:  Adding Zoom in,
// MARK: Getting Photo
// MARK: Output format
// MARK: Output format selection (JPEG, HEIF, RAW if supported)
// MARK: Flash
// MARK: Auto pause after 10 minutes
// MARK: Ability to toggle camera
// MARK: Zoom in and zoom out
// MARK: make the CameraConfiguration Injectable

class CameraManager: NSObject, CameraManaging {
    
    @Published var isSessionRunning = false
    @Published var isPaused = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    @Published var capturedImage: UIImage?

    let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    
    
    override init() {
        super.init()
        setupCamera()
        setupSessionObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupSessionObservers() {
          if #available(iOS 18.0, *) {
              NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(sessionDidStartRunning),
                  name: AVCaptureSession.didStartRunningNotification,
                  object: session
              )
              
              NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(sessionDidStopRunning),
                  name: AVCaptureSession.didStopRunningNotification,
                  object: session
              )
          } else {
              NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(sessionDidStartRunning),
                  name: .AVCaptureSessionDidStartRunning,
                  object: session
              )
              
              NotificationCenter.default.addObserver(
                  self,
                  selector: #selector(sessionDidStopRunning),
                  name: .AVCaptureSessionDidStopRunning,
                  object: session
              )
          }
      }
    
    @objc private func sessionDidStartRunning() {
        DispatchQueue.main.async {
            self.isSessionRunning = true
        }
    }
    
    @objc private func sessionDidStopRunning() {
        DispatchQueue.main.async {
            self.isSessionRunning = false
        }
    }
    
    //TODO: this should be Out of here
    func requestPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.global().async {
                self.startSession()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.global().async {
                        self.startSession()
                    }
                }
            }
        case .denied, .restricted:
            showAlert(message: "Camera access is required to use this app")
        @unknown default:
            break
        }
        
        // Also request photo library permissions
        PHPhotoLibrary.requestAuthorization { status in
            if status != .authorized {
                DispatchQueue.main.async {
                    self.showAlert(message: "Photo library access is required to save photos")
                }
            }
        }
    }
    
    func togglePause() {
        if isPaused {
            resumeCamera()
        } else {
            pauseCamera()
        }
    }
    
    private func pauseCamera() {
        guard isSessionRunning && !isPaused else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()
            
            if let videoInput = self.videoDeviceInput {
                self.session.removeInput(videoInput)
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.isPaused = true
            }
        }
    }
    
    private func resumeCamera() {
        guard isPaused else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()
            
            if let videoInput = self.videoDeviceInput {
                if self.session.canAddInput(videoInput) {
                    self.session.addInput(videoInput)
                }
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.isPaused = false
            }
        }
    }
    
    private func setupCamera() {
        //Remove this out of here as well,  by default this is set to high but should be injectible
        session.sessionPreset = .high
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            showAlert(message: "Could not find camera")
            return
        }
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput!) {
                session.addInput(videoDeviceInput!)
            }
            
            // Configure for 60fps
            try configureFor60FPS(device: videoDevice)
            
        } catch {
            showAlert(message: "Could not create video device input: \(error.localizedDescription)")
            return
        }
        
        // Add photo output
        photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput!) {
            session.addOutput(photoOutput!)
        }
    }
    
    func clearCaptureImage() {
        capturedImage = nil
    }
    
    private func configureFor60FPS(device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        
        // Find the best format that supports 60fps
        let formats = device.formats
        var bestFormat: AVCaptureDevice.Format?
        var bestFrameRateRange: AVFrameRateRange?
        
        for format in formats {
            for range in format.videoSupportedFrameRateRanges {
                if range.maxFrameRate >= 60.0 {
                    if bestFormat == nil ||
                       CMVideoFormatDescriptionGetDimensions(format.formatDescription).width >
                       CMVideoFormatDescriptionGetDimensions(bestFormat!.formatDescription).width {
                        bestFormat = format
                        bestFrameRateRange = range
                    }
                }
            }
        }
        
        if let format = bestFormat, let _ = bestFrameRateRange {
            device.activeFormat = format
            device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 60)
            device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 60)
        }
        
        device.unlockForConfiguration()
    }
    
    private func startSession() {
        guard !session.isRunning else { return }
        
        session.startRunning()
        
        DispatchQueue.main.async {
            self.isPaused = false
        }
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput, !isPaused else { return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func showAlert(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            showAlert(message: "Failed to capture photo")
            return
        }
        
        // Save to photo library
        DispatchQueue.main.async {
            self.capturedImage = image
        }
//        PHPhotoLibrary.shared().performChanges {
//            PHAssetChangeRequest.creationRequestForAsset(from: image)
//        } completionHandler: { success, error in
//            DispatchQueue.main.async {
//                if success {
//                    // Optional: Show success feedback
//                } else {
//                    self.showAlert(message: "Failed to save photo: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }
//        }
    }
}
