//
//  ResultViewModel.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI
import HealthKit
import UIKit

@MainActor
final class ResultViewModel: ObservableObject {
    @Published var state: LoadingState = .loading

    enum LoadingState {
        case loading, success(HydrationResult), failure(Error)
    }

    init(image: UIImage) {
        Task {
            let start = Date()
            do {
                // 1) Run your existing analysis
                let result = try ImageAnalyzer().analyse(image)

                // 2) Compute how long we’ve already spent
                let elapsed = Date().timeIntervalSince(start)
                let minimum: TimeInterval = 1.0
                if elapsed < minimum {
                    // sleep the remainder
                    let nanos = UInt64((minimum - elapsed) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: nanos)
                }

                // 3) Only now publish the success
                state = .success(result)

            } catch {
                // Same trick if you want a minimum spinner on failure too:
                let elapsed = Date().timeIntervalSince(start)
                if elapsed < 1.0 {
                    let nanos = UInt64((1.0 - elapsed) * 1_000_000_000)
                    try? await Task.sleep(nanoseconds: nanos)
                }
                state = .failure(error)
            }
        }
    }
}
