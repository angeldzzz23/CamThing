//
//  CameraAttributes.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//

import Foundation

struct CameraManagerAttributes {
    var capturedMedia: CameraMedia? = nil
    var error: CameraError? = nil
}


public enum CameraError: Error {
    case cameraPermissionsNotGranted
    case cannotSetupInput, cannotSetupOutput
}
