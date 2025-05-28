//
//  ImageAnalyzer.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import UIKit
import CoreImage

struct HydrationResult {
    let averageColor: UIColor
    let level: UrineColorLevel
}

enum ImageAnalyzerError: Error { case ciContext }

struct ImageAnalyzer {
    private let context = CIContext()

    func analyse(_ image: UIImage) throws -> HydrationResult {
        guard let cgImage = image.cgImage else { throw ImageAnalyzerError.ciContext }

        // ---- 1. Crop centre-square ROI ----
        let side = min(cgImage.width, cgImage.height) / 2
        let originX = (cgImage.width  - side) / 2
        let originY = (cgImage.height - side) / 2
        guard let cropped = cgImage.cropping(to: .init(x: originX, y: originY, width: side, height: side)) else {
            throw ImageAnalyzerError.ciContext
        }

        // ---- 2. CIAreaAverage ----
        let ciImage = CIImage(cgImage: cropped)
        let extent = CIVector(x: 0, y: 0, z: CGFloat(side), w: CGFloat(side))
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: ciImage,
                                                 kCIInputExtentKey: extent]),
              let output = filter.outputImage else {
            throw ImageAnalyzerError.ciContext
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        let avgColor = UIColor(red: CGFloat(bitmap[0]) / 255,
                               green: CGFloat(bitmap[1]) / 255,
                               blue: CGFloat(bitmap[2]) / 255,
                               alpha: 1)

        // ---- 3. Map to level ----
        let (_, sat, bri) = avgColor.toHSV()
        // simplest heuristic: darker & more saturated → higher level
        let index = Int(round( max(0, min(7, (1 - bri + sat) * 4) ) )) + 1
        let level = UrineColorLevel(rawValue: index)!

        return HydrationResult(averageColor: avgColor, level: level)
    }
}
