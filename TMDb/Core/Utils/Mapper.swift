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
                posterPath: item.posterPath ?? "",
                rating: item.rating ?? 0.0,
                releaseDate: item.releaseDate ?? ""
            )
        }
    }
    
    static func mapMovieDetailResponseToDomain(
        input movieDetailResponse: MovieDetailResponse
    ) -> MovieDetailModel {
        var movieCertification = "NR"
        for movieDateItem in movieDetailResponse.releaseDates.results {
            for certificationItem in movieDateItem.movieCertificationResponseModel where movieDateItem.region == "US" {
                movieCertification = certificationItem.certification ?? ""
                break
            }
        }
        
        var movieGenres = ""
        let sortedGenre = movieDetailResponse.genres.sorted { genre1, genre2 in
            genre1.genreName < genre2.genreName
        }
        for genre in sortedGenre {
            if genre == sortedGenre.last {
                movieGenres += "\(genre.genreName)"
            } else {
                movieGenres += "\(genre.genreName), "
            }
        }
        
        let spokenLanguage = movieDetailResponse.spokenLanguages.first?.englishName ?? "-"
        
        return MovieDetailModel(
            id: movieDetailResponse.id,
            title: movieDetailResponse.title,
            rating: movieDetailResponse.rating,
            posterPath: movieDetailResponse.posterPath ?? "",
            overview: movieDetailResponse.overview ?? "-",
            tagline: movieDetailResponse.tagline,
            releaseDate: movieDetailResponse.releaseDate ?? "",
            backdropPath: movieDetailResponse.backdropPath ?? "",
            runtime: movieDetailResponse.runtime ?? 0,
            certification: movieCertification,
            genre: movieGenres,
            cast: mapCreditResponseModelToDomains(input: movieDetailResponse),
            budget: movieDetailResponse.budget,
            revenue: movieDetailResponse.revenue,
            status: movieDetailResponse.status,
            spokenLanguage: spokenLanguage,
            instagramId: movieDetailResponse.externalMedia?.instagramId ?? "",
            facebookId: movieDetailResponse.externalMedia?.facebookId ?? "",
            twitterId: movieDetailResponse.externalMedia?.twitterId ?? "",
            imdbId: movieDetailResponse.externalMedia?.imdbId ?? ""
        )
    }
    
    static func mapMovieDetailModelToFavoriteEntity(
        input movieDetailModel: MovieDetailModel
    ) -> FavoriteEntity {
        let favoriteEntity = FavoriteEntity()
        favoriteEntity.id = movieDetailModel.id
        favoriteEntity.title = movieDetailModel.title
        favoriteEntity.posterPath = movieDetailModel.posterPath
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
    
    static func mapPersonResponseToDomain(
        input personResponse: PersonResponse
    ) -> PersonModel {
        var genderText = "Unknown"
        if personResponse.gender == 1 {
            genderText = "Female"
        } else if personResponse.gender == 2 {
            genderText = "Male"
        }
        
        return PersonModel(
            id: personResponse.id,
            name: personResponse.name ?? "",
            profilePath: personResponse.profilePath ?? "",
            birthday: personResponse.birthday ?? "-",
            deathday: personResponse.deathday ?? "",
            gender: genderText,
            biography: personResponse.biography ?? "-",
            birthplace: personResponse.birthplace ?? "-",
            knownFor: personResponse.knownFor ?? "-",
            credits: mapPersonCreditResponseToDomains(input: personResponse)
        )
    }
    
    private static func mapCreditResponseModelToDomains(
        input movieDetailResponse: MovieDetailResponse
    ) -> [CreditModel] {
        return movieDetailResponse.credits.cast.map { cast in
            CreditModel(
                id: cast.id,
                name: cast.name ?? "",
                profilePath: cast.profilePath ?? "",
                characterName: cast.characterName ?? "",
                order: cast.order ?? 0
            )
        }
    }
    
    private static func mapPersonCreditResponseToDomains(
        input personResponse: PersonResponse
    ) -> [CreditModel] {
        return personResponse.credits.cast.map { cast in
            CreditModel(
                id: cast.id,
                name: cast.title ?? "",
                profilePath: cast.posterPath ?? "",
                characterName: cast.characterName ?? "",
                order: cast.order ?? 0
            )
        }
    }
}
