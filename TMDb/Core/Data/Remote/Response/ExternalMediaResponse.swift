//
//  ExternalMediaResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 20/06/23.
//

import Foundation

struct ExternalMediaResponse: Decodable {
    let imdbId: String?
    let instagramId: String?
    let twitterId: String?
    let facebookId: String?
    let wikidataId: String?
    
    private enum CodingKeys: String, CodingKey {
        case imdbId = "imdb_id"
        case instagramId = "instagram_id"
        case facebookId = "facebook_id"
        case twitterId = "twitter_id"
        case wikidataId = "wikidata_id"
    }
}
