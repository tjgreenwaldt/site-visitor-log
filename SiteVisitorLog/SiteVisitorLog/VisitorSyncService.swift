import Foundation
import SwiftUI
import Combine

@MainActor
final class VisitorSyncService: ObservableObject {
    @Published private(set) var pendingSyncCount = 0
    @Published private(set) var lastSyncAttemptAt: Date?
    @Published private(set) var lastSuccessfulSyncAt: Date?
    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncError: String?

    private let repository: any VisitorRepository
    private let remoteDataSource: any VisitorRemoteDataSource
    private var changeObserver: NSObjectProtocol?

    init(repository: any VisitorRepository, remoteDataSource: any VisitorRemoteDataSource) {
        self.repository = repository
        self.remoteDataSource = remoteDataSource
        changeObserver = NotificationCenter.default.addObserver(
            forName: .visitorRecordsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshPendingSyncCount()
            }
        }

        refreshPendingSyncCount()
    }

    deinit {
        if let changeObserver {
            NotificationCenter.default.removeObserver(changeObserver)
        }
    }

    func refreshPendingSyncCount() {
        do {
            pendingSyncCount = try repository.fetchVisitorsNeedingSync().count
        } catch {
            print("Failed to refresh pending sync count: \(error)")
        }
    }

    func syncPendingVisitors() async {
        guard !isSyncing else { return }

        isSyncing = true
        lastSyncAttemptAt = Date()
        lastSyncError = nil
        defer {
            isSyncing = false
            refreshPendingSyncCount()
        }

        do {
            try await uploadPendingVisitors()
            try await downloadRemoteChanges()
            lastSuccessfulSyncAt = Date()
        } catch {
            lastSyncError = error.localizedDescription
        }
    }

    private func uploadPendingVisitors() async throws {
        let pendingVisitors = try repository.fetchVisitorsNeedingSync()

        for visitor in pendingVisitors {
            do {
                let canonicalVisitor = try await remoteDataSource.upload(visitor: visitor)
                _ = try repository.markSyncSuccess(
                    id: visitor.id,
                    remoteId: canonicalVisitor.remoteId,
                    updatedAt: canonicalVisitor.updatedAt
                )
            } catch {
                _ = try? repository.markSyncFailure(id: visitor.id)
                lastSyncError = error.localizedDescription
            }
        }
    }

    private func downloadRemoteChanges() async throws {
        let remoteVisitors = try await remoteDataSource.fetchVisitorsChanged(since: lastSuccessfulSyncAt)

        for remoteVisitor in remoteVisitors {
            _ = try repository.upsertRemoteVisitor(remoteVisitor)
        }
    }
}
