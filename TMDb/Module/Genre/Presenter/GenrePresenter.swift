import Combine
import Foundation
import Observation

@MainActor
@Observable
final class GenrePresenter {
    enum Sort: String, CaseIterable {
        case popularity = "Popularity"
        case newest = "Newest first"
        case highestRated = "Highest rated"
        case title = "Title A–Z"
        case mostVoted = "Most voted"

        var apiValue: String {
            switch self {
            case .popularity: "popularity.desc"
            case .newest: "primary_release_date.desc"
            case .highestRated: "vote_average.desc"
            case .title: "title.asc"
            case .mostVoted: "vote_count.desc"
            }
        }
    }

    enum ReleaseYear: String, CaseIterable {
        case year2024 = "2024"
        case year2023 = "2023"
        case year2022 = "2022"
        case year2021 = "2021"
        case all = "All years"

        var value: Int? { Int(rawValue) }
    }

    enum MinimumRating: String, CaseIterable {
        case six = "6.0+"
        case seven = "7.0+"
        case eight = "8.0+"
        case nine = "9.0+"
        case any = "Any rating"

        var value: Double? { Double(rawValue.dropLast()) }
    }

    private(set) var sort: Sort = .popularity
    private(set) var releaseYear: ReleaseYear = .all
    private(set) var minimumRating: MinimumRating = .any
    private(set) var movies: [MovieModel] = []
    private(set) var totalResults = 0
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasLoaded = false
    private(set) var loadError = false
    private(set) var loadMoreError = false
    private(set) var listVersion = 0

    @ObservationIgnored private var request: AnyCancellable?
    private let useCase: GenreUseCase
    private let genreID: Int
    private var nextPage = 1
    private var totalPages = 1
    private var requestGeneration = 0

    init(useCase: GenreUseCase, genreID: Int) {
        self.useCase = useCase
        self.genreID = genreID
    }

    var canLoadMore: Bool {
        hasLoaded && !movies.isEmpty && nextPage <= min(totalPages, 500)
    }

    func load() {
        guard !hasLoaded && !isLoading else { return }
        loadNextPage()
    }

    func apply(sort: Sort, year: ReleaseYear, rating: MinimumRating) {
        guard self.sort != sort || releaseYear != year || minimumRating != rating else { return }
        self.sort = sort
        releaseYear = year
        minimumRating = rating
        request?.cancel()
        requestGeneration += 1
        nextPage = 1
        totalPages = 1
        totalResults = 0
        hasLoaded = false
        isLoading = false
        isLoadingMore = false
        loadError = false
        loadMoreError = false
        movies = []
        listVersion += 1
        loadNextPage()
    }

    func loadMoreIfNeeded(after movie: MovieModel) {
        guard !loadMoreError && movies.suffix(3).contains(where: { $0.id == movie.id }) else { return }
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoading && !isLoadingMore && nextPage <= min(totalPages, 500) else { return }

        let page = nextPage
        let generation = requestGeneration
        isLoading = page == 1
        isLoadingMore = page > 1
        loadError = false
        loadMoreError = false

        let query = GenreMovieQuery(
            genreID: genreID,
            sortBy: sort.apiValue,
            releaseYear: releaseYear.value,
            minimumRating: minimumRating.value,
            page: page,
            region: "ID"
        )

        request = useCase.discoverMovies(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self, generation == self.requestGeneration else { return }
                if case .failure = completion {
                    if page == 1 { self.loadError = true }
                    else { self.loadMoreError = true }
                }
                self.isLoading = false
                self.isLoadingMore = false
                self.request = nil
            } receiveValue: { [weak self] result in
                guard let self, generation == self.requestGeneration else { return }
                let knownIDs = Set(self.movies.map(\.id))
                self.movies.append(contentsOf: result.movies.filter { !knownIDs.contains($0.id) })
                self.totalResults = result.totalResults
                self.totalPages = max(1, result.totalPages)
                self.nextPage = result.movies.isEmpty ? self.totalPages + 1 : page + 1
                self.hasLoaded = true
            }
    }
}
