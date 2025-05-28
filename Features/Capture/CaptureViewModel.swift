//
//  CaptureViewModel.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI

@MainActor
final class CaptureViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var showCamera = false
    @Published var navPath = NavigationPath()   // ← new

    func handleImage(_ img: UIImage) {
        capturedImage = img
        showCamera = false            // dismiss camera
        navPath.append(img)           // push ResultView
    }
}
