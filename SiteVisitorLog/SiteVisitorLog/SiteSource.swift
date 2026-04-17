//
//  SiteSource.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/17/26.
//

import Foundation
import SwiftData

struct SeedSite {
    let siteId: String
    let name: String
}

enum SiteSource {
    static let defaultSites: [SeedSite] = [
        SeedSite(siteId: "escalante", name: "Escalante"),
        SeedSite(siteId: "swift-air-1", name: "Swift Air 1"),
        SeedSite(siteId: "swift-air-2", name: "Swift Air 2"),
        SeedSite(siteId: "swift-air-3", name: "Swift Air 3"),
        SeedSite(siteId: "golden-triangle", name: "Golden Triangle"),
        SeedSite(siteId: "golden-triangle-ii", name: "Golden Triangle II"),
        SeedSite(siteId: "walker-springs", name: "Walker Springs"),
        SeedSite(siteId: "optimist", name: "Optimist"),
        SeedSite(siteId: "wing", name: "Wing"),
    ]

    @MainActor
    static func seedSitesIfNeeded(in modelContext: ModelContext) {
        let descriptor = FetchDescriptor<SiteEntity>()

        guard let existingSites = try? modelContext.fetch(descriptor), existingSites.isEmpty else {
            return
        }

        let now = Date()

        for site in defaultSites {
            modelContext.insert(
                SiteEntity(
                    siteId: site.siteId,
                    name: site.name,
                    isActive: true,
                    createdAt: now,
                    updatedAt: now
                )
            )
        }

        try? modelContext.save()
    }

    static func makeSiteId(from name: String, existingSiteIds: Set<String>) -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = trimmedName
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))

        let baseSiteId = normalized.isEmpty ? "site" : normalized
        var candidate = baseSiteId
        var suffix = 2

        while existingSiteIds.contains(candidate) {
            candidate = "\(baseSiteId)-\(suffix)"
            suffix += 1
        }

        return candidate
    }
}

enum SiteSelectionStorageKeys {
    static let selectedSiteId = "selectedSiteId"
    static let selectedSiteName = "selectedSiteName"
}
