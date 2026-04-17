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

    init() {
        let sharedModelContainer = {
        let schema = Schema([
            Item.self,
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
        _syncService = StateObject(wrappedValue: VisitorSyncService(repository: repository))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.visitorRepository, SwiftDataVisitorRepository(modelContext: sharedModelContainer.mainContext))
                .environmentObject(syncService)
        }
        .modelContainer(sharedModelContainer)
    }
}
