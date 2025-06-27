//
//  CameraContainerView+Modifiers.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//
import SwiftUI
import AVKit

// MARK: - CameraContainerView Modifiers
extension CameraContainerView {
    
    /// Set a callback for when an image is captured
    func onImageCaptured(_ callback: @escaping (UIImage) -> Void) -> CameraContainerView {
        CameraContainerView(
            content: content,
            onImageCaptured: callback,
            onStateChanged: onCameraStateChanged,
            errorHandler: customErrorHandler
        )
    }
    
    /// Set a callback for when camera state changes (e.g., session starts)
    func onCameraStateChanged(_ callback: @escaping (CameraManager) -> Void) -> CameraContainerView {
        CameraContainerView(
            content: content,
            onImageCaptured: onImageCapturedCallback,
            onStateChanged: callback,
            errorHandler: customErrorHandler
        )
    }
    
    /// Set a custom error handler
    func onError(_ handler: @escaping (CameraError) -> Void) -> CameraContainerView {
        CameraContainerView(
            content: content,
            onImageCaptured: onImageCapturedCallback,
            onStateChanged: onCameraStateChanged,
            errorHandler: handler
        )
    }
    
    /// Configure initial camera settings
    func cameraConfiguration(_ configuration: @escaping (CameraManager) -> Void) -> CameraContainerView {
        let newView = CameraContainerView(
            content: content,
            onImageCaptured: onImageCapturedCallback,
            onStateChanged: { manager in
                configuration(manager)
                onCameraStateChanged?(manager)
            },
            errorHandler: customErrorHandler
        )
        return newView
    }
}
