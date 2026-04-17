import Foundation

struct VisitorRecordDTO: Codable, Identifiable, Sendable {
    let localId: UUID
    let remoteId: String?
    let siteId: String
    let fullName: String
    let company: String
    let phoneNumber: String
    let hostName: String
    let siteName: String
    let visitReason: String
    let signInTime: Date
    let signOutTime: Date?
    let safetyBriefingCompleted: Bool
    let escorted: Bool
    let notes: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: Date
    let updatedAt: Date
    let syncStatus: VisitorRecordSyncStatus
    let deviceId: String

    var id: UUID { localId }

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
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
        self.deviceId = deviceId
    }
}
