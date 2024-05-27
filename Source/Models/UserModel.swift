//
//  UserModel.swift
//  Audition
//
//  Created by decoherence on 5/27/24.
//

import Foundation

class UserModel: ObservableObject {
    @Published var user: APIUser?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    var userId: String = ""
    
    func fetchUserData() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        UserAPI.fetchUserData(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    print("Fetched user data")
                    self.user = response.data
                    self.isLoading = false
                case .failure(let error):
                    print("Error fetching user data: \(error.localizedDescription)")
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
}

struct UserResponse: Decodable {
    let data: APIUser
}

struct APIUser: Decodable {
    let id: String
    let username: String
    let bio: String
    let image: String
    let followersCount: String
    let artifactsCount: String
    let essentials: [APIEssential]
    let isFollowingAtoB: Bool?
    let isFollowingBtoA: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, username, bio, image
        case followersCount = "followers_count"
        case artifactsCount = "artifacts_count"
        case essentials
        case isFollowingAtoB = "isFollowingAtoB"
        case isFollowingBtoA = "isFollowingBtoA"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        bio = try container.decode(String.self, forKey: .bio)
        image = try container.decode(String.self, forKey: .image)
        followersCount = try container.decode(String.self, forKey: .followersCount)
        artifactsCount = try container.decode(String.self, forKey: .artifactsCount)
        
        // Decode the essentials string decode it to an array of Essential
        let essentialsString = try container.decode(String.self, forKey: .essentials)
        if let data = essentialsString.data(using: .utf8) {
            essentials = try JSONDecoder().decode([APIEssential].self, from: data)
        } else {
            essentials = []
        }
        
        isFollowingAtoB = try container.decodeIfPresent(Bool.self, forKey: .isFollowingAtoB)
        isFollowingBtoA = try container.decodeIfPresent(Bool.self, forKey: .isFollowingBtoA)
    }
}
