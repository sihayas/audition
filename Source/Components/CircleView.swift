//
//  CircleView.swift
//  InstagramTransition
//
//  Created by decoherence on 5/4/24.
//

import SwiftUI

struct CircleView: View {
    var hexColor: String
    var width: CGFloat
    var height: CGFloat
    var startRadius: CGFloat
    var endRadius: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: hexColor), .clear]),
                    center: .center,
                    startRadius: startRadius,
                    endRadius: endRadius
                )
            )
            .frame(width: width, height: height)
            .blur(radius: 40)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

import UIKit


class UICircleCell: UICollectionViewCell {
    private var circleView: UICircleView?

    func configure(hexColor: String, width: CGFloat) {
        if let circleView = circleView {
            circleView.removeFromSuperview()
        }

        let circleFrame = CGRect(x: 0, y: 0, width: width, height: width)
        let circleView = UICircleView(hexColor: hexColor, frame: circleFrame, startRadius: 0, endRadius: width)
        self.circleView = circleView
        circleView.frame = contentView.bounds
        contentView.addSubview(circleView)
    }
}



class UICircleView: UIView {
    private var hexColor: String
    private var startRadius: CGFloat
    private var endRadius: CGFloat

    init(hexColor: String, frame: CGRect, startRadius: CGFloat, endRadius: CGFloat) {
        self.hexColor = hexColor
        self.startRadius = startRadius
        self.endRadius = endRadius
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let colors = [UIColor(hex: hexColor)?.cgColor, UIColor.clear.cgColor] as CFArray
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil)
        context.drawRadialGradient(gradient!, startCenter: center, startRadius: startRadius, endCenter: center, endRadius: endRadius, options: [])
    }
}
