//
//  CameraContainerView.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//

import SwiftUI

struct CameraContainerView<Content: View>: View {
    @StateObject private var cameraManager = CameraManager()
    @ViewBuilder var content: (_ manager: CameraManager) -> Content
    
    private var onImageCapturedCallback: ((UIImage) -> Void)?
    
    init(@ViewBuilder content: @escaping (_ manager: CameraManager) -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            content(cameraManager)
        }
        .onAppear {
            cameraManager.requestPermissions()
            cameraManager.onImageCaptured = onImageCapturedCallback
        }
        .alert("Camera Error", isPresented: $cameraManager.isShowingAlert) {
            Button("OK") { }
        } message: {
            Text(cameraManager.alertMessage)
        }
    }
    
    func onImageCaptured(_ callback: @escaping (UIImage) -> Void) -> CameraContainerView {
        var newView = self
        newView.onImageCapturedCallback = callback
        return newView
    }
}

