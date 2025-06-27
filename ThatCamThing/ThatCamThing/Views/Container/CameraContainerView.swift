//
//  CameraContainerView.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//

import SwiftUI

// MARK: 
struct CameraContainerView<Content: View>: View {
    
    @StateObject private var cameraManager = CameraManager()
    @ViewBuilder var content: (_ manager: CameraManager) -> Content
    
     let onImageCapturedCallback: ((UIImage) -> Void)?
     let onCameraStateChanged: ((CameraManager) -> Void)?
     let customErrorHandler: ((CameraError) -> Void)?
    
    // default initializer
    init(@ViewBuilder content: @escaping (_ manager: CameraManager) -> Content) {
        self.content = content
        self.onImageCapturedCallback = nil
        self.onCameraStateChanged = nil
        self.customErrorHandler = nil
    }
    
     init(
        content: @escaping (_ manager: CameraManager) -> Content,
        onImageCaptured: ((UIImage) -> Void)?,
        onStateChanged: ((CameraManager) -> Void)?,
        errorHandler: ((CameraError) -> Void)?
    ) {
        self.content = content
        self.onImageCapturedCallback = onImageCaptured
        self.onCameraStateChanged = onStateChanged
        self.customErrorHandler = errorHandler
    }
    
    // initializer with custom attributes
    init(
        attributes: CameraManagerAttributes,
        @ViewBuilder content: @escaping (_ manager: CameraManager) -> Content,
        onImageCaptured: ((UIImage) -> Void)? = nil,
        onStateChanged: ((CameraManager) -> Void)? = nil,
        errorHandler: ((CameraError) -> Void)? = nil
    ) {
        self._cameraManager = StateObject(wrappedValue: CameraManager(initialAttributes: attributes))
        self.content = content
        self.onImageCapturedCallback = onImageCaptured
        self.onCameraStateChanged = onStateChanged
        self.customErrorHandler = errorHandler
    }
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            content(cameraManager)
        }
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
        .alert("Camera Error", isPresented: $cameraManager.isShowingAlert) {
            Button("OK") {
                cameraManager.attributes.error = nil
            }
        } message: {
            Text(cameraManager.alertMessage)
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



