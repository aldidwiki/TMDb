//
//  PersonCreditResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 10/05/23.
//

import Foundation

struct PersonCreditResponse: Decodable {
    let cast: [PersonCreditResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case cast
    }
}

struct PersonCreditResponseModel: Decodable {
    let id: Int
    let title: String?
    let posterPath: String?
    let characterName: String?
    let releaseDate: String?
    let order: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case characterName = "character"
        case releaseDate = "release_date"
        case order
    }
}
