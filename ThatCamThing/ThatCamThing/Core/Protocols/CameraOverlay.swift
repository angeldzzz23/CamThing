//
//  CameraOverlay.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/27/25.
//

import SwiftUI
import AVKit

// MARK: - Updated Protocol
protocol CameraOverlayView: View {
    associatedtype Control: CameraControl
    var cameraControl: Control { get }
    
    init(cameraControl: Control)
}





