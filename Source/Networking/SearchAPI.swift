//
//  SearchAPI.swift
//  InstagramTransition
//
//  Created by decoherence on 5/23/24.
//

import Foundation

class SearchAPI {
    static func search(query: String, completion: @escaping (Result<SearchAPIResponse, Error>) -> Void) {
        let urlString = "http://192.168.1.249:8000/api/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "SearchAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        APIClient.shared.sendRequest(url: url, completion: completion)
    }
}
