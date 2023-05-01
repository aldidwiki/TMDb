//
//  MovieItem.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct MovieItem: View {
    var movie: MovieModel
    
    var body: some View {
        HStack(alignment: .center) {
            moviePoster
            content
            
            Spacer()
            Text("\(movie.rating, specifier: "%.1f")")
                .font(.headline)
                .fontWeight(.medium)
                .padding(.leading, 8.0)
        }
    }
}

extension MovieItem {
    var moviePoster: some View {
        WebImage(url: URL(string: API.imageBaseUrl + (movie.posterPath ?? "")))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(width: 100, height: 100)
            .cornerRadius(20)
    }
    
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
        MovieItem(movie: MovieModel(
            id: 436270,
            title: "Black Adam",
            posterPath: "/3zXceNTtyj5FLjwQXuPvLYK5YYL.jpg",
            rating: 7.1,
            releaseDate: "2022-10-19"
        ))
    }
}
