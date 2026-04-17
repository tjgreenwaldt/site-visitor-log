//
//  HistoryView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.visitorRepository) private var visitorRepository
    let selectedSiteId: String
    @State private var searchText = ""
    @State private var historyVisitors: [VisitorRecordDTO] = []

    private var filteredVisitors: [VisitorRecordDTO] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearch.isEmpty else {
            return historyVisitors
        }

        return historyVisitors.filter { visitor in
            visitor.fullName.localizedCaseInsensitiveContains(trimmedSearch) ||
            visitor.company.localizedCaseInsensitiveContains(trimmedSearch) ||
            visitor.hostName.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }

    var body: some View {
        Group {
            if filteredVisitors.isEmpty {
                emptyStateView
            } else {
                List(filteredVisitors) { visitor in
                    NavigationLink {
                        VisitorDetailView(visitorId: visitor.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(visitor.fullName)
                                .font(.headline)
                            Text(visitor.company)
                            Text(visitor.siteName)
                                .foregroundStyle(.secondary)
                            Text("Host: \(visitor.hostName)")
                                .font(.caption)
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search name, company, or host")
        .navigationTitle("History")
        .onAppear(perform: loadVisitors)
    }

    @ViewBuilder
    private var emptyStateView: some View {
        if historyVisitors.isEmpty {
            ContentUnavailableView(
                "No Visitor History",
                systemImage: "clock.arrow.circlepath",
                description: Text("Signed-out visitor records for this site will appear here.")
            )
        } else {
            ContentUnavailableView.search(text: searchText)
        }
    }

    private func loadVisitors() {
        do {
            historyVisitors = try visitorRepository.fetchVisitorHistory(for: selectedSiteId)
        } catch {
            print("Failed to load visitor history: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(selectedSiteId: "escalante")
    }
    .environment(\.visitorRepository, PreviewSampleData.visitorRepository)
    .modelContainer(PreviewSampleData.container)
}
