//
//  UIImageView.swift
//  InstagramTransition
//
//  Created by decoherence on 5/25/24.
//
import UIKit

// Extension to load image from URL (placeholder code)
extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

extension UIImageView {
    func setImage(from url: URL, completion: ((UIImage?) -> Void)? = nil) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion?(nil)
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.image = image
                completion?(image)
            }
        }.resume()
    }
}
