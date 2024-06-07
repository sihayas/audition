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
            
            guard let data = data, !data.isEmpty else {
                let missingDataError = NSError(domain: "APIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Response data is missing"])
                completion(.failure(missingDataError))
                return
            }
            
            // Print the JSON data as a string
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON:")
                print(jsonString)
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
