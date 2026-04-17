//
//  ActiveVisitorsView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct ActiveVisitorsView: View {
    @Environment(\.visitorRepository) private var visitorRepository
    let selectedSiteId: String
    @State private var searchText = ""
    @State private var activeVisitors: [VisitorRecordDTO] = []

    private var filteredVisitors: [VisitorRecordDTO] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearch.isEmpty else {
            return activeVisitors
        }

        return activeVisitors.filter { visitor in
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
                List {
                    ForEach(filteredVisitors) { visitor in
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
                                Text(visitor.signInTime, format: .dateTime.hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search name, company, or host")
        .navigationTitle("Active Visitors")
        .onAppear(perform: loadVisitors)
    }

    @ViewBuilder
    private var emptyStateView: some View {
        if activeVisitors.isEmpty {
            ContentUnavailableView(
                "No Active Visitors",
                systemImage: "person.2.slash",
                description: Text("Active visitor records for this site will appear here.")
            )
        } else {
            ContentUnavailableView.search(text: searchText)
        }
    }

    private func loadVisitors() {
        do {
            activeVisitors = try visitorRepository.fetchActiveVisitors(for: selectedSiteId)
        } catch {
            print("Failed to load active visitors: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ActiveVisitorsView(selectedSiteId: "escalante")
    }
    .environment(\.visitorRepository, PreviewSampleData.visitorRepository)
    .modelContainer(PreviewSampleData.container)
}
