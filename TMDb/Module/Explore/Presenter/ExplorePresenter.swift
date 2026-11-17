import Combine
import Foundation
import Observation

@MainActor
@Observable
final class ExplorePresenter {
    struct Settings: Equatable {
        var collection: ExploreCollection?
        var sort: ExploreSort?
        var filters = ExploreFilters()

        var effectiveSort: ExploreSort {
            if let sort { return sort }
            switch collection {
            case .topRated: return .highestRated
            case .trending: return .trending
            case .alphabetical: return .name
            default: return .popular
            }
        }
    }

    struct Feed {
        var settings = Settings()
        var items: [ExploreItem] = []
        var nextPages: [ExploreMedia: Int] = [:]
        var finished: Set<ExploreMedia> = []
        var failed: Set<ExploreMedia> = []
        var isLoading = false
        var hasLoaded = false
        let revision = UUID()
    }

    private let useCase: ExploreUseCase
    private var feeds: [ExploreCategory: Feed] = [:]
    @ObservationIgnored private var requests: [ExploreCategory: AnyCancellable] = [:]
    @ObservationIgnored private var genreRequests: [ExploreMedia: AnyCancellable] = [:]
    private var catalogs: [ExploreMedia: [GenreModel]] = [:]
    private(set) var genreFailures: Set<ExploreMedia> = []
    private(set) var genresLoading: Set<ExploreMedia> = []
    private(set) var category: ExploreCategory = .all

    init(useCase: ExploreUseCase) {
        self.useCase = useCase
    }

    var feed: Feed { feeds[category, default: Feed()] }

    var hasMore: Bool {
        sources(for: category, settings: feed.settings).contains { !feed.finished.contains($0) }
    }

    var genreOptions: [String] {
        Set(genreSources.flatMap { catalogs[$0, default: []].map(\.name) }).sorted {
            $0.localizedStandardCompare($1) == .orderedAscending
        }
    }

    var isLoadingGenres: Bool { genreSources.contains { genresLoading.contains($0) } }
    var hasGenreError: Bool { genreSources.contains { genreFailures.contains($0) } }

    var items: [ExploreItem] {
        let settings = feed.settings
        let sort = settings.effectiveSort
        let filtered = feed.items.filter { item in
            guard item.id.media == .person else { return true }
            let filters = settings.filters
            return (filters.department == nil || filters.department == item.department)
                && (filters.knownFor?.matches(item.knownFor) ?? true)
        }

        guard category == .all || category == .people else { return filtered }
        return filtered.sorted { left, right in
            switch sort {
            case .title, .name:
                return left.title.localizedStandardCompare(right.title) == .orderedAscending
            case .newest:
                return (left.date ?? "") > (right.date ?? "")
            case .highestRated:
                return (left.rating ?? -1) > (right.rating ?? -1)
            case .mostVoted:
                return (left.votes ?? -1) > (right.votes ?? -1)
            case .knownMovies, .knownShows:
                let type: ExploreMedia = sort == .knownMovies ? .movie : .tv
                let leftMatch = left.knownFor.contains(type)
                let rightMatch = right.knownFor.contains(type)
                if leftMatch != rightMatch { return leftMatch }
                return (left.popularity ?? -1) > (right.popularity ?? -1)
            case .popular:
                return (left.popularity ?? -1) > (right.popularity ?? -1)
            case .trending:
                return false
            }
        }
    }

    private var genreSources: [ExploreMedia] {
        switch category {
        case .all: [.movie, .tv]
        case .movies: [.movie]
        case .shows: [.tv]
        case .people: []
        }
    }

    func start() {
        for media in [ExploreMedia.movie, .tv] where !genreFailures.contains(media) { loadGenres(media) }
        loadIfNeeded()
    }

    func selectCategory(_ selected: ExploreCategory) {
        category = selected
        loadIfNeeded()
    }

    func selectCollection(_ collection: ExploreCollection) {
        var settings = feed.settings
        settings.collection = settings.collection == collection ? nil : collection
        if category == .people { settings.sort = nil }
        update(settings)
    }

    func applyFilters(_ filters: ExploreFilters) {
        var settings = feed.settings
        settings.filters = filters
        update(settings)
    }

    func applySort(_ sort: ExploreSort) {
        var settings = feed.settings
        settings.sort = sort
        update(settings)
    }

