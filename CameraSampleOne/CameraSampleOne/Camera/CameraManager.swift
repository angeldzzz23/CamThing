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

// MARK: captured photo
// MARK: Adding Zoom in,
// MARK: Getting Photo
// MARK: Output format selection (JPEG, HEIF, RAW if supported)

class CameraManager: NSObject, CameraManaging {
    
    // this takes in all the camera attributes
    @Published var attributes: CameraManagerAttributes = .init() {
        didSet {
            handleAttributeChanges(oldValue: oldValue)
        }
    }
    
    @Published var isSessionRunning = false
    @Published var isPaused = false
    @Published var isShowingAlert = false
    @Published var alertMessage = ""
    
    @Published var capturedImage: UIImage?
    
    // Image capture callback
    var onImageCaptured: ((UIImage) -> Void)?

    let session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    
    override init() {
        super.init()
        setupCamera()
        setupSessionObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Attribute Change Handling
    
    private func handleAttributeChanges(oldValue: CameraManagerAttributes) {
        // Handle camera position change
        if oldValue.cameraPosition != attributes.cameraPosition {
            switchCamera()
        }
        
        // Handle resolution change
        if oldValue.resolution != attributes.resolution {
            updateResolution()
        }
        
        // Handle zoom factor change
        if oldValue.zoomFactor != attributes.zoomFactor {
            updateZoom()
        }
        
        // Handle frame rate change
        if oldValue.frameRate != attributes.frameRate {
            updateFrameRate()
        }
        
    }
    
    // MARK: - Camera Configuration Methods
    private func switchCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()
            
            // Remove current input
            if let currentInput = self.videoDeviceInput {
                self.session.removeInput(currentInput)
            }
            
            // Get the desired camera position
            let position: AVCaptureDevice.Position = self.attributes.cameraPosition == .back ? .back : .front
            
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.showAlert(message: "Could not find \(position == .back ? "back" : "front") camera")
                }
                return
            }
            
            do {
                let newInput = try AVCaptureDeviceInput(device: videoDevice)
                
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    self.videoDeviceInput = newInput
                    
                    // Configure frame rate if possible
                    try self.configureFrameRate(device: videoDevice)
                    
                    // Apply current zoom level to new camera
                    self.applyZoom(to: videoDevice)
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(message: "Could not switch camera: \(error.localizedDescription)")
                }
            }
            
            self.session.commitConfiguration()
        }
    }
    
    private func updateResolution() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.beginConfiguration()
            self.session.sessionPreset = self.attributes.resolution
            self.session.commitConfiguration()
        }
    }
    
    private func updateZoom() {
        guard let device = videoDeviceInput?.device else { return }
        applyZoom(to: device)
    }
    
    private func updateFrameRate() {
        guard let device = videoDeviceInput?.device else { return }
        
        do {
            try configureFrameRate(device: device)
        } catch {
            DispatchQueue.main.async {
                self.showAlert(message: "Could not update frame rate: \(error.localizedDescription)")
            }
        }
    }
    
    private func applyZoom(to device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            
            let maxZoom = device.activeFormat.videoMaxZoomFactor
            let zoomFactor = min(max(attributes.zoomFactor, 1.0), maxZoom)
            device.videoZoomFactor = zoomFactor
            
            // Update the actual zoom factor in attributes if it was clamped
            if zoomFactor != attributes.zoomFactor {
                DispatchQueue.main.async {
                    self.attributes.zoomFactor = zoomFactor
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            DispatchQueue.main.async {
                self.showAlert(message: "Could not adjust zoom: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Public Configuration Methods
    func updateCameraPosition(_ position: CameraPosition) {
        attributes.cameraPosition = position
    }
    
    func updateResolution(_ resolution: AVCaptureSession.Preset) {
        attributes.resolution = resolution
    }
    
    func updateZoomFactor(_ zoom: CGFloat) {
        attributes.zoomFactor = zoom
    }
    
    func updateFlashMode(_ flashMode: CameraFlashMode) {
        attributes.flashMode = flashMode
    }
    
    func updateMirrorOutput(_ mirror: Bool) {
        attributes.mirrorOutput = mirror
    }
    
    func updateFrameRate(_ frameRate: Int32) {
        attributes.frameRate = frameRate
    }
    
    // MARK: - Session Observers
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
    
    // MARK: - Permissions
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
                } else {
                    DispatchQueue.main.async {
                        self.attributes.error = .cameraPermissionsNotGranted
                    }
                }
            }
        case .denied, .restricted:
            attributes.error = .cameraPermissionsNotGranted
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
    
    // MARK: - Session Control
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
    
    // MARK: - Camera Setup
    private func setupCamera() {
        // Use resolution from attributes
        session.sessionPreset = attributes.resolution
        
        // Add video input based on attributes
        let position: AVCaptureDevice.Position = attributes.cameraPosition == .back ? .back : .front
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            attributes.error = .cannotSetupInput
            showAlert(message: "Could not find camera")
            return
        }
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput!) {
                session.addInput(videoDeviceInput!)
            }
            
            // Configure frame rate
            try configureFrameRate(device: videoDevice)
            
            // Apply initial zoom
            applyZoom(to: videoDevice)
            
        } catch {
            attributes.error = .cannotSetupInput
            showAlert(message: "Could not create video device input: \(error.localizedDescription)")
            return
        }
        
        // Add photo output
        photoOutput = AVCapturePhotoOutput()
        if session.canAddOutput(photoOutput!) {
            session.addOutput(photoOutput!)
        } else {
            attributes.error = .cannotSetupOutput
        }
    }
    
    func clearCaptureImage() {
        capturedImage = nil
        attributes.capturedMedia = nil
    }
    
    private func configureFrameRate(device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        
        let targetFrameRate = attributes.frameRate
        
        // Find the best format that supports the target frame rate
        let formats = device.formats
        var bestFormat: AVCaptureDevice.Format?
        var bestFrameRateRange: AVFrameRateRange?
        
        for format in formats {
            for range in format.videoSupportedFrameRateRanges {
                if range.maxFrameRate >= Double(targetFrameRate) && range.minFrameRate <= Double(targetFrameRate) {
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
            device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: targetFrameRate)
            device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: targetFrameRate)
        } else {
            // Fallback: try to find any format that supports a reasonable frame rate
            for format in formats {
                for range in format.videoSupportedFrameRateRanges {
                    if range.maxFrameRate >= 30.0 {
                        device.activeFormat = format
                        let clampedFrameRate = min(Double(targetFrameRate), range.maxFrameRate)
                        let clampedFrameRateInt32 = Int32(clampedFrameRate)
                        device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: clampedFrameRateInt32)
                        device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: clampedFrameRateInt32)
                        
                        // Update attributes with actual frame rate if it was clamped
                        if clampedFrameRateInt32 != targetFrameRate {
                            DispatchQueue.main.async {
                                self.attributes.frameRate = clampedFrameRateInt32
                            }
                        }
                        break
                    }
                }
            }
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
    
    // MARK: - Photo Capture
    
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.isShowingAlert = true
        }
    }
}
 
extension UIImage {
    func mirrored() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .upMirrored)
    }
}
