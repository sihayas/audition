//
//  FeedAPI.swift
//  InstagramTransition
//
//  Created by decoherence on 5/23/24.
//

import Foundation

class FeedAPI {
    static func fetchEntries(page: Int, userId: String, completion: @escaping (Result<APIFeedResponse, Error>) -> Void) {
        let baseURL = "http://192.168.1.46:8000"
        let urlString = "\(baseURL)/api/feed?page=\(page)&userId=\(userId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FeedAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        APIClient.shared.sendRequest(url: url, completion: completion)
    }
}
