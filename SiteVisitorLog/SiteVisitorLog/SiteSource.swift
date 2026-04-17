//
//  SiteSource.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/17/26.
//

import Foundation

struct AppSite: Identifiable, Hashable {
    let id: String
    let name: String
}

enum SiteSource {
    static let sites: [AppSite] = [
        AppSite(id: "escalante", name: "Escalante"),
        AppSite(id: "swift-air-1", name: "Swift Air 1"),
        AppSite(id: "swift-air-2", name: "Swift Air 2"),
        AppSite(id: "swift-air-3", name: "Swift Air 3"),
        AppSite(id: "golden-triangle", name: "Golden Triangle"),
        AppSite(id: "golden-triangle-ii", name: "Golden Triangle II"),
        AppSite(id: "walker-springs", name: "Walker Springs"),
        AppSite(id: "optimist", name: "Optimist"),
        AppSite(id: "wing", name: "Wing"),
    ]
}

enum SiteSelectionStorageKeys {
    static let selectedSiteId = "selectedSiteId"
    static let selectedSiteName = "selectedSiteName"
}
