import Foundation

extension Mapper {
    static func mapSimilarMoviePage(_ response: MovieResponse, requestedPage: Int) -> SimilarTitlesPage {
        SimilarTitlesPage(
            titles: response.movies.map { movie in
                SimilarTitle(
                    id: movie.id,
                    title: movie.title,
                    posterPath: movie.posterPath ?? "",
                    releaseDate: movie.releaseDate ?? "",
                    rating: movie.rating
                )
            },
            page: response.page ?? requestedPage,
            totalPages: response.totalPages ?? requestedPage,
            totalResults: response.totalResults
        )
    }

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
        joinedCreditNames(crew.filter { $0.job == job }.map(\.name))
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
}
