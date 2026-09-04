//
//  GenreItemView.swift
//  TMDb
//
//  Created by Aldi Prahasta on 04/09/26.
//

import SwiftUI

struct GenreItemView: View {
    var palette: ColorPalette
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            palette.background
            
            VStack(alignment: .leading) {
                Text("Sci-Fi")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(palette.title)
                
                Text("1,420")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(palette.subtitle)
            }
            .padding()
        }
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    GenreItemView(palette: ColorPalette.natureBotanical)
}
