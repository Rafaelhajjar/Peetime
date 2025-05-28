//
//  UIColor+HSV.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import UIKit

extension UIColor {
    /// Returns (h,s,v) in 0…1 range
    func toHSV() -> (CGFloat, CGFloat, CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        return (h, s, v)
    }
}
