//
//  AnimatedTextView.swift
//  InstagramTransition
//
//  Created by decoherence on 5/2/24.
//

import Foundation
import SwiftUI

struct AnimateTextOutView: View {
    var fontSize: Double
    var text: String
    var weight: Font.Weight

    @State private var opacity: Double = 0.75
    @State private var blurRadius: CGFloat = 0
    @State private var scale: CGFloat = 1.0

    init(fontSize: Double, text: String, weight: Font.Weight) {
        self.fontSize = fontSize
        self.text = text
        self.weight = weight
    }

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: weight))
            .foregroundColor(.white)
            .opacity(opacity)
            .blur(radius: blurRadius)
            .scaleEffect(scale)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.5, blendDuration: 0.25)) {
                    blurRadius = 8
                    opacity = 0.0
                    scale = 0.9
                }
            }
        }
    }
}

struct AnimateTextInView: View {
    var fontSize: Double
    var text: String
    var weight: Font.Weight

    @State private var opacity: Double = 0.0
    @State private var blurRadius: CGFloat = 8
    @State private var scale: CGFloat = 0.9

    init(fontSize: Double, text: String, weight: Font.Weight) {
        self.fontSize = fontSize
        self.text = text
        self.weight = weight
    }

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: weight))
            .opacity(opacity)
            .blur(radius: blurRadius)
            .scaleEffect(scale)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    blurRadius = 0
                    opacity = 0.75
                    scale = 1.0
                }
            }
        }
    }
}
