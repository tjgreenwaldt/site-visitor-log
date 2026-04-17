import Foundation
import SwiftData

@Model
final class VisitorRecordEntity {
    @Attribute(.unique) var localId: UUID
    var remoteId: String?
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
    // Kept for now to avoid a persistence migration while photo support is disabled.
    var photoData: Data?
    var latitude: Double?
    var longitude: Double?
    var createdAt: Date
    var updatedAt: Date
    var syncStatusRawValue: String
    var deviceId: String

    var syncStatus: VisitorRecordSyncStatus {
        get { VisitorRecordSyncStatus(rawValue: syncStatusRawValue) ?? .localOnly }
        set { syncStatusRawValue = newValue.rawValue }
    }

    init(
        localId: UUID = UUID(),
        remoteId: String? = nil,
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
        longitude: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncStatus: VisitorRecordSyncStatus = .localOnly,
        deviceId: String = ""
    ) {
        self.localId = localId
        self.remoteId = remoteId
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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatusRawValue = syncStatus.rawValue
        self.deviceId = deviceId
    }
}

extension VisitorRecordEntity {
    convenience init(dto: VisitorRecordDTO) {
        self.init(
            localId: dto.localId,
            remoteId: dto.remoteId,
            siteId: dto.siteId,
            fullName: dto.fullName,
            company: dto.company,
            phoneNumber: dto.phoneNumber,
            hostName: dto.hostName,
            siteName: dto.siteName,
            visitReason: dto.visitReason,
            signInTime: dto.signInTime,
            signOutTime: dto.signOutTime,
            safetyBriefingCompleted: dto.safetyBriefingCompleted,
            escorted: dto.escorted,
            notes: dto.notes,
            latitude: dto.latitude,
            longitude: dto.longitude,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            syncStatus: dto.syncStatus,
            deviceId: dto.deviceId
        )
    }

    var dto: VisitorRecordDTO {
        VisitorRecordDTO(
            localId: localId,
            remoteId: remoteId,
            siteId: siteId,
            fullName: fullName,
            company: company,
            phoneNumber: phoneNumber,
            hostName: hostName,
            siteName: siteName,
            visitReason: visitReason,
            signInTime: signInTime,
            signOutTime: signOutTime,
            safetyBriefingCompleted: safetyBriefingCompleted,
            escorted: escorted,
            notes: notes,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            deviceId: deviceId
        )
    }

    func applyValues(from dto: VisitorRecordDTO) {
        remoteId = dto.remoteId
        siteId = dto.siteId
        fullName = dto.fullName
        company = dto.company
        phoneNumber = dto.phoneNumber
        hostName = dto.hostName
        siteName = dto.siteName
        visitReason = dto.visitReason
        signInTime = dto.signInTime
        signOutTime = dto.signOutTime
        safetyBriefingCompleted = dto.safetyBriefingCompleted
        escorted = dto.escorted
        notes = dto.notes
        latitude = dto.latitude
        longitude = dto.longitude
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
        syncStatus = dto.syncStatus
        deviceId = dto.deviceId
    }
}
