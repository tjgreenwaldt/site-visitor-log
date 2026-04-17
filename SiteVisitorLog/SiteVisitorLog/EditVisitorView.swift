//
//  EditVisitorView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct EditVisitorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let visitor: Visitor

    @State private var fullName: String
    @State private var company: String
    @State private var phoneNumber: String
    @State private var hostName: String
    @State private var visitReason: String
    @State private var safetyBriefingCompleted: Bool
    @State private var escorted: Bool
    @State private var notes: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoImage: UIImage?
    @State private var showingCamera = false
    @State private var showingCameraUnavailableAlert = false

    init(visitor: Visitor) {
        self.visitor = visitor
        _fullName = State(initialValue: visitor.fullName)
        _company = State(initialValue: visitor.company)
        _phoneNumber = State(initialValue: visitor.phoneNumber)
        _hostName = State(initialValue: visitor.hostName)
        _visitReason = State(initialValue: visitor.visitReason)
        _safetyBriefingCompleted = State(initialValue: visitor.safetyBriefingCompleted)
        _escorted = State(initialValue: visitor.escorted)
        _notes = State(initialValue: visitor.notes ?? "")
        _selectedPhotoImage = State(initialValue: visitor.photoData.flatMap(UIImage.init(data:)))
    }

    private var canSave: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !hostName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Visitor Photo") {
                HStack {
                    Spacer()
                    photoPreview
                    Spacer()
                }

                Button("Take Photo", action: openCamera)

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text("Choose Photo")
                }

                if selectedPhotoImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        selectedPhotoItem = nil
                        selectedPhotoImage = nil
                    }
                }
            }

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
        .sheet(isPresented: $showingCamera) {
            CameraPicker(image: $selectedPhotoImage)
        }
        .alert("Camera Unavailable", isPresented: $showingCameraUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This device does not have a camera available.")
        }
        .task(id: selectedPhotoItem) {
            await loadSelectedPhoto()
        }
    }

    private func saveChanges() {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        visitor.fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        visitor.company = company.trimmingCharacters(in: .whitespacesAndNewlines)
        visitor.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        visitor.hostName = hostName.trimmingCharacters(in: .whitespacesAndNewlines)
        visitor.visitReason = visitReason.trimmingCharacters(in: .whitespacesAndNewlines)
        visitor.safetyBriefingCompleted = safetyBriefingCompleted
        visitor.escorted = escorted
        visitor.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        visitor.photoData = selectedPhotoImage?.jpegData(compressionQuality: 0.7)

        do {
            try modelContext.save()
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

    @ViewBuilder
    private var photoPreview: some View {
        if let selectedPhotoImage {
            Image(uiImage: selectedPhotoImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Image(systemName: "person.crop.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundStyle(.secondary)
                .frame(width: 120, height: 120)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showingCameraUnavailableAlert = true
            return
        }

        showingCamera = true
    }

    @MainActor
    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem else { return }

        do {
            if let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedPhotoImage = image
            }
        } catch {
            print("Failed to load selected photo: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        EditVisitorView(
            visitor: Visitor(
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
    .modelContainer(PreviewSampleData.container)
}
