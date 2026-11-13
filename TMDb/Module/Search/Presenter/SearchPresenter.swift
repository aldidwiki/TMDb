//
//  SearchPresenter.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import Observation
import Combine

@MainActor
@Observable
final class SearchPresenter {
    enum Filter: String, CaseIterable {
        case all = "All"
        case movies = "Movies"
        case tv = "TV"
        case people = "People"

        func includes(_ result: SearchModel) -> Bool {
            switch self {
            case .all: true
            case .movies: result.id.mediaType == .movie
            case .tv: result.id.mediaType == .tv
            case .people: result.id.mediaType == .person
            }
        }
    }

    enum Phase {
        case idle
        case loading
        case results
        case failed
    }

    private let searchUseCase: SearchUseCase
    private let queryChanges = PassthroughSubject<String, Never>()
    @ObservationIgnored private var querySubscription: AnyCancellable?
    @ObservationIgnored private var pageRequest: AnyCancellable?
    @ObservationIgnored private var requestID: UUID?
    @ObservationIgnored private var resultIDs: Set<SearchModel.ID> = []

    private var results: [SearchModel] = []
    private var nextPage = 1
    private var totalPages = 0

    private(set) var phase: Phase = .idle
    private(set) var isLoadingMore = false
    private(set) var hasPaginationError = false
    var filter: Filter = .all
    var searchQuery = "" {
        didSet {
            let query = normalizedQuery
            guard query != oldValue.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            resetSearch(for: query)
            queryChanges.send(query)
        }
    }

    init(searchUseCase: SearchUseCase) {
        self.searchUseCase = searchUseCase

        querySubscription = queryChanges
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard let self, !query.isEmpty, query == self.normalizedQuery else { return }
                self.loadPage(query: query, page: 1)
            }
    }

    var visibleResults: [SearchModel] {
        results.filter(filter.includes)
    }

    var canLoadMore: Bool {
        phase == .results && nextPage <= totalPages
    }

    private var normalizedQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func count(for filter: Filter) -> Int {
        results.count(where: filter.includes)
    }

    func retrySearch() {
        guard phase == .failed else { return }
        loadPage(query: normalizedQuery, page: 1)
    }

    func loadMore() {
        guard canLoadMore, !isLoadingMore else { return }
        loadPage(query: normalizedQuery, page: nextPage)
    }

    private func resetSearch(for query: String) {
        requestID = nil
        pageRequest?.cancel()
        pageRequest = nil
        resultIDs.removeAll()
        results.removeAll()
        nextPage = 1
        totalPages = 0
        isLoadingMore = false
        hasPaginationError = false
        phase = query.isEmpty ? .idle : .loading

        if query.isEmpty {
            filter = .all
        }
    }

    private func loadPage(query: String, page: Int) {
        if page == 1 {
            phase = .loading
        } else {
            isLoadingMore = true
            hasPaginationError = false
        }

        let id = UUID()
        requestID = id
        pageRequest = searchUseCase.search(query: query, page: page)
            .map { Result<SearchPage, Error>.success($0) }
            .catch { Just(Result<SearchPage, Error>.failure($0)) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, self.requestID == id else { return }
                self.isLoadingMore = false

                switch result {
                case .success(let response):
                    let uniqueResults = response.results.filter { self.resultIDs.insert($0.id).inserted }
                    self.results.append(contentsOf: uniqueResults)
                    self.nextPage = page + 1
                    self.totalPages = min(response.totalPages, 500)
                    self.phase = .results
                case .failure:
                    if page == 1 {
                        self.phase = .failed
                    } else {
                        self.hasPaginationError = true
                    }
                }
            }
    }
}
