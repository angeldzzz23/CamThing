//
//  CameraManaging.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//

import SwiftUI

protocol CameraManaging: ObservableObject {
    var isSessionRunning: Bool { get }
    var isPaused: Bool { get }
    var isShowingAlert: Bool { get }
    var alertMessage: String { get }

    func requestPermissions()
    func togglePause()
    func capturePhoto()
}
