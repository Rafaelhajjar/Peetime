//
//  UrineColorLevel.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

enum UrineColorLevel: Int, CaseIterable {
    case level1 = 1, level2, level3, level4, level5, level6, level7, level8
    
    var description: String {
        switch self {
        case .level1: return "Crystal clear – over-hydrated?"
        case .level2: return "Very light – nicely hydrated"
        case .level3: return "Light straw – good"
        case .level4: return "Straw – adequate"
        case .level5: return "Dark straw – drink soon"
        case .level6: return "Amber – dehydrated"
        case .level7: return "Dark amber – seriously dehydrated"
        case .level8: return "Brownish – seek water (or doctor)"
        }
    }
}
