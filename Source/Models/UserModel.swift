//
//  UserModel.swift
//  Audition
//
//  Created by decoherence on 5/27/24.
//

import Foundation

struct UserResponse: Decodable {
    let data: APIUser
}

struct APIUser: Codable {
    let id: String
    let image: String
    let username: String
    let bio: String
    let essentialOne: APISound?
    let essentialTwo: APISound?
    let essentialThree: APISound?
    let followersCount: Double
    let artifactsCount: Double
    let isFollowingAtoB: Bool?
    let isFollowingBtoA: Bool?

    enum CodingKeys: String, CodingKey {
        case id, image, username, bio
        case essentialOne = "essential_one"
        case essentialTwo = "essential_two"
        case essentialThree = "essential_three"
        case followersCount = "followers_count"
        case artifactsCount = "artifacts_count"
        case isFollowingAtoB = "isFollowingAtoB"
        case isFollowingBtoA = "isFollowingBtoA"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        image = try container.decode(String.self, forKey: .image)
        username = try container.decode(String.self, forKey: .username)
        bio = try container.decode(String.self, forKey: .bio)
        followersCount = try container.decode(Double.self, forKey: .followersCount)
        artifactsCount = try container.decode(Double.self, forKey: .artifactsCount)

        // Use decodeIfPresent for optional properties
        isFollowingAtoB = try container.decodeIfPresent(Bool.self, forKey: .isFollowingAtoB)
        isFollowingBtoA = try container.decodeIfPresent(Bool.self, forKey: .isFollowingBtoA)

        essentialOne = try APIUser.decodeAPISound(from: container, forKey: .essentialOne)
        essentialTwo = try APIUser.decodeAPISound(from: container, forKey: .essentialTwo)
        essentialThree = try APIUser.decodeAPISound(from: container, forKey: .essentialThree)
    }

    private static func decodeAPISound(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> APISound? {
        guard let stringValue = try container.decodeIfPresent(String.self, forKey: key),
              !stringValue.isEmpty else {
            return nil
        }
        
        let data = stringValue.data(using: .utf8)!
        return try JSONDecoder().decode(APISound.self, from: data)
    }
}
