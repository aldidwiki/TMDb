//
//  SearchResponse.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation

struct SearchResponse: Decodable {
    let searchResults: [SearchResponseModel]?
    let totalPages: Int
    
    private enum CodingKeys: String, CodingKey {
        case searchResults = "results"
        case totalPages = "total_pages"
    }
}

struct SearchResponseModel: Decodable {
    let id: Int
    let title: String?
    let posterPath: String?
    let mediaType: String?
    let voteAverage: Double?
    let releaseDate: String?
    let name: String?
    let firstAirDate: String?
    let profilePath: String?
    let overview: String?
    let knownForDepartment: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case name = "name"
        case firstAirDate = "first_air_date"
        case profilePath = "profile_path"
        case overview
        case knownForDepartment = "known_for_department"
    }
}
