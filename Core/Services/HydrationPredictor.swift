//
//  HydrationPredictor.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//
//  A simple predictor that trains a softmax regression model on
//  user-labelled entries. Falls back to the original heuristic when
//  insufficient data is available.
//

import Foundation
import CoreData

struct HSVPoint {
    let h: Double, s: Double, v: Double
    let label: Int         // user-supplied hydration level (1-8)
}

final class HydrationPredictor {

    private let context = PersistenceController.shared.container.viewContext

    // pull all entries that have a userRating set
    private func fetchLabeledPoints() -> [HSVPoint] {
        let req = Entry.fetchRequest()
        req.predicate = NSPredicate(format: "userRating != nil")
        let entries = (try? context.fetch(req)) ?? []
        return entries.compactMap { e in
            let rating = e.userRating
            //guard let rating = e.userRating else { return nil }
            return HSVPoint(h: e.h, s: e.s, v: e.v, label: Int(rating))
        }
    }

    /// Return a predicted hydration level (1-8) for this HSV triple.
    func predict(h: Double, s: Double, v: Double, k: Int = 5) -> Int {
        let points = fetchLabeledPoints()
        guard points.count >= k else {
            return fallbackLevel(h: h, s: s, v: v)
        }

        // Train a small softmax regression model on-device
        let model = SoftmaxRegression.train(points: points)
        return model.predict(h: h, s: s, v: v)
    }

    /// original bucket logic as safety net
    private func fallbackLevel(h: Double, s: Double, v: Double) -> Int {
        let score = (1 - v + s) * 4        // crude but serviceable
        return Int(round(max(0, min(7, score)))) + 1
    }
}
