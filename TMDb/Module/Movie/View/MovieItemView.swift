//
//  MovieItem.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI

struct MovieItemView: View {
    var movie: MovieModel
    
    var body: some View {
        HStack(alignment: .center) {
            PosterView(posterType: .movie(path: movie.posterPath))
            content
            
            Spacer()
            
            ContentRatingView(contentRating: movie.rating)
        }
    }
}

extension MovieItemView {
    var content: some View {
        VStack(alignment: .leading) {
            Text(movie.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Text(movie.releaseDate.formatDateString())
                .font(.subheadline)
        }
    }
}

struct MovieItem_Previews: PreviewProvider {
    static var previews: some View {
        MovieItemView(movie: MovieModel(
            id: 436270,
            title: "Black Adam",
            posterPath: "/3zXceNTtyj5FLjwQXuPvLYK5YYL.jpg",
            rating: 7.1,
            releaseDate: "2022-10-19"
        ))
    }
}
