//
//  SearchModel.swift
//  InstagramTransition
//
//  Created by decoherence on 5/7/24.
//

import Foundation
import SwiftUI

class SearchModel: ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var isLoading = false

    enum SearchResult: Hashable {
        case song(Song)
        case album(Album)
        case user(UserResult)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .song(let song):
                hasher.combine(song)
            case .album(let album):
                hasher.combine(album)
            case .user(let user):
                hasher.combine(user)
            }
        }

        static func ==(lhs: SearchResult, rhs: SearchResult) -> Bool {
            switch (lhs, rhs) {
            case let (.song(l), .song(r)):
                return l == r
            case let (.album(l), .album(r)):
                return l == r
            case let (.user(l), .user(r)):
                return l == r
            default:
                return false
            }
        }
    }

    func search(query: String) {
            isLoading = true
            
            SearchAPI.search(query: query) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    switch result {
                    case .success(let response):
                        self.searchResults = response.songs.map { .song($0) } +
                                             response.albums.map { .album($0) } +
                                             response.users.map { .user($0) }
                        print("Successfully fetched search results.")
                    case .failure(let error):
                        print("Error fetching search results: \(error.localizedDescription)")
                    }
                }
            }
        }
}

extension SearchModel.SearchResult: Soundable, Identifiable {
    var id: String {
        switch self {
        case .song(let song):
            return song.id
        case .album(let album):
            return album.id
        case .user(let user):
            return user.id
        }
    }

    var type: String {
        switch self {
        case .song:
            return "song"
        case .album:
            return "album"
        case .user:
            return "user"
        }
    }
}

struct SearchAPIResponse: Codable, Hashable {
    let songs: [Song]
    let albums: [Album]
    let users: [UserResult]
}

protocol Soundable {
    var id: String { get }
    var type: String { get }
}

struct SimpleSoundable: Hashable, Encodable {
    let appleId: String
    let name: String
    let artistName: String
    let releaseDate: String
    let identifier: String
    let type: String
    let albumName: String?
    
    init(searchResult: SearchModel.SearchResult) {
        switch searchResult {
        case .song(let song):
            appleId = song.id
            name = song.attributes.name
            artistName = song.attributes.artistName
            releaseDate = song.attributes.releaseDate
            identifier = song.attributes.isrc
            type = "songs"
            albumName = song.attributes.albumName
        case .album(let album):
            appleId = album.id
            name = album.attributes.name
            artistName = album.attributes.artistName
            releaseDate = album.attributes.releaseDate
            identifier = album.attributes.upc
            type = "albums"
            albumName = nil
        case .user:
            // Handle user case if needed
            appleId = ""
            name = ""
            artistName = ""
            releaseDate = ""
            identifier = ""
            type = "User"
            albumName = nil
        }
    }
}

// MARK: - Album
struct Album: Codable, Identifiable, Hashable, Soundable {
    let attributes: AlbumAttributes
    let id: String
    let relationships: AlbumRelationships?
    let type: String
    let href: String
}

struct AlbumAttributes: Codable, Hashable {
    let artistName: String
    let artwork: Artwork
    let copyright: String
    let editorialNotes: EditorialNotes?
    let genreNames: [String]
    let isCompilation: Bool
    let isComplete: Bool
    let isMasteredForItunes: Bool
    let isSingle: Bool
    let name: String
    let playParams: PlayParams
    let recordLabel: String
    let releaseDate: String
    let trackCount: Int
    let url: String
    let upc: String
}


struct Artwork: Codable, Hashable {
    let width: Int
    let height: Int
    let bgColor: String
    let textColor1: String
    let textColor2: String
    let textColor3: String
    let textColor4: String
    let url: String
}


struct EditorialNotes: Codable, Hashable {
    let short: String?
    let standard: String?
}

struct PlayParams: Codable, Hashable {
    let id: String
    let kind: String
}

struct AlbumRelationships: Codable, Hashable {
    let tracks: Tracks?
}


struct Tracks: Codable, Hashable {
    let data: [Song]
}

// MARK: - Song
struct Song: Codable, Identifiable, Hashable, Soundable {
    let attributes: SongAttributes
    let href: String
    let id: String
    let type: String
    let relationships: SongRelationships?
}

struct SongAttributes: Codable, Hashable {
    let albumName: String?
    let artistName: String
    let artwork: Artwork
    let composerName: String?
    let contentRating: String?
    let discNumber: Int
    let durationInMillis: Int
    let genreNames: [String]
    let hasCredits: Bool
    let hasLyrics: Bool
    let isAppleDigitalMaster: Bool
    let isrc: String
    let name: String
    let playParams: PlayParams
    let releaseDate: String
    let trackNumber: Int
    let url: String
}

struct SongRelationships: Codable, Hashable {
    let albums: Albums
}

struct Albums: Codable, Hashable {
    let data: [Album]?
}

struct Artists: Codable, Hashable {
    let data: [Artist]
}

struct Artist: Codable, Identifiable, Hashable {
    let id: String
    let type: String
    let href: String
    let attributes: ArtistAttributes
}

struct ArtistAttributes: Codable, Hashable {
    let name: String
    let genreNames: [String]
    let url: String
}

struct UserResult: Codable, Identifiable, Hashable {
    let id: String
    let username: String
    let image: URL

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case image
    }
}
