//
//  TvShowSeasonModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 12/08/23.
//

import Foundation

struct TvShowSeasonModel: Identifiable {
    let id: Int
    let posterPath: String
    let seasonName: String
    let releaseYear: String
    let episodeCount: Int
    let seasonNumber: Int
    let seasonOverview: String
}
