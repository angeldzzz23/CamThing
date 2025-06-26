//
//  CameraManager+PhotoOutput.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/26/25.
//

import Foundation
import AVKit

extension CameraManager {
    
    func capturePhoto() {
        guard let photoOutput = photoOutput, !isPaused else { return }
        
        let settings = AVCapturePhotoSettings()
        
        // Apply flash mode from attributes
        switch attributes.flashMode {
        case .off:
            settings.flashMode = .off
        case .on:
            settings.flashMode = .on
        case .auto:
            settings.flashMode = .auto
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            showAlert(message: "Failed to capture photo")
            return
        }
        
        let finalImage = attributes.mirrorOutput ? image.mirrored() : image
        
        // Save to attributes and published property
        DispatchQueue.main.async {
            self.capturedImage = finalImage
            // TODO: can create a CameraMedia struct to store in attributes.capturedMedia
            self.onImageCaptured?(finalImage)
        }
    }
}

private extension CameraManager {

}
