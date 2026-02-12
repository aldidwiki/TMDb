//
//  SearchPresenter.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import Combine

class SearchPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    
    private let searchUseCase: SearchUseCase
    
    @Published var searchResults: [SearchModel] = []
    @Published var errorMessage = ""
    @Published var loadingState = true
    
    @Published var isFetchingMore = false
    private var currentPage = 1
    private var canLoadMore = true
    
    @Published var searchQuery: String = ""
    
    init(searchUseCase: SearchUseCase) {
        self.searchUseCase = searchUseCase
        
        $searchQuery
            .receive(on: RunLoop.main)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { query in
                if query.isEmpty {
                    self.search(query: query, reset: true)
                } else {
                    self.search(query: query)
                }
            }
            .store(in: &cancellable)
    }
    
    func search(query: String, reset: Bool = false) {
        if reset {
            currentPage = 1
            canLoadMore = true
            isFetchingMore = true
            searchResults.removeAll()
        }
        
        searchUseCase.search(query: query, page: currentPage)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure:
                    self.errorMessage = String(describing: completion)
                case .finished:
                    self.isFetchingMore = false
                }
            } receiveValue: { newResults in
                let uniqueResults = newResults.filter { result in
                    !self.searchResults.contains(where: { $0.id == result.id })
                }
                
                if uniqueResults.isEmpty {
                    self.canLoadMore = false
                    
                    if self.currentPage == 1 {
                        self.loadingState = false
                        self.searchResults = newResults
                    }
                } else {
                    if reset {
                        self.searchResults = uniqueResults
                    } else {
                        self.searchResults.append(contentsOf: uniqueResults)
                    }
                    
                    if self.currentPage == 1 {
                        self.loadingState = false
                    }
                    
                    self.currentPage += 1
                }
            }
            .store(in: &cancellable)
    }
}
