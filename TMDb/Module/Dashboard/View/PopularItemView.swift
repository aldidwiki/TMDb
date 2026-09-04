//
//  PopularItemView.swift
//  TMDb
//
//  Created by Aldi Prahasta on 04/09/26.
//

import SwiftUI

struct PopularItemView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                Color.green
                
                VStack(alignment: .leading) {
                    Text("Season 3")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(Color.yellow)
                        
                        Text("9.3")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.white)
                    }
                }
                .padding(10)
            }
            .frame(width: 200, height: 275)
            
            Group {
                Text("Severed Reality")
                    .font(.system(size: 22, weight: .medium))
                
                Text("8 Episodes \u{2022} 2024")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.gray)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 10)
    }
}

#Preview {
    PopularItemView()
}
