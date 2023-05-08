//
//  GenreResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation

struct GenreResponseModel: Decodable, Equatable {
    let id: Int
    let genreName: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case genreName = "name"
    }
}
