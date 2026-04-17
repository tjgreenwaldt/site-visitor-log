//
//  SignInView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit
import CoreLocation

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
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
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoImage: UIImage?
    @State private var showingCamera = false
    @State private var showingCameraUnavailableAlert = false

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
        .sheet(isPresented: $showingCamera) {
            CameraPicker(image: $selectedPhotoImage)
        }
        .alert("Camera Unavailable", isPresented: $showingCameraUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This device does not have a camera available.")
        }
        .task {
            locationManager.prepare()
        }
        .task(id: selectedPhotoItem) {
            await loadSelectedPhoto()
        }
    }

    private func saveVisitor() {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let visitor = Visitor(
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
            photoData: selectedPhotoImage?.jpegData(compressionQuality: 0.7),
            latitude: locationManager.latitude,
            longitude: locationManager.longitude
        )

        modelContext.insert(visitor)
        clearForm()
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
        selectedPhotoItem = nil
        selectedPhotoImage = nil
        locationManager.requestLocation()
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

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    SignInView()
        .modelContainer(PreviewSampleData.container)
}
