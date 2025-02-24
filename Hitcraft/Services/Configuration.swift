import Foundation

// MARK: - Environment Configuration
enum HCEnvironment {  // Renamed to avoid conflicts
    static let apiBaseURL = "https://api.dev.hitcraft.ai"
    static let webAppURL = "https://app.dev.hitcraft.ai"
    static let authBaseURL = "https://auth.dev.hitcraft.ai"
    static let descopeProjectId = "P2rIvbtGcXTcUfT68LGuVqPitlJd"
}

// MARK: - API Endpoints
enum ApiEndpoint {
    static let artist = "/api/v1/artist"
    static let chat = "/api/v1/chat"
    static let user = "/api/v1/user"
}
