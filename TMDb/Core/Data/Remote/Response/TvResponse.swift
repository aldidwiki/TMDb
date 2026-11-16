//
//  TvResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import Foundation

struct TvResponse: Decodable {
    let tvShows: [TvResponseModel]
    let page: Int?
    let totalPages: Int?
    let totalResults: Int?
    
    private enum CodingKeys: String, CodingKey {
        case tvShows = "results"
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct TvResponseModel: Decodable {
    let id: Int
    let title: String
    let releaseDate: String?
    let posterPath: String?
    let rating: Double?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case releaseDate = "first_air_date"
        case posterPath = "poster_path"
        case rating = "vote_average"
    }
}
