//
//  TvShowModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 03/07/23.
//

import Foundation

struct TvShowModel: Equatable, Identifiable {
    let id: Int
    let title: String
    let posterPath: String
    let rating: Double
    let releaseDate: String
}
