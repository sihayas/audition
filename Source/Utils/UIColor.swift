//
//  UIColor.swift
//  InstagramTransition
//
//  Created by decoherence on 5/3/24.
//
import SwiftUI

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        let start = hex.index(hex.startIndex, offsetBy: 0)
        let hexColor = String(hex[start...])

        if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255

                self.init(red: r, green: g, blue: b, alpha: 1.0)
                return
            }
        }

        return nil
    }
}

