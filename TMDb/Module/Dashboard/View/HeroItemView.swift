//
//  HeroItemView.swift
//  TMDb
//
//  Created by Aldi Prahasta on 04/09/26.
//

import SwiftUI

struct HeroItemView: View {
    var body: some View {
        ZStack {
            Color.green
            
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        Image(systemName: "flame")
                            .resizable()
                            .foregroundStyle(Color.red)
                            .frame(width: 16, height: 16)
                        
                        Text("Trending #1")
                            .font(.subheadline)
                            .foregroundStyle(Color("cinematic_primary"))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .resizable()
                            .foregroundStyle(Color.yellow)
                            .frame(width: 16, height: 16)
                        
                        Text("8.9")
                            .font(.subheadline)
                            .foregroundStyle(Color.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                Spacer()
                
                HStack {
                    Text("SCI-FI / DRAMA")
                    Text("\u{2022}")
                    Text("2024")
                }
                .foregroundStyle(Color("cinematic_hero_genre"))
                
                Text("Echoes of Eternity")
                    .font(.title)
                    .foregroundStyle(Color.white)
                
                Text("Directed by John Wick")
                    .font(.subheadline)
                    .foregroundStyle(Color("cinematic_director_name"))
                
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Watch Trailer")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundStyle(Color.white)
                    .background(Color("cinematic_primary"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HeroItemView()
}
