//
//  AuthUserAPI.swift
//  InstagramTransition
//
//  Created by decoherence on 5/24/24.
//

import Foundation

class UserAPI {
    static func fetchUserData(userId: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        let baseURL = "http://192.168.1.249:8000"
        let urlString = "\(baseURL)/api/user/?userId=\(userId)&pageUserId=\(userId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "AuthUserAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        APIClient.shared.sendRequest(url: url, completion: completion)
    }
}
