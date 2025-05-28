//
//  ResultViewModel.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI
import HealthKit

@MainActor
final class ResultViewModel: ObservableObject {
    @Published var state: LoadingState = .loading
    enum LoadingState {
        case loading, success(HydrationResult), failure(Error)
    }

    init(image: UIImage) {
        Task {
            do {
                let result = try ImageAnalyzer().analyse(image)
                state = .success(result)
                //Remember to add the HealthKit entitlement + plist description if you do this.
                //let store = HKHealthStore()
                //let type = HKQuantityType(.dietaryWater)
                //let quantity = HKQuantity(unit: .liter(), doubleValue: res.level.rawValue <= 4 ? 0.2 : 0.0)
                //let sample = HKQuantitySample(type: type, quantity: quantity, start: Date(), end: Date())
                //try? await store.requestAuthorization(toShare: [type], read: [])
                //? await store.save(sample)
            } catch {
                state = .failure(error)
            }
        }
    }
}
