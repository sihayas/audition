//
//  VisionColor.swift
//  InstagramTransition
//
//  Created by decoherence on 5/21/24.
//

import UIKit
import Vision

func dominantColor(from image: UIImage, completion: @escaping (UIColor?) -> Void) {
    guard let cgImage = image.cgImage else {
        print("Error: Failed to get cgImage from UIImage")
        completion(nil)
        return
    }
    
    let context = CIContext()
    let ciImage = CIImage(cgImage: cgImage)
    
    if let averageColor = context.averageColor(ciImage: ciImage) {
//        print("Dominant color found: \(averageColor)")
        completion(averageColor)
    } else {
        print("Error: Failed to compute average color")
        completion(nil)
    }
}

extension CIContext {
    func averageColor(ciImage: CIImage) -> UIColor? {
        let extentVector = CIVector(x: ciImage.extent.origin.x, y: ciImage.extent.origin.y, z: ciImage.extent.size.width, w: ciImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: extentVector]) else {
            print("Error: Failed to create CIAreaAverage filter")
            return nil
        }
        
        guard let outputImage = filter.outputImage else {
            print("Error: Failed to get output image from CIAreaAverage filter")
            return nil
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        self.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let red = CGFloat(bitmap[0]) / 255.0
        let green = CGFloat(bitmap[1]) / 255.0
        let blue = CGFloat(bitmap[2]) / 255.0
        let alpha = CGFloat(bitmap[3]) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor {
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255.0)
        let g = Int(green * 255.0)
        let b = Int(blue * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
