import Combine

protocol ExploreRepositoryProtocol {
    func page(_ query: ExploreQuery) -> AnyPublisher<ExplorePage, Error>
    func genres(for media: ExploreMedia) -> AnyPublisher<[GenreModel], Error>
}

final class ExploreRepository: ExploreRepositoryProtocol {
    private let dataSource: ExploreDataSource

    init(dataSource: ExploreDataSource) {
        self.dataSource = dataSource
    }

    func page(_ query: ExploreQuery) -> AnyPublisher<ExplorePage, Error> {
        dataSource.page(query)
            .map { response in
                let items = response.results.compactMap { result -> ExploreItem? in
                    guard let title = result.title ?? result.name, !title.isEmpty else { return nil }
                    return ExploreItem(
                        id: .init(media: query.media, value: result.id),
                        title: title,
                        imagePath: result.posterPath ?? result.profilePath,
                        date: result.releaseDate ?? result.firstAirDate,
                        genres: result.genres ?? [],
                        overview: result.overview,
                        rating: result.rating,
                        popularity: result.popularity,
                        votes: result.votes,
                        department: result.department,
                        knownFor: Set((result.knownFor ?? []).compactMap {
                            $0.mediaType.flatMap(ExploreMedia.init(rawValue:))
                        })
                    )
                }
                return ExplorePage(items: items, totalPages: query.trendingPeople ? 1 : min(500, response.totalPages))
            }
            .eraseToAnyPublisher()
    }

    func genres(for media: ExploreMedia) -> AnyPublisher<[GenreModel], Error> {
        dataSource.genres(for: media)
            .map { $0.genres.map { GenreModel(id: $0.id, name: $0.genreName) } }
            .eraseToAnyPublisher()
    }
}
