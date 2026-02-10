//
//  TvShowItemView.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import SwiftUI

struct TvShowItemView: View {
    var tvModel: TvShowModel
    
    var body: some View {
        HStack {
            PosterView(posterType: .tv(path: tvModel.posterPath))
            content
            
            Spacer()
            ContentRatingView(contentRating: tvModel.rating)
        }
    }
}

extension TvShowItemView {
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
