//
//  AuthUserAPI.swift
//  InstagramTransition
//
//  Created by decoherence on 5/24/24.
//

import Foundation

class AuthUserAPI {
    static func fetchUserData(userId: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        let urlString = "http://192.168.1.249:8000/api/user/?userId=\(userId)&pageUserId=\(userId)"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "UserAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("Error creating URL: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error in data task: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "UserAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data returned"])
                print("Error: No data returned")
                completion(.failure(error))
                return
            }
        
            
            do {
                let decodedResponse = try JSONDecoder().decode(UserResponse.self, from: data)
//                print("Decoded response: \(decodedResponse)")
                completion(.success(decodedResponse))
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
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
