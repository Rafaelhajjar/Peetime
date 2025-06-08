//
//  ResultView.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//
import SwiftUI
import UIKit

struct ResultView: View {
    let capturedImage: UIImage
    @StateObject private var vm: ResultViewModel
    @State private var peeColorIndicator: Double = 4

    init(image: UIImage) {
        self.capturedImage = image
        _vm = StateObject(wrappedValue: ResultViewModel(image: image))
    }

    var body: some View {
        VStack {
            switch vm.state {
            case .loading:
                VStack { ProgressView(); Text("Analyzing…") }
            case let .failure(msg):
                VStack {
                    Image(systemName: "xmark.octagon").font(.largeTitle)
                    Text(msg)
                        .multilineTextAlignment(.center)
                }
            case let .success(res):
                VStack(spacing: 20) {
                    // Display the captured image
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    
                    // Hydration score
                    Text("Hydration Level: \(res.level.rawValue)/8")
                        .font(.title2)
                        .bold()
                        .onAppear { peeColorIndicator = Double(res.level.rawValue) }
                    
                    // Slider label
                    Text("Adjust actual color:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Gradient bar representing white → dark yellow
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color.yellow.opacity(0.5), Color.yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 20)
                        .padding(.horizontal)
                    
                    // Slider for user rating (1-8)
                    Slider(value: $peeColorIndicator, in: 1...8, step: 1)
                        .accentColor(Color.yellow)
                        .padding(.horizontal)
                        .onChange(of: peeColorIndicator) { newValue in
                            vm.updateUserRating(Int(newValue))
                        }
                }
            }
        }
        .padding()
        .navigationTitle("Hydration")
    }
}
