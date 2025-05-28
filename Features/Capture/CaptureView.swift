//
//  CaptureView.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI
import UIKit

struct CaptureView: View {
    @State private var isShowingCamera = false
    @State private var image: UIImage? = nil

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }

            Button("Take Photo") {
                isShowingCamera = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView(image: $image)
        }
    }
}
