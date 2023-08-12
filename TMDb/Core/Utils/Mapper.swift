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
        
        return MovieDetailModel(
            id: movieDetailResponse.id,
            title: movieDetailResponse.title,
            rating: movieDetailResponse.rating ?? 0.0,
            posterPath: movieDetailResponse.posterPath ?? "",
            overview: movieDetailResponse.overview ?? "-",
            tagline: movieDetailResponse.tagline,
            releaseDate: movieDetailResponse.releaseDate ?? "",
            backdropPath: movieDetailResponse.backdropPath ?? "",
            runtime: movieDetailResponse.runtime ?? 0,
            certification: movieCertification,
            genre: movieDetailResponse.genres.formatGenres(),
            cast: mapMovieCreditResponseModelToDomains(input: movieDetailResponse.credits),
            budget: movieDetailResponse.budget,
            revenue: movieDetailResponse.revenue,
            status: movieDetailResponse.status,
            spokenLanguage: movieDetailResponse.spokenLanguages.formatSpokenLanguage(),
            instagramId: movieDetailResponse.externalMedia?.instagramId ?? "",
            facebookId: movieDetailResponse.externalMedia?.facebookId ?? "",
            twitterId: movieDetailResponse.externalMedia?.twitterId ?? "",
            imdbId: movieDetailResponse.externalMedia?.imdbId ?? "",
            videos: mapVideoResponseModelToDomains(input: movieDetailResponse.videos)
        )
    }
    
    static func mapTvShowDetailResponseToDomain(
        input tvShowDetailResponse: TvShowDetailResponse
    ) -> TvShowDetailModel {
        let tvContentRating = tvShowDetailResponse.contentRating.results.first { contentRating in
            contentRating.ratingRegion == "US"
        }?.rating ?? "NR"
        
        return TvShowDetailModel(
            id: tvShowDetailResponse.id,
            backdropPath: tvShowDetailResponse.backdropPath ?? "",
            releaseDate: tvShowDetailResponse.releaseDate ?? "",
            title: tvShowDetailResponse.title,
            overview: tvShowDetailResponse.overview ?? "",
            posterPath: tvShowDetailResponse.posterPath ?? "",
            tagline: tvShowDetailResponse.tagline,
            status: tvShowDetailResponse.status,
            type: tvShowDetailResponse.type,
            genre: tvShowDetailResponse.genres.formatGenres(),
            rating: tvShowDetailResponse.rating ?? 0.0,
            runtime: tvShowDetailResponse.runtime.first ?? 0,
            spokenLanguage: tvShowDetailResponse.spokenLanguages.formatSpokenLanguage(),
            contentRating: tvContentRating,
            instagramId: tvShowDetailResponse.externalMedia?.instagramId ?? "",
            facebookId: tvShowDetailResponse.externalMedia?.facebookId ?? "",
            twitterId: tvShowDetailResponse.externalMedia?.twitterId ?? "",
            imdbId: tvShowDetailResponse.externalMedia?.imdbId ?? "",
            videos: mapVideoResponseModelToDomains(input: tvShowDetailResponse.videos),
            credits: mapTvShowCreditResponseModelToDomains(input: tvShowDetailResponse.credits),
            networks: mapNetworkResponseModelToDomains(input: tvShowDetailResponse.networks)
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
        favoriteEntity.mediaType = Constants.movieType
        return favoriteEntity
    }
    
    static func mapTvShowDetailModelToFavoriteEntity(
        input tvShowDetailModel: TvShowDetailModel
    ) -> FavoriteEntity {
        let favoriteEntity = FavoriteEntity()
        favoriteEntity.id = tvShowDetailModel.id
        favoriteEntity.title = tvShowDetailModel.title
        favoriteEntity.posterPath = tvShowDetailModel.posterPath
        favoriteEntity.rating = tvShowDetailModel.rating
        favoriteEntity.releasedDate = tvShowDetailModel.releaseDate
        favoriteEntity.mediaType = Constants.tvType
        return favoriteEntity
    }
    
    static func mapFavoriteEntitiesToDomains(
        input favoriteEntities: [FavoriteEntity]
    ) -> [FavoriteModel] {
        return favoriteEntities.map { item in
            FavoriteModel(
                id: item.id,
                title: item.title,
                posterPath: item.posterPath,
                rating: item.rating,
                releaseDate: item.releasedDate,
                mediaType: item.mediaType
            )
        }
    }
    
    static func mapFavoriteModelToMovieModel(
        input favoriteModel: FavoriteModel
    ) -> MovieModel {
        return MovieModel(
            id: favoriteModel.id,
            title: favoriteModel.title,
            posterPath: favoriteModel.posterPath,
            rating: favoriteModel.rating,
            releaseDate: favoriteModel.releaseDate
        )
    }
    
    static func mapFavoriteModelToTvShowModel(
        input favoriteModel: FavoriteModel
    ) -> TvShowModel {
        return TvShowModel(
            id: favoriteModel.id,
            title: favoriteModel.title,
            posterPath: favoriteModel.posterPath,
            rating: favoriteModel.rating,
            releaseDate: favoriteModel.releaseDate
        )
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
            credits: mapPersonCreditResponseToDomains(input: personResponse),
            instagramId: personResponse.externalMedia?.instagramId ?? "",
            facebookId: personResponse.externalMedia?.facebookId ?? "",
            imdbId: personResponse.externalMedia?.imdbId ?? "",
            twitterId: personResponse.externalMedia?.twitterId ?? ""
        )
    }
    
    static func mapTvResponseModelsToDomains(
        input tvResponseModels: [TvResponseModel]
    ) -> [TvShowModel] {
        return tvResponseModels.map { tvResponseModel in
            TvShowModel(
                id: tvResponseModel.id,
                title: tvResponseModel.title,
                posterPath: tvResponseModel.posterPath ?? "",
                rating: tvResponseModel.rating ?? 0.0,
                releaseDate: tvResponseModel.releaseDate ?? ""
            )
        }
    }
    
    private static func mapMovieCreditResponseModelToDomains(
        input creditResponse: MovieCreditResponse
    ) -> [CreditModel] {
        return creditResponse.cast.map { cast in
            CreditModel(
                id: cast.id,
                name: cast.name ?? "",
                profilePath: cast.profilePath ?? "",
                characterName: cast.characterName ?? "",
                order: cast.order ?? 0,
                popularity: cast.popularity,
                releaseDate: "",
                episodeCount: 0
            )
        }
    }
    
    private static func mapTvShowCreditResponseModelToDomains(
        input tvShowCreditResponse: TvShowCreditResponse
    ) -> [CreditModel] {
        return tvShowCreditResponse.cast.map { tvShowCast in
            CreditModel(
                id: tvShowCast.id,
                name: tvShowCast.name ?? "",
                profilePath: tvShowCast.profilePath ?? "",
                characterName: tvShowCast.roles.first?.characterName ?? "",
                order: tvShowCast.order ?? 0,
                popularity: tvShowCast.popularity,
                releaseDate: "",
                episodeCount: tvShowCast.totalEpisodeCount
            )
        }.sorted {
            $0.episodeCount > $1.episodeCount
        }
    }
    
    private static func mapVideoResponseModelToDomains(
        input videoResponse: VideoResponse
    ) -> [VideoModel] {
        return videoResponse.results.map { video in
            VideoModel(
                id: video.id,
                key: video.key,
                name: video.name,
                site: video.site,
                type: video.type
            )
        }
        .filter { video in
            video.site == "YouTube" && video.type == "Trailer"
        }
        .sorted {
            $0.name < $1.name
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
                order: cast.order ?? 0,
                popularity: cast.popularity,
                releaseDate: cast.releaseDate ?? "",
                episodeCount: 0
            )
        }.sorted {
            $0.releaseDate > $1.releaseDate
        }
    }
    
    private static func mapNetworkResponseModelToDomains(
        input networkResponseModel: [NetworkResponseModel]
    ) -> [NetworkModel] {
        return networkResponseModel.map { network in
            NetworkModel(
                id: network.id,
                logoPath: network.logoPath ?? "",
                name: network.name
            )
        }
    }
}
