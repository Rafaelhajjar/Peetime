//
//  UserSession.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import Foundation

/// Holds basic details about the current user and persists them to `UserDefaults`.

class UserSession: ObservableObject {
    @Published var username: String? {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }

    @Published var profile: UserProfile {
        didSet {
            if let data = try? JSONEncoder().encode(profile) {
                UserDefaults.standard.set(data, forKey: "userProfile")
            }
        }
    }

    init() {
        self.username = UserDefaults.standard.string(forKey: "username")
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = UserProfile()
        }
    }

    func logout() {
        username = nil
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "userProfile")
    }
}
