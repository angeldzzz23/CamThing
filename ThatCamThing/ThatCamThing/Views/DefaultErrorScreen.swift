//
//  DefaultErrorScreen.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/27/25.
//

import SwiftUI

struct DefaultErrorScreen: ErrorScreenView {
    let error: Error
    let onRetry: () -> Void
    
    init(error: Error, onRetry: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Camera Error!!!!!!!!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                onRetry()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
//    DefaultErrorScreen(error: ., onRetry: <#() -> Void#>)
}

struct CustomCameraErrorScreen: ErrorScreenView {
    let error: Error
    let onRetry: () -> Void
    
    init(error: Error, onRetry: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(1)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .opacity(0.7)
                
                VStack(spacing: 15) {
                    Text("Camera Unavailable")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(errorMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)
                }
                
                VStack(spacing: 15) {
                    Button("Retry") {
                        onRetry()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    Button("Go to Settings") {
                        openAppSettings()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    private var errorMessage: String {
        if let cameraError = error as? CameraError {
            switch cameraError {
            case .cameraPermissionsNotGranted:
                return "Please allow camera access in Settings to continue."
            case .cannotSetupInput:
                return "Unable to setup camera input. Please try again."
            case .cannotSetupOutput:
                return "Unable to setup camera output. Please try again."
            }
        }
        return error.localizedDescription
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
