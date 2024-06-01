//
//  FormArtworkView.swift
//  Audition
//
//  Created by decoherence on 5/30/24.
//

import SwiftUI

struct ArtworkImageView: View {
    var image: UIImage
    var albumName: String
    var artistName: String
    var songName: String?
    @State private var blurRadius: CGFloat = 18
    @State private var rotationAngle: Double = 15
    @State private var swivelAngle: Double = 0
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 270, height: 270)
                .cornerRadius(18)
                .blur(radius: blurRadius)
                .rotation3DEffect(
                    Angle(degrees: rotationAngle),
                    axis: (x: 0.0, y: 1.0, z: 0.0),
                    perspective: 0.5
                )
                .rotation3DEffect(
                    Angle(degrees: swivelAngle),
                    axis: (x: 1.0, y: 0.0, z: 0.0),
                    perspective: 0.5
                )
            
            VStack {
                Text(artistName)
                    .font(.subheadline)
                    .foregroundColor(.white).opacity(0.75)
                Text(albumName)
                    .font(.headline)
                    .foregroundColor(.white).opacity(0.75)
            }
            .padding(.top, 8)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2)) {
                blurRadius = 0
                rotationAngle = 0
            }
            
            let baseAnimation = Animation.easeInOut(duration: 4)
            let repeated = baseAnimation.repeatForever(autoreverses: true)
            
            withAnimation(repeated) {
                rotationAngle = 5
            }
            
            withAnimation(repeated.delay(1.5)) {
                swivelAngle = 5
            }
        }
    }
}
