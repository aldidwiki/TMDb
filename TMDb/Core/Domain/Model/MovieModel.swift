//
//  MovieModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation

struct MovieModel: Equatable, Identifiable {
    let id: Int
    let title: String
    let posterPath: String
    let rating: Double
    let releaseDate: String
    let backdropPath: String?
    let genreIDs: [Int]
    let overview: String

    init(
        id: Int,
        title: String,
        posterPath: String,
        rating: Double,
        releaseDate: String,
        backdropPath: String? = nil,
        genreIDs: [Int] = [],
        overview: String = ""
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.rating = rating
        self.releaseDate = releaseDate
        self.backdropPath = backdropPath
        self.genreIDs = genreIDs
        self.overview = overview
    }
}
