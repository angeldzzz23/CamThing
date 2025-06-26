//
//  CameraOverlay.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//


import SwiftUI

struct CameraOverlay: View {
    @ObservedObject var manager: CameraManager

    var body: some View {
        ZStack {
            if manager.isPaused {
                Rectangle()
                    .fill(Color.black.opacity(0)) // adding this. 
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
                    Button(action: {
                        manager.togglePause()
                    }) {
                        Image(systemName: manager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .disabled(!manager.isSessionRunning)

                    Button(action: {
                        manager.capturePhoto()
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
                    .disabled(!manager.isSessionRunning || manager.isPaused)

                    Spacer().frame(width: 40)
                }
                .padding(.bottom, 50)
            }

            VStack {
                HStack {
                    Text(manager.isPaused ? "PAUSED" : "60 FPS")
                        .font(.caption)
                        .padding(8)
                        .background(manager.isPaused ? Color.red.opacity(0.8) : Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    Spacer()
                }
                .padding()

                Spacer()
            }
        }
    }
}
