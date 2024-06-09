//
//  PostEntryAPI.swift
//  Audition
//
//  Created by decoherence on 6/2/24.
//
import Foundation
import UIKit

class PostAPI {
    static func submitPost(text: String, rating: Int, userId: String, sound: SimpleSoundable, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let urlString = "http://192.168.1.249:8000/api/post/"
        
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
    
    static func createAction(authorId: String, actionType: String, sourceId: String, sourceType: String, soundId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let authSession = appDelegate.fetchAuthSession(),
              let userId = authSession.userId else {
            completion(.failure(NSError(domain: "PostAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let urlString = "http://192.168.1.249:8000/api/action/"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "PostAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "userId": userId,
            "authorId": authorId,
            "actionType": actionType,
            "sourceId": sourceId,
            "sourceType": sourceType,
            "soundId": soundId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
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
