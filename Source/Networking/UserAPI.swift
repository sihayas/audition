//
//  AuthUserAPI.swift
//  InstagramTransition
//
//  Created by decoherence on 5/24/24.
//

import Foundation

class UserAPI {
    static func fetchAuthUserData(authUserId: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        let urlString = "http://192.168.1.23:8000/api/user/auth/?authUserId=\(authUserId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "AuthUserAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        APIClient.shared.sendRequest(url: url, completion: { (result: Result<UserResponse, Error>) in
            switch result {
            case .success(let userResponse):
                completion(.success(userResponse))
            case .failure(let error):
                print("Error fetching user data:", error)
                completion(.failure(error))
            }
        })
    }
    
    static func fetchUserData(userId: String, pageUserId: String, completion: @escaping (Result<UserResponse, Error>) -> Void) {
        let urlString = "http://192.168.1.23:8000/api/user/?userId=\(userId)&pageUserId=\(pageUserId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "AuthUserAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        APIClient.shared.sendRequest(url: url, completion: completion)
    }
}
