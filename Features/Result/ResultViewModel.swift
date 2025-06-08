//
//  ResultViewModel.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI
import HealthKit
import UIKit
import CoreData

@MainActor
final class ResultViewModel: ObservableObject {

    // MARK: – Public state
    @Published var state: LoadingState = .loading

    enum LoadingState {
        case loading
        case success(HydrationResult)       // analysis succeeded
        case failure(String)                // error message for UI
    }

    // MARK: – Init (kick-off analysis)
    init(image: UIImage) {
        Task { await analyse(image) }
    }

    // MARK: – Main pipeline
    private func analyse(_ image: UIImage) async {
        do {
            // 0️⃣ Optional: gate out non-toilet images
            switch ToiletChecker().classify(image) {
            case .notToilet:
                state = .failure("That doesn’t look like a toilet bowl. Please retake the photo.")
                return
            case .unknown:
                // Drop through but still show a warning?
                break
            case .isToilet:
                break
            }

            let start = Date()

            // 1️⃣ Low-level colour analysis
            let result = try ImageAnalyzer().analyse(image)            // average HSV + UIImage

            // 2️⃣ k-NN personalised prediction
            let hsv = result.averageColor.toHSV()
            let predicted = HydrationPredictor()
                .predict(h: Double(hsv.0),
                         s: Double(hsv.1),
                         v: Double(hsv.2))

            // 3️⃣ Persist to Core Data
            try save(image: image,
                     hsv: hsv,
                     predictedLevel: predicted)

            // 4️⃣ Guarantee spinner ≥ 1 s
            let elapsed = Date().timeIntervalSince(start)
            if elapsed < 1 {
                try await Task.sleep(nanoseconds: UInt64((1 - elapsed) * 1_000_000_000))
            }

            state = .success(result)

        } catch {
            print("⚠️ Analysis error: \(error)")
            state = .failure("You seem to not have taken a picture of your peepee. \(error.localizedDescription)")
        }
    }

    // MARK: – Core Data save
    private func save(image: UIImage,
                      hsv: (CGFloat, CGFloat, CGFloat),
                      predictedLevel: Int) throws
    {
        let ctx   = PersistenceController.shared.container.viewContext
        let entry = Entry(context: ctx)

        entry.timestamp  = Date()
        entry.level      = Int16(predictedLevel)
        entry.imageData  = image.jpegData(compressionQuality: 0.6)

        entry.h = Double(hsv.0)
        entry.s = Double(hsv.1)
        entry.v = Double(hsv.2)

        // userRating left nil until slider feedback
        try ctx.save()
    }
}
