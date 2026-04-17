//
//  HistoryView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData
import UIKit

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
            NavigationLink {
                VisitorDetailView(visitor: visitor)
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    photoThumbnail(for: visitor)

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
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 4)
        }
        .searchable(text: $searchText, prompt: "Search name or company")
        .navigationTitle("History")
    }

    @ViewBuilder
    private func photoThumbnail(for visitor: Visitor) -> some View {
        if let photoData = visitor.photoData,
           let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Image(systemName: "person.crop.square")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(.secondary)
                .frame(width: 52, height: 52)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(PreviewSampleData.container)
}
