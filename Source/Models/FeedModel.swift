//
//  ItemViewModel.swift
//  vaela
//
//  Created by decoherence on 4/29/24.
//

import Foundation

struct APIFeedResponse: Codable {
    let entries: [APIEntry]
    let pagination: Pagination
}

struct Pagination: Codable {
    let currentPage: Int
    let hasNextPage: Bool
    let nextPage: Int?
}

struct APIEntry: Codable, Identifiable, Hashable {
    let id: String
    let sound: APISound
    let type: String
    let authorId: String
    let text: String
    let rating: Double?
    let loved: Bool
    let replay: Bool
    let chainsCount: Int
    let actionsCount: Int
    let createdAt: String
    let author: APIUser
    let heartedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case sound
        case type
        case authorId = "author_id"
        case text
        case rating
        case loved
        case replay
        case chainsCount = "chains_count"
        case actionsCount = "actions_count"
        case createdAt = "created_at"
        case author
        case heartedByUser
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        sound = try container.decode(APISound.self, forKey: .sound)
        type = try container.decode(String.self, forKey: .type)
        authorId = try container.decode(String.self, forKey: .authorId)
        text = try container.decode(String.self, forKey: .text)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        loved = try container.decode(Bool.self, forKey: .loved)
        replay = try container.decode(Bool.self, forKey: .replay)
        chainsCount = try container.decode(Int.self, forKey: .chainsCount)
        actionsCount = try container.decode(Int.self, forKey: .actionsCount)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        author = try container.decode(APIUser.self, forKey: .author)
        heartedByUser = try container.decode(Bool.self, forKey: .heartedByUser)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(sound, forKey: .sound)
        try container.encode(type, forKey: .type)
        try container.encode(authorId, forKey: .authorId)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(rating, forKey: .rating)
        try container.encode(loved, forKey: .loved)
        try container.encode(replay, forKey: .replay)
        try container.encode(chainsCount, forKey: .chainsCount)
        try container.encode(actionsCount, forKey: .actionsCount)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(author, forKey: .author)
        try container.encode(heartedByUser, forKey: .heartedByUser)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: APIEntry, rhs: APIEntry) -> Bool {
        lhs.id == rhs.id
    }
}


struct APISound: Codable {
    let id: String
    let appleId: String
    let type: String
    let appleData: APIAppleSoundData?
    
    enum CodingKeys: String, CodingKey {
        case id, type
        case appleId = "apple_id"
        case appleData = "apple_data"
    }
}


struct APIAppleSoundData: Codable {
    let id: String
    let type: String
    let name: String
    let artistName: String
    let releaseDate: String
    let artworkUrl: String
    let artworkBgColor: String // Change this to String
    let identifier: String
    
    enum CodingKeys: String, CodingKey {
        case id, type, name
        case artistName = "artist_name"
        case releaseDate = "release_date"
        case artworkUrl = "artwork_url"
        case artworkBgColor = "artwork_bgColor"
        case identifier
    }
}
