//
//  FavoriteEntity.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 25/11/22.
//

import Foundation
import SwiftData

@Model
class FavoriteEntity {
    var id: Int
    var title: String
    var posterPath: String
    var releasedDate: String
    var rating: Double
    var mediaType: String
    var createdAt: Date
    var overview: String?
    var voteCount: Int?
    var department: String?
    
    init(
        id: Int,
        title: String,
        posterPath: String,
        releasedDate: String = "",
        rating: Double = 0.0,
        mediaType: String,
        createdAt: Date = .now,
        overview: String? = nil,
        voteCount: Int? = nil,
        department: String? = nil
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releasedDate = releasedDate
        self.rating = rating
        self.mediaType = mediaType
        self.createdAt = createdAt
        self.overview = overview
        self.voteCount = voteCount
        self.department = department
    }
}
