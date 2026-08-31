//
//  FavoriteRequest.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation

struct FavoriteRequest: Encodable {
    let mediaType: String
    let mediaId: Int
    let isFavorite: Bool
    
    private enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case isFavorite = "favorite"
    }
}
