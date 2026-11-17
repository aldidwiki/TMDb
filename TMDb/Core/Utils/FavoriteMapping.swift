import Foundation

extension Mapper {
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
}
