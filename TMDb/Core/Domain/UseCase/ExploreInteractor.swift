import Combine

protocol ExploreUseCase {
    func page(_ query: ExploreQuery) -> AnyPublisher<ExplorePage, Error>
    func genres(for media: ExploreMedia) -> AnyPublisher<[GenreModel], Error>
}

final class ExploreInteractor: ExploreUseCase {
    private let repository: ExploreRepositoryProtocol

    init(repository: ExploreRepositoryProtocol) {
        self.repository = repository
    }

    func page(_ query: ExploreQuery) -> AnyPublisher<ExplorePage, Error> {
        repository.page(query)
    }

    func genres(for media: ExploreMedia) -> AnyPublisher<[GenreModel], Error> {
        repository.genres(for: media)
    }
}
