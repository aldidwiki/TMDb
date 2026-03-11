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
    @Attribute(.unique) var id: Int
    var title: String
    var posterPath: String
    var releasedDate: String
    var rating: Double
    var mediaType: String
    var createdAt: Date
    
    init(
        id: Int,
        title: String,
        posterPath: String,
        releasedDate: String = "",
        rating: Double = 0.0,
        mediaType: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releasedDate = releasedDate
        self.rating = rating
        self.mediaType = mediaType
        self.createdAt = createdAt
    }
}
