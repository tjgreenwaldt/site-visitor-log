import Foundation
import SwiftData

#if os(iOS)
import UIKit
#endif

@MainActor
final class SwiftDataVisitorRepository: VisitorRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO {
        let now = Date()
        let preparedVisitor = VisitorRecordDTO(
            localId: visitor.localId,
            remoteId: visitor.remoteId,
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
            createdAt: now,
            updatedAt: now,
            syncStatus: .pendingUpload,
            deviceId: resolvedDeviceId(from: visitor.deviceId)
        )

        let entity = VisitorRecordEntity(dto: preparedVisitor)
        modelContext.insert(entity)
        try save()
        return entity.dto
    }

    func updateVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO {
        let entity = try fetchEntity(id: visitor.localId)
        let now = Date()
        let preparedVisitor = VisitorRecordDTO(
            localId: entity.localId,
            remoteId: visitor.remoteId ?? entity.remoteId,
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
            createdAt: entity.createdAt,
            updatedAt: now,
            syncStatus: mutationSyncStatus(for: entity),
            deviceId: resolvedDeviceId(from: visitor.deviceId.isEmpty ? entity.deviceId : visitor.deviceId)
        )

        entity.applyValues(from: preparedVisitor)
        try save()
        return entity.dto
    }

    func signOutVisitor(id: UUID) throws -> VisitorRecordDTO {
        let entity = try fetchEntity(id: id)
        entity.signOutTime = Date()
        entity.updatedAt = Date()
        entity.syncStatus = mutationSyncStatus(for: entity)
        entity.deviceId = resolvedDeviceId(from: entity.deviceId)
        try save()
        return entity.dto
    }

    func fetchActiveVisitors(for siteId: String) throws -> [VisitorRecordDTO] {
        let descriptor = FetchDescriptor<VisitorRecordEntity>(
            predicate: #Predicate { entity in
                entity.siteId == siteId && entity.signOutTime == nil
            },
            sortBy: [SortDescriptor(\.signInTime, order: .reverse)]
        )

        return try modelContext.fetch(descriptor).map(\.dto)
    }

    func fetchVisitorHistory(for siteId: String) throws -> [VisitorRecordDTO] {
        let descriptor = FetchDescriptor<VisitorRecordEntity>(
            predicate: #Predicate { entity in
                entity.siteId == siteId && entity.signOutTime != nil
            },
            sortBy: [SortDescriptor(\.signOutTime, order: .reverse)]
        )

        return try modelContext.fetch(descriptor).map(\.dto)
    }

    func fetchVisitor(id: UUID) throws -> VisitorRecordDTO? {
        let descriptor = FetchDescriptor<VisitorRecordEntity>(
            predicate: #Predicate { entity in
                entity.localId == id
            }
        )

        return try modelContext.fetch(descriptor).first?.dto
    }

    func fetchVisitorsNeedingSync() throws -> [VisitorRecordDTO] {
        let descriptor = FetchDescriptor<VisitorRecordEntity>(
            sortBy: [SortDescriptor(\VisitorRecordEntity.updatedAt, order: .forward)]
        )

        return try modelContext.fetch(descriptor)
            .filter { $0.syncStatus == .pendingUpload || $0.syncStatus == .modified || $0.syncStatus == .syncError }
            .map(\.dto)
    }

    func markSyncStatus(id: UUID, status: VisitorRecordSyncStatus) throws -> VisitorRecordDTO {
        let entity = try fetchEntity(id: id)
        entity.syncStatus = status
        entity.updatedAt = Date()
        try save()
        return entity.dto
    }

    func markSyncSuccess(id: UUID, remoteId: String?, updatedAt: Date) throws -> VisitorRecordDTO {
        let entity = try fetchEntity(id: id)
        entity.remoteId = remoteId ?? entity.remoteId ?? "mock-\(entity.localId.uuidString.lowercased())"
        entity.syncStatus = .synced
        entity.updatedAt = updatedAt
        try save()
        return entity.dto
    }

    func markSyncFailure(id: UUID) throws -> VisitorRecordDTO {
        let entity = try fetchEntity(id: id)
        entity.syncStatus = .syncError
        entity.updatedAt = Date()
        try save()
        return entity.dto
    }

    func upsertRemoteVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO {
        if let remoteId = visitor.remoteId, let entity = try fetchEntity(remoteId: remoteId) {
            guard visitor.updatedAt >= entity.updatedAt else {
                return entity.dto
            }

            applyRemote(visitor, to: entity)
            try save()
            return entity.dto
        }

        if let entity = try fetchEntity(localId: visitor.localId) {
            guard visitor.updatedAt >= entity.updatedAt else {
                return entity.dto
            }

            applyRemote(visitor, to: entity)
            try save()
            return entity.dto
        }

        let remoteVisitor = VisitorRecordDTO(
            localId: visitor.localId,
            remoteId: visitor.remoteId,
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
            updatedAt: visitor.updatedAt,
            syncStatus: .synced,
            deviceId: visitor.deviceId
        )

        let entity = VisitorRecordEntity(dto: remoteVisitor)
        modelContext.insert(entity)
        try save()
        return entity.dto
    }

    private func fetchEntity(id: UUID) throws -> VisitorRecordEntity {
        guard let entity = try fetchEntity(localId: id) else {
            throw VisitorRepositoryError.visitorNotFound
        }

        return entity
    }

    private func fetchEntity(localId: UUID) throws -> VisitorRecordEntity? {
        let descriptor = FetchDescriptor<VisitorRecordEntity>(
            predicate: #Predicate { entity in
                entity.localId == localId
            }
        )

        return try modelContext.fetch(descriptor).first
    }

    private func fetchEntity(remoteId: String) throws -> VisitorRecordEntity? {
        let descriptor = FetchDescriptor<VisitorRecordEntity>(
            predicate: #Predicate { entity in
                entity.remoteId == remoteId
            }
        )

        return try modelContext.fetch(descriptor).first
    }

    private func mutationSyncStatus(for entity: VisitorRecordEntity) -> VisitorRecordSyncStatus {
        if entity.remoteId == nil {
            return .pendingUpload
        }

        switch entity.syncStatus {
        case .localOnly, .pendingUpload:
            return .pendingUpload
        case .synced, .modified, .syncError:
            return .modified
        }
    }

    private func resolvedDeviceId(from value: String) -> String {
        if !value.isEmpty {
            return value
        }

        #if os(iOS)
        return UIDevice.current.identifierForVendor?.uuidString ?? ProcessInfo.processInfo.hostName
        #else
        return ProcessInfo.processInfo.hostName
        #endif
    }

    private func save() throws {
        try modelContext.save()
        NotificationCenter.default.post(name: .visitorRecordsDidChange, object: nil)
    }

    private func applyRemote(_ visitor: VisitorRecordDTO, to entity: VisitorRecordEntity) {
        entity.remoteId = visitor.remoteId
        entity.siteId = visitor.siteId
        entity.fullName = visitor.fullName
        entity.company = visitor.company
        entity.phoneNumber = visitor.phoneNumber
        entity.hostName = visitor.hostName
        entity.siteName = visitor.siteName
        entity.visitReason = visitor.visitReason
        entity.signInTime = visitor.signInTime
        entity.signOutTime = visitor.signOutTime
        entity.safetyBriefingCompleted = visitor.safetyBriefingCompleted
        entity.escorted = visitor.escorted
        entity.notes = visitor.notes
        entity.latitude = visitor.latitude
        entity.longitude = visitor.longitude
        entity.createdAt = visitor.createdAt
        entity.updatedAt = visitor.updatedAt
        entity.syncStatus = .synced
        entity.deviceId = visitor.deviceId
    }
}
