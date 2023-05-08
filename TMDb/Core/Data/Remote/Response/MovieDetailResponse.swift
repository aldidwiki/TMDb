//
//  MovieDetailResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation

struct MovieDetailResponse: Decodable {
    let id: Int
    let title: String
    let rating: Double
    let posterPath: String?
    let overview: String
    let tagline: String
    let releaseDate: String
    let backdropPath: String?
    let runtime: Int?
    let releaseDates: MovieReleaseDatesResponseModel
    let genres: [GenreResponseModel]
    let credits: CreditResponse
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case rating = "vote_average"
        case posterPath = "poster_path"
        case overview
        case tagline
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path"
        case runtime
        case releaseDates = "release_dates"
        case genres = "genres"
        case credits
    }
}

struct MovieReleaseDatesResponseModel: Decodable {
    let results: [MovieCertificationResponse]
    
    private enum CodingKeys: String, CodingKey {
        case results
    }
}
