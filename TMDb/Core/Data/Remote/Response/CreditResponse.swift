//
//  CreditResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation

struct CreditResponse: Decodable {
    let cast: [CreditResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case cast
    }
}

struct CreditResponseModel: Decodable {
    let id: Int
    let name: String?
    let profilePath: String?
    let characterName: String?
    let order: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case characterName = "character"
        case order
    }
}
