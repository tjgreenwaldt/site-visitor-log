import Foundation

protocol SiteRemoteDataSource: Sendable {
    func fetchSites() async throws -> [SiteDTO]
}
