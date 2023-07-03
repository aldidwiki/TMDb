//
//  TvResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import Foundation

struct TvResponse: Decodable {
    let tvShows: [TvResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case tvShows = "results"
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
