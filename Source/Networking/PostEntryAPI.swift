//
//  PostEntryAPI.swift
//  Audition
//
//  Created by decoherence on 6/2/24.
//
import Foundation

class PostAPI {
    static func submitPost(text: String, rating: Int, userId: String, sound: SimpleSoundable, completion: @escaping (Result<Void, Error>) -> Void) {
        
        print("Text: \(text)")
        print("Rating: \(rating)")
        print("User ID: \(userId)")
        print("Soundable: \(sound)")
        let urlString = "http://192.168.1.23:8000/api/post/"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "PostAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let soundData = try encoder.encode(sound)
            if let soundJson = try JSONSerialization.jsonObject(with: soundData, options: []) as? [String: Any] {
                
                let parameters: [String: Any] = [
                    "userId": userId,
                    "text": text,
                    "rating": rating,
                    "sound": soundJson
                ]
                
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } else {
                completion(.failure(NSError(domain: "PostAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode soundable to JSON"])))
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "PostAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            completion(.success(()))
        }.resume()
    }

}
