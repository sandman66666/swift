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
        ),
        ArtistProfile(
            id: "6761865ea1047907a44dc298",
            name: "The Chainsmokers",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/chainsmokers_image.png",
            role: ArtistRole(primary: "Producer", secondary: ["DJ", "Artist"])
        ),
        ArtistProfile(
            id: "676187038584d203389d367a",
            name: "Chamillionaire",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/cam_image.jpg",
            role: ArtistRole(primary: "Rapper", secondary: ["Producer"])
        ),
        ArtistProfile(
            id: "676187d61cf433efe9a025aa",
            name: "Max Martin",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/max_martin+(1).png",
            role: ArtistRole(primary: "Producer", secondary: ["Songwriter"])
        ),
        ArtistProfile(
            id: "67618d0af1728f41f0819b62",
            name: "Yinon Yahel (DJ)",
            imageUrl: "https://chord-analyser-public-s3bucket-dev.s3.us-east-1.amazonaws.com/yinon+image.png",
            role: ArtistRole(primary: "DJ", secondary: ["Producer"])
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

// MARK: - Message
struct Message: Identifiable, Codable, Hashable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    static let sampleMessages = [
        Message(
            text: "I'm an AI music creation expert, specializing in music production, lyrics, and distribution. What can I help you with today?",
            isFromUser: false,
            timestamp: Date()
        ),
        Message(
            text: "Can you help me find some good house music loops with R&B influence from the early 90s?",
            isFromUser: true,
            timestamp: Date().addingTimeInterval(-60)
        )
    ]
}

// MARK: - Chat
struct Chat: Identifiable {
    let id = UUID()
    let title: String
    let lastMessage: String
    let timestamp: Date
    var artist: ArtistProfile
    
    static let sampleChats = [
        Chat(
            title: "Need help with my 2nd verse...",
            lastMessage: "Let me help you with that lyrics",
            timestamp: Date().addingTimeInterval(-86400),
            artist: ArtistProfile.sampleArtists[0]
        ),
        Chat(
            title: "Catchy drop ideas",
            lastMessage: "Here are some suggestions for your drop",
            timestamp: Date().addingTimeInterval(-86400 * 3),
            artist: ArtistProfile.sampleArtists[1]
        ),
        Chat(
            title: "Pop ballad production",
            lastMessage: "Let's work on your ballad",
            timestamp: Date().addingTimeInterval(-86400 * 4),
            artist: ArtistProfile.sampleArtists[2]
        )
    ]
}
