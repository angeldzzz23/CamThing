//
//  ContentView.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//

import SwiftUI
import AVFoundation
import Photos

struct ContentView: View {
    
    var body: some View {
        
        CameraContainerView { manager in
            
            CameraOverlay(manager: manager)
            
        }
        
    }
    
}



#Preview {
    ContentView()
}


// We always use this
struct CameraContainerWithoutViews: View {
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        ZStack {

            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
    
            
            if cameraManager.isPaused {
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                            Text("Camera Paused")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        }
                    )
            }
            
            VStack {
                Spacer()
                
                HStack(spacing: 30) {
                    // Pause/Resume button
                    Button(action: {
                        cameraManager.togglePause()
                    }) {
                        Image(systemName: cameraManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .disabled(!cameraManager.isSessionRunning)
                    
                    // Capture button
                    Button(action: {
                        cameraManager.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .disabled(!cameraManager.isSessionRunning || cameraManager.isPaused)
                    
                    // Spacer to balance the layout
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.bottom, 50)
            }
            
            // Status overlay
            VStack {
                HStack {
                    Text(cameraManager.isPaused ? "PAUSED" : "60 FPS")
                        .font(.caption)
                        .padding(8)
                        .background(cameraManager.isPaused ? Color.red.opacity(0.8) : Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
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
