//
//  VisitorDetailView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct VisitorDetailView: View {
    @Environment(\.visitorRepository) private var visitorRepository
    @State private var showingEditView = false
    @State private var visitor: VisitorRecordDTO?

    let visitorId: UUID

    var body: some View {
        Group {
            if let visitor {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
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
                            detailRow(title: "Notes", value: notesText(for: visitor))
                            detailRow(title: "Location", value: locationText(for: visitor))
                            detailRow(title: "Sync Status", value: syncStatusText(for: visitor.syncStatus))
                        }

                        if visitor.signOutTime == nil {
                            Button("Sign Out", action: signOutVisitor)
                                .buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding()
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(visitor?.fullName ?? "Visitor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditView = true
                }
                .disabled(visitor == nil)
            }
        }
        .sheet(isPresented: $showingEditView) {
            if let visitor {
                NavigationStack {
                    EditVisitorView(visitor: visitor) { updatedVisitor in
                        self.visitor = updatedVisitor
                    }
                }
            }
        }
        .onAppear(perform: loadVisitor)
    }

    private func notesText(for visitor: VisitorRecordDTO) -> String {
        let trimmedNotes = visitor.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedNotes.isEmpty ? "None" : trimmedNotes
    }

    private func locationText(for visitor: VisitorRecordDTO) -> String {
        guard let latitude = visitor.latitude, let longitude = visitor.longitude else {
            return "Location not captured"
        }

        return "Lat: \(formattedCoordinate(latitude)), Lon: \(formattedCoordinate(longitude))"
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
        do {
            visitor = try visitorRepository.signOutVisitor(id: visitorId)
        } catch {
            print("Failed to sign out visitor: \(error)")
        }
    }

    private func loadVisitor() {
        do {
            visitor = try visitorRepository.fetchVisitor(id: visitorId)
        } catch {
            print("Failed to load visitor: \(error)")
        }
    }

    private func formattedCoordinate(_ value: Double) -> String {
        String(format: "%.5f", value)
    }

    private func syncStatusText(for status: VisitorRecordSyncStatus) -> String {
        switch status {
        case .localOnly:
            return "Local only"
        case .pendingUpload:
            return "Pending upload"
        case .synced:
            return "Synced"
        case .modified:
            return "Modified"
        case .syncError:
            return "Sync error"
        }
    }
}

#Preview {
    NavigationStack {
        VisitorDetailView(visitorId: PreviewSampleData.detailPreviewVisitorId)
    }
    .environment(\.visitorRepository, PreviewSampleData.visitorRepository)
    .environmentObject(PreviewSampleData.syncService)
    .modelContainer(PreviewSampleData.container)
}
