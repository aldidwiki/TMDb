//
//  ContentRatingView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 12/08/23.
//

import SwiftUI

struct ContentRatingView: View {
    var contentRating: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("content_rating_color"))
            
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .foregroundColor(Color("label_color"))
                    .frame(width: 8, height: 8)
                
                Text("\(contentRating, specifier: "%.1f")")
                    .foregroundColor(Color("label_color"))
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
            }
        }
        .frame(width: 50, height: 20)
    }
}

struct ContentRatingView_Previews: PreviewProvider {
    static var previews: some View {
        ContentRatingView(contentRating: 7.4)
    }
}
