//
//  TvShowSeasonDetailModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 14/09/23.
//

import Foundation

struct TvShowSeasonDetailModel: Identifiable {
    let id: Int
    let name: String
    let overview: String
    let runtime: Int
    let rating: Double
    let episodeNumber: Int
    let stillPath: String
    let airDate: String
}
