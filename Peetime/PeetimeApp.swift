//
//  PeetimeApp.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI

@main
struct PeetimeApp: App {
    @StateObject private var session = UserSession()
    private let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            if session.username == nil {
                UsernameEntryView()
                    .environmentObject(session)
            } else {
                MainTabView()                                          // ← NEW
                    .environmentObject(session)
                    .environment(\.managedObjectContext,
                                  persistence.container.viewContext)    // ← pass context
            }
        }
    }
}
