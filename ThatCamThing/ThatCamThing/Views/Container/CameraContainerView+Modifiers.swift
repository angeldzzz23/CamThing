//
//  CameraContainerView+Modifiers.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//
import SwiftUI
import AVKit

// MARK: - CameraContainerView Modifiers
//extension CameraContainerView {
//  
//    
//    /// Set a callback for when an image is captured
//    func onImageCaptured(_ callback: @escaping (UIImage) -> Void) -> CameraContainerView<Overlay> {
//        CameraContainerView<Overlay>(
//            attributes: defaultAttributes,
//            onImageCaptured: callback,
//            onStateChanged: onCameraStateChanged,
//            errorHandler: customErrorHandler,
//            createOverlay: createOverlay
//        )
//    }
//    
//    /// Set a callback for when camera state changes (e.g., session starts)
//    func onCameraStateChanged(_ callback: @escaping (CameraManager) -> Void) -> CameraContainerView<Overlay> {
//        CameraContainerView<Overlay>(
//            attributes: defaultAttributes,
//            onImageCaptured: onImageCapturedCallback,
//            onStateChanged: callback,
//            errorHandler: customErrorHandler,
//            createOverlay: createOverlay
//        )
//    }
//    
//    /// Set a custom error handler
//    func onError(_ handler: @escaping (CameraError) -> Void) -> CameraContainerView<Overlay> {
//        CameraContainerView<Overlay>(
//            attributes: defaultAttributes,
//            onImageCaptured: onImageCapturedCallback,
//            onStateChanged: onCameraStateChanged,
//            errorHandler: handler,
//            createOverlay: createOverlay
//        )
//    }
//    
//    /// Configure initial camera settings
//    func cameraConfiguration(_ configuration: @escaping (CameraManager) -> Void) -> CameraContainerView<Overlay> {
//        let newView = CameraContainerView<Overlay>(
//            attributes: defaultAttributes,
//            onImageCaptured: onImageCapturedCallback,
//            onStateChanged: { manager in
//                configuration(manager)
//                onCameraStateChanged?(manager)
//            },
//            errorHandler: customErrorHandler,
//            createOverlay: createOverlay
//        )
//        return newView
//    }
//}
//
//
