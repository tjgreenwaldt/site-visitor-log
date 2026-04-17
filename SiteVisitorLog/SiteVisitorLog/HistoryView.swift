//
//  HistoryView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @State private var searchText = ""

    @Query(
        filter: #Predicate<Visitor> { visitor in
            visitor.signOutTime != nil
        },
        sort: \Visitor.signOutTime,
        order: .reverse
    ) private var historyVisitors: [Visitor]

    private var filteredVisitors: [Visitor] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearch.isEmpty else {
            return historyVisitors
        }

        return historyVisitors.filter { visitor in
            visitor.fullName.localizedCaseInsensitiveContains(trimmedSearch) ||
            visitor.company.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }

    var body: some View {
        List(filteredVisitors) { visitor in
            VStack(alignment: .leading, spacing: 4) {
                Text(visitor.fullName)
                    .font(.headline)
                Text(visitor.company)
                Text(visitor.siteName)
                    .foregroundStyle(.secondary)
                Text("Signed In: \(visitor.signInTime, format: .dateTime.month().day().year().hour().minute())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let signOutTime = visitor.signOutTime {
                    Text("Signed Out: \(signOutTime, format: .dateTime.month().day().year().hour().minute())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .searchable(text: $searchText, prompt: "Search name or company")
        .navigationTitle("History")
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(PreviewSampleData.container)
}
