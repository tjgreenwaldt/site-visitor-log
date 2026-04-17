import Foundation

struct SiteDTO: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}
