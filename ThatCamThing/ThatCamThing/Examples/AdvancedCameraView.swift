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
            .onImageCaptured { image in
                
            }
            .setErrorScreen(CustomCameraErrorScreen.self)
        
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
