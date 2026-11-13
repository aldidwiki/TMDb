//
//  PersonCreditResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 10/05/23.
//

import Foundation

struct PersonCreditResponse: Decodable {
    let cast: [PersonCreditResponseModel]?
    let crew: [PersonCreditResponseModel]?
}

struct PersonCreditResponseModel: Decodable {
    let id: Int
    let movieTitle: String?
    let posterPath: String?
    let characterName: String?
    let job: String?
    let releaseDate: String?
    let firstAirDate: String?
    let order: Int?
    let popularity: Double?
    let mediaType: String
    let tvTitle: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case movieTitle = "title"
        case posterPath = "poster_path"
        case characterName = "character"
        case job
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case order
        case popularity
        case mediaType = "media_type"
        case tvTitle = "name"
    }
}
