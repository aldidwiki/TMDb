//
//  NewReleaseItemView.swift
//  TMDb
//
//  Created by Aldi Prahasta on 04/09/26.
//

import SwiftUI

struct NewReleaseItemView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                Color.green
                ratingView
                    .padding(12)
            }
            .frame(width: 200, height: 275)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("Silent Horizon")
                .font(.system(size: 22, weight: .medium))
            
            Text("Sci-Fi Thriller \u{2022} 2024")
                .font(.system(size: 16))
                .foregroundStyle(Color.gray)
        }
    }
}

extension NewReleaseItemView {
    var ratingView: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .resizable()
                .foregroundStyle(Color.yellow)
                .frame(width: 12, height: 12)
            
            Text("8.9")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.white)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NewReleaseItemView()
}
