//
//  VisitorDetailView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData
import UIKit

struct VisitorDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditView = false

    let visitor: Visitor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    photoView
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 16) {
                    detailRow(title: "Full Name", value: visitor.fullName)
                    detailRow(title: "Company", value: visitor.company)
                    detailRow(title: "Phone Number", value: visitor.phoneNumber)
                    detailRow(title: "Host Name", value: visitor.hostName)
                    detailRow(title: "Site Name", value: visitor.siteName)
                    detailRow(title: "Reason for Visit", value: visitor.visitReason)
                    detailRow(title: "Sign In Time", value: visitor.signInTime.formatted(date: .abbreviated, time: .shortened))
                    detailRow(
                        title: "Sign Out Time",
                        value: visitor.signOutTime?.formatted(date: .abbreviated, time: .shortened) ?? "Still signed in"
                    )
                    detailRow(title: "Safety Briefing", value: visitor.safetyBriefingCompleted ? "Completed" : "Not completed")
                    detailRow(title: "Escorted", value: visitor.escorted ? "Yes" : "No")
                    detailRow(title: "Notes", value: notesText)
                }

                if visitor.signOutTime == nil {
                    Button("Sign Out", action: signOutVisitor)
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
        .navigationTitle(visitor.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditView = true
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            NavigationStack {
                EditVisitorView(visitor: visitor)
            }
        }
    }

    private var notesText: String {
        let trimmedNotes = visitor.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedNotes.isEmpty ? "None" : trimmedNotes
    }

    @ViewBuilder
    private var photoView: some View {
        if let photoData = visitor.photoData,
           let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            Image(systemName: "person.crop.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.secondary)
                .frame(width: 140, height: 140)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func signOutVisitor() {
        visitor.signOutTime = Date()

        do {
            try modelContext.save()
        } catch {
            print("Failed to sign out visitor: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        VisitorDetailView(
            visitor: Visitor(
                fullName: "Jordan Lee",
                company: "Acme Industrial",
                phoneNumber: "555-0101",
                hostName: "Taylor Smith",
                siteName: "North Plant",
                visitReason: "Equipment inspection",
                safetyBriefingCompleted: true,
                escorted: true,
                notes: "Wearing required PPE."
            )
        )
    }
    .modelContainer(PreviewSampleData.container)
}
