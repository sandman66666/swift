import Foundation

@MainActor
final class ArtistApi {
    private let apiClient: ApiClient
    
    static let shared: ArtistApi = {
        let api = ArtistApi(apiClient: .shared)
        return api
    }()
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func list() async throws -> [ArtistProfile] {
        let response: HCApiResponse<[ArtistProfile]> = try await apiClient.get(path: ApiEndpoint.artist)
        return response.data
    }
    
    func get(artistId: String) async throws -> ArtistProfile {
        let response: HCApiResponse<ArtistProfile> = try await apiClient.get(path: "\(ApiEndpoint.artist)/\(artistId)")
        return response.data
    }
    
    func updateInstructions(artistId: String, instructions: String) async throws {
        let _: HCApiResponse<ArtistProfile> = try await apiClient.post(
            path: "\(ApiEndpoint.artist)/\(artistId)/instructions",
            body: ["instructions": instructions]
        )
    }
    
    func updateInfo(artistId: String, data: [String: Any]) async throws {
        let _: HCApiResponse<ArtistProfile> = try await apiClient.post(
            path: "\(ApiEndpoint.artist)/\(artistId)/info",
            body: data
        )
    }
}
