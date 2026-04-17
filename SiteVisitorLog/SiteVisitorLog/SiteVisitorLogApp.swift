//
//  SiteVisitorLogApp.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import SwiftUI
import SwiftData

@main
struct SiteVisitorLogApp: App {
    private let sharedModelContainer: ModelContainer
    @StateObject private var syncService: VisitorSyncService
    @StateObject private var siteCatalogService: SiteCatalogService

    init() {
        let sharedModelContainer = {
        let schema = Schema([
            Item.self,
            SiteEntity.self,
            VisitorRecordEntity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        }()

        self.sharedModelContainer = sharedModelContainer
        let repository = SwiftDataVisitorRepository(modelContext: sharedModelContainer.mainContext)
        let remoteDataSource = VisitorRemoteDataSourceProvider.make()
        _syncService = StateObject(wrappedValue: VisitorSyncService(repository: repository, remoteDataSource: remoteDataSource))
        _siteCatalogService = StateObject(
            wrappedValue: SiteCatalogService(
                modelContext: sharedModelContainer.mainContext,
                remoteDataSource: SupabaseSiteRemoteDataSource()
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.visitorRepository, SwiftDataVisitorRepository(modelContext: sharedModelContainer.mainContext))
                .environmentObject(syncService)
                .environmentObject(siteCatalogService)
        }
        .modelContainer(sharedModelContainer)
    }
}
