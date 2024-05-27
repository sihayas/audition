//
//  DotView.swift
//  vaela
//
//  Created by decoherence on 4/29/24.

import Foundation
import SwiftUI

struct DotView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var index: Int
    @Binding var isLoading: Bool
    @State private var scale: CGFloat = 1.0
    @State private var currentColor: Color

    // Using computed properties for activeColor and inactiveColor
    private var activeColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.5) : Color.black
    }
    
    private var inactiveColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }
    
    init(index: Int, isLoading: Binding<Bool>) {
        self.index = index
        _isLoading = isLoading
        _currentColor = State(initialValue: Color.clear)
    }
    
    var body: some View {
        Circle()
            .frame(width: 4, height: 4)
            .foregroundColor(currentColor)
            .scaleEffect(scale)
            .onChange(of: isLoading) { newValue in
                isLoadingUpdated(newValue: newValue)
            }
            .onAppear {
                runAnimation()
            }
    }
    
    private func isLoadingUpdated(newValue: Bool) {
        withAnimation {
            currentColor = newValue ? activeColor : inactiveColor
            scale = 1.0 // Reset the scale to its original value
        }
    }
    
    private func runAnimation() {
        let baseDelay = Double(index) * 0.05
        
        DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay) {
            withAnimation(getAnimation()) {
                scale = 1.5
            }
            
            withAnimation(getAnimation().delay(0.5)) {
                scale = 1.0
            }
        }
    }
    
    private func getAnimation() -> Animation {
        Animation.linear(duration: 0.5).repeatForever(autoreverses: true)
    }
}
struct DashView: View {
    @Binding var isLoading: Bool
    private let numberOfDots: Int = Int(UIScreen.main.bounds.height / 12)

    var body: some View {
        VStack {
            ForEach(0..<numberOfDots, id: \.self) { index in
                DotView(index: index, isLoading: $isLoading)
            }
        }
    }
}
