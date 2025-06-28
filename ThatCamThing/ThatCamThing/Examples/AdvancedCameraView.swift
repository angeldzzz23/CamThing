//
//  AdvancedCameraView.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//
import SwiftUI
import AVKit
import Photos

/// Sample Code on how to use the library

struct AdvancedCameraView: View {
    
    @State private var showingSettings = false
    
    var body: some View {
        CameraContainerView()
            .setOverlayScreen(DefaultCameraOverlay.self)
//            .onImageCaptured { image in
                
//            }
        
        
        
        
//            .setOverlayScreen(DefaultCameraOverlay.self)
//            .onImageCaptured { image in
//                saveImageInGallery(image)
//            }
        
    }
    
    
    private func saveImageInGallery(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Image saved successfully")
                } else {
                    print("Failed to save image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}


//        .onImageCaptured { image in
//            saveImageInGallery(image)
//        }
        
//        CameraContainerView(
//            attributes: CameraManagerAttributes(cameraPosition: .front)
//        )
//        { manager in
//
//            VStack {
//
//                Spacer()
//
//                HStack {
//
//                    Button("Switch Camera") {
//                        manager.updateCameraPosition(
//                            manager.attributes.cameraPosition == .back ? .front : .back
//                        )
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(8)
//
//                    Spacer()
//
//                    // Flash mode toggle
//                    Button("Flash: \(flashModeText(manager.attributes.flashMode))") {
//                        let nextFlashMode = nextFlashModeValue(manager.attributes.flashMode)
//                        manager.updateFlashMode(nextFlashMode)
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(8)
//                }
//                .padding(.horizontal)
//
//                HStack {
//                    // Resolution toggle
//                    Button("Resolution: \(resolutionText(manager.attributes.resolution))") {
//                        let nextResolution = nextResolutionValue(manager.attributes.resolution)
//                        manager.updateResolution(nextResolution)
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(8)
//
//                    Spacer()
//
//                    // Frame rate toggle
//                    Button("FPS: \(manager.attributes.frameRate)") {
//                        let nextFrameRate = nextFrameRateValue(manager.attributes.frameRate)
//                        manager.updateFrameRate(nextFrameRate)
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(8)
//                }
//                .padding(.horizontal)
//
//                HStack {
//                    // Mirror toggle
//                    Button("Mirror: \(manager.attributes.mirrorOutput ? "ON" : "OFF")") {
//                        manager.updateMirrorOutput(!manager.attributes.mirrorOutput)
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(8)
//
//                    Spacer()
//                }
//                .padding(.horizontal)
//
//                // Zoom slider
//                VStack {
//                    Text("Zoom: \(String(format: "%.1f", manager.attributes.zoomFactor))x")
//                        .foregroundColor(.white)
//
//                    Slider(
//                        value: Binding(
//                            get: { manager.attributes.zoomFactor },
//                            set: { manager.updateZoomFactor($0) }
//                        ),
//                        in: 1...10.0,
//                        step: 0.5
//                    )
//                    .accentColor(.white)
//                }
//                .padding()
//                .background(Color.black.opacity(0.7))
//                .cornerRadius(8)
//                .padding(.horizontal)
//
//                // Capture button
//                Button(action: {
//                    manager.capturePhoto()
//                }) {
//                    Circle()
//                        .fill(Color.white)
//                        .frame(width: 70, height: 70)
//                        .overlay(
//                            Circle()
//                                .stroke(Color.black, lineWidth: 2)
//                                .frame(width: 60, height: 60)
//                        )
//                }
//                .padding(.bottom, 50)
//            }
//        }
//        .onImageCaptured { image in
//            saveImageInGallery(image)
//        }
//        .setErrorScreen(CustomCameraErrorScreen.self)
        
        
