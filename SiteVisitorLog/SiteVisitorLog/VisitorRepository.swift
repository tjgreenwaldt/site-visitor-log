import Foundation
import SwiftUI
import SwiftData

@MainActor
protocol VisitorRepository {
    func createVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO
    func updateVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO
    func signOutVisitor(id: UUID) throws -> VisitorRecordDTO
    func fetchActiveVisitors(for siteId: String) throws -> [VisitorRecordDTO]
    func fetchVisitorHistory(for siteId: String) throws -> [VisitorRecordDTO]
    func fetchVisitor(id: UUID) throws -> VisitorRecordDTO?
    func fetchVisitorsNeedingSync() throws -> [VisitorRecordDTO]
    func markSyncStatus(id: UUID, status: VisitorRecordSyncStatus) throws -> VisitorRecordDTO
    func markSyncSuccess(id: UUID, remoteId: String?, updatedAt: Date) throws -> VisitorRecordDTO
    func markSyncFailure(id: UUID) throws -> VisitorRecordDTO
    func upsertRemoteVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO
    func pruneSyncedHistory(olderThan cutoffDate: Date) throws
}

enum VisitorRepositoryError: LocalizedError {
    case visitorNotFound

    var errorDescription: String? {
        switch self {
        case .visitorNotFound:
            return "Visitor record not found."
        }
    }
}

extension Notification.Name {
    static let visitorRecordsDidChange = Notification.Name("visitorRecordsDidChange")
}

private struct VisitorRepositoryKey: EnvironmentKey {
    @MainActor
    static var defaultValue: any VisitorRepository {
        PreviewVisitorRepository()
    }
}

extension EnvironmentValues {
    var visitorRepository: any VisitorRepository {
        get { self[VisitorRepositoryKey.self] }
        set { self[VisitorRepositoryKey.self] = newValue }
    }
}

@MainActor
private final class PreviewVisitorRepository: VisitorRepository {
    private let repository = SwiftDataVisitorRepository(modelContext: PreviewSampleData.container.mainContext)

    func createVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO {
        try repository.createVisitor(visitor)
    }

    func updateVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO {
        try repository.updateVisitor(visitor)
    }

    func signOutVisitor(id: UUID) throws -> VisitorRecordDTO {
        try repository.signOutVisitor(id: id)
    }

    func fetchActiveVisitors(for siteId: String) throws -> [VisitorRecordDTO] {
        try repository.fetchActiveVisitors(for: siteId)
    }

    func fetchVisitorHistory(for siteId: String) throws -> [VisitorRecordDTO] {
        try repository.fetchVisitorHistory(for: siteId)
    }

    func fetchVisitor(id: UUID) throws -> VisitorRecordDTO? {
        try repository.fetchVisitor(id: id)
    }

    func fetchVisitorsNeedingSync() throws -> [VisitorRecordDTO] {
        try repository.fetchVisitorsNeedingSync()
    }

    func markSyncStatus(id: UUID, status: VisitorRecordSyncStatus) throws -> VisitorRecordDTO {
        try repository.markSyncStatus(id: id, status: status)
    }

    func markSyncSuccess(id: UUID, remoteId: String?, updatedAt: Date) throws -> VisitorRecordDTO {
        try repository.markSyncSuccess(id: id, remoteId: remoteId, updatedAt: updatedAt)
    }

    func markSyncFailure(id: UUID) throws -> VisitorRecordDTO {
        try repository.markSyncFailure(id: id)
    }

    func upsertRemoteVisitor(_ visitor: VisitorRecordDTO) throws -> VisitorRecordDTO {
        try repository.upsertRemoteVisitor(visitor)
    }

    func pruneSyncedHistory(olderThan cutoffDate: Date) throws {
        try repository.pruneSyncedHistory(olderThan: cutoffDate)
    }
}
