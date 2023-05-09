//
//  MovieModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation

struct MovieModel: Equatable, Identifiable {
    let id: Int
    let title: String
    let posterPath: String
    let rating: Double
    let releaseDate: String
}
