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
    @Published var navigateToResult = false

    func handleImage(_ img: UIImage) {
        capturedImage = img
        navigateToResult = true
    }
}
