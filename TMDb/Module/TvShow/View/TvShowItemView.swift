//
//  TvShowItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TvShowItemView: View {
    var tvModel: TvShowModel
    
    var body: some View {
        HStack(alignment: .center) {
            tvPoster
            content
            
            Spacer()
            ContentRatingView(contentRating: tvModel.rating)
        }
    }
}

extension TvShowItemView {
    var tvPoster: some View {
        WebImage(url: URL(string: API.imageBaseUrl + tvModel.posterPath))
            .resizable()
            .placeholder(content: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            })
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(width: 100, height: 100)
            .cornerRadius(20)
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            Text(tvModel.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Text(tvModel.releaseDate.formatDateString())
                .font(.subheadline)
        }
    }
}

struct TvShowItemView_Previews: PreviewProvider {
    static var previews: some View {
        TvShowItemView(tvModel: TvShowModel(
            id: 436270,
            title: "Black Adam",
            posterPath: "/3zXceNTtyj5FLjwQXuPvLYK5YYL.jpg",
            rating: 7.1,
            releaseDate: "2022-10-19"
        ))
    }
}
