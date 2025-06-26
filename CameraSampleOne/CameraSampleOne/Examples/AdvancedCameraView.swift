//
//  AdvancedCameraView.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/26/25.
//
import SwiftUI
import UIKit
import Photos

struct AdvancedCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        CameraContainerView { manager in
            VStack {
                Spacer()
                
                HStack {
                    Button("Switch Camera") {
                        manager.updateCameraPosition(
                            manager.attributes.cameraPosition == .back ? .front : .back
                        )
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("Capture") {
                        manager.capturePhoto()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
        }
        .onImageCaptured { image in
            // Save image
            saveImageInGallery(image)
            
            // Dismiss and reopen camera (simulating controller.reopenCameraScreen())
            presentationMode.wrappedValue.dismiss()
       
        }
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
