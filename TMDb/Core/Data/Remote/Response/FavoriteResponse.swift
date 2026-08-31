//
//  FavoriteResponse.swift
//  TMDb
//
//  Created by Aldi Prahasta on 31/08/26.
//

import Foundation

struct FavoriteResponse: Decodable {
    let statusCode: Int
    let statusMessage: String
    let success: Bool
    
    private enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
        case success
    }
}
