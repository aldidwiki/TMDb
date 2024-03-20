//
//  PersonImageResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 15/02/24.
//

import Foundation

struct ImageResponse: Decodable {
    let imageId: Int
    let profileImages: [ImageResponseModel]?
    let backdrops: [ImageResponseModel]?
    
    private enum CodingKeys: String, CodingKey {
        case imageId = "id"
        case profileImages = "profiles"
        case backdrops
    }
}

struct ImageResponseModel: Decodable {
    let filePath: String?
    let voteAverage: Double?
    
    private enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
        case voteAverage = "vote_average"
    }
}
