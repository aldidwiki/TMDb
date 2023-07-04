//
//  ContentRatingResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation

struct ContentRatingResponse: Decodable {
    let results: [ContentRatingResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case results
    }
}

struct ContentRatingResponseModel: Decodable {
    let rating: String
    let ratingRegion: String
    
    private enum CodingKeys: String, CodingKey {
        case rating
        case ratingRegion = "iso_3166_1"
    }
}
