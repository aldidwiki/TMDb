//
//  SearchModel.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation

struct SearchModel: Equatable, Identifiable {
    let id: Int
    let name: String
    let releaseDate: String
    let imagePath: String
    let voteAverage: Double
    let mediaType: String
}
