import Foundation
import SwiftUI

enum ActivityLevel: String, CaseIterable, Identifiable, Codable {
    case low, moderate, high

    var id: String { rawValue }

    var description: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        }
    }
}

struct UserProfile: Codable {
    var height: Double? = nil
    var weight: Double? = nil
    var activityLevel: ActivityLevel = .moderate
    var goal: String = ""
}
