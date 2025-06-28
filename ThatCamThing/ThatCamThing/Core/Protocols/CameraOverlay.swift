//
//  CameraOverlay.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/27/25.
//

import SwiftUI
import AVKit


// MARK: - Camera Manager Extension
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

// MARK: - Updated Protocol
protocol CameraOverlayView: View {
    associatedtype Control: CameraControl
    var cameraControl: Control { get }
    
    init(cameraControl: Control)
}


struct DefaultCameraOverlay<Control: CameraControl>: CameraOverlayView {
    
    @ObservedObject var cameraControl: Control

    
    init(cameraControl: Control) {
        self.cameraControl = cameraControl
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Button("Switch Camera") {
                    cameraControl.switchCamera()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                
                Spacer()
                
                Button("Flash: \(flashModeText(cameraControl.flashMode))") {
                    cameraControl.toggleFlashMode()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            HStack {
                Button("Resolution: \(resolutionText(cameraControl.resolution))") {
                    cameraControl.cycleResolution()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                
                Spacer()
                
                Button("FPS: \(cameraControl.frameRate)") {
                    cameraControl.cycleFrameRate()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            HStack {
                Button("Mirror: \(cameraControl.mirrorOutput ? "ON" : "OFF")") {
                    cameraControl.toggleMirrorOutput()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding(.horizontal)
            
            VStack {
                Text("Zoom: \(String(format: "%.1f", cameraControl.zoomFactor))x")
                    .foregroundColor(.white)
                
                Slider(
                    value: Binding(
                        get: { Float(cameraControl.zoomFactor) },
                        set: { cameraControl.zoomFactor = Float(CGFloat($0)) }
                    ),
                    in: 1...10.0,
                    step: 0.5
                )
                .accentColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .padding(.horizontal)
            
            Button(action: {
                cameraControl.capturePhoto()
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
            .padding(.bottom, 50)
        }
    }
    
    private func flashModeText(_ mode: CameraFlashMode) -> String {
        switch mode {
        case .off: return "OFF"
        case .on: return "ON"
        case .auto: return "AUTO"
        }
    }
    
    private func resolutionText(_ resolution: AVCaptureSession.Preset) -> String {
        switch resolution {
        case .hd1920x1080: return "1080p"
        case .hd1280x720: return "720p"
        case .vga640x480: return "VGA"
        case .high: return "HIGH"
        default: return "CUSTOM"
        }
    }
}



