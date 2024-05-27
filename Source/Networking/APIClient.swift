//
//  APIClient.swift
//  InstagramTransition
//
//  Created by decoherence on 5/23/24.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    func sendRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data returned"])))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
