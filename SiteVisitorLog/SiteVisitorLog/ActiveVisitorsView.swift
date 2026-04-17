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
    @State private var activeVisitors: [VisitorRecordDTO] = []

    var body: some View {
        List {
            ForEach(activeVisitors) { visitor in
                NavigationLink {
                    VisitorDetailView(visitorId: visitor.id)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(visitor.fullName)
                            .font(.headline)
                        Text(visitor.company)
                        Text(visitor.siteName)
                            .foregroundStyle(.secondary)
                        Text(visitor.signInTime, format: .dateTime.hour().minute())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationTitle("Active Visitors")
        .onAppear(perform: loadVisitors)
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
