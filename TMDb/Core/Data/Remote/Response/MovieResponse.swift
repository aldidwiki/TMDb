//
//  MovieResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation

struct MovieResponse: Decodable {
    let movies: [MovieResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case movies = "results"
    }
}

struct MovieResponseModel: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let rating: Double
    let releaseDate: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case rating = "vote_average"
        case releaseDate = "release_date"
    }
}
