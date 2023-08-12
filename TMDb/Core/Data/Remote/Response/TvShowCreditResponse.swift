//
//  TvShowCreditResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 12/08/23.
//

import Foundation

struct TvShowCreditResponse: Decodable {
    let cast: [TvShowCastResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case cast
    }
}

struct TvShowCastResponseModel: Decodable {
    let id: Int
    let name: String?
    let profilePath: String?
    let order: Int?
    let popularity: Double
    let totalEpisodeCount: Int
    let roles: [TvShowRolesResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case order
        case popularity
        case roles
        case totalEpisodeCount = "total_episode_count"
    }
}

struct TvShowRolesResponseModel: Decodable {
    let creditId: String
    let characterName: String
    let episodeCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case creditId = "credit_id"
        case characterName = "character"
        case episodeCount = "episode_count"
    }
}
