//
//  CaptureView.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI
import UIKit

struct CaptureView: View {
    @StateObject private var vm = CaptureViewModel()

    var body: some View {
        NavigationStack(path: $vm.navPath) {
            VStack(spacing: 40) {
                if let img = vm.capturedImage {
                    Image(uiImage: img)
                        .resizable().scaledToFit()
                        .frame(height: 220)
                } else {
                    Text("No image yet").foregroundColor(.secondary)
                }

                Button("Take Photo") { vm.showCamera = true }
                    .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Peetime")
            // 🚀 push ResultView whenever navPath gets a UIImage
            .navigationDestination(for: UIImage.self) { img in
                ResultView(image: img)
            }
            .fullScreenCover(isPresented: $vm.showCamera) {
                CameraView(image: Binding(
                    get: { vm.capturedImage },
                    set: { if let img = $0 { vm.handleImage(img) } }
                ))
                .ignoresSafeArea()
            }
        }
    }
}
