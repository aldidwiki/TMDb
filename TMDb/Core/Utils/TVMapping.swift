import Foundation

extension Mapper {
    static func mapSimilarShowPage(_ response: TvResponse, requestedPage: Int) -> SimilarTitlesPage {
        SimilarTitlesPage(
            titles: response.tvShows.map { show in
                SimilarTitle(
                    id: show.id,
                    title: show.title,
                    posterPath: show.posterPath ?? "",
                    releaseDate: show.releaseDate ?? "",
                    rating: show.rating
                )
            },
            page: response.page ?? requestedPage,
            totalPages: response.totalPages ?? requestedPage,
            totalResults: response.totalResults
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
            networks: mapNetworkResponseModelToDomains(input: tvShowDetailResponse.networks),
            seasons: mapTvShowSeasonResponseModelToDomains(input: tvShowDetailResponse.seasons),
            voteCount: tvShowDetailResponse.voteCount,
            creators: joinedCreditNames(tvShowDetailResponse.creators?.map(\.name) ?? []),
            executiveProducers: joinedCreditNames(tvShowDetailResponse.credits.crew?
                .filter { $0.jobs?.contains { $0.job == "Executive Producer" } == true }
                .map(\.name) ?? [])
        )
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

    private static func mapTvShowCreditResponseModelToDomains(
        input tvShowCreditResponse: TvShowCreditResponse
    ) -> [CreditModel] {
        return tvShowCreditResponse.cast.map { tvShowCast in
            CreditModel(
                id: tvShowCast.id,
                name: tvShowCast.name ?? "",
                profilePath: tvShowCast.profilePath ?? "",
                characterName: tvShowCast.roles.first?.characterName ?? "",
                order: tvShowCast.order ?? .max,
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
