//
//  CreditResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation

struct MovieCreditResponse: Decodable {
    let cast: [MovieCreditResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case cast
    }
}

struct MovieCreditResponseModel: Decodable {
    let id: Int
    let name: String?
    let profilePath: String?
    let characterName: String?
    let order: Int?
    let popularity: Double
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case characterName = "character"
        case order
        case popularity
    }
}
