//
//  TvShowEpisodesResponse.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import Foundation

struct TvShowSeasonDetailResponse: Decodable {
    let airDate: String?
    let episodes: [TvShowSeasonDetailResponseModel]
    
    private enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodes
    }
}

struct TvShowSeasonDetailResponseModel: Decodable {
    let id: Int
    let airDate: String?
    let episodeNumber: Int
    let episodeName: String
    let overview: String?
    let episodeRuntime: Int?
    let seasonNumber: Int
    let stillPath: String?
    let voteAverage: Double?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case episodeName = "name"
        case overview
        case episodeRuntime = "runtime"
        case seasonNumber = "season_number"
        case stillPath = "still_path"
        case voteAverage = "vote_average"
    }
}
