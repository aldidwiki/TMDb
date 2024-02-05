//
//  CreditModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 08/05/23.
//

import Foundation

struct CreditModel: Identifiable, Equatable {
    let id: Int
    let name: String
    let profilePath: String
    let characterName: String
    let order: Int
    let popularity: Double
    let releaseDate: String
    let episodeCount: Int
    let mediaType: String
}
