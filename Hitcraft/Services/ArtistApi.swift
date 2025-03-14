import Foundation

@MainActor
final class ArtistApi {
    private let apiClient: ApiClient
    
    static let shared = ArtistApi(apiClient: .shared)
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func list() async throws -> [ArtistProfile] {
        let response: ArtistsResponse = try await apiClient.get(path: HCEnvironment.Endpoint.artists)
        // Convert dictionary to array and sort by name
        return response.artists.values.sorted { $0.name < $1.name }
    }
    
    func get(artistId: String) async throws -> ArtistProfile {
        let response: ArtistProfile = try await apiClient.get(path: HCEnvironment.Endpoint.artist(artistId))
        return response
    }
}

extension ArtistProfile {
    var displayName: String {
        name
    }
    
    var profileImageURL: URL? {
        guard let imageUrl = imageUrl else { return nil }
        return URL(string: imageUrl)
    }
    
    var genresList: String {
        preferredGenres?.joined(separator: ", ") ?? "No genres specified"
    }
    
    var shortBio: String {
        about ?? "No bio available"
    }
}
