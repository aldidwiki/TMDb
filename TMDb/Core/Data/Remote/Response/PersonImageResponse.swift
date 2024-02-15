//
//  PersonImageResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 15/02/24.
//

import Foundation

struct PersonImageResponse: Decodable {
    let personId: Int
    let profileImages: [PersonImageResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case personId = "id"
        case profileImages = "profiles"
    }
}

struct PersonImageResponseModel: Decodable {
    let filePath: String?
    let voteAverage: Double?
    
    private enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
        case voteAverage = "vote_average"
    }
}
