import Foundation

// MARK: - API Response Type
struct HCApiResponse<T: Codable>: Codable {  // Renamed to avoid conflicts
    let data: T
    let status: Int
    let message: String?
}

// MARK: - Artist Types
struct ArtistProfile: Codable, Identifiable {
    var id: String { email }
    let email: String
    let name: String
    var instructions: String?
    var phoneNumber: String?
    var birthdate: String?
    var imageUrl: String?
    var about: String?
    var biography: [String]?
    var role: ArtistRole?
    var livesIn: String?
    var musicalAchievements: [String]?
    var buisnessAchievements: [String]?
    var preferredGenres: [String]?
    var famousWorks: [String]?
    var socialMediaLinks: [String]?
}

struct ArtistRole: Codable {
    let primary: String
    var secondary: [String]?
}
