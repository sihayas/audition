//
//  UIImage.swift
//  InstagramTransition
//
//  Created by decoherence on 5/16/24.
//
import UIKit

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Determine the scale factor that maintains aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that maintains aspect ratio
        let newSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)
        
        // Create a new image context with the new size
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
