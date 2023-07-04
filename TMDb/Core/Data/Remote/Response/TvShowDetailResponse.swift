//
//  TvShowDetailResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation

struct TvShowDetailResponse: Decodable {
    let id: Int
    let backdropPath: String?
    let releaseDate: String?
    let title: String
    let overview: String?
    let posterPath: String?
    let tagline: String
    let status: String
    let type: String
    let genres: [GenreResponseModel]
    let rating: Double?
    let runtime: [Int]
    let spokenLanguages: [SpokenLanguageResponse]
    let contentRating: ContentRatingResponse
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case backdropPath = "backdrop_path"
        case releaseDate = "first_air_date"
        case overview
        case posterPath = "poster_path"
        case tagline
        case status
        case type
        case genres
        case rating = "vote_average"
        case runtime = "episode_run_time"
        case spokenLanguages = "spoken_languages"
        case contentRating = "content_ratings"
    }
}
