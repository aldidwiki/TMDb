import Combine
import Foundation
import Observation

@MainActor
@Observable
final class DashboardPresenter {
    struct FeaturedMovie: Identifiable {
        let id: Int
        let title: String
        let metadata: String
        let rating: String
        let backdrop: UInt32
    }

    struct Poster: Identifiable {
        let title: String
        let color: UInt32

        var id: String { title }
    }

    struct Genre: Identifiable {
        let title: String
        let monogram: String
        let titleCount: String
        let background: UInt32
        let accent: UInt32

        var id: String { title }
    }

    let trendingMovies: [FeaturedMovie] = [
        .init(id: 693134, title: "Dune: Part Two", metadata: "2024 · Sci-Fi / Adventure", rating: "8.8", backdrop: 0x292667),
        .init(id: 670292, title: "The Creator", metadata: "2023 · Sci-Fi / Action", rating: "7.1", backdrop: 0x173D49),
        .init(id: 545611, title: "Everything Everywhere All at Once", metadata: "2022 · Action / Adventure", rating: "7.8", backdrop: 0x4D2848),
        .init(id: 335984, title: "Blade Runner 2049", metadata: "2017 · Sci-Fi / Drama", rating: "7.6", backdrop: 0x3F3D67),
        .init(id: 414906, title: "The Batman", metadata: "2022 · Crime / Mystery", rating: "7.7", backdrop: 0x54293C)
    ]

    let nowPlaying: [Poster] = [
        .init(title: "TIDE", color: 0x175469),
        .init(title: "NEON", color: 0x75324D),
        .init(title: "ORBIT", color: 0x2B5963)
    ]

    let genres: [Genre] = [
        .init(title: "Sci-Fi", monogram: "SF", titleCount: "1.4k titles", background: 0xEEF0FF, accent: 0x3B4CCA),
        .init(title: "Action", monogram: "AC", titleCount: "2.1k titles", background: 0xFFF0F2, accent: 0xB52330),
        .init(title: "Drama", monogram: "DR", titleCount: "3.6k titles", background: 0xFFF5E5, accent: 0x8C5D19),
        .init(title: "Thriller", monogram: "TH", titleCount: "1.8k titles", background: 0xEEF1F5, accent: 0x334155)
    ]

    var selectedPage = 0
    private(set) var loadingTrailerID: Int?

    @ObservationIgnored private var trailerRequest: AnyCancellable?
    private let detailUseCase: DetailUseCase

    init(detailUseCase: DetailUseCase) {
        self.detailUseCase = detailUseCase
    }

    func loadTrailer(for movie: FeaturedMovie, completion: @escaping (URL?) -> Void) {
        guard loadingTrailerID != movie.id else { return }

        trailerRequest?.cancel()
        loadingTrailerID = movie.id

        trailerRequest = detailUseCase.getMovie(movieId: movie.id)
            .map { movie in
                movie.videos.first.flatMap { URL(string: Constants.youtubeBaseUrl + $0.key) }
            }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let self else { return }
                self.loadingTrailerID = nil
                completion(url)
            }
    }
}