    func genreLabels(for item: ExploreItem) -> [String] {
        catalogs[item.id.media, default: []].filter { item.genres.contains($0.id) }.map(\.name)
    }

    func retryGenres() {
        for media in genreSources where genreFailures.contains(media) { loadGenres(media) }
    }

    func loadMore() {
        let current = feed
        guard !current.isLoading, current.failed.isEmpty else { return }
        request(sources(for: category, settings: current.settings).filter { !current.finished.contains($0) })
    }

    func retry() {
        request(sources(for: category, settings: feed.settings).filter { feed.failed.contains($0) })
    }

    private func loadIfNeeded() {
        if feeds[category] == nil { feeds[category] = Feed() }
        if !feed.hasLoaded { loadMore() }
    }

    private func update(_ settings: Settings) {
        guard settings != feed.settings else { return }
        requests[category] = nil
        feeds[category] = Feed(settings: settings)
        loadMore()
    }

    private func sources(for category: ExploreCategory, settings: Settings) -> [ExploreMedia] {
        let candidates: [ExploreMedia]
        switch category {
        case .all:
            candidates = settings.effectiveSort.includesPeopleInAll && !settings.filters.filtersTitles
                ? [.movie, .tv, .person] : [.movie, .tv]
        case .movies: candidates = [.movie]
        case .shows: candidates = [.tv]
        case .people: candidates = [.person]
        }
        return candidates.filter { type in
            type == .person || settings.filters.genres.isEmpty || !genreIDs(for: type, settings: settings).isEmpty
        }
    }

    private func genreIDs(for media: ExploreMedia, settings: Settings) -> [Int] {
        catalogs[media, default: []].filter { settings.filters.genres.contains($0.name) }.map(\.id)
    }

    private func request(_ sources: [ExploreMedia]) {
        let selected = category
        var current = feed
        guard !current.isLoading else { return }
        guard !sources.isEmpty else {
            current.hasLoaded = true
            feeds[selected] = current
            return
        }
        current.isLoading = true
        feeds[selected] = current
        let revision = current.revision
        let settings = current.settings

        let publishers = sources.map { media in
            let query = ExploreQuery(
                media: media, page: current.nextPages[media, default: 1], collection: settings.collection,
                sort: settings.effectiveSort, genreIDs: genreIDs(for: media, settings: settings),
                year: settings.filters.year, minimumRating: settings.filters.minimumRating
            )
            return useCase.page(query)
                .map { (media, Result<ExplorePage, Error>.success($0)) }
                .catch { Just((media, Result<ExplorePage, Error>.failure($0))) }
                .replaceEmpty(with: (media, .failure(Foundation.URLError(.badServerResponse))))
                .eraseToAnyPublisher()
        }

        requests[selected] = Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] responses in
                guard let self, var updated = feeds[selected], updated.revision == revision else { return }
                updated.isLoading = false
                var seen = Set(updated.items.map(\.id))
                for media in sources {
                    guard let result = responses.first(where: { $0.0 == media })?.1 else { continue }
                    switch result {
                    case .success(let page):
                        let pageNumber = updated.nextPages[media, default: 1]
                        updated.hasLoaded = true
                        updated.items.append(contentsOf: seen.unseenItems(page.items))
                        updated.nextPages[media] = pageNumber + 1
                        if pageNumber >= page.totalPages { updated.finished.insert(media) }
                        updated.failed.remove(media)
                    case .failure:
                        updated.failed.insert(media)
                    }
                }
                feeds[selected] = updated
                requests[selected] = nil
            }
    }

    private func loadGenres(_ media: ExploreMedia) {
        guard catalogs[media] == nil, !genresLoading.contains(media) else { return }
        genresLoading.insert(media)
        genreFailures.remove(media)
        genreRequests[media] = useCase.genres(for: media)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                genresLoading.remove(media)
                if case .failure = completion { genreFailures.insert(media) }
                genreRequests[media] = nil
            } receiveValue: { [weak self] genres in
                guard let self else { return }
                catalogs[media] = genres
                if let all = feeds[.all], !genreIDs(for: media, settings: all.settings).isEmpty {
                    requests[.all] = nil
                    feeds[.all] = Feed(settings: all.settings)
                    if category == .all { loadMore() }
                }
            }
    }
}
