import Combine
import Foundation
import Observation

@MainActor
@Observable
final class DashboardPresenter {
    enum SectionState<Item> {
        case idle
        case loading
        case loaded([Item])
        case failed

        func mapItems<Result>(_ transform: ([Item]) -> [Result]) -> SectionState<Result> {
            switch self {
            case .idle: .idle
            case .loading: .loading
            case .loaded(let items): .loaded(transform(items))
            case .failed: .failed
            }
        }
    }

    private struct GenreStyle {
        let id: Int
        let monogram: String
        let background: UInt32
        let accent: UInt32
    }

    private struct GenrePalette {
        let background: UInt32
        let accent: UInt32
    }

    struct GenreTile: Identifiable {
        let id: Int
        let name: String
        let monogram: String
        let background: UInt32
        let accent: UInt32
    }

    private static let genreStyles: [GenreStyle] = [
        .init(id: 878, monogram: "SF", background: 0xEEF0FF, accent: 0x3B4CCA),
        .init(id: 28, monogram: "AC", background: 0xFFF0F2, accent: 0xB52330),
        .init(id: 18, monogram: "DR", background: 0xFFF5E5, accent: 0x8C5D19),
        .init(id: 53, monogram: "TH", background: 0xEEF1F5, accent: 0x334155)
    ]

    private static let genrePalettes: [GenrePalette] = [
        .init(background: 0xEEF0FF, accent: 0x3B4CCA),
        .init(background: 0xFFF0F2, accent: 0xB52330),
        .init(background: 0xFFF5E5, accent: 0x8C5D19),
        .init(background: 0xEEF1F5, accent: 0x334155),
        .init(background: 0xEAF6F2, accent: 0x26735D),
        .init(background: 0xF4ECFA, accent: 0x75439A)
    ]

    private(set) var trending: SectionState<MovieModel> = .idle
    private(set) var nowPlaying: SectionState<MovieModel> = .idle
    private var genres: SectionState<GenreModel> = .idle
    private(set) var loadingTrailerID: Int?

    @ObservationIgnored private var requests: [PartialKeyPath<DashboardPresenter>: AnyCancellable] = [:]
    @ObservationIgnored private var trailerRequest: AnyCancellable?
    private let dashboardUseCase: DashboardUseCase
    private let detailUseCase: DetailUseCase

    init(dashboardUseCase: DashboardUseCase, detailUseCase: DetailUseCase) {
        self.dashboardUseCase = dashboardUseCase
        self.detailUseCase = detailUseCase
    }

    func load() {
        loadTrending()
        loadNowPlaying()
        loadGenres()
    }

    func loadTrending() {
        loadSection(\.trending, from: dashboardUseCase.getTrendingMovies().map { Array($0.prefix(5)) })
    }

    func loadNowPlaying() {
        loadSection(\.nowPlaying, from: dashboardUseCase.getNowPlayingMovies().map { Array($0.prefix(10)) })
    }

    func loadGenres() {
        loadSection(\.genres, from: dashboardUseCase.getMovieGenres())
    }

    var allGenres: SectionState<GenreTile> {
        genres.mapItems { genres in
            genres.map { genre in
                let style = Self.genreStyles.first { $0.id == genre.id }
                let palette = Self.genrePalettes[genre.id % Self.genrePalettes.count]
                return GenreTile(
                    id: genre.id,
                    name: genre.name,
                    monogram: style?.monogram ?? Self.monogram(for: genre.name),
                    background: style?.background ?? palette.background,
                    accent: style?.accent ?? palette.accent
                )
            }
        }
    }

    private static func monogram(for name: String) -> String {
        let initials = name
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()

        return initials.isEmpty ? String(name.prefix(2)).uppercased() : initials.uppercased()
    }

    func metadata(for movie: MovieModel) -> String {
        let year = String(movie.releaseDate.prefix(4))
        guard case .loaded(let genres) = genres else { return year }
        let names = movie.genreIDs.compactMap { id in genres.first { $0.id == id }?.name }
        let genreSummary = names.prefix(2).joined(separator: " / ")
        return [year, genreSummary].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    private func loadSection<Items: Publisher, Item>(
        _ keyPath: ReferenceWritableKeyPath<DashboardPresenter, SectionState<Item>>,
        from publisher: @autoclosure () -> Items
    ) where Items.Output == [Item], Items.Failure == Error {
        switch self[keyPath: keyPath] {
        case .loading, .loaded:
            return
        case .idle, .failed:
            self[keyPath: keyPath] = .loading
        }

        requests[keyPath] = publisher()
            .first()
            .map(SectionState<Item>.loaded)
            .replaceEmpty(with: .loaded([]))
            .replaceError(with: .failed)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?[keyPath: keyPath] = state
                self?.requests[keyPath] = nil
            }
    }

    func loadTrailer(for movie: MovieModel, completion: @escaping (URL?) -> Void) {
        guard loadingTrailerID != movie.id else { return }

        trailerRequest?.cancel()
        loadingTrailerID = movie.id

        trailerRequest = detailUseCase.getMovie(movieId: movie.id)
            .map { movie in
                movie.videos.first.flatMap { URL(string: Constants.youtubeBaseUrl + $0.key) }
            }
            .replaceEmpty(with: nil)
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let self else { return }
                self.loadingTrailerID = nil
                completion(url)
            }
    }
}
