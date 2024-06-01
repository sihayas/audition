//
//  SearchResultsView.swift
//  InstagramTransition
//
//  Created by decoherence on 5/7/24.
//

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var searchModel: SearchModel
    @State private var showingDetailsFor: SearchModel.SearchResult?

    var body: some View {
        List(searchModel.searchResults, id: \.self) { result in
            Button(action: {
                let details = SoundScreenDetails(
                    id: result.resultId(),
                    title: result.title(),
                    subtitle: result.subtitle(),
                    imageUrl: result.imageUrl(size: 1000),
                    color: result.color()
                )
                NavigationManager.shared.navigateToSoundScreen(withDetails: details)
            }) {
                HStack {
                    AsyncImage(url: result.imageUrl(size: 96)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 48, height: 48)
                    .cornerRadius(result.cornerRadius())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.title())
                            .font(.system(size: 15, weight: .medium))
                        Text(result.subtitle())
                            .font(.system(size: 13, weight: .regular))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        NavBarManager.shared.setSelectedSearchResult(result)
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listRowBackground(Color.clear)
        }
        .background(Color.clear)
        .listStyle(PlainListStyle())
    }
}


extension SearchModel.SearchResult {
    
    func resultId() -> String {
        switch self {
        case .song(let song): return song.id
        case .album(let album): return album.id
        case .user(let user): return user.id
        }
    }
    
    func title() -> String {
        switch self {
        case .song(let song): return song.attributes.name
        case .album(let album): return album.attributes.name
        case .user(let user): return user.username
        }
    }

    func subtitle() -> String {
        switch self {
        case .song(let song): return song.attributes.artistName
        case .album(let album): return album.attributes.artistName
        case .user: return "User"
        }
    }
    
    func color() -> String {
        switch self {
        case .song(let song): return song.attributes.artwork.bgColor
        case .album(let album): return album.attributes.artwork.bgColor
        case .user: return ""
        }
    }

    func imageUrl(size: Int) -> URL? {
        switch self {
        case .song(let song):
            return URL(string: song.attributes.artwork.url.replacingOccurrences(of: "{w}x{h}bb.jpg", with: "\(size)x\(size)bb.jpg"))
        case .album(let album):
            return URL(string: album.attributes.artwork.url.replacingOccurrences(of: "{w}x{h}bb.jpg", with: "\(size)x\(size)bb.jpg"))
        case .user(let user):
            return user.image
        }
    }

    func cornerRadius() -> CGFloat {
        switch self {
        case .album, .song: return 8
        case .user: return 20
        }
    }

    func isSongOrAlbum() -> Bool {
        switch self {
        case .song, .album: return true
        default: return false
        }
    }
}
