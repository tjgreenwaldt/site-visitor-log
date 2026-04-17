//
//  SignInView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.visitorRepository) private var visitorRepository
    @AppStorage(SiteSelectionStorageKeys.selectedSiteId) private var selectedSiteId = ""
    @AppStorage(SiteSelectionStorageKeys.selectedSiteName) private var selectedSiteName = ""
    @StateObject private var locationManager = LocationManager()

    @State private var fullName = ""
    @State private var company = ""
    @State private var phoneNumber = ""
    @State private var hostName = ""
    @State private var visitReason = ""
    @State private var safetyBriefingCompleted = false
    @State private var escorted = false
    @State private var notes = ""

    private var canSave: Bool {
        !selectedSiteId.isEmpty &&
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !hostName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Current Site") {
                Text(selectedSiteName.isEmpty ? "No site selected" : selectedSiteName)
                    .foregroundStyle(selectedSiteName.isEmpty ? .secondary : .primary)
            }

            Section("Location Status") {
                HStack(spacing: 10) {
                    Circle()
                        .fill(locationStatusColor)
                        .frame(width: 12, height: 12)

                    Text("Location")
                        .foregroundStyle(.primary)
                }
            }

            Section("Required Information") {
                TextField("Full name", text: $fullName, prompt: Text("Enter visitor name"))
                TextField("Company", text: $company, prompt: Text("Enter company name"))
                TextField("Host name", text: $hostName, prompt: Text("Enter host name"))
            }

            Section("Visit Details") {
                phoneNumberField
                TextField("Reason for visit", text: $visitReason, prompt: Text("Enter reason for visit"))
            }

            Section("Safety and Access") {
                Toggle("Safety briefing completed", isOn: $safetyBriefingCompleted)
                Toggle("Escorted", isOn: $escorted)
            }

            Section("Additional Notes") {
                TextField("Notes", text: $notes, prompt: Text("Add optional notes"), axis: .vertical)
                    .lineLimit(3...6)
            }

            Section {
                Button("Save", action: saveVisitor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(!canSave)
            }
        }
        .navigationTitle("Sign In")
        .task {
            locationManager.prepareLocation()
        }
    }

    private func saveVisitor() {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        let visitor = VisitorRecordDTO(
            siteId: selectedSiteId,
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            hostName: hostName.trimmingCharacters(in: .whitespacesAndNewlines),
            siteName: selectedSiteName,
            visitReason: visitReason.trimmingCharacters(in: .whitespacesAndNewlines),
            safetyBriefingCompleted: safetyBriefingCompleted,
            escorted: escorted,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            latitude: locationManager.latitude,
            longitude: locationManager.longitude
        )

        do {
            _ = try visitorRepository.createVisitor(visitor)
            clearForm()
            dismiss()
        } catch {
            print("Failed to save visitor: \(error)")
        }
    }

    private func clearForm() {
        fullName = ""
        company = ""
        phoneNumber = ""
        hostName = ""
        visitReason = ""
        safetyBriefingCompleted = false
        escorted = false
        notes = ""
    }

    private var locationStatusColor: Color {
        switch locationManager.status {
        case .ready:
            return .green
        case .checking:
            return .yellow
        case .unavailable, .denied:
            return .red
        }
    }

    @ViewBuilder
    private var phoneNumberField: some View {
        #if os(iOS)
        TextField("Phone number", text: $phoneNumber, prompt: Text("Enter phone number"))
            .keyboardType(UIKeyboardType.phonePad)
        #else
        TextField("Phone number", text: $phoneNumber, prompt: Text("Enter phone number"))
        #endif
    }
}

#Preview {
    SignInView()
        .environment(\.visitorRepository, PreviewSampleData.visitorRepository)
        .modelContainer(PreviewSampleData.container)
}
