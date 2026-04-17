import Foundation
import SwiftData

@Model
final class SiteEntity {
    @Attribute(.unique) var localId: UUID
    @Attribute(.unique) var siteId: String
    var name: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        localId: UUID = UUID(),
        siteId: String,
        name: String,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.localId = localId
        self.siteId = siteId
        self.name = name
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
