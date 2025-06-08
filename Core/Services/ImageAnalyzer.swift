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

enum ImageAnalyzerError: Error {
    case ciContext, noImage
}

struct ImageAnalyzer {
    private let context = CIContext()

    func analyse(_ image: UIImage) throws -> HydrationResult {
        // 0️⃣ Create a CIImage from the UIImage
        guard let ciImage = CIImage(image: image) else {
            throw ImageAnalyzerError.noImage
        }
        let width  = ciImage.extent.width
        let height = ciImage.extent.height
        print("DEBUG CIImage size: \(width)x\(height)")

        // 1️⃣ Crop centre-square ROI
        let side    = min(width, height) / 2
        let originX = (width  - side) / 2
        let originY = (height - side) / 2
        let cropRect = CGRect(x: originX, y: originY, width: side, height: side)
        let croppedCI = ciImage.cropped(to: cropRect)

        // 2️⃣ CIAreaAverage
        guard
            let filter = CIFilter(name: "CIAreaAverage"),
            filter.inputKeys.contains(kCIInputImageKey),
            filter.inputKeys.contains(kCIInputExtentKey)
        else {
            throw ImageAnalyzerError.ciContext
        }
        filter.setValue(croppedCI, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: cropRect), forKey: kCIInputExtentKey)
        guard let output = filter.outputImage else {
            throw ImageAnalyzerError.ciContext
        }

        // Render a 1×1 image to extract the average color
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())

        let avgColor = UIColor(
            red:   CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue:  CGFloat(bitmap[2]) / 255,
            alpha: 1
        )

        // 3️⃣ Map to level (fallback heuristic)
        let (_, sat, bri) = avgColor.toHSV()
        let index = Int(round(max(0, min(7, (1 - bri + sat) * 4)))) + 1
        let level = UrineColorLevel(rawValue: index)!

        return HydrationResult(averageColor: avgColor, level: level)
    }
}
