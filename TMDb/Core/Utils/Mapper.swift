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
                releaseDate: item.releaseDate ?? "",
                backdropPath: item.backdropPath,
                genreIDs: item.genreIDs ?? [],
                overview: item.overview ?? ""
            )
        }
    }

    static func mapGenreResponseToDomains(input: GenreResponse) -> [GenreModel] {
        input.genres.map { GenreModel(id: $0.id, name: $0.genreName) }
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
            videos: mapVideoResponseModelToDomains(input: movieDetailResponse.videos),
            voteCount: movieDetailResponse.voteCount,
            director: crewNames(for: "Director", in: movieDetailResponse.credits.crew ?? []),
            usReleaseDate: usTheatricalReleaseDate(in: movieDetailResponse.releaseDates.results),
            composer: crewNames(for: "Original Music Composer", in: movieDetailResponse.credits.crew ?? [])
        )
    }

    private static func crewNames(for job: String, in crew: [MovieCrewResponseModel]) -> String? {
        var seen: Set<String> = []
        let names = crew.compactMap { credit -> String? in
            guard credit.job == job, let name = credit.name?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty, seen.insert(name).inserted else { return nil }
            return name
        }
        return names.isEmpty ? nil : names.joined(separator: ", ")
    }

    private static func usTheatricalReleaseDate(in releases: [MovieCertificationResponse]) -> String? {
        let usReleases = releases.filter { $0.region == "US" }.flatMap(\.movieCertificationResponseModel)
        // Prefer a wide theatrical release. Use a limited release when there is no wide date.
        for type in [3, 2] {
            let dates = usReleases.filter { $0.type == type }.compactMap { release -> String? in
                guard let rawDate = release.releaseDate, rawDate.count >= 10 else { return nil }
                return String(rawDate.prefix(10))
            }
            if let earliest = dates.min() { return earliest }
        }
        return nil
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
            networks: mapNetworkResponseModelToDomains(input: tvShowDetailResponse.networks),
            seasons: mapTvShowSeasonResponseModelToDomains(input: tvShowDetailResponse.seasons),
            voteCount: tvShowDetailResponse.voteCount
        )
    }
    
    static func mapMovieToFavorite(_ movie: MovieDetailModel) -> FavoriteModel {
        FavoriteModel(
            id: .init(mediaType: .movie, mediaID: movie.id),
            title: movie.title,
            posterPath: movie.posterPath,
            rating: movie.rating,
            releaseDate: movie.releaseDate,
            overview: movie.overview,
            voteCount: movie.voteCount
        )
    }

    static func mapTvShowToFavorite(_ tvShow: TvShowDetailModel) -> FavoriteModel {
        FavoriteModel(
            id: .init(mediaType: .tv, mediaID: tvShow.id),
            title: tvShow.title,
            posterPath: tvShow.posterPath,
            rating: tvShow.rating,
            releaseDate: tvShow.releaseDate,
            overview: tvShow.overview,
            voteCount: tvShow.voteCount
        )
    }

    static func mapPersonToFavorite(_ person: PersonModel) -> FavoriteModel {
        FavoriteModel(
            id: .init(mediaType: .person, mediaID: person.id),
            title: person.name,
            posterPath: person.profilePath,
            department: person.knownFor
        )
    }

    static func mapFavoriteEntitiesToDomains(input: [FavoriteEntity]) -> [FavoriteModel] {
        input.compactMap { item in
            guard let type = FavoriteModel.MediaType(rawValue: item.mediaType) else { return nil }
            return FavoriteModel(
                id: .init(mediaType: type, mediaID: item.id),
                title: item.title,
                posterPath: item.posterPath,
                rating: item.rating,
                releaseDate: item.releasedDate,
                overview: item.overview,
                voteCount: item.voteCount,
                department: item.department,
                createdAt: item.createdAt
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
            alsoKnownAs: personResponse.alsoKnownAs ?? [],
            credits: mapPersonCreditResponseToDomains(input: personResponse),
            instagramId: personResponse.externalMedia?.instagramId ?? "",
            facebookId: personResponse.externalMedia?.facebookId ?? "",
            imdbId: personResponse.externalMedia?.imdbId ?? personResponse.imdbId ?? "",
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
    
    static func mapTvShowSeasonDetailResponseToDomains(
        input tvShowSeasonDetailResponse: TvShowSeasonDetailResponse
    ) -> [TvShowSeasonDetailModel] {
        return tvShowSeasonDetailResponse.episodes.map { episode in
            TvShowSeasonDetailModel(
                id: episode.id,
                name: episode.episodeName,
                overview: episode.overview ?? "",
                runtime: episode.episodeRuntime ?? 0,
                rating: episode.voteAverage ?? 0.0,
                episodeNumber: episode.episodeNumber,
                stillPath: episode.stillPath ?? "",
                airDate: episode.airDate ?? ""
            )
        }
    }
    
    static func mapPersonPopularResponseToDomains(
        input personPopularResponse: PersonPopularResponse
    ) -> [PersonPopularModel] {
        return personPopularResponse.results.map { person in
            PersonPopularModel(
                id: person.id,
                name: person.name ?? "",
                profilePath: person.profilePath ?? ""
            )
        }
    }
    
    static func mapImageResponseToPersonImageDomains(
        input imageResponse: ImageResponse
    ) -> [PersonImageModel] {
        guard let profileImages = imageResponse.profileImages else {
            return []
        }
        
        var seen: Set<String> = []
        return profileImages.compactMap { image in
            guard let path = image.filePath, path.hasPrefix("/"), path.count > 1,
                  seen.insert(path).inserted else { return nil }
            return PersonImageModel(filePath: path, aspectRatio: image.aspectRatio)
        }
    }
    
    static func mapImageResponseToImageDomains(
        input imageResponse: ImageResponse
    ) -> [ImageModel] {
        guard let backdrops = imageResponse.backdrops else {
            return []
        }
        
        return backdrops.map { imageResponseModel in
            ImageModel(
                id: imageResponse.imageId,
                filePath: imageResponseModel.filePath ?? ""
            )
        }
    }
    
    static func mapSearchResponseModelToDomains(
        input responseModel: [SearchResponseModel]
    ) -> [SearchModel] {
        return responseModel.compactMap { model in
            guard let mediaType = model.mediaType.flatMap(SearchModel.MediaType.init(rawValue:)) else {
                return nil
            }
            return SearchModel(
                id: .init(mediaType: mediaType, value: model.id),
                name: model.title ?? model.name ?? "",
                releaseDate: model.releaseDate ?? model.firstAirDate ?? "",
                imagePath: model.posterPath ?? model.profilePath ?? "",
                voteAverage: model.voteAverage,
                overview: model.overview ?? "",
                knownForDepartment: model.knownForDepartment ?? ""
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
                order: cast.order ?? .max,
                popularity: cast.popularity,
                releaseDate: "",
                episodeCount: 0,
                mediaType: Constants.movieResponseType
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
                episodeCount: tvShowCast.totalEpisodeCount,
                mediaType: Constants.tvType
            )
        }.sorted {
            $0.order < $1.order
        }
    }
    
    private static func mapTvShowSeasonResponseModelToDomains(
        input tvShowSeasonResponseModels: [TvShowSeasonResponseModel]
    ) -> [TvShowSeasonModel] {
        return tvShowSeasonResponseModels.map { tvShowSeasonResponseModel in
            TvShowSeasonModel(
                id: tvShowSeasonResponseModel.id,
                posterPath: tvShowSeasonResponseModel.posterPath ?? "",
                seasonName: tvShowSeasonResponseModel.seasonName ?? "",
                seasonAirDate: tvShowSeasonResponseModel.airDate ?? "",
                episodeCount: tvShowSeasonResponseModel.episodeCount ?? 0,
                seasonNumber: tvShowSeasonResponseModel.seasonNumber,
                seasonOverview: tvShowSeasonResponseModel.overview ?? "",
                seasonVoteAverage: tvShowSeasonResponseModel.voteAverage ?? 0.0
            )
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
        let cast = (personResponse.credits?.cast ?? []).map { ($0, false) }
        let crew = (personResponse.credits?.crew ?? []).map { ($0, true) }
        return (cast + crew).map { credit, isCrewCredit in
            CreditModel(
                id: credit.id,
                name: credit.movieTitle ?? credit.tvTitle ?? "",
                profilePath: credit.posterPath ?? "",
                characterName: credit.characterName ?? credit.job ?? "",
                order: credit.order ?? 0,
                popularity: credit.popularity ?? 0,
                releaseDate: credit.releaseDate ?? credit.firstAirDate ?? "",
                episodeCount: credit.mediaType == Constants.tvShowResponseType && !isCrewCredit
                    ? (credit.episodeCount ?? 0)
                    : 0,
                mediaType: credit.mediaType,
                isCrewCredit: isCrewCredit
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
