//
//  FavoriteModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 07/07/23.
//

import Foundation

struct FavoriteModel: Equatable, Identifiable {
    let id: Int
    let title: String
    let posterPath: String
    let rating: Double
    let releaseDate: String
    let mediaType: String
    
    var toMovieModel : MovieModel {
        return Mapper.mapFavoriteModelToMovieModel(input: self)
    }
}
