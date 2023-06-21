//
//  VideoResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 21/06/23.
//

import Foundation

struct VideoResponse: Decodable {
    let results: [VideoResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case results
    }
}

struct VideoResponseModel: Decodable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case name
        case site
        case type
    }
}
