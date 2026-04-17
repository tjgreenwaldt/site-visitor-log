//
//  PreviewSampleData.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import Foundation
import SwiftData

@MainActor
enum PreviewSampleData {
    static let detailPreviewVisitorId = UUID()

    static let container: ModelContainer = {
        let schema = Schema([
            Item.self,
            SiteEntity.self,
            VisitorRecordEntity.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        let now = Date()

        SiteSource.seedSitesIfNeeded(in: context)

        let sampleVisitors = [
            VisitorRecordEntity(
                localId: detailPreviewVisitorId,
                siteId: "escalante",
                fullName: "Jordan Lee",
                company: "Acme Industrial",
                phoneNumber: "555-0101",
                hostName: "Taylor Smith",
                siteName: "Escalante",
                visitReason: "Equipment inspection",
                signInTime: now.addingTimeInterval(-1800),
                safetyBriefingCompleted: true,
                escorted: true,
                notes: "Wearing required PPE.",
                latitude: 32.22174,
                longitude: -110.92648,
                createdAt: now.addingTimeInterval(-1800),
                updatedAt: now.addingTimeInterval(-1800),
                syncStatus: .localOnly,
                deviceId: "preview-device"
            ),
            VisitorRecordEntity(
                siteId: "escalante",
                fullName: "Casey Nguyen",
                company: "Blue River Logistics",
                phoneNumber: "555-0102",
                hostName: "Morgan Davis",
                siteName: "Escalante",
                visitReason: "Delivery coordination",
                signInTime: now.addingTimeInterval(-7200),
                signOutTime: now.addingTimeInterval(-3600),
                safetyBriefingCompleted: true,
                escorted: false,
                latitude: 33.44838,
                longitude: -112.07404,
                createdAt: now.addingTimeInterval(-7200),
                updatedAt: now.addingTimeInterval(-3600),
                syncStatus: .synced,
                deviceId: "preview-device"
            ),
            VisitorRecordEntity(
                siteId: "escalante",
                fullName: "Avery Patel",
                company: "Summit Contractors",
                phoneNumber: "555-0103",
                hostName: "Jamie Cooper",
                siteName: "Escalante",
                visitReason: "Site walkthrough",
                signInTime: now.addingTimeInterval(-14400),
                signOutTime: now.addingTimeInterval(-10800),
                safetyBriefingCompleted: true,
                escorted: true,
                createdAt: now.addingTimeInterval(-14400),
                updatedAt: now.addingTimeInterval(-10800),
                syncStatus: .synced,
                deviceId: "preview-device"
            ),
            VisitorRecordEntity(
                siteId: "swift-air-1",
                fullName: "Riley Brooks",
                company: "Northstar Power",
                phoneNumber: "555-0104",
                hostName: "Alex Morgan",
                siteName: "Swift Air 1",
                visitReason: "Maintenance review",
                signInTime: now.addingTimeInterval(-21600),
                signOutTime: now.addingTimeInterval(-18000),
                safetyBriefingCompleted: false,
                escorted: true,
                createdAt: now.addingTimeInterval(-21600),
                updatedAt: now.addingTimeInterval(-18000),
                syncStatus: .localOnly,
                deviceId: "preview-device"
            ),
            VisitorRecordEntity(
                siteId: "swift-air-1",
                fullName: "Taylor Gomez",
                company: "Riverbend Supply",
                phoneNumber: "555-0105",
                hostName: "Chris Reed",
                siteName: "Swift Air 1",
                visitReason: "Parts delivery",
                signInTime: now.addingTimeInterval(-28800),
                signOutTime: now.addingTimeInterval(-25200),
                safetyBriefingCompleted: true,
                escorted: false,
                createdAt: now.addingTimeInterval(-28800),
                updatedAt: now.addingTimeInterval(-25200),
                syncStatus: .localOnly,
                deviceId: "preview-device"
            ),
        ]

        for visitor in sampleVisitors {
            context.insert(visitor)
        }

        return container
    }()

    static var visitorRepository: any VisitorRepository {
        SwiftDataVisitorRepository(modelContext: container.mainContext)
    }

    @MainActor
    static var syncService: VisitorSyncService {
        VisitorSyncService(repository: visitorRepository, remoteDataSource: MockVisitorRemoteDataSource())
    }
}
