import Combine

protocol GenreUseCase {
    func discoverMovies(query: GenreMovieQuery) -> AnyPublisher<GenreMoviePage, Error>
}

final class GenreInteractor: GenreUseCase {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    func discoverMovies(query: GenreMovieQuery) -> AnyPublisher<GenreMoviePage, Error> {
        repository.discoverMovies(query: query)
    }
}
