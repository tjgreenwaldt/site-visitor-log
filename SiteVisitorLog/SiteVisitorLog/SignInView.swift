//
//  SignInView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var fullName = ""
    @State private var company = ""
    @State private var phoneNumber = ""
    @State private var hostName = ""
    @State private var siteName = ""
    @State private var visitReason = ""
    @State private var safetyBriefingCompleted = false
    @State private var escorted = false
    @State private var notes = ""

    private var canSave: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !hostName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !siteName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Required Information") {
                TextField("Full name", text: $fullName, prompt: Text("Enter visitor name"))
                TextField("Company", text: $company, prompt: Text("Enter company name"))
                TextField("Host name", text: $hostName, prompt: Text("Enter host name"))
                TextField("Site name", text: $siteName, prompt: Text("Enter site name"))
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
    }

    private func saveVisitor() {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let visitor = Visitor(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            hostName: hostName.trimmingCharacters(in: .whitespacesAndNewlines),
            siteName: siteName.trimmingCharacters(in: .whitespacesAndNewlines),
            visitReason: visitReason.trimmingCharacters(in: .whitespacesAndNewlines),
            safetyBriefingCompleted: safetyBriefingCompleted,
            escorted: escorted,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes
        )

        modelContext.insert(visitor)
        clearForm()
    }

    private func clearForm() {
        fullName = ""
        company = ""
        phoneNumber = ""
        hostName = ""
        siteName = ""
        visitReason = ""
        safetyBriefingCompleted = false
        escorted = false
        notes = ""
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
        .modelContainer(PreviewSampleData.container)
}
