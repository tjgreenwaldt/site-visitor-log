import Foundation
import Combine
import SwiftData

@MainActor
final class SiteCatalogService: ObservableObject {
    @Published private(set) var isRefreshing = false
    @Published private(set) var lastRefreshError: String?

    private let modelContext: ModelContext
    private let remoteDataSource: any SiteRemoteDataSource

    init(modelContext: ModelContext, remoteDataSource: any SiteRemoteDataSource) {
        self.modelContext = modelContext
        self.remoteDataSource = remoteDataSource
    }

    func refreshSites() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        lastRefreshError = nil
        defer { isRefreshing = false }

        do {
            let remoteSites = try await remoteDataSource.fetchSites()
            try cache(remoteSites)
        } catch {
            lastRefreshError = error.localizedDescription
            print("Failed to refresh sites: \(error)")
        }
    }

    private func cache(_ remoteSites: [SiteDTO]) throws {
        let existingSites = try modelContext.fetch(FetchDescriptor<SiteEntity>())
        let existingSitesById = Dictionary(uniqueKeysWithValues: existingSites.map { ($0.siteId, $0) })
        let remoteSiteIds = Set(remoteSites.map(\.id))

        for remoteSite in remoteSites {
            if let existingSite = existingSitesById[remoteSite.id] {
                existingSite.name = remoteSite.name
                existingSite.isActive = remoteSite.isActive
                existingSite.createdAt = remoteSite.createdAt
                existingSite.updatedAt = remoteSite.updatedAt
            } else {
                modelContext.insert(
                    SiteEntity(
                        siteId: remoteSite.id,
                        name: remoteSite.name,
                        isActive: remoteSite.isActive,
                        createdAt: remoteSite.createdAt,
                        updatedAt: remoteSite.updatedAt
                    )
                )
            }
        }

        for existingSite in existingSites where !remoteSiteIds.contains(existingSite.siteId) {
            existingSite.isActive = false
            existingSite.updatedAt = max(existingSite.updatedAt, Date())
        }

        try modelContext.save()
    }
}
