//
//  ToiletChecker.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import CoreML
import Vision
import UIKit

enum ToiletCheckResult { case isToilet, notToilet, unknown }

struct ToiletChecker {

    /// Returns `.isToilet` if top-5 classes include “toilet”-related label.
    func classify(_ uiImage: UIImage) -> ToiletCheckResult {
        guard let cg = uiImage.cgImage else { return .unknown }

        let orientation = CGImagePropertyOrientation(uiImage.imageOrientation)
        let handler = VNImageRequestHandler(cgImage: cg, orientation: orientation, options: [:])
        let request = VNCoreMLRequest(model: try! VNCoreMLModel(for: MobileNetV2().model))
        
        
        do {
            try handler.perform([request])
            guard
                let results = request.results as? [VNClassificationObservation]
            else { return .unknown }

            let top5 = results.prefix(5).map { $0.identifier.lowercased() }
            if top5.contains(where: { $0.contains("toilet") || $0.contains("latrine") }) {
                return .isToilet
            } else {
                return .notToilet
            }
        } catch {
            print("Vision error: \(error)")
            return .unknown
        }
    }
}
