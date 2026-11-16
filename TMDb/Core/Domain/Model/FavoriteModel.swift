//
//  FavoriteModel.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 07/07/23.
//

import Foundation

struct FavoriteModel: Equatable, Identifiable {
    enum MediaType: String {
        case movie = "movie_type"
        case tv = "tv_type"
        case person = "person_type"
    }

    struct ID: Hashable {
        let mediaType: MediaType
        let mediaID: Int
    }

    let id: ID
    let title: String
    let posterPath: String
    var rating: Double = 0
    var releaseDate = ""
    var overview: String?
    var voteCount: Int?
    var department: String?
    var createdAt: Date = .now
}
