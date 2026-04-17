//
//  Visitor.swift
//  SiteVisitorLog
//
//  Created by Tyler Greenwaldt on 4/16/26.
//

import Foundation
import SwiftData

@Model
final class Visitor {
    @Attribute(.unique) var id: UUID
    var siteId: String
    var fullName: String
    var company: String
    var phoneNumber: String
    var hostName: String
    var siteName: String
    var visitReason: String
    var signInTime: Date
    var signOutTime: Date?
    var safetyBriefingCompleted: Bool
    var escorted: Bool
    var notes: String?
    var photoData: Data?
    var latitude: Double?
    var longitude: Double?

    init(
        id: UUID = UUID(),
        siteId: String,
        fullName: String,
        company: String,
        phoneNumber: String,
        hostName: String,
        siteName: String,
        visitReason: String,
        signInTime: Date = Date(),
        signOutTime: Date? = nil,
        safetyBriefingCompleted: Bool,
        escorted: Bool,
        notes: String? = nil,
        photoData: Data? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.siteId = siteId
        self.fullName = fullName
        self.company = company
        self.phoneNumber = phoneNumber
        self.hostName = hostName
        self.siteName = siteName
        self.visitReason = visitReason
        self.signInTime = signInTime
        self.signOutTime = signOutTime
        self.safetyBriefingCompleted = safetyBriefingCompleted
        self.escorted = escorted
        self.notes = notes
        self.photoData = photoData
        self.latitude = latitude
        self.longitude = longitude
    }
}
