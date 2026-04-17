import Foundation
import SwiftUI
import Combine

@MainActor
final class VisitorSyncService: ObservableObject {
    @Published private(set) var pendingSyncCount = 0
    @Published private(set) var lastSyncAttemptAt: Date?
    @Published private(set) var isSyncing = false

    private let repository: any VisitorRepository
    private var changeObserver: NSObjectProtocol?

    init(repository: any VisitorRepository) {
        self.repository = repository
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
        defer {
            isSyncing = false
            refreshPendingSyncCount()
        }

        do {
            let pendingVisitors = try repository.fetchVisitorsNeedingSync()

            for visitor in pendingVisitors {
                do {
                    _ = try repository.markSyncStatus(id: visitor.id, status: .pendingUpload)
                    try await Task.sleep(for: .milliseconds(350))
                    let remoteId = visitor.remoteId ?? "mock-\(visitor.id.uuidString.lowercased())"
                    _ = try repository.markSyncSuccess(id: visitor.id, remoteId: remoteId)
                } catch {
                    do {
                        _ = try repository.markSyncFailure(id: visitor.id)
                    } catch {
                        print("Failed to mark sync failure: \(error)")
                    }
                }
            }
        } catch {
            print("Failed to sync visitors: \(error)")
        }
    }
}
