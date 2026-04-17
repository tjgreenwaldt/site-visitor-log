//
//  ContentView.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var syncService: VisitorSyncService
    @EnvironmentObject private var siteCatalogService: SiteCatalogService
    @AppStorage(SiteSelectionStorageKeys.selectedSiteId) private var selectedSiteId = ""
    @AppStorage(SiteSelectionStorageKeys.selectedSiteName) private var selectedSiteName = ""

    var body: some View {
        NavigationStack {
            if selectedSiteId.isEmpty {
                SiteSelectionView()
            } else {
                ZStack {
                    Color(red: 0.97, green: 0.98, blue: 0.99)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {
                        Spacer()

                        Image("origis_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                            .frame(maxWidth: .infinity)

                        Text("Site Visitor Log")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.secondaryNavy)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        VStack(spacing: 10) {
                            Text("Current Site")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .textCase(.uppercase)
                                .foregroundStyle(.secondary)

                            Text(selectedSiteName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.secondaryNavy)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Sync")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .textCase(.uppercase)
                                        .foregroundStyle(.secondary)
                                    Text(syncSummaryText)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondaryNavy)
                                }

                                Spacer()

                                Button(syncService.isSyncing ? "Syncing..." : "Sync Now") {
                                    Task {
                                        await syncService.syncPendingVisitors(forSiteId: selectedSiteId)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(syncService.isSyncing)
                            }

                            #if DEBUG
                            VStack(alignment: .leading, spacing: 8) {
                                Divider()

                                HStack {
                                    Text("Diagnostics")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .textCase(.uppercase)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Button("Refresh From Server") {
                                        Task {
                                            await syncService.refreshFromServer(forSiteId: selectedSiteId)
                                        }
                                    }
                                    .font(.caption)
                                    .disabled(syncService.isSyncing)
                                }

                                diagnosticRow(title: "Backend", value: backendLabel)
                                diagnosticRow(title: "Pending", value: "\(syncService.pendingSyncCount)")
                                diagnosticRow(
                                    title: "Last Success",
                                    value: syncService.lastSuccessfulSyncAt?.formatted(date: .abbreviated, time: .shortened) ?? "Never"
                                )
                                diagnosticRow(title: "Last Error", value: syncService.lastSyncError ?? "None")
                            }
                            #endif

                            if let lastSyncAttemptAt = syncService.lastSyncAttemptAt {
                                if let lastSuccessfulSyncAt = syncService.lastSuccessfulSyncAt {
                                    Text("Last successful sync: \(lastSuccessfulSyncAt, format: .dateTime.month().day().hour().minute())")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Last attempt: \(lastSyncAttemptAt, format: .dateTime.month().day().hour().minute())")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            if let lastSyncError = syncService.lastSyncError {
                                Text(lastSyncError)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)

                        VStack(spacing: 10) {
                            NavigationLink {
                                SignInView()
                            } label: {
                                Text("Sign In")
                            }
                            .buttonStyle(PrimaryButtonStyle())

                            NavigationLink {
                                ActiveVisitorsView(selectedSiteId: selectedSiteId)
                            } label: {
                                Text("Active Visitors")
                            }
                            .buttonStyle(SecondaryButtonStyle())

                            NavigationLink {
                                HistoryView(selectedSiteId: selectedSiteId)
                            } label: {
                                Text("History")
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }

                        Button("Change Site") {
                            selectedSiteId = ""
                            selectedSiteName = ""
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.secondaryNavy)
                        .opacity(0.8)

                        Spacer()
                    }
                    .frame(maxWidth: 420)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 24)
                }
            }
        }
        .task {
            syncService.refreshPendingSyncCount()
            await siteCatalogService.refreshSites()
            refreshSelectedSite()
        }
        .task(id: selectedSiteId) {
            refreshSelectedSite()
        }
    }

    private var syncSummaryText: String {
        if syncService.isSyncing {
            return "Sync in progress"
        }

        if let _ = syncService.lastSyncError, syncService.pendingSyncCount > 0 {
            return "\(syncService.pendingSyncCount) visitor records pending retry"
        }

        if syncService.pendingSyncCount == 0 {
            return "All visitor records are synced"
        }

        if syncService.pendingSyncCount == 1 {
            return "1 visitor record pending sync"
        }

        return "\(syncService.pendingSyncCount) visitor records pending sync"
    }

    #if DEBUG
    private var backendLabel: String {
        switch SupabaseConfig.backend {
        case .mock:
            return "Mock"
        case .supabase:
            return "Supabase"
        }
    }

    private func diagnosticRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 88, alignment: .leading)

            Text(value)
                .font(.caption)
                .foregroundStyle(Color.secondaryNavy)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    #endif

    private func refreshSelectedSite() {
        guard !selectedSiteId.isEmpty else { return }

        let descriptor = FetchDescriptor<SiteEntity>(
            predicate: #Predicate { site in
                site.siteId == selectedSiteId
            }
        )

        guard let site = try? modelContext.fetch(descriptor).first else {
            selectedSiteId = ""
            selectedSiteName = ""
            return
        }

        guard site.isActive else {
            selectedSiteId = ""
            selectedSiteName = ""
            return
        }

        if selectedSiteName != site.name {
            selectedSiteName = site.name
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PreviewSampleData.syncService)
        .environmentObject(PreviewSampleData.siteCatalogService)
        .modelContainer(PreviewSampleData.container)
}
