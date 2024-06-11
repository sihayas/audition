//
//  EntryView.swift
//  Audition
//
//  Created by decoherence on 6/10/24.
//

import Foundation
import SwiftUI

struct EntryView: View {
    let entry: APIEntry
    let appleData: APIAppleSoundData
    
    @State private var isArtAnimating = false
    @State private var isContentAnimating = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 24) {
            // Sound Text & Art
            HStack(alignment: .bottom) {
                VStack(alignment: .trailing) {
                    RatingView(rating: entry.rating ?? 0)
                        .frame(width: 20, height: 20)
                        .padding(.bottom, 8)
                    
                    Text(appleData.artistName)
                        .font(.system(size: 13, weight: .medium))
                        .opacity(0.75)
                    
                    Text(appleData.name)
                        .font(.system(size: 15, weight: .semibold))
                        .opacity(0.75)
                        .multilineTextAlignment(.trailing)
                }
                .padding([.bottom, .trailing], 24)
                
                AsyncImage(url: URL(string: appleData.artworkUrl.replacingOccurrences(of: "{w}", with: "1000").replacingOccurrences(of: "{h}", with: "1000"))) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(32)
                        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
                } placeholder: {
                    Color.clear
                }
                .frame(width: 240, height: 240)
                .scaleEffect(isArtAnimating ? 1 : 0)
                .animation(.spring(response: 1, dampingFraction: 1, blendDuration: 0.2).delay(0.1), value: isArtAnimating)
            }

            // Body Text & Avatar
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    Text(entry.text)
                        .font(.system(size: 15, weight: .regular))
                        .opacity(0.75)
                        .padding([.top, .leading, .trailing, .bottom], 24)
                }
                .background(Color.black)
                .cornerRadius(32)
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                .scaleEffect(isContentAnimating ? 1 : 0.9)
                .animation(.spring(response: 1, dampingFraction: 1, blendDuration: 1.0).delay(0.25), value: isContentAnimating)
                
                HStack(alignment: .top, spacing: 12) {
                     AsyncImage(url: URL(string: entry.author.image)) { image in
                         image
                             .resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: 40, height: 40)
                             .cornerRadius(20)
                             .overlay(
                                 RoundedRectangle(cornerRadius: 20)
                                     .stroke(Color.black, lineWidth: 4)
                             )
                     } placeholder: {
                         Color.clear
                     }
                     
                     Text(entry.author.username)
                         .font(.system(size: 15, weight: .medium))
                         .opacity(0.75)
                         .offset(x: 0, y: -12)
                 }
                .offset(x: -12, y: -12)
                .scaleEffect(isContentAnimating ? 1 : 0.5)
                .animation(.spring(response: 1, dampingFraction: 1, blendDuration: 1.0).delay(0.25), value: isContentAnimating)
                
            }
        }
        .padding([.leading, .trailing], 24)
        .onAppear {
            isArtAnimating = true
            isContentAnimating = true
        }
    }
}
