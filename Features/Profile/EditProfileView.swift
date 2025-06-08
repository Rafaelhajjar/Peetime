import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var session: UserSession
    @Environment(\.dismiss) private var dismiss

    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var goal: String = ""
    @State private var activity: ActivityLevel = .moderate

    var body: some View {
        Form {
            Section(header: Text("Basics")) {
                TextField("Height (cm)", text: $height)
                    .keyboardType(.decimalPad)
                TextField("Weight (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                Picker("Activity Level", selection: $activity) {
                    ForEach(ActivityLevel.allCases) { level in
                        Text(level.description).tag(level)
                    }
                }
            }
            Section(header: Text("Goal")) {
                TextField("Your goal", text: $goal)
            }
        }
        .navigationTitle("Edit Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    session.profile.height = Double(height)
                    session.profile.weight = Double(weight)
                    session.profile.activityLevel = activity
                    session.profile.goal = goal
                    dismiss()
                }
            }
        }
        .onAppear {
            if let h = session.profile.height { height = String(h) }
            if let w = session.profile.weight { weight = String(w) }
            goal = session.profile.goal
            activity = session.profile.activityLevel
        }
    }
}
