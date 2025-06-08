//
//  ProfileView.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//

import SwiftUI

struct ProfileView: View {
    private static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", startOfToday as NSDate))
    private var entries: FetchedResults<Entry>

    var body: some View {
        NavigationStack {
            if entries.isEmpty {
                ContentUnavailableView("No readings yet today", systemImage: "drop")
            } else {
                List {
                    ForEach(entries) { entry in
                        row(for: entry)
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.insetGrouped)
                .toolbar { EditButton() }
            }
        }
        .navigationTitle("Today")
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
}
