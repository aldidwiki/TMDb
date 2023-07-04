//
//  TvShowDetailModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 04/07/23.
//

import Foundation

struct TvShowDetailModel: Identifiable {
    let id: Int
    let backdropPath: String
    let releaseDate: String
    let title: String
    let overview: String
    let posterPath: String
    let tagline: String
    let status: String
    let type: String
    let genre: String
    let rating: Double
    let runtime: Int
    let spokenLanguage: String
}
