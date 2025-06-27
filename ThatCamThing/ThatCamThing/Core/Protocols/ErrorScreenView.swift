//
//  ErrorScreenView.swift
//  ThatCamThing
//
//  Created by angel zambrano on 6/27/25.
//

import SwiftUI

// MARK: - Error Screen View Protocol
protocol ErrorScreenView: View {
    var error: Error { get }
    var onRetry: () -> Void { get }
    
    init(error: Error, onRetry: @escaping () -> Void)
}
