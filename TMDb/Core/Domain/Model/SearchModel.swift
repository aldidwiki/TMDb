//
//  SearchModel.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import SwiftUI

struct SearchModel: Equatable, Identifiable {
    let id: Int
    let name: String
    let releaseDate: String
    let imagePath: String
    let voteAverage: Double
    let mediaType: String
}

extension SearchModel {
    private func mapToMovieModel() -> MovieModel {
        return MovieModel(
            id: id,
            title: name,
            posterPath: imagePath,
            rating: voteAverage,
            releaseDate: releaseDate
        )
    }
    
    private func mapToTvShowModel() -> TvShowModel {
        return TvShowModel(
            id: id,
            title: name,
            posterPath: imagePath,
            rating: voteAverage,
            releaseDate: releaseDate
        )
    }
    
    private func mapToPersonPopularModel() -> PersonPopularModel {
        return PersonPopularModel(
            id: id,
            name: name,
            profilePath: imagePath
        )
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch mediaType {
        case Constants.movieResponseType:
            MovieItemView(movie: mapToMovieModel())
        case Constants.tvShowResponseType:
            TvShowItemView(tvModel: mapToTvShowModel())
        case Constants.personResponseType:
            PersonItemView(personPopular: mapToPersonPopularModel())
        default:
            EmptyView(emptyTitle: "")
        }
    }
}
