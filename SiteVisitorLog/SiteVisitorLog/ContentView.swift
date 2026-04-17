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
                                        await syncService.syncPendingVisitors()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(syncService.isSyncing)
                            }

                            if let lastSyncAttemptAt = syncService.lastSyncAttemptAt {
                                Text("Last attempt: \(lastSyncAttemptAt, format: .dateTime.month().day().hour().minute())")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
        }
        .task(id: selectedSiteId) {
            refreshSelectedSite()
        }
    }

    private var syncSummaryText: String {
        if syncService.pendingSyncCount == 0 {
            return "All visitor records are synced"
        }

        if syncService.pendingSyncCount == 1 {
            return "1 visitor record pending sync"
        }

        return "\(syncService.pendingSyncCount) visitor records pending sync"
    }

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
        .modelContainer(PreviewSampleData.container)
}
