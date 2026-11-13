import Combine

protocol DashboardUseCase {
    func getTrendingMovies() -> AnyPublisher<[MovieModel], Error>
    func getNowPlayingMovies() -> AnyPublisher<[MovieModel], Error>
    func getMovieGenres() -> AnyPublisher<[GenreModel], Error>
}

final class DashboardInteractor: DashboardUseCase {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    func getTrendingMovies() -> AnyPublisher<[MovieModel], Error> {
        repository.getTrendingMovies()
    }

    func getNowPlayingMovies() -> AnyPublisher<[MovieModel], Error> {
        repository.getNowPlayingMovies(page: 1, region: "ID")
    }

    func getMovieGenres() -> AnyPublisher<[GenreModel], Error> {
        repository.getMovieGenres()
    }
}
