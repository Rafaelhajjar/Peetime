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
        NavigationStack {
            VStack(spacing: 30) {
                if let img = vm.capturedImage {
                    Image(uiImage: img)
                        .resizable().scaledToFit().frame(height: 250)
                }
                Button("Take Photo") { vm.navigateToResult = false; vm.capturedImage = nil; }
                    .sheet(isPresented: $vm.navigateToResult, content: {})
                    // (sheet shown indirectly below)
            }
            .navigationTitle("Pee Capture")
            .toolbar {
                Button("📸") { vm.navigateToResult = false }
                    .sheet(isPresented: $vm.navigateToResult) { } // placeholder
            }
            .sheet(isPresented: .constant(vm.capturedImage == nil)) {
                CameraView(image: Binding(
                    get: { vm.capturedImage },
                    set: { if let img = $0 { vm.handleImage(img) } }
                ))
            }
            .navigationDestination(isPresented: $vm.navigateToResult) {
                if let img = vm.capturedImage {
                    ResultView(image: img)
                }
            }
        }
    }
}
