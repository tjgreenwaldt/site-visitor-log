import Foundation

enum VisitorRemoteDataSourceProvider {
    static func make(
        backend: SupabaseConfig.Backend = SupabaseConfig.backend
    ) -> any VisitorRemoteDataSource {
        switch backend {
        case .mock:
            return makeMock()
        case .supabase:
            guard SupabaseConfig.isConfigured else {
                return makeMock()
            }

            return makeSupabase()
        }
    }

    static func makeMock() -> any VisitorRemoteDataSource {
        MockVisitorRemoteDataSource()
    }

    static func makeSupabase() -> any VisitorRemoteDataSource {
        SupabaseVisitorRemoteDataSource()
    }
}
