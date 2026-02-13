//
//  SearchPresenter.swift
//  TMDb
//
//  Created by Macbook on 12/02/26.
//

import Foundation
import Combine
import SwiftUI

class SearchPresenter: ObservableObject {
    private var cancellable: Set<AnyCancellable> = []
    private let router = SearchRouter()
    
    private let searchUseCase: SearchUseCase
    
    @Published var searchResults: [SearchModel] = []
    @Published var errorMessage = ""
    @Published var loadingState = false
    
    @Published var isFetchingMore = false
    private var currentPage = 1
    private var canLoadMore = true
    
    @Published var searchQuery: String = ""
    
    init(searchUseCase: SearchUseCase) {
        self.searchUseCase = searchUseCase
        
        $searchQuery
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { query in
                self.search(query: query, reset: true)
            }
            .store(in: &cancellable)
    }
    
    func search(query: String, reset: Bool = false) {
        if reset {
            currentPage = 1
            canLoadMore = true
            loadingState = true
            searchResults.removeAll()
        }
        
        if currentPage > 1 {
            isFetchingMore = true
        }
        
        searchUseCase.search(query: query, page: currentPage)
            .receive(on: DispatchQueue.main)
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
    
    func linkBuilder<Content: View>(
        for contentId: Int,
        mediaType: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(destination: {
            switch mediaType {
            case Constants.movieResponseType:
                router.goToMovieDetailView(for: contentId)
            case Constants.tvShowResponseType:
                router.goToTvDetailView(for: contentId)
            case Constants.personResponseType:
                router.goToPersonDetailView(for: contentId)
            default:
                EmptyView(emptyTitle: "")
            }
        }, label: {
            content()
        })
        .buttonStyle(.plain)
    }
}
