//
//  PersonPopularResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/10/23.
//

import Foundation

struct PersonPopularResponse: Decodable {
    let results: [PersonPopularResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case results
    }
}

struct PersonPopularResponseModel: Decodable {
    let id: Int
    let gender: Int?
    let knownForDepartment: String?
    let name: String?
    let popularity: Double?
    let profilePath: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case gender
        case knownForDepartment = "known_for_department"
        case name
        case popularity
        case profilePath = "profile_path"
    }
}
