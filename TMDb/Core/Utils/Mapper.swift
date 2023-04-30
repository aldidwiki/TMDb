//
//  Mapper.swift
//  TMDb
//
//  Created by Aldi Dwiki Prahasta on 24/11/22.
//

import Foundation

final class Mapper {
    static func mapMovieResponseModelsToDomains (
        input movieResponseModels: [MovieResponseModel]
    ) -> [MovieModel] {
        return movieResponseModels.map { item in
            MovieModel(
                id: item.id,
                title: item.title,
                posterPath: item.posterPath,
                rating: item.rating,
                releaseDate: item.releaseDate
            )
        }
    }
    
    static func mapMovieDetailResponseToDomain(
        input movieDetailResponse: MovieDetailResponse
    ) -> MovieDetailModel {
        return MovieDetailModel(
            id: movieDetailResponse.id,
            title: movieDetailResponse.title,
            rating: movieDetailResponse.rating,
            posterPath: movieDetailResponse.posterPath,
            overview: movieDetailResponse.overview,
            tagline: movieDetailResponse.tagline,
            releaseDate: movieDetailResponse.releaseDate,
            backdropPath: movieDetailResponse.backdropPath
        )
    }
    
    static func mapMovieDetailModelToFavoriteEntity(
        input movieDetailModel: MovieDetailModel
    ) -> FavoriteEntity {
        let favoriteEntity = FavoriteEntity()
        favoriteEntity.id = movieDetailModel.id
        favoriteEntity.title = movieDetailModel.title
        favoriteEntity.posterPath = movieDetailModel.posterPath ?? ""
        favoriteEntity.rating = movieDetailModel.rating
        favoriteEntity.releasedDate = movieDetailModel.releaseDate
        return favoriteEntity
    }
    
    static func mapFavoriteEntitiesToDomains(
        input favoriteEntities: [FavoriteEntity]
    ) -> [MovieModel] {
        return favoriteEntities.map { item in
            MovieModel(
                id: item.id,
                title: item.title,
                posterPath: item.posterPath,
                rating: item.rating,
                releaseDate: item.releasedDate
            )
        }
    }
}
