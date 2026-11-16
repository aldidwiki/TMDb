import Combine
import Foundation
import Observation

@MainActor
@Observable
final class SimilarTitlesPresenter {
    enum Phase {
        case idle
        case loading
        case ready
        case failed
    }

    private let fetchPage: (Int) -> AnyPublisher<SimilarTitlesPage, Error>
    @ObservationIgnored private var request: AnyCancellable?
    @ObservationIgnored private var seenIDs: Set<Int>

    private var loadedPage = 0
    private var totalPages = 1

    private(set) var phase: Phase = .idle
    private(set) var titles: [SimilarTitle] = []
    private(set) var previewTitles: [SimilarTitle] = []
    private(set) var totalResults: Int?

    var hasLoaded: Bool { loadedPage > 0 }
    var loadedCount: Int { titles.count }
    var nextPage: Int { loadedPage + 1 }
    var hasMore: Bool { hasLoaded && loadedPage < totalPages }

    init(sourceID: Int, fetchPage: @escaping (Int) -> AnyPublisher<SimilarTitlesPage, Error>) {
        self.fetchPage = fetchPage
        seenIDs = [sourceID]
    }

    func load() {
        guard phase == .idle else { return }
        requestNextPage()
    }

    func loadMore() {
        guard phase == .ready, hasMore else { return }
        requestNextPage()
    }

    func retry() {
        guard phase == .failed else { return }
        requestNextPage()
    }

    private func requestNextPage() {
        let page = nextPage
        phase = .loading
        var response: SimilarTitlesPage?

        request = fetchPage(page)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                request = nil

                guard case .finished = completion, let response, response.page == page else {
                    phase = .failed
                    return
                }

                let additions = response.titles.filter { $0.id > 0 && self.seenIDs.insert($0.id).inserted }
                titles.append(contentsOf: additions)
                if page == 1 {
                    previewTitles = Array(additions.prefix(10))
                }

                loadedPage = page
                totalPages = min(response.totalPages, 500)
                totalResults = response.totalResults ?? totalResults
                phase = .ready
            } receiveValue: { result in
                response = result
            }
    }
}
