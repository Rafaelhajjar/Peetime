//
//  UserSession.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import Foundation

class UserSession: ObservableObject {
    @Published var username: String? {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }

    init() {
        self.username = UserDefaults.standard.string(forKey: "username")
    }

    func logout() {
        username = nil
        UserDefaults.standard.removeObject(forKey: "username")
    }
}
