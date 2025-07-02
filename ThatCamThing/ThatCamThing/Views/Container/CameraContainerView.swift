//
//  CameraContainerView.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//

import SwiftUI

struct CameraContainerView: View {
    
    @StateObject private var cameraManager = CameraManager()
    
    let onImageCapturedCallback: ((UIImage) -> Void)?
    let onCameraStateChanged: ((CameraManager) -> Void)?
    let customErrorHandler: ((CameraError) -> Void)?
    let defaultAttributes: CameraManagerAttributes
    
    // Store the overlay type
    private var overlayType: (any CameraOverlayView.Type)?
    
    init(
        attributes: CameraManagerAttributes,
        onImageCaptured: ((UIImage) -> Void)? = nil,
        onStateChanged: ((CameraManager) -> Void)? = nil,
        errorHandler: ((CameraError) -> Void)? = nil
    ) {
        self.defaultAttributes = attributes
        self._cameraManager = StateObject(wrappedValue: CameraManager(initialAttributes: attributes))
        self.onImageCapturedCallback = onImageCaptured
        self.onCameraStateChanged = onStateChanged
        self.customErrorHandler = errorHandler
        self.overlayType = nil
    }
    
    // Private init for overlay type
    private init(
        attributes: CameraManagerAttributes,
        onImageCaptured: ((UIImage) -> Void)?,
        onStateChanged: ((CameraManager) -> Void)?,
        errorHandler: ((CameraError) -> Void)?,
        overlayType: (any CameraOverlayView.Type)?
    ) {
        self.defaultAttributes = attributes
        self._cameraManager = StateObject(wrappedValue: CameraManager(initialAttributes: attributes))
        self.onImageCapturedCallback = onImageCaptured
        self.onCameraStateChanged = onStateChanged
        self.customErrorHandler = errorHandler
        self.overlayType = overlayType
    }
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Use overlay if specified, otherwise use default
            if let overlayType = overlayType {
                AnyView(overlayType.init(manager: cameraManager))
            } else {
                DefaultCameraOverlay(manager: cameraManager)
            }
        }
        .setErrorScreen(DefaultErrorScreen.self)
        .onAppear {
            setupCameraManager()
        }
        .onChange(of: cameraManager.isSessionRunning) { _, newValue in
            if newValue {
                onCameraStateChanged?(cameraManager)
            }
        }
        .onChange(of: cameraManager.attributes.error) { _, error in
            if let error = error {
                handleError(error)
            }
        }
    }
    
    private func setupCameraManager() {
        cameraManager.onImageCaptured = onImageCapturedCallback
        cameraManager.requestPermissions()
    }
    
    private func handleError(_ error: CameraError) {
        if let customErrorHandler = customErrorHandler {
            customErrorHandler(error)
        } else {
            // Default error handling
            switch error {
            case .cameraPermissionsNotGranted:
                cameraManager.showAlert(message: "Camera permissions are required to use this feature. Please enable camera access in Settings.")
            case .cannotSetupInput:
                cameraManager.showAlert(message: "Unable to setup camera input. Please try again.")
            case .cannotSetupOutput:
                cameraManager.showAlert(message: "Unable to setup camera output. Please try again.")
            }
        }
    }
}




extension CameraContainerView {
    func setOverlayScreen<T: CameraOverlayView>(_ overlayType: T.Type) -> some View {
        return CameraContainerView(
            attributes: defaultAttributes,
            onImageCaptured: onImageCapturedCallback,
            onStateChanged: onCameraStateChanged,
            errorHandler: customErrorHandler,
            overlayType: overlayType
        )
    }
}
