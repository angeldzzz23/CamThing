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

    var body: some View {
        ZStack {
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            content(cameraManager)
        }
        .onAppear {
            cameraManager.requestPermissions()
        }
        .alert("Camera Error", isPresented: $cameraManager.showAlert) {
            Button("OK") { }
        } message: {
            Text(cameraManager.alertMessage)
        }
    }
}
