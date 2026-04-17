import Foundation

protocol VisitorRemoteDataSource: Sendable {
    func upload(visitor: VisitorRecordDTO) async throws -> VisitorRecordDTO
    func fetchVisitorsChanged(since: Date?) async throws -> [VisitorRecordDTO]
}

actor MockVisitorRemoteDataSource: VisitorRemoteDataSource {
    private var recordsByRemoteId: [String: VisitorRecordDTO] = [:]

    func upload(visitor: VisitorRecordDTO) async throws -> VisitorRecordDTO {
        try await Task.sleep(for: .milliseconds(300))

        let remoteId = visitor.remoteId ?? "remote-\(visitor.localId.uuidString.lowercased())"
        let serverNow = Date()
        let existingRecord = recordsByRemoteId[remoteId]
        let mergedUpdatedAt = max(existingRecord?.updatedAt ?? .distantPast, visitor.updatedAt, serverNow)

        let storedRecord = VisitorRecordDTO(
            localId: visitor.localId,
            remoteId: remoteId,
            siteId: visitor.siteId,
            fullName: visitor.fullName,
            company: visitor.company,
            phoneNumber: visitor.phoneNumber,
            hostName: visitor.hostName,
            siteName: visitor.siteName,
            visitReason: visitor.visitReason,
            signInTime: visitor.signInTime,
            signOutTime: visitor.signOutTime,
            safetyBriefingCompleted: visitor.safetyBriefingCompleted,
            escorted: visitor.escorted,
            notes: visitor.notes,
            latitude: visitor.latitude,
            longitude: visitor.longitude,
            createdAt: visitor.createdAt,
            updatedAt: mergedUpdatedAt,
            syncStatus: .synced,
            deviceId: visitor.deviceId
        )

        recordsByRemoteId[remoteId] = storedRecord
        return storedRecord
    }

    func fetchVisitorsChanged(since: Date?) async throws -> [VisitorRecordDTO] {
        try await Task.sleep(for: .milliseconds(250))

        let records = recordsByRemoteId.values.sorted { $0.updatedAt < $1.updatedAt }

        guard let since else {
            return records
        }

        return records.filter { $0.updatedAt > since }
    }
}
