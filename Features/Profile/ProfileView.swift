//
//  ProfileView.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI
import Charts

struct ProfileView: View {
    private static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }

    @EnvironmentObject var session: UserSession

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.timestamp, ascending: true)])
    private var entries: FetchedResults<Entry>

    private var todayEntries: [Entry] {
        entries.filter { entry in
            if let ts = entry.timestamp {
                return ts >= Self.startOfToday
            }
            return false
        }
    }

    private var avgToday: Double {
        let total = todayEntries.map { Double($0.level) }.reduce(0, +)
        return todayEntries.isEmpty ? 0 : total / Double(todayEntries.count)
    }

    private var dailySummaries: [DailySummary] {
        let grouped = Dictionary(grouping: entries) { entry in
            entry.timestamp.map { Calendar.current.startOfDay(for: $0) } ?? Date.distantPast
        }
        return grouped.map { (date, items) in
            let count = items.count
            let avg = items.map { Double($0.level) }.reduce(0, +) / Double(count)
            return DailySummary(date: date, count: count, avgLevel: avg)
        }
        .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            List {
                profileSection

                summarySection

                if todayEntries.isEmpty {
                    ContentUnavailableView("No readings yet today", systemImage: "drop")
                } else {
                    Section(header: Text("Today")) {
                        ForEach(todayEntries.reversed()) { entry in
                            row(for: entry)
                        }
                        .onDelete(perform: delete)
                    }
                }

                if dailySummaries.count > 1 {
                    Section(header: Text("Trend")) {
                        Chart(dailySummaries) { item in
                            LineMark(
                                x: .value("Date", item.date),
                                y: .value("Average", item.avgLevel)
                            )
                        }
                        .frame(height: 150)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Edit") { EditProfileView() }
                }
                ToolbarItem(placement: .navigationBarLeading) { EditButton() }
            }
        }
    }

    // MARK: Row
    private func row(for entry: Entry) -> some View {
        HStack(spacing: 12) {

            // photo thumbnail
            Group {
                if let data = entry.imageData,
                   let uiImg = UIImage(data: data) {
                    Image(uiImage: uiImg)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            // HSV swatch
            Circle()
                .fill(Color(hue: entry.h, saturation: entry.s, brightness: entry.v))
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(Color.secondary, lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(entry.level)")
                    .font(.headline)

                HStack(spacing: 4) {          // show H S V numbers
                    Text(String(format: "H %.2f", entry.h))
                    Text(String(format: "S %.2f", entry.s))
                    Text(String(format: "V %.2f", entry.v))
                }
                .font(.caption2)
                .foregroundColor(.secondary)

                if let ts = entry.timestamp {
                    Text(ts, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: Delete
    private func delete(offsets: IndexSet) {
        let ctx = PersistenceController.shared.container.viewContext
        offsets.map { entries[$0] }.forEach(ctx.delete)
        try? ctx.save()
    }

    // MARK: Sections
    private var profileSection: some View {
        Section(header: Text("User")) {
            if let name = session.username { Text("Name: \(name)") }
            if let h = session.profile.height { Text("Height: \(Int(h)) cm") }
            if let w = session.profile.weight { Text("Weight: \(Int(w)) kg") }
            Text("Activity: \(session.profile.activityLevel.description)")
            if !session.profile.goal.isEmpty { Text("Goal: \(session.profile.goal)") }
        }
    }

    private var summarySection: some View {
        Section(header: Text("Today Summary")) {
            Text("Total pees: \(todayEntries.count)")
            Text(String(format: "Average level: %.2f", avgToday))
        }
    }

    // MARK: Models
    private struct DailySummary: Identifiable {
        var id: Date { date }
        let date: Date
        let count: Int
        let avgLevel: Double
    }
}
