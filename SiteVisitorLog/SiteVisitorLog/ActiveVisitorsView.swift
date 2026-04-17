//
//  ActiveVisitorsView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct ActiveVisitorsView: View {
    @Query(
        filter: #Predicate<Visitor> { visitor in
            visitor.signOutTime == nil
        },
        sort: \Visitor.signInTime,
        order: .reverse
    ) private var activeVisitors: [Visitor]

    var body: some View {
        List {
            ForEach(activeVisitors) { visitor in
                NavigationLink {
                    VisitorDetailView(visitor: visitor)
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
    }
}

#Preview {
    NavigationStack {
        ActiveVisitorsView()
    }
    .modelContainer(PreviewSampleData.container)
}
