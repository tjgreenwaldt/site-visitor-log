import Foundation

enum VisitorRecordSyncStatus: String, Codable, Sendable, CaseIterable {
    case localOnly
    case pendingUpload
    case synced
    case modified
    case syncError
}

extension VisitorRecordSyncStatus {
    var needsSync: Bool {
        switch self {
        case .localOnly, .pendingUpload, .modified, .syncError:
            return true
        case .synced:
            return false
        }
    }
}
