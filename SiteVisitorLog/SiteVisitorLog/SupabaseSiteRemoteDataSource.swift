import Foundation
import Supabase

final class SupabaseSiteRemoteDataSource: SiteRemoteDataSource, @unchecked Sendable {
    private let client = SupabaseClientProvider.shared

    func fetchSites() async throws -> [SiteDTO] {
        let rows: [SupabaseSiteRow] = try await client
            .from("sites")
            .select()
            .order("name", ascending: true)
            .execute()
            .value

        return rows.map(\.dto)
    }
}

private struct SupabaseSiteRow: Codable, Sendable {
    let id: String
    let name: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var dto: SiteDTO {
        SiteDTO(
            id: id,
            name: name,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
