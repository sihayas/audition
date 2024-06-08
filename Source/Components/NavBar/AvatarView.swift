//
//  AvatarView.swift
//  Audition
//
//  Created by decoherence on 6/6/24.
//
import SwiftUI

struct AvatarView: View {
    let imageUrl: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        } placeholder: {
            ProgressView()
                .frame(width: 32, height: 32)
        }
        .contextMenu {
            Menu {
                Section("Identity") {
                    Button(action: {
                        print("Alias")
                    }) {
                        Label("Alias", systemImage: "person.fill")
                    }
                    Button(action: {
                        print("Avatar")
                    }) {
                        Label("Avatar", systemImage: "photo.fill")
                    }
                }
                
                Section("Essentials") {
                    Button(action: {
                        print("1")
                    }) {
                        Label("", systemImage: "1.circle")
                    }
                    Button(action: {
                        print("2")
                    }) {
                        Label("", systemImage: "2.circle")
                    }
                    Button(action: {
                        print("3")
                    }) {
                        Label("", systemImage: "3.circle")
                    }
                }
                
                Section("Notifications") {
                    Button(action: {
                        print("Follows")
                    }) {
                        Label("Follows", systemImage: "circle.fill")
                    }
                    Button(action: {
                        print("Hearts")
                    }) {
                        Label("Hearts", systemImage: "circle.fill")
                    }
                    Button(action: {
                        print("Chains")
                    }) {
                        Label("Chains", systemImage: "circle.fill")
                    }
                }
            } label: {
                Label("Settings", systemImage: "gear")
            }
            
            Button(action: {
                print("Disconnect")
            }) {
                Label("Disconnect", image: "disconnect")
                    .foregroundColor(.white)
            }
        }
    }
}
