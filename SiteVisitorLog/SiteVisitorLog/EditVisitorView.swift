//
//  EditVisitorView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct EditVisitorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.visitorRepository) private var visitorRepository

    let visitor: VisitorRecordDTO
    let onSave: (VisitorRecordDTO) -> Void

    @State private var fullName: String
    @State private var company: String
    @State private var phoneNumber: String
    @State private var hostName: String
    @State private var visitReason: String
    @State private var safetyBriefingCompleted: Bool
    @State private var escorted: Bool
    @State private var notes: String

    init(visitor: VisitorRecordDTO, onSave: @escaping (VisitorRecordDTO) -> Void = { _ in }) {
        self.visitor = visitor
        self.onSave = onSave
        _fullName = State(initialValue: visitor.fullName)
        _company = State(initialValue: visitor.company)
        _phoneNumber = State(initialValue: visitor.phoneNumber)
        _hostName = State(initialValue: visitor.hostName)
        _visitReason = State(initialValue: visitor.visitReason)
        _safetyBriefingCompleted = State(initialValue: visitor.safetyBriefingCompleted)
        _escorted = State(initialValue: visitor.escorted)
        _notes = State(initialValue: visitor.notes ?? "")
    }

    private var canSave: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !hostName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Required Information") {
                TextField("Full name", text: $fullName, prompt: Text("Enter visitor name"))
                TextField("Company", text: $company, prompt: Text("Enter company name"))
                TextField("Host name", text: $hostName, prompt: Text("Enter host name"))
            }

            Section("Current Site") {
                Text(visitor.siteName)
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
        }
        .navigationTitle("Edit Visitor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: saveChanges)
                    .disabled(!canSave)
            }
        }
    }

    private func saveChanges() {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedVisitor = VisitorRecordDTO(
            localId: visitor.localId,
            remoteId: visitor.remoteId,
            siteId: visitor.siteId,
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            hostName: hostName.trimmingCharacters(in: .whitespacesAndNewlines),
            siteName: visitor.siteName,
            visitReason: visitReason.trimmingCharacters(in: .whitespacesAndNewlines),
            signInTime: visitor.signInTime,
            signOutTime: visitor.signOutTime,
            safetyBriefingCompleted: safetyBriefingCompleted,
            escorted: escorted,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            latitude: visitor.latitude,
            longitude: visitor.longitude,
            createdAt: visitor.createdAt,
            updatedAt: visitor.updatedAt,
            syncStatus: visitor.syncStatus,
            deviceId: visitor.deviceId
        )

        do {
            let savedVisitor = try visitorRepository.updateVisitor(updatedVisitor)
            onSave(savedVisitor)
            dismiss()
        } catch {
            print("Failed to save visitor changes: \(error)")
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
    NavigationStack {
        EditVisitorView(
            visitor: VisitorRecordDTO(
                siteId: "escalante",
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
    .environment(\.visitorRepository, PreviewSampleData.visitorRepository)
    .modelContainer(PreviewSampleData.container)
}
