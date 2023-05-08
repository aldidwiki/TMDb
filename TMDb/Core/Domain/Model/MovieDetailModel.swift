//
//  MovieDetailModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation

struct MovieDetailModel: Identifiable {
    let id: Int
    let title: String
    let rating: Double
    let posterPath: String?
    let overview: String
    let tagline: String
    let releaseDate: String
    let backdropPath: String?
    let runtime: Int?
    let certification: String
    let genre: String
    let cast: [CreditModel]
}
