//
//  CameraMedia.swift
//  CameraSampleOne
//
//  Created by angel zambrano on 6/25/25.
//

import SwiftUI

public struct CameraMedia: Sendable {
    let image: UIImage?
    
    init?(data: Any?) {
        if let image = data as? UIImage { self.image = image;}
        else { return nil }
    }
}
