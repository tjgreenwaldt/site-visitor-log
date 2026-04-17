import SwiftUI
import SwiftData

struct SiteManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage(SiteSelectionStorageKeys.selectedSiteId) private var selectedSiteId = ""
    @AppStorage(SiteSelectionStorageKeys.selectedSiteName) private var selectedSiteName = ""

    @Query(sort: \SiteEntity.name) private var sites: [SiteEntity]

    @State private var draftName = ""
    @State private var editingSite: SiteEntity?
    @State private var isPresentingEditor = false

    private var activeSites: [SiteEntity] {
        sites.filter(\.isActive)
    }

    private var inactiveSites: [SiteEntity] {
        sites.filter { !$0.isActive }
    }

    var body: some View {
        List {
            Section("Active Sites") {
                if activeSites.isEmpty {
                    Text("No active sites")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(activeSites) { site in
                        siteRow(for: site)
                    }
                }
            }

            Section("Inactive Sites") {
                if inactiveSites.isEmpty {
                    Text("No inactive sites")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(inactiveSites) { site in
                        siteRow(for: site)
                    }
                }
            }
        }
        .navigationTitle("Manage Sites")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Add Site") {
                    draftName = ""
                    editingSite = nil
                    isPresentingEditor = true
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                SiteEditorView(
                    title: editingSite == nil ? "Add Site" : "Edit Site",
                    name: $draftName,
                    isActive: Binding(
                        get: { editingSite?.isActive ?? true },
                        set: { newValue in
                            editingSite?.isActive = newValue
                        }
                    ),
                    isNewSite: editingSite == nil,
                    onSave: saveSiteChanges
                )
            }
        }
    }

    @ViewBuilder
    private func siteRow(for site: SiteEntity) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.headline)
                Text(site.siteId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(site.isActive ? "Active" : "Inactive")
                .font(.caption)
                .foregroundStyle(site.isActive ? .green : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            draftName = site.name
            editingSite = site
            isPresentingEditor = true
        }
    }

    private func saveSiteChanges() {
        let trimmedName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let now = Date()

        if let editingSite {
            editingSite.name = trimmedName
            editingSite.updatedAt = now

            if selectedSiteId == editingSite.siteId {
                if editingSite.isActive {
                    selectedSiteName = trimmedName
                } else {
                    selectedSiteId = ""
                    selectedSiteName = ""
                }
            }
        } else {
            let existingSiteIds = Set(sites.map(\.siteId))
            let site = SiteEntity(
                siteId: SiteSource.makeSiteId(from: trimmedName, existingSiteIds: existingSiteIds),
                name: trimmedName,
                isActive: true,
                createdAt: now,
                updatedAt: now
            )
            modelContext.insert(site)
        }

        do {
            try modelContext.save()
            isPresentingEditor = false
        } catch {
            print("Failed to save site changes: \(error)")
        }
    }
}

private struct SiteEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    @Binding var name: String
    @Binding var isActive: Bool
    let isNewSite: Bool
    let onSave: () -> Void

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Site Details") {
                TextField("Site name", text: $name)

                if !isNewSite {
                    Toggle("Active", isOn: $isActive)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    onSave()
                }
                .disabled(!canSave)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SiteManagementView()
    }
    .modelContainer(PreviewSampleData.container)
}
