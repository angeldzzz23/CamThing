//
//  CameraConfigurationManaging.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/26/25.
//

import AVKit

protocol CameraConfigurationManaging {
    func updateCameraPosition(_ position: CameraPosition)
    func updateResolution(_ resolution: AVCaptureSession.Preset)
    func updateZoomFactor(_ zoom: CGFloat)
    func updateFlashMode(_ flashMode: CameraFlashMode)
    func updateMirrorOutput(_ mirror: Bool)
    func updateFrameRate(_ frameRate: Int32)
}
