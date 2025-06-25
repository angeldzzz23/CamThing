//
//  ContentView.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//

import SwiftUI
import AVFoundation
import Photos

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {

            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
    
            
            if cameraManager.isPaused {
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            Text("Camera Paused")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        }
                    )
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 30) {
                    // Pause/Resume button
                    Button(action: {
                        cameraManager.togglePause()
                    }) {
                        Image(systemName: cameraManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .disabled(!cameraManager.isSessionRunning)
                    
                    // Capture button
                    Button(action: {
                        cameraManager.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .disabled(!cameraManager.isSessionRunning || cameraManager.isPaused)
                    
                    // Spacer to balance the layout
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.bottom, 50)
            }
            
            // Status overlay
            VStack {
                HStack {
                    Text(cameraManager.isPaused ? "PAUSED" : "60 FPS")
                        .font(.caption)
                        .padding(8)
                        .background(cameraManager.isPaused ? Color.red.opacity(0.8) : Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            cameraManager.requestPermissions()
        }
        .alert("Camera Error", isPresented: $cameraManager.showAlert) {
            Button("OK") { }
        } message: {
            Text(cameraManager.alertMessage)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class CameraManager: NSObject, ObservableObject {
    @Published var isSessionRunning = false
    @Published var isPaused = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
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
        
        if let format = bestFormat, let frameRateRange = bestFrameRateRange {
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
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    // Optional: Show success feedback
                } else {
                    self.showAlert(message: "Failed to save photo: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
