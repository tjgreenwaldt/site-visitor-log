//
//  ActiveVisitorsView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct ActiveVisitorsView: View {
    @Environment(\.modelContext) private var modelContext
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
                Button {
                    signOut(visitor)
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
                .buttonStyle(.plain)
            }
        }
    }

    private func signOut(_ visitor: Visitor) {
        visitor.signOutTime = Date()

        do {
            try modelContext.save()
        } catch {
            print("Failed to sign out visitor: \(error)")
        }
    }
}

#Preview {
    ActiveVisitorsView()
        .modelContainer(PreviewSampleData.container)
}
