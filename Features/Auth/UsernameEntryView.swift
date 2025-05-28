//
//  UsernameEntryView.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI

struct UsernameEntryView: View {
    @EnvironmentObject var session: UserSession
    @State private var name = ""

    var body: some View {
        VStack(spacing: 30) {
            Text("What’s your name?")
                .font(.title)
            TextField("Enter name", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("Continue") {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                session.username = trimmed
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
    }
}
