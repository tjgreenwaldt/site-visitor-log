import Foundation

enum SupabaseConfig {
    enum Backend {
        case mock
        case supabase
    }

    static let backend: Backend = .supabase
    static let projectURL = "https://ekietqycbvnrpbprcmtj.supabase.co"
    static let anonKey = "sb_publishable_iXaKbYjgSHqReatDvLWM9w_swKbidIO"

    static var isConfigured: Bool {
        projectURL != "YOUR_SUPABASE_PROJECT_URL" &&
        anonKey != "YOUR_SUPABASE_ANON_KEY" &&
        URL(string: projectURL) != nil
    }
}
