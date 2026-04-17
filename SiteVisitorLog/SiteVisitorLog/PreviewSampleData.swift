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
    static let container: ModelContainer = {
        let schema = Schema([
            Item.self,
            Visitor.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let sampleVisitors = [
            Visitor(
                fullName: "Jordan Lee",
                company: "Acme Industrial",
                phoneNumber: "555-0101",
                hostName: "Taylor Smith",
                siteName: "North Plant",
                visitReason: "Equipment inspection",
                signInTime: Date(),
                safetyBriefingCompleted: true,
                escorted: true,
                notes: "Wearing required PPE."
            ),
            Visitor(
                fullName: "Casey Nguyen",
                company: "Blue River Logistics",
                phoneNumber: "555-0102",
                hostName: "Morgan Davis",
                siteName: "Warehouse A",
                visitReason: "Delivery coordination",
                signInTime: Date().addingTimeInterval(-3600),
                signOutTime: Date(),
                safetyBriefingCompleted: true,
                escorted: false
            ),
        ]

        for visitor in sampleVisitors {
            context.insert(visitor)
        }

        return container
    }()
}
