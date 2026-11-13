//
//  SearchModel.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation

struct SearchModel: Equatable, Identifiable {
    enum MediaType: String {
        case movie
        case tv
        case person
    }

    struct ID: Hashable {
        let mediaType: MediaType
        let value: Int
    }

    let id: ID
    let name: String
    let releaseDate: String
    let imagePath: String
    let voteAverage: Double?
    let overview: String
    let knownForDepartment: String
}

struct SearchPage {
    let results: [SearchModel]
    let totalPages: Int
}
