//
//  PreviewSampleData.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import Foundation
import SwiftData
import UIKit

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
        let now = Date()

        let sampleVisitors = [
            Visitor(
                fullName: "Jordan Lee",
                company: "Acme Industrial",
                phoneNumber: "555-0101",
                hostName: "Taylor Smith",
                siteName: "North Plant",
                visitReason: "Equipment inspection",
                signInTime: now.addingTimeInterval(-1800),
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
                signInTime: now.addingTimeInterval(-7200),
                signOutTime: now.addingTimeInterval(-3600),
                safetyBriefingCompleted: true,
                escorted: false,
                photoData: makePhotoData(systemName: "person.fill", color: .systemBlue)
            ),
            Visitor(
                fullName: "Avery Patel",
                company: "Summit Contractors",
                phoneNumber: "555-0103",
                hostName: "Jamie Cooper",
                siteName: "South Gate",
                visitReason: "Site walkthrough",
                signInTime: now.addingTimeInterval(-14400),
                signOutTime: now.addingTimeInterval(-10800),
                safetyBriefingCompleted: true,
                escorted: true,
                photoData: makePhotoData(systemName: "person.crop.circle.fill", color: .systemGreen)
            ),
            Visitor(
                fullName: "Riley Brooks",
                company: "Northstar Power",
                phoneNumber: "555-0104",
                hostName: "Alex Morgan",
                siteName: "Control Room",
                visitReason: "Maintenance review",
                signInTime: now.addingTimeInterval(-21600),
                signOutTime: now.addingTimeInterval(-18000),
                safetyBriefingCompleted: false,
                escorted: true
            ),
            Visitor(
                fullName: "Taylor Gomez",
                company: "Riverbend Supply",
                phoneNumber: "555-0105",
                hostName: "Chris Reed",
                siteName: "Loading Dock",
                visitReason: "Parts delivery",
                signInTime: now.addingTimeInterval(-28800),
                signOutTime: now.addingTimeInterval(-25200),
                safetyBriefingCompleted: true,
                escorted: false
            ),
        ]

        for visitor in sampleVisitors {
            context.insert(visitor)
        }

        return container
    }()

    private static func makePhotoData(systemName: String, color: UIColor) -> Data? {
        let size = CGSize(width: 120, height: 120)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let configuration = UIImage.SymbolConfiguration(pointSize: 52, weight: .medium)
            let symbolImage = UIImage(systemName: systemName, withConfiguration: configuration)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)

            let symbolSize = CGSize(width: 52, height: 52)
            let symbolOrigin = CGPoint(
                x: (size.width - symbolSize.width) / 2,
                y: (size.height - symbolSize.height) / 2
            )

            symbolImage?.draw(in: CGRect(origin: symbolOrigin, size: symbolSize))
        }

        return image.jpegData(compressionQuality: 0.8)
    }
}
