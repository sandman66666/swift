// Models.swift
import Foundation

// MARK: - API Response Types
struct ArtistsResponse: Codable {
    let artists: [String: ArtistProfile]
}

// MARK: - Artist Profile
struct ArtistProfile: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let imageUrl: String?
    
    var instructions: String?
    var phoneNumber: String?
    var birthdate: String?
    var about: String?
    var biography: [String]?
    var role: ArtistRole?
    var livesIn: String?
    var musicalAchievements: [String]?
    var buisnessAchievements: [String]?
    var preferredGenres: [String]?
    var famousWorks: [String]?
    var socialMediaLinks: [String]?
    
    // Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ArtistProfile, rhs: ArtistProfile) -> Bool {
        lhs.id == rhs.id
    }
    
    // Sample data
    static let sampleArtists = [
        ArtistProfile(
            id: "67618ad67dc13643acff6a25",
            name: "HitCraft",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/hiti.svg",
            role: ArtistRole(primary: "AI Music Assistant")
        )
    ]
    
    static let sample = sampleArtists[0]
}

// MARK: - Artist Role
struct ArtistRole: Codable, Hashable {
    let primary: String
    var secondary: [String]?
}

// MARK: - Track
struct Track: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let imageNumber: Int
    let verified: Bool
    var artistId: String?
    var imageUrl: String?
    
    init(id: UUID = UUID(), title: String, artist: String, imageNumber: Int, verified: Bool = true, artistId: String? = nil, imageUrl: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.imageNumber = imageNumber
        self.verified = verified
        self.artistId = artistId
        self.imageUrl = imageUrl
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
    
    static let sampleTracks = [
        Track(
            title: "Summer Vibes",
            artist: "The Chainsmokers",
            imageNumber: 1,
            verified: true,
            artistId: "6761865ea1047907a44dc298",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/chainsmokers_image.png"
        ),
        Track(
            title: "Midnight Dreams",
            artist: "Max Martin",
            imageNumber: 2,
            verified: true,
            artistId: "676187d61cf433efe9a025aa",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/max_martin+(1).png"
        ),
        Track(
            title: "Dance Tonight",
            artist: "Yinon Yahel",
            imageNumber: 3,
            verified: true,
            artistId: "67618d0af1728f41f0819b62",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/yinon+image.png"
        ),
        Track(
            title: "Urban Flow",
            artist: "Chamillionaire",
            imageNumber: 4,
            verified: true,
            artistId: "676187038584d203389d367a",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/cam_image.jpg"
        )
    ]
}
