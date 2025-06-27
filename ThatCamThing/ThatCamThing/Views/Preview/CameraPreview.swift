//
//  CameraPreview.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//


import Foundation
import AVKit
import SwiftUI
import Photos

// MARK: - Camera Preview UIViewRepresentable

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.session = session
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        // Update if needed
    }
}
