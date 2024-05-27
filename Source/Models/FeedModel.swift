//
//  ItemViewModel.swift
//  vaela
//
//  Created by decoherence on 4/29/24.
//

import Foundation

class FeedModel: ObservableObject {
    @Published var entries: [APIEntry] = []
    @Published var isLoading: Bool = false
    @Published var currentPage = 1
    @Published var canLoadMore = true
    var userId: String = ""
    
    func fetchEntries() {
            guard !isLoading && canLoadMore else { return }
            isLoading = true
            
            FeedAPI.fetchEntries(page: currentPage, userId: userId) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let response):
                        print("Fetched \(response.entries.count) new entries")
                        self.entries.append(contentsOf: response.entries)
                        self.currentPage = response.pagination.nextPage ?? self.currentPage + 1
                        self.canLoadMore = response.pagination.hasNextPage
                        self.isLoading = false
                    case .failure(let error):
                        print("Error fetching items: \(error.localizedDescription)")
                        self.isLoading = false
                        self.canLoadMore = false
                    }
                }
            }
        }
}



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
    let soundId: String
    let soundAppleId: String
    let soundType: String
    let type: String
    let authorId: String
    let text: String
    let createdAt: String
    let actionsCount: String
    let chainsCount: String
    let rating: Double
    let loved: Bool
    let replay: Bool
    let heartedByUser: Bool
    let author: APIAuthor
    let soundData: APISound
    
    enum CodingKeys: String, CodingKey {
        case id, soundId = "sound_id", soundAppleId = "sound_apple_id", soundType = "sound_type", type, authorId = "author_id", text, createdAt = "created_at", actionsCount = "actions_count", chainsCount = "chains_count", rating, loved, replay, heartedByUser = "heartedByUser", author, soundData = "sound_data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        soundId = try container.decode(String.self, forKey: .soundId)
        soundAppleId = try container.decode(String.self, forKey: .soundAppleId)
        soundType = try container.decode(String.self, forKey: .soundType)
        type = try container.decode(String.self, forKey: .type)
        authorId = try container.decode(String.self, forKey: .authorId)
        text = try container.decode(String.self, forKey: .text)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        actionsCount = try container.decode(String.self, forKey: .actionsCount)
        chainsCount = try container.decode(String.self, forKey: .chainsCount)
        let ratingString = try container.decode(String.self, forKey: .rating)
        rating = Double(ratingString) ?? 0.0
        
        let lovedString = try container.decode(String.self, forKey: .loved)
        loved = lovedString.lowercased() == "true"
        
        let replayString = try container.decode(String.self, forKey: .replay)
        replay = replayString.lowercased() == "true"
        
        heartedByUser = try container.decode(Bool.self, forKey: .heartedByUser)
        author = try container.decode(APIAuthor.self, forKey: .author)
        soundData = try container.decode(APISound.self, forKey: .soundData)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: APIEntry, rhs: APIEntry) -> Bool {
        lhs.id == rhs.id
    }
}

struct APIEssential: Codable, Identifiable {
    let id: String
    let rank: Int
    let soundAppleId: String
    let soundId: String
    let soundData: APISound
    
    enum CodingKeys: String, CodingKey {
        case id
        case rank
        case soundAppleId = "sound__apple_id"
        case soundId = "sound__id"
        case soundData
    }
}

struct APIAuthor: Codable, Identifiable {
    let id: String
    let image: URL?
    let username: String
    let bio: String?
    let essentials: [APIEssential]
    
    enum CodingKeys: String, CodingKey {
        case id, image, username, bio, essentials
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        let imageString = try container.decode(String.self, forKey: .image)
        image = URL(string: imageString)
        username = try container.decode(String.self, forKey: .username)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        
        // Decode the essentials string decode it to an array of Essential
        let essentialsString = try container.decode(String.self, forKey: .essentials)
        if let data = essentialsString.data(using: .utf8) {
            essentials = try JSONDecoder().decode([APIEssential].self, from: data)
        } else {
            essentials = []
        }
    }
}

struct APISound: Codable {
    let identifier: String
    let name: String
    let releaseDate: String
    let type: String
    let artistName: String
    let artworkBgColor: String
    let artworkUrl: String
    
    var formattedArtworkUrl: URL? {
        let modifiedURLString = artworkUrl
            .replacingOccurrences(of: "{w}", with: "1000")
            .replacingOccurrences(of: "{h}", with: "1000")
        
        return URL(string: modifiedURLString)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier, name, releaseDate = "release_date", type, artistName = "artist_name", artworkBgColor = "artwork_bgColor", artworkUrl = "artwork_url"
    }
}
